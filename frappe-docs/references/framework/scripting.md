# Frappe Framework — Scripting Reference

This file covers writing scripts in Frappe: Server Scripts (Python via Desk), Client Scripts (JavaScript via Desk), Form Scripts (JS bundled with app), and hooks.py. Use this when the user wants to add custom behavior to existing DocTypes without writing a full custom app.

## Table of Contents

1. [Server Scripts](#server-scripts)
2. [Client Scripts](#client-scripts)
3. [Form Scripts (Bundled JS)](#form-scripts-bundled-js)
4. [hooks.py Reference](#hookspy-reference)
5. [Jinja Templates](#jinja-templates)
6. [Common Patterns](#common-patterns)
7. [Debugging Scripts](#debugging-scripts)
8. [Security Considerations](#security-considerations)

## Server Scripts

Server Scripts are Python code snippets stored in the database (tabServer Script) and executed by the framework on specific events. They're a no-deploy way to add behavior.

### When to use Server Scripts

✅ Use for:
- Quick validations on existing DocTypes
- Auto-populating fields based on linked docs
- Sending notifications on specific events
- Small one-off business rules

❌ Don't use for:
- Complex logic (>50 lines) — write a custom app instead
- Anything that needs version control — Server Scripts live in DB
- Performance-critical paths — Server Scripts have overhead
- Production systems without strict review — anyone with Desk access can edit them

### Creating a Server Script

1. Desk → Server Script → New
2. Name it
3. Choose script type:
   - **DocType Event** — runs on a DocType lifecycle hook
   - **API** — exposes an endpoint callable via `/api/method/<script_name>`
   - **Scheduler Event** — runs on a cron schedule
   - **Permission Query** — replaces `get_permission_query_conditions`
4. Configure target DocType and event
5. Write Python code

### DocType Event scripts

Triggered on lifecycle hooks (validate, on_update, etc.):

```python
# Script Type: DocType Event
# DocType: Sales Invoice
# DocType Event: Before Submit

# 'doc' is the document being submitted
total_qty = sum(item.qty for item in doc.items)
if total_qty > 1000:
    frappe.throw("Bulk orders require manager approval", frappe.ValidationError)

# Set a custom field
doc.custom_bulk_flag = 1 if total_qty > 500 else 0
```

Available events:
- `before_insert`
- `before_validate`
- `validate` (most common)
- `on_update`
- `before_save`
- `after_insert`
- `on_submit`
- `before_cancel`
- `on_cancel`
- `on_trash`
- `before_rename` / `after_rename`
- `on_update_after_submit`
- `before_submit`
- `before_cancel`
- `on_trash`

The `doc` variable is the Document instance. You also have access to `frappe.*` APIs.

### API scripts

Expose a callable endpoint:

```python
# Script Type: API
# API Method: my_custom_api  (becomes /api/method/my_custom_api)

# Arguments come from request.form / request.args
import frappe

@frappe.whitelist()
def my_custom_api(user_email=None, limit=10):
    if not user_email:
        user_email = frappe.session.user

    tasks = frappe.get_all("Task",
        filters={"owner": user_email, "status": "Open"},
        fields=["name", "subject", "due_date"],
        limit=limit
    )

    return {"tasks": tasks, "count": len(tasks)}
```

Call via REST:

```bash
curl -X POST -H "Authorization: token ..." \
  -d "user_email=a@b.com&limit=5" \
  https://site/api/method/my_custom_api
```

### Scheduler Event scripts

```python
# Script Type: Scheduler Event
# Event Frequency: Daily

import frappe

# Send daily digest of overdue tasks
overdue = frappe.get_all("Task",
    filters={"status": "Open", "due_date": ["<", frappe.utils.today()]},
    fields=["name", "subject", "owner", "due_date"]
)

for task in overdue:
    frappe.sendmail(
        recipients=[task.owner],
        subject=f"Overdue: {task.subject}",
        template="overdue_task",
        args={"task": task}
    )

frappe.logger().info(f"Sent {len(overdue)} overdue notifications")
```

Frequencies: `All` (every min), `Hourly`, `Daily`, `Weekly`, `Monthly`, `Cron` (with custom expression).

### Permission Query scripts

Replace `get_permission_query_conditions`:

```python
# Script Type: Permission Query
# DocType: Task

# Return SQL fragment to filter list view
user = frappe.session.user
if "System Manager" in frappe.get_roles(user):
    return ""  # see all
return f"`tabTask`.`owner` = {frappe.db.escape(user)}"
```

## Client Scripts

Client Scripts are JavaScript snippets that run in the browser on form events. Stored in `tabClient Script`.

### When to use Client Scripts

✅ Use for:
- Conditional field display
- Auto-calculating field values
- Adding custom buttons
- Form validation before server save
- Calling custom server methods
- Setting field defaults based on user

❌ Don't use for:
- Anything that needs to be enforced server-side (use Server Script + validate hook)
- Heavy computations — they block the UI
- Cross-form logic

### Creating a Client Script

1. Desk → Client Script → New
2. Select DocType
3. Apply To: All, or specific view (Form, List, etc.)
4. Write JavaScript

### Form event handlers

```javascript
// Client Script for "Task" DocType

frappe.ui.form.on("Task", {
    // ====== Lifecycle events ======
    setup: function(frm) {
        // Runs once when form is initialized
        // Use to set up custom state, fetch reference data
        frm.doc._custom_state = {};
    },

    refresh: function(frm) {
        // Runs on every form refresh (load, save, after save)
        // Use to add buttons, set field visibility

        if (frm.doc.status === "Open" && !frm.doc.__islocal) {
            frm.add_custom_button(__("Mark Complete"), function() {
                frappe.confirm("Mark this task as complete?", () => {
                    frappe.call({
                        method: "frappe.client.run_doc_method",
                        args: {
                            dt: frm.doc.doctype,
                            dn: frm.doc.name,
                            method: "mark_complete"
                        },
                        callback: r => {
                            if (!r.exc) {
                                frappe.msgprint(__("Marked complete"));
                                frm.refresh();
                            }
                        }
                    });
                });
            }, __("Actions"));
        }

        // Hide fields based on status
        frm.toggle_display("rejection_reason", frm.doc.status === "Rejected");
    },

    onload: function(frm) {
        // Runs once when form loads
        // Use to set defaults from query string
        const assignee = frappe.utils.get_url_arg("assignee");
        if (assignee && frm.doc.__islocal) {
            frm.set_value("assigned_to", assignee);
        }
    },

    // ====== Before save ======
    before_save: function(frm) {
        // Runs before save — can modify doc
        if (frm.doc.priority === "Urgent" && !frm.doc.due_date) {
            frm.set_value("due_date", frappe.datetime.add_days(frappe.datetime.get_today(), 1));
        }
    },

    validate: function(frm) {
        // Client-side validation (before server validate)
        if (frm.doc.due_date && frm.doc.due_date < frappe.datetime.get_today()) {
            frappe.msgprint(__("Due date is in the past"));
            frappe.validated = false;  // prevent save
        }
    },

    // ====== Field change events ======
    priority: function(frm) {
        // Runs when priority field changes
        if (frm.doc.priority === "Urgent") {
            frm.set_value("due_date", frappe.datetime.add_days(frappe.datetime.get_today(), 1));
        }
    },

    customer: function(frm) {
        // Runs when customer link is set
        if (frm.doc.customer) {
            // Fetch customer details
            frappe.db.get_value("Customer", frm.doc.customer, ["customer_name", "credit_limit"])
                .then(r => {
                    if (r.message) {
                        frm.set_value("customer_name", r.message.customer_name);
                        if (r.message.credit_limit) {
                            frm.set_value("credit_limit_display", r.message.credit_limit);
                        }
                    }
                });
        }
    },

    // ====== After save ======
    on_save: function(frm) {
        // Runs after save
        frappe.show_alert(__("Saved"));
    },

    on_submit: function(frm) {
        frappe.set_route("List", "Task");
    },

    // ====== Custom button handlers (via frm.call) ======
    mark_complete: function(frm) {
        // This is triggered by frm.call("mark_complete")
        // But typically you'd call the server method via frappe.call
    }
});

// Child table event handlers
frappe.ui.form.on("Task Item", {
    item_code: function(frm, cdt, cdn) {
        // Runs when item_code changes in a child row
        const row = locals[cdt][cdn];
        if (row.item_code) {
            frappe.db.get_value("Item", row.item_code, "standard_rate")
                .then(r => {
                    if (r.message) {
                        frappe.model.set_value(cdt, cdn, "rate", r.message.standard_rate);
                    }
                });
        }
    },

    qty: function(frm, cdt, cdn) {
        // Auto-calculate amount
        const row = locals[cdt][cdn];
        frappe.model.set_value(cdt, cdn, "amount", flt(row.qty) * flt(row.rate));
    },

    rate: function(frm, cdt, cdn) {
        const row = locals[cdt][cdn];
        frappe.model.set_value(cdt, cdn, "amount", flt(row.qty) * flt(row.rate));
    },

    items_remove: function(frm, cdt, cdn) {
        // Runs when a child row is removed
        recalculate_total(frm);
    },

    items_add: function(frm, cdt, cdn) {
        // Runs when a new child row is added
        // Set default values
        frappe.model.set_value(cdt, cdn, "qty", 1);
    }
});

function recalculate_total(frm) {
    let total = 0;
    frm.doc.items.forEach(item => {
        total += flt(item.amount);
    });
    frm.set_value("total_amount", total);
}
```

### Available form events

| Event | When |
|---|---|
| `setup` | Form initialization (once) |
| `onload` | Form loaded |
| `refresh` | After load, save, or refresh |
| `before_save` | Before save (can modify doc) |
| `before_submit` | Before submit |
| `before_cancel` | Before cancel |
| `before_print` | Before print dialog |
| `validate` | Before save (set `frappe.validated = false` to abort) |
| `on_save` | After save |
| `on_submit` | After submit |
| `on_cancel` | After cancel |
| `<fieldname>` | When field changes |
| `<child_fieldname>_add` | When child row added |
| `<child_fieldname>_remove` | When child row removed |
| `<child_fieldname>_move` | When child row reordered |

### Form API reference

```javascript
// Get/set values
frm.doc.field_name                      // get
frm.set_value("field_name", value)      // set
frm.get_field("field_name")             // get field object

// Refresh
frm.refresh()                           // refresh whole form
frm.refresh_field("field_name")         // refresh one field
frm.refresh_fields()                    // refresh all fields
frm.reload_doc()                        // reload from server

// Field display
frm.toggle_display("field_name", true)  // show/hide
frm.toggle_reqd("field_name", true)     // toggle required
frm.toggle_enable("field_name", true)   // toggle editable

// Set field options (for Select)
frm.set_df_property("status", "options", ["Open", "Closed"])

// Add custom button
frm.add_custom_button("Click Me", () => {
    // ...
}, __("Actions"));  // group

// Remove custom button
frm.remove_custom_button("Click Me", __("Actions"))

// Set route
frappe.set_route("List", "Task")
frappe.set_route("Form", "Task", "TASK00001")

// Dialogs
frappe.msgprint("Hello")
frappe.throw("Error")  // shows error and stops
frappe.confirm("Are you sure?", () => { /* yes */ }, () => { /* no */ })
frappe.prompt([
    {"fieldname": "name", "fieldtype": "Data", "label": "Name", "reqd": 1},
    {"fieldname": "age", "fieldtype": "Int", "label": "Age"}
], (values) => {
    console.log(values);
}, "Enter details");

// Server calls
frappe.call({
    method: "frappe.client.get",
    args: { doctype: "Task", name: "TASK00001" },
    callback: r => console.log(r.message)
});

// Or async/await
const r = await frappe.call({
    method: "frappe.client.get_value",
    args: { doctype: "Task", filters: { status: "Open" }, fieldname: "name" }
});

// frm.call: calls a controller method on the current doc
frm.call("custom_method", { arg1: "value" })
    .then(r => console.log(r.message));

// DB lookups (read-only, current user's permissions)
frappe.db.get_value("Customer", "CUST-001", "customer_name").then(r => console.log(r.message))
frappe.db.get_list("Customer", { fields: ["name", "customer_name"], limit: 10 }).then(r => console.log(r))

// URL utils
frappe.utils.get_url_arg("key")
frappe.utils.set_title("Custom Title")
```

## Form Scripts (Bundled JS)

For custom apps, write JS files alongside the DocType:

```
my_app/my_app/tasks/doctype/task/task.js
```

```javascript
// frappe.ui.form.on is the same as Client Script
frappe.ui.form.on("Task", {
    refresh: function(frm) {
        // ...
    }
});

// Include via hooks.py:
// doctype_js = {
//     "Task": "public/js/task_custom.js"
// }
```

Or use `doctype_js` in hooks.py to add JS to existing DocTypes (e.g. extending ERPNext DocTypes):

```python
# hooks.py
doctype_js = {
    "Sales Invoice": "public/js/sales_invoice_custom.js",
    "Customer": "public/js/customer_custom.js"
}

doctype_list_js = {
    "Task": "public/js/task_list_custom.js"  // runs on list view
}

doctype_tree_js = {
    "Account": "public/js/account_tree_custom.js"  // runs on tree view
}
```

## hooks.py Reference

`hooks.py` is the central configuration file for a Frappe app. It tells the framework how to wire up your app.

### Most-used hooks

```python
# apps/myapp/myapp/hooks.py

# App info
app_name = "myapp"
app_title = "My App"
app_publisher = "Your Name"
app_description = "Custom ERPNext extensions"
app_icon = "octicon octicon-file"
app_color = "grey"
app_email = "you@example.com"
app_license = "MIT"

# Required apps (must be installed first)
required_apps = ["erpnext"]

# Fixtures: DocTypes to export on each migrate (Custom Field, Property Setter, etc.)
fixtures = [
    "Custom Field",
    "Property Setter",
    {"dt": "Print Format", "filters": [["standard", "Yes"]]},
    {"dt": "Notification", "filters": [["module", "My App"]]}
]

# App assets (loaded on every Desk page)
app_include_js = "/assets/myapp/js/myapp.js"
app_include_css = "/assets/myapp/css/myapp.css"

# DocType-specific assets
doctype_js = {
    "Sales Invoice": "public/js/sales_invoice.js"
}
doctype_list_js = {"Task": "public/js/task_list.js"}
doctype_tree_js = {"Account": "public/js/account_tree.js"}

# Page assets (custom Desk Pages)
page_js = {
    "my_page": "public/js/my_page.js"
}

# Boot info injection (called on every login/page load)
boot_session = "myapp.boot.get_boot_info"

# DocType events (lifecycle hooks for any DocType)
doc_events = {
    "*": {
        "on_update": "myapp.audit.log_changes"
    },
    "Sales Invoice": {
        "validate": "myapp.invoices.validate_sales_invoice",
        "on_submit": "myapp.invoices.handle_invoice_submit",
        "on_cancel": "myapp.invoices.handle_invoice_cancel"
    },
    "Customer": {
        "validate": "myapp.customers.validate_customer",
        "on_trash": "myapp.customers.cleanup_customer_data"
    }
}

# Override whitelisted methods
override_whitelisted_methods = {
    "frappe.client.get": "myapp.client.get",
    "erpnext.accounts.doctype.sales_invoice.sales_invoice.make_sales_return": "myapp.returns.custom_make_sales_return"
}

# Scheduled jobs
scheduler_events = {
    "all": ["myapp.tasks.every_minute"],
    "hourly": ["myapp.tasks.hourly_cleanup"],
    "daily": ["myapp.tasks.daily_report", "myapp.tasks.cleanup_expired"],
    "weekly": ["myapp.tasks.weekly_backup"],
    "monthly": ["myapp.tasks.monthly_close"],
    "cron": {
        "*/15 * * * *": ["myapp.tasks.fifteen_min_check"],
        "0 9 * * 1": ["myapp.tasks.monday_morning"],
        "0 0 1 * *": ["myapp.tasks.month_start"]
    }
}

# Installation hooks
after_install = "myapp.setup.after_install"
before_uninstall = "myapp.setup.before_uninstall"
after_migrate = "myapp.setup.after_migrate"
before_migrate = "myapp.setup.before_migrate"

# Website / portal hooks
website_route_rules = [
    {"from_route": "/old-path", "to_route": "new-page"},
    {"from_route": "/docs/<doc>", "to_route": "documentation"}
]

update_website_context = "myapp.website.update_context"
website_redirects = [
    {"source": "/old", "target": "/new", "status_code": 301}
]

# Email hooks
email_brand = "My App"
before_email_send = "myapp.email.before_send"

# Auth hooks
before_login = "myapp.auth.before_login"
on_login = "myapp.auth.on_login"
on_logout = "myapp.auth.on_logout"

# Permission hooks
permission_query_conditions = {
    "Task": "myapp.permissions.task_query_conditions",
    "Customer": "myapp.permissions.customer_query_conditions"
}

has_permission = {
    "Task": "myapp.permissions.task_has_permission"
}

# Custom fields (auto-create on install)
custom_fields = {
    "Sales Invoice": [
        {"fieldname": "custom_field", "fieldtype": "Data", "label": "Custom"}
    ]
}

# Reports
standard_reports = "myapp.reports.get_standard_reports"

# Test hooks
before_tests = "myapp.tests.before_tests"
```

### DocEvents hook signature

```python
# myapp/invoices.py
import frappe

def validate_sales_invoice(doc, method=None):
    # doc: the Document instance
    # method: the name of the hook that triggered this (e.g. "validate")
    if doc.is_new():
        # Only on create
        pass

    if doc.has_value_changed("customer"):
        # Customer changed
        old_customer = doc.get_doc_before_save().customer
        # ...

def handle_invoice_submit(doc, method=None):
    # DocType is being submitted
    frappe.sendmail(
        recipients=[doc.contact_email],
        subject=f"Invoice {doc.name}",
        template="invoice_submitted",
        args={"invoice": doc}
    )
```

## Jinja Templates

Jinja is used for:
- Email templates
- Print formats
- Web pages (portal)
- Custom HTML fields in forms

### Available context

```python
# In any Jinja template, you have access to:
# - frappe (the framework module)
# - _ (translation function)
# - frappe.utils (utility functions)
# - frappe.db (database interface)
# - frappe.session (current session)
# - doc (the document being rendered, if applicable)
# - args (custom args passed via render_template)
```

### Email template example

```html
<!-- templates/emails/welcome.html -->
<p>Hello {{ user.first_name|default("there") }},</p>

<p>Welcome to {{ frappe.db.get_single_value("Website Settings", "website_name") }}.</p>

<p>Your account details:</p>
<ul>
    <li>Email: {{ user.email }}</li>
    <li>Role: {{ user.role }}</li>
</ul>

{% if user.invited_by %}
<p>You were invited by {{ user.invited_by }}.</p>
{% endif %}

<p>Click <a href="{{ frappe.utils.get_url('/login') }}">here</a> to log in.</p>

<p>Regards,<br>{{ _("The Team") }}</p>
```

```python
# Sending the email
frappe.sendmail(
    recipients=[user.email],
    subject="Welcome",
    template="welcome",  # file path relative to templates/emails/
    args={"user": user_doc}
)
```

### Print format example

```html
<!-- Print Format: Custom HTML/Jinja -->
<div class="print-header">
    <h1>{{ doc.customer_name }}</h1>
    <p>Invoice: {{ doc.name }} | Date: {{ frappe.utils.formatdate(doc.posting_date) }}</p>
</div>

<table class="print-table">
    <thead>
        <tr>
            <th>Item</th>
            <th>Qty</th>
            <th>Rate</th>
            <th>Amount</th>
        </tr>
    </thead>
    <tbody>
        {% for item in doc.items %}
        <tr>
            <td>{{ item.item_name }}</td>
            <td>{{ item.qty }} {{ item.uom }}</td>
            <td>{{ frappe.utils.fmt_money(item.rate, currency=doc.currency) }}</td>
            <td>{{ frappe.utils.fmt_money(item.amount, currency=doc.currency) }}</td>
        </tr>
        {% endfor %}
    </tbody>
    <tfoot>
        <tr>
            <td colspan="3" class="text-right">Total</td>
            <td>{{ frappe.utils.fmt_money(doc.grand_total, currency=doc.currency) }}</td>
        </tr>
    </tfoot>
</table>
```

## Common Patterns

### Pattern 1: Conditional field visibility

```javascript
// Client Script
frappe.ui.form.on("Sales Invoice", {
    refresh: function(frm) {
        frm.toggle_display("custom_discount_fields", frm.doc.total > 1000);
    }
});
```

### Pattern 2: Auto-fetch linked doc data

```javascript
frappe.ui.form.on("Sales Invoice", {
    customer: function(frm) {
        if (frm.doc.customer) {
            frappe.db.get_value("Customer", frm.doc.customer, ["customer_name", "tax_id"])
                .then(r => {
                    if (r.message) {
                        frm.set_value("customer_name", r.message.customer_name);
                        frm.set_value("tax_id", r.message.tax_id);
                    }
                });
        }
    }
});
```

### Pattern 3: Server-side validation hook

```python
# Server Script: DocType Event on Sales Invoice → validate
def validate(doc, method):
    if doc.is_pos and not doc.cashier:
        frappe.throw("POS invoices require a cashier", frappe.ValidationError)

    # Auto-set due date based on payment terms
    if doc.payment_terms_template and not doc.due_date:
        from erpnext.accounts.utils import get_due_date
        doc.due_date = get_due_date(doc.posting_date, doc.payment_terms_template, doc.customer)
```

### Pattern 4: Custom REST endpoint via Server Script

```python
# Server Script: API Method
# Name: my_custom_endpoint

import frappe

@frappe.whitelist()
def my_custom_endpoint(action, target=None):
    """My custom API endpoint.

    Args:
        action: 'list' or 'detail'
        target: name of the target doc (for 'detail')
    """
    if action == "list":
        return frappe.get_all("Task",
            filters={"status": "Open"},
            fields=["name", "subject", "due_date"]
        )
    elif action == "detail":
        if not target:
            frappe.throw("Target required for detail action")
        return frappe.get_doc("Task", target).as_dict()
    else:
        frappe.throw(f"Unknown action: {action}")
```

### Pattern 5: Scheduled cleanup job

```python
# Server Script: Scheduler Event → Daily
import frappe

# Delete logs older than 90 days
old_logs = frappe.db.get_list("Error Log",
    filters={"creation": ["<", frappe.utils.add_days(frappe.utils.now(), -90)]},
    pluck="name"
)

for name in old_logs:
    frappe.delete_doc("Error Log", name, ignore_permissions=True)

frappe.logger().info(f"Cleaned up {len(old_logs)} old error logs")
```

## Debugging Scripts

### Server-side

```python
# Use frappe.log_error to capture exceptions
try:
    risky_call()
except Exception as e:
    frappe.log_error(f"Failed: {e}", title="My Script Error")

# Use frappe.logger for less critical logging
import logging
logger = frappe.logger("myapp")
logger.info("Info message")
logger.debug({"doc": doc.name, "user": frappe.session.user})

# Inspect with frappe.db.trace_on / trace_off
frappe.db.trace_on(True)  # log all queries
# ... do stuff
queries = frappe.db.trace_off()  # returns list of executed queries
```

### Client-side

```javascript
// console.log / console.error work in Desk
console.log("frm.doc:", frm.doc);

// Frappe's logger (visible in browser console with prefix)
frappe.utils.logger("myapp").info("Hello");

// Inspect locals (in-memory doc cache)
console.log(locals);  // all loaded docs
console.log(locals["Task"]["TASK00001"]);  // specific doc
```

### Inspecting via bench

```bash
# Drop into Python shell with frappe context
bench --site mysite.localhost console

# Run a one-liner
bench --site mysite.localhost execute myapp.utils.do_something

# Watch logs in real-time
tail -f logs/web.log
tail -f logs/error.log
tail -f logs/worker.log
```

## Security Considerations

### Server Scripts are powerful — secure them

- Server Scripts can execute **arbitrary Python** — including `os.system`, `subprocess`, file reads, etc.
- By default, only System Managers can create Server Scripts.
- In production, consider disabling Server Scripts entirely:
  ```json
  // site_config.json
  {
    "disable_server_scripting": true
  }
  ```
- Review all Server Scripts periodically.
- Never let non-admin users create Server Scripts.

### Client Scripts are visible to users

- Client Script JS is sent to the browser — users can read it.
- Never put secrets (API keys, passwords) in Client Scripts.
- Validate everything server-side too — Client Scripts can be bypassed.

### SQL injection

- Server Scripts have access to `frappe.db.sql` — always use parameterized queries.
- Never trust user input from `frappe.request.form` or `frappe.request.args`.

### Cross-site scripting (XSS)

- Jinja templates auto-escape by default — don't disable it (`{% autoescape false %}`) unless you know what you're doing.
- HTML fields (`fieldtype: "HTML Editor"`) store raw HTML — sanitize before display.

### Permissions

- Always check `frappe.has_permission(doctype, action, docname)` before returning data via API.
- Don't expose whitelisted methods that don't check permissions — they're callable by any authenticated user.

## Where to Learn More

- Live docs: https://docs.frappe.io/framework/user/en/desk/scripting
- Server Script docs: https://docs.frappe.io/framework/user/en/desk/scripting/server-script
- Client Script docs: https://docs.frappe.io/framework/user/en/desk/scripting/client-script
- hooks.py reference: https://docs.frappe.io/framework/user/en/python-api/hooks
- Jinja API: https://docs.frappe.io/framework/user/en/api/jinja
