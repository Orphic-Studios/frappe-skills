# ERPNext — Customization

ERPNext is highly extensible without writing a custom app. Most customizations live in the database as records of dedicated DocTypes (Custom Field, Property Setter, Print Format, Workflow, Notification, etc.). This file is the comprehensive reference for all of them. Use it for any question about customizing ERPNext behavior, layouts, print outputs, reports, workflows, notifications, server/client scripts, dashboards, or hooks into core DocTypes. For the framework-level scripting primitives (form events, `frappe.call`, `frappe.whitelist`), read `../framework/scripting.md`. For DocType creation, read `../framework/doctype-guide.md`.

## Table of Contents

1. [Custom Fields](#custom-fields)
2. [Property Setters](#property-setters)
3. [Print Formats](#print-formats)
4. [Workflows](#workflows)
5. [Notifications](#notifications)
6. [Email Rules](#email-rules)
7. [Reports (List, Query, Script)](#reports-list-query-script)
8. [Auto Repeat (Subscriptions)](#auto-repeat-subscriptions)
9. [Server Scripts](#server-scripts)
10. [Client Scripts](#client-scripts)
11. [Custom Dashboards](#custom-dashboards)
12. [Custom Desk Pages](#custom-desk-pages)
13. [Hooks for ERPNext DocTypes](#hooks-for-erpnext-doctypes)
14. [Fixtures (Exporting Customizations)](#fixtures-exporting-customizations)
15. [Environment Management & Upgrade Considerations](#environment-management--upgrade-considerations)
16. [Where to Learn More](#where-to-learn-more)

## Custom Fields

`Custom Field` is the safe way to add a field to an existing DocType. The field is stored in `tabCustom Field` and merged into the DocType's metadata at runtime — never edit `tabDocField` directly, since `bench migrate` overwrites it from the app's JSON.

### Creating a Custom Field

#### Via Desk

1. Search "Custom Field" in the Awesome Bar.
2. Click **Add New Custom Field**.
3. Pick the **DocType** (e.g. `Sales Invoice`).
4. Fill in field properties (Label, Type, Options, Section, etc.).
5. Save. Refresh any open forms of the DocType to see the new field.

#### Via Python

```python
cf = frappe.get_doc({
    "doctype": "Custom Field",
    "dt": "Sales Invoice",
    "label": "Customer PO Status",
    "fieldname": "custom_customer_po_status",
    "fieldtype": "Select",
    "options": "Pending\nReceived\nVerified",
    "insert_after": "po_no",
    "default": "Pending",
    "allow_on_submit": 1,
    "no_copy": 1,
    "translatable": 1,
})
cf.insert()
```

After insert, run `bench clear-cache` (or `frappe.clear_cache()`) to refresh the metadata in user sessions.

### Field Naming Convention

Always prefix your custom field names with `custom_`. This:

- Distinguishes them from core fields in code review.
- Avoids name collisions with future core additions.
- Makes fixtures export cleaner.

If you skip the prefix, ERPNext auto-prefixes on save (silently) — but relying on the auto-prefix is fragile.

### Fetching Data from a Linked Doc

Custom Fields can auto-populate from the linked DocType using the `fetch_from` property. For example, on a Sales Invoice, fetch the Customer's credit limit:

```python
cf = frappe.get_doc({
    "doctype": "Custom Field",
    "dt": "Sales Invoice",
    "label": "Credit Limit",
    "fieldname": "custom_credit_limit",
    "fieldtype": "Currency",
    "fetch_from": "customer.credit_limit",
    "read_only": 1,
    "insert_after": "customer_name",
})
cf.insert()
```

The `fetch_from` syntax is `link_field.field_name` — ERPNext refreshes this value whenever `link_field` changes.

### Conditional Display (`depends_on`)

Use `depends_on` to conditionally show/hide a field. The value is a Python expression evaluated in the client context:

| Expression | Effect |
|---|---|
| `eval:doc.status=="Open"` | Show only when status is Open. |
| `eval:doc.is_return==1` | Show only for Credit Notes. |
| `customer` | Show only when `customer` is set (truthy). |
| `eval:doc.total>1000` | Show only when total exceeds 1000. |

### Mandatory Conditionally

Set `mandatory_depends_on` similarly to require the field only when the expression is true. Useful for "if check box X is on, Y is required".

### Permission Levels

Custom fields respect `permlevel`. Set `permlevel` to a value (0-9) and configure the per-role read/write on that level in the DocType's Permissions table. Use this to restrict sensitive fields (e.g. cost rate) to specific roles.

### Pitfalls

- **Field not visible on form** — verify `insert_after` points to a field that exists. Use `Insert After = "naming_series"` or any known field; ERPNext will place it.
- **Field lost after migrate** — Custom Fields are stored in DB, not in JSON. They survive `bench migrate`. They do NOT survive a fresh site restore without re-running your fixtures (see [Fixtures](#fixtures-exporting-customizations)).
- **Performance** — avoid `fetch_from` on high-volume list views; each row triggers a sub-query.
- **Custom field on a child table** — set `dt` to the child DocType name (e.g. `Sales Invoice Item`), not the parent.

## Property Setters

`Property Setter` is a single-property override on any field or DocType. Use it to change a label, default value, hidden status, or print format — without creating a Custom Field.

### Creating One

#### Via Desk (Form Customization)

1. Open any DocType form (e.g. a Sales Invoice).
2. Click the **Menu → Customize** icon (top right).
3. The Customize Form opens — edit labels, hide fields, change defaults.
4. Save. ERPNext creates Property Setter records in the background.

#### Via Python

```python
ps = frappe.get_doc({
    "doctype": "Property Setter",
    "doctype_or_field": "DocField",
    "doc_type": "Sales Invoice",
    "field_name": "po_no",
    "property": "label",
    "value": "Customer PO Number",
    "property_type": "Data",
})
ps.insert()
```

### Common Use Cases

| Property | Example | Effect |
|---|---|---|
| `label` | "Customer PO Number" | Changes the displayed label. |
| `default` | "Pending" | Sets a default value for new records. |
| `hidden` | 1 | Hides the field on the form. |
| `read_only` | 1 | Makes the field non-editable. |
| `reqd` | 1 | Makes the field mandatory. |
| `precision` | 3 | Changes decimal precision for Float/Currency. |
| `options` | "A\nB\nC" | Changes Select options. |
| `no_copy` | 1 | Field value not copied when duplicating document. |
| `print_hide` | 1 | Field hidden in print formats. |
| `in_list_view` | 1 | Field appears as a column in list view. |

### Pitfalls

- **Property Setters override Custom Fields** — if both exist for the same property, Property Setter wins.
- **Lost on bench migrate for standard fields** — most survive, but some get cleared when the upstream app changes the property. Re-apply via fixtures.
- **Hard to debug** — Property Setters are scattered; the **Customize Form** view aggregates them visually.

## Print Formats

`Print Format` controls how a document looks when printed or emailed. ERPNext supports three creation modes:

### 1. Standard (Builder-based, v15+)

The visual builder in the Print Format Designer. Drag-drop fields, sections, headers. No code. Saved as a `Print Format` record with `print_format_builder = 1`. Use for most use cases.

### 2. HTML Print Format

A custom HTML/CSS layout stored in the `html` field of the Print Format record. Use when the builder is too limited (complex layouts, conditional sections, multi-page).

```html
<!-- Print Format: Custom Sales Invoice -->
<div class="invoice-header">
  <h1>{{ doc.company }}</h1>
  <p>{{ doc.address_display }}</p>
</div>

<table class="items">
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
      <td>{{ item.item_code }} - {{ item.item_name }}</td>
      <td>{{ item.qty }} {{ item.uom }}</td>
      <td>{{ frappe.utils.fmt_money(item.rate, currency=doc.currency) }}</td>
      <td>{{ frappe.utils.fmt_money(item.amount, currency=doc.currency) }}</td>
    </tr>
    {% endfor %}
  </tbody>
</table>

<div class="totals">
  <p>Subtotal: {{ frappe.utils.fmt_money(doc.net_total, currency=doc.currency) }}</p>
  <p>Tax: {{ frappe.utils.fmt_money(doc.total_taxes_and_charges, currency=doc.currency) }}</p>
  <p><strong>Grand Total: {{ frappe.utils.fmt_money(doc.grand_total, currency=doc.currency) }}</strong></p>
</div>

{% if doc.terms %}
<div class="terms">
  <h3>Terms & Conditions</h3>
  {{ doc.terms }}
</div>
{% endif %}
```

### 3. Jinja-based Custom Print Format (DocType-based)

For programmatic generation, create a Print Format with `print_format_type = Jinja` and write Jinja directly. Use this when you need server-side helpers (translation, currency conversion, custom queries):

```jinja
{# Jinja Print Format #}
{% set company_address = frappe.db.get_value("Address", doc.company_address, "address_display") %}

<div>
  <h1>{{ _("Invoice") }}: {{ doc.name }}</h1>
  <p>{{ _("Date") }}: {{ frappe.utils.formatdate(doc.posting_date) }}</p>
  <p>{{ _("Customer") }}: {{ doc.customer_name }}</p>
  {% if company_address %}
  <p>{{ _("From") }}: {{ company_address }}</p>
  {% endif %}
</div>

{# Loop items #}
{% for item in doc.items %}
  <div>
    {{ loop.index }}. {{ item.item_name }} - {{ item.qty }} x {{ item.rate }}
  </div>
{% endfor %}

{# Total #}
<p>Total: {{ frappe.utils.fmt_money(doc.grand_total, currency=doc.currency) }}</p>
```

### Print Format Settings

On the Print Format record:

| Field | Effect |
|---|---|
| `doc_type` | Target DocType. |
| `print_format_type` | `DocType` (standard), `Jinja`, or `HTML`. |
| `default_print_format` | One default per DocType per user. |
| `custom_format` | 1 if HTML/Jinja. |
| `disabled` | Soft toggle. |
| `print_format_builder` | 1 if using the visual builder. |
| `standard` | "Yes" for app-provided formats (cannot be edited). |
| `align_labels_right` | Visual builder setting. |
| `show_section_headings` | Show section names in print. |
| `show_line_numbers` | Numbered item rows. |
| `font` / `font_size` | Typography. |
| `page_number` | Show "Page X of Y". |
| `letter_head` | Default letterhead (overridable per document). |
| `margin_top/bottom/left/right` | Print margins in mm. |

### Common Pitfalls

- **Jinja sandbox** — Server-side Jinja runs in a restricted sandbox. Not all Python built-ins are available. Access `frappe.utils.*` explicitly.
- **Translation in Jinja** — use `{{ _("Text") }}`. Without translation, multi-language printouts break.
- **Currency formatting** — never use `{{ doc.rate }}` directly. Use `frappe.utils.fmt_money(value, currency=doc.currency)`.
- **HTML format with `doc.items`** — `doc` is the document object; iterate `doc.items` for child rows.
- **PDF generation timeout** — very large HTML formats (e.g. 1000-row invoices) can time out. Use the **PDF Page Size** and **PDF Orientation** settings, or paginate.

## Workflows

`Workflow` DocType defines multi-step state machines on submittable DocTypes. Use it when the simple Draft→Submitted→Cancelled lifecycle is not enough (e.g. Sales Invoice with Quotation→Approval→Billed→Closed states).

### Anatomy

A Workflow has:

- **Workflow States** (child table) — the named states (e.g. "Draft", "Pending Approval", "Approved", "Rejected").
- **Workflow Transition** (child table) — the allowed moves between states (state, action, next_state, allowed_role).
- Document-level settings — `document_type`, `is_active`, `send_email`, `update_field`, `update_value`.

### Example: Sales Invoice Approval

```python
wf = frappe.get_doc({
    "doctype": "Workflow",
    "workflow_name": "Sales Invoice Approval",
    "document_type": "Sales Invoice",
    "is_active": 1,
    "send_email": 1,
    "states": [
        {"state": "Draft", "doc_status": "0", "update_field": "status", "update_value": "Draft", "allow_edit": "Sales User"},
        {"state": "Pending Approval", "doc_status": "0", "update_field": "status", "update_value": "Pending Approval", "allow_edit": "Sales User"},
        {"state": "Approved", "doc_status": "1", "update_field": "status", "update_value": "Submitted", "allow_edit": "Sales Manager"},
        {"state": "Rejected", "doc_status": "2", "update_field": "status", "update_value": "Cancelled", "allow_edit": "Sales Manager"},
    ],
    "transitions": [
        {"state": "Draft", "action": "Send for Approval", "next_state": "Pending Approval", "allowed": "Sales User"},
        {"state": "Pending Approval", "action": "Approve", "next_state": "Approved", "allowed": "Sales Manager"},
        {"state": "Pending Approval", "action": "Reject", "next_state": "Rejected", "allowed": "Sales Manager"},
        {"state": "Pending Approval", "action": "Recall", "next_state": "Draft", "allowed": "Sales User"},
    ],
})
wf.insert()
```

### Workflow Actions

Each transition's `action` becomes a button on the form. Clicking it triggers the transition; ERPNext validates the role and updates the document's state and `docstatus` (per `doc_status`).

### On-Create / On-Update / On-Cancel Actions

Workflow transitions can fire **Notifications**, **Server Scripts**, or **Webhooks**. Configure via the **Workflow Actions** child table (in v15+). For each transition, you can:

- Send an email notification.
- Trigger a Server Script.
- Call an external webhook.

### Pitfalls

- **Workflow replaces DocStatus** — `doc_status` 0/1/2 maps to Draft/Submitted/Cancelled. ERPNext hides the standard **Save** / **Submit** buttons when a Workflow is active.
- **Permission conflict** — the `allow_edit` role on a state must match your role setup. Otherwise, users can't move the document.
- **Cancel still allowed for submitted docs** — even within a workflow, cancelling a submitted doc reverses GL/SLE postings.
- **Workflow state field** — `update_field` should point to the DocType's `status` field (or a custom field). Without it, the state isn't persisted.

## Notifications

`Notification` DocType automates email and in-app messages on document events. Use it for "send welcome email on new customer", "alert manager on large PO", etc.

### Creating a Notification

1. Open **Notification → New**.
2. Pick **Subject**, **Document Type** (e.g. `Sales Invoice`).
3. Set the **Event**: `New Document`, `Value Change`, `Date Change`, `Method` (custom hook), `Submit`, `Cancel`, `Custom`.
4. Configure the **Recipients** — by role, by email field, by customer/supplier contact, or static.
5. Write the **Message** in Jinja — full access to `doc` and `frappe.utils`.

```jinja
{# Notification message body #}
Hello {{ doc.customer_name }},

Your invoice {{ doc.name }} for {{ frappe.utils.fmt_money(doc.grand_total, currency=doc.currency) }}
is now due on {{ frappe.utils.formatdate(doc.due_date) }}.

Thank you for your business!
```

### Notification Conditions

Use `condition` field to fire the notification only when a Python expression is true:

```python
# Condition: only for invoices over $1000
doc.grand_total > 1000 and doc.customer is not None
```

### Recipients Options

| Source | Field |
|---|---|
| Email field on document | `email_to` = `doc.contact_email` |
| Customer/Supplier contact | Set `recipient_document_type` = `Customer` and let ERPNext look up. |
| Role-based | Send to all users with `Sales Manager` role. |
| Static email | `recipients` = `manager@acme.com`. |

### In-App Notifications

Set `notification_type` to `Email` or `Slack` or both. For in-app messages, use the **Notification Log** DocType via Server Script.

### Pitfalls

- **Notifications fire on every event match** — if `Value Change` watches `status` and status changes from A→B→C in a single save, you get two notifications.
- **Recipient not found** — if `doc.contact_email` is empty, the notification silently skips. Add a fallback.
- **Email queue blocking** — large notifications can fill the email queue; use `frappe.enqueue` for batch sends.

## Email Rules

`Email Rule` is the lightweight cousin of Notification. It triggers on incoming email events (e.g. emails to `support@acme.com`) and can create documents, assign to users, or auto-reply. Use it for ticket-creation workflows.

### Anatomy

| Field | Effect |
|---|---|
| `email_id` | The mailbox to watch (`support@acme.com`). |
| `filter_on` | Filter condition (e.g. subject contains "Urgent"). |
| `action` | `Create Document`, `Assign To`, `Reply`, `Forward`. |
| `target_doctype` | For Create Document — typically `Issue` or `Communication`. |
| `target_fieldname` | Where to store the email body. |

## Reports (List, Query, Script)

ERPNext has three report types. Each is appropriate for different use cases.

### 1. List Report (built-in)

Auto-generated for every DocType. Accessed via the list view. No configuration needed. You can add columns via the list view's **Set Columns** button (which stores user preferences).

### 2. Query Report

SQL-driven. The report stores a `query` field with parameterized SQL. Use this for simple joins and aggregations.

```sql
-- Query Report: Top 10 Customers by Sales
SELECT
    customer,
    SUM(grand_total) AS total_sales
FROM `tabSales Invoice`
WHERE docstatus = 1
    AND posting_date BETWEEN %(from_date)s AND %(to_date)s
GROUP BY customer
ORDER BY total_sales DESC
LIMIT 10
```

Filters are defined as a JSON in the `json` field:

```json
{
  "filters": [
    {"fieldname": "from_date", "label": "From Date", "fieldtype": "Date", "default": "2026-01-01"},
    {"fieldname": "to_date", "label": "To Date", "fieldtype": "Date", "default": "2026-12-31"}
  ]
}
```

### 3. Script Report

Python-driven. Use for complex logic, multi-pass computations, or external API calls. Stored as a Python module in `erpnext/<module>/report/<report_name>/<report_name>.py`.

```python
# erpnext/regional/report/top_customers/top_customers.py

import frappe

def execute(filters=None):
    columns = get_columns()
    data = get_data(filters)
    return columns, data

def get_columns():
    return [
        {"label": "Customer", "fieldname": "customer", "fieldtype": "Link", "options": "Customer", "width": 200},
        {"label": "Total Sales", "fieldname": "total_sales", "fieldtype": "Currency", "width": 150},
        {"label": "Invoice Count", "fieldname": "invoice_count", "fieldtype": "Int", "width": 100},
    ]

def get_data(filters):
    return frappe.db.sql("""
        SELECT
            customer,
            SUM(grand_total) AS total_sales,
            COUNT(*) AS invoice_count
        FROM `tabSales Invoice`
        WHERE docstatus = 1
            AND posting_date BETWEEN %(from_date)s AND %(to_date)s
            AND company = %(company)s
        GROUP BY customer
        ORDER BY total_sales DESC
        LIMIT 10
    """, {
        "from_date": filters.from_date,
        "to_date": filters.to_date,
        "company": filters.company,
    }, as_dict=True)
```

The `execute` function returns `(columns, data)`. ERPNext renders the report with the standard Query Report UI.

### Report via Desk

Most reports are created via the **Report List → Add Report → Report Type** UI. Saved as a `Report` DocType record. Script Reports require file-system code; Query Reports are stored entirely in the DB.

### Report Permissions

Each report has a `roles` child table restricting who can run it. Use this for finance/salary reports that only HR should see.

## Auto Repeat (Subscriptions)

`Auto Repeat` is the legacy name; in v15+ the DocType is `Subscription`. Use it for recurring transactions. See `selling-buying.md` for the full reference.

## Server Scripts

`Server Script` is Python code stored in the database and executed on specific events. Useful for fast iteration without deploying app code. See `../framework/scripting.md` for the full reference.

### Quick Reference

| Script Type | Trigger | Use |
|---|---|---|
| **DocType Event** | `validate`, `on_submit`, `on_cancel`, etc. | Custom validation, side effects. |
| **API** | `/api/method/<script_name>` | Custom REST endpoint. |
| **Scheduler Event** | Cron | Periodic jobs. |
| **Permission Query** | List view filter | Row-level security. |

### Example: Auto-set Cost Center on Sales Invoice

```python
# Script Type: DocType Event
# DocType: Sales Invoice
# DocType Event: Before Validate

if not doc.cost_center:
    default_cc = frappe.db.get_value("Company", doc.company, "cost_center")
    if default_cc:
        doc.cost_center = default_cc

# Also set per-row cost center
for item in doc.items:
    if not item.cost_center:
        item.cost_center = doc.cost_center
```

### Security Considerations

- Server Scripts run with the calling user's permissions unless `frappe.flags.ignore_permissions = True` is set.
- Never use `frappe.db.sql` with f-string interpolation — use parameterized queries.
- Anyone with `System Manager` role can edit Server Scripts. In a regulated environment, restrict this via role.
- Server Scripts are stored in the DB — back up the DB to back up scripts (or use Fixtures + a custom app for version control).

## Client Scripts

`Client Script` is JavaScript run in the browser on form events. Stored in `tabClient Script`. See `../framework/scripting.md` for the full reference.

### Quick Reference

```javascript
// Client Script for Sales Invoice
frappe.ui.form.on("Sales Invoice", {
    refresh: function(frm) {
        // Add a custom button
        if (frm.doc.docstatus === 1) {
            frm.add_custom_button(__("Print Sticker"), function() {
                frappe.set_route("print", frm.doc.doctype, frm.doc.name, "Sticker Format");
            });
        }
    },

    customer: function(frm) {
        // When customer changes, fetch credit limit
        if (frm.doc.customer) {
            frappe.db.get_value("Customer", frm.doc.customer, "credit_limit")
                .then(r => {
                    if (r && r.message) {
                        frm.set_value("custom_credit_limit_display", r.message.credit_limit);
                    }
                });
        }
    },

    validate: function(frm) {
        // Client-side validation before save
        if (frm.doc.total < 0) {
            frappe.throw(__("Total cannot be negative"));
        }
    }
});
```

### When to Use Client Scripts

- Add custom buttons.
- Compute field values interactively.
- Conditional field display (use `depends_on` on Custom Field for simpler cases).
- Pre-fetch reference data.

### When NOT to Use Client Scripts

- Security-sensitive validation — always re-validate server-side.
- Anything that needs to run on import — Client Scripts only run in the Desk UI.
- Long-running computations — block the UI thread.

## Custom Dashboards

The Dashboard stack in ERPNext (and Frappe Framework) consists of three DocTypes:

### 1. Dashboard

`Dashboard` is a container for charts and number cards. Created via **Dashboards → New**:

```python
dash = frappe.get_doc({
    "doctype": "Dashboard",
    "dashboard_name": "Sales Overview",
    "charts": [
        {"chart": "Sales Trend"},
        {"chart": "Top Customers"},
        {"chart": "Sales by Territory"},
    ],
    "number_cards": [
        {"number_card": "Total Sales This Month"},
        {"number_card": "Open Sales Orders"},
    ],
})
dash.insert()
```

### 2. Number Card

`Number Card` shows a single aggregated number (e.g. "Total Sales This Month"). Configurable with:

- `document_type`, `aggregate_function` (Sum/Average/Count/Min/Max).
- `based_on` (date field for the period).
- `filter_conditions` (JSON).
- `color`, `icon`.

### 3. Dashboard Chart

`Dashboard Chart` is a chart (bar, line, pie, donut, heatmap). Created via **Dashboard Chart → New**:

```python
chart = frappe.get_doc({
    "doctype": "Dashboard Chart",
    "chart_name": "Monthly Sales",
    "chart_type": "Sum",
    "document_type": "Sales Invoice",
    "based_on": "posting_date",
    "value_based_on": "grand_total",
    "group_by_based_on": "month",
    "filters_json": '{"docstatus": 1, "company": "Acme"}',
    "type": "Line",
    "timeseries": 1,
    "time_span": "Last Year",
    "time_interval": "Monthly",
})
chart.insert()
```

### Custom Dashboard with Script

For dashboards driven by external data or complex aggregation, use the **Frappe Insights** app. It supports SQL queries, joins, and visualizations beyond what Dashboard Chart offers.

## Custom Desk Pages

The Desk home page in v14+ uses **Workspace** DocTypes. Each Workspace is a card-grid of shortcuts, lists, charts, and quick lists. To create a custom Workspace:

1. Open **Workspace → New**.
2. Set **Module** (e.g. `Selling`), **Label**, **Icon**.
3. Add **Shortcuts** (links to DocTypes or pages).
4. Add **Cards** (lists filtered by status).
5. Add **Charts** (link to Dashboard Chart).
6. Save & set as default for a role.

### Workspace via Python

```python
ws = frappe.get_doc({
    "doctype": "Workspace",
    "label": "Sales Operations",
    "module": "Selling",
    "icon": "sales",
    "is_default": 1,
    "shortcuts": [
        {"type": "DocType", "link_to": "Sales Order", "label": "Sales Order"},
        {"type": "DocType", "link_to": "Customer", "label": "Customer"},
    ],
    "links": [
        {"type": "Report", "link_to": "Sales Analytics", "label": "Sales Analytics"},
    ],
})
ws.insert()
```

## Hooks for ERPNext DocTypes

If you have a custom app, you can hook into ERPNext DocTypes via `hooks.py`. This is the production-grade alternative to Server Scripts — version-controlled, testable, and migratable.

### `doc_events`

```python
# my_app/my_app/hooks.py

doc_events = {
    "Sales Invoice": {
        "validate": "my_app.sales_invoice.validate",
        "before_submit": "my_app.sales_invoice.before_submit",
        "on_submit": "my_app.sales_invoice.on_submit",
        "on_cancel": "my_app.sales_invoice.on_cancel",
        "before_delete": "my_app.sales_invoice.before_delete",
    },
    "Purchase Order": {
        "on_submit": "my_app.purchase_order.notify_supplier",
    },
    "*": {  # All DocTypes
        "on_update": "my_app.audit.log_change",
    },
}
```

### `before_tests` and `after_tests`

Run setup/teardown around test execution.

### `override_whitelisted_methods`

Replace a core whitelisted method with your own:

```python
override_whitelisted_methods = {
    "erpnext.accounts.doctype.payment_entry.payment_entry.get_payment_entry":
        "my_app.payment_entry.get_payment_entry",
}
```

### `realtime_user_typeinfo`

For custom realtime channels (e.g. live order updates).

### Other Useful Hooks

- `boot_session` — add data to the boot payload sent to every logged-in user.
- `on_login` / `on_logout` — auth lifecycle.
- `before_save` / `after_save` — global save hooks.
- `payment_gateway_enabled` — register a custom payment gateway.

Read `../framework/scripting.md` for the complete hooks reference.

## Fixtures (Exporting Customizations)

`Fixtures` is the mechanism for exporting DB-stored customizations into your app's codebase, so they survive migrations and can be version-controlled.

### Setup

In your custom app's `hooks.py`:

```python
fixtures = [
    "Custom Field",
    "Property Setter",
    "Print Format",
    "Workflow",
    "Notification",
    "Client Script",
    "Server Script",
    "Report",
    {"doctype": "Custom Field", "filters": [["dt", "=", "Sales Invoice"]]},
    {"doctype": "Role", "filters": [["name", "in", ["Sales Approver", "Stock Auditor"]]]},
]
```

### Export

```bash
bench --site mysite.localhost export-fixtures
```

ERPNext writes one JSON file per fixture entry to `<app>/<app>/fixtures/<doctype>.json`. Commit these files to your git repo.

### Auto-Import on Migrate

When `bench migrate` runs on a fresh site that has the app installed, ERPNext auto-imports all fixtures from the app, recreating the customizations.

### Pitfalls

- **Fixtures overwrite manual edits** — every `bench migrate` re-imports the JSON. If you manually edited a Custom Field on the production site, your edit gets overwritten.
- **App load order matters** — fixtures from later-loaded apps override earlier ones. Use `fixtures` carefully in multi-app setups.
- **Custom Fields on core DocTypes** — always include `Custom Field` in fixtures; otherwise the field is lost on a fresh install.
- **Roles and Permissions** — fixtures can carry Roles, but per-DocType permission overrides go in `custom_perms` (separate fixture).

## Environment Management & Upgrade Considerations

### Dev → Staging → Production Workflow

1. **Develop** in a custom app (`my_app`) on a local bench.
2. **Export fixtures** to `my_app/my_app/fixtures/`.
3. **Commit** the app to git.
4. **Deploy** to staging: `bench get-app my_app git@repo:my_app.git` + `bench --site staging install-app my_app` + `bench --site staging migrate`.
5. **Test** on staging — verify fixtures imported correctly, hooks fire, custom reports run.
6. **Deploy** to production: same as staging.
7. **Hot fixes** — small fixes go via Server/Client Scripts (DB-only); larger ones via app version bump.

### Managing Server Scripts in Version Control

Server Scripts are DB-only — they do not auto-export to fixtures. To version-control them:

1. Use the **Server Script → Export to File** feature (v15+) to dump scripts to a custom app folder.
2. Or write the equivalent logic in your custom app's Python modules and reference via `doc_events` in hooks.py (recommended for production).

### Upgrade Considerations

When upgrading ERPNext (e.g. v14 → v15):

1. **Read the release notes** for breaking changes — many customization patterns get deprecated.
2. **Test on a staging copy of production data** — `bench restore` from a backup.
3. **Run `bench migrate`** on staging first; resolve any errors.
4. **Custom Fields** may collide with new core fields — ERPNext warns but does not auto-rename. Rename your `custom_*` fields if there's a conflict.
5. **Property Setters** can override new defaults — review and remove stale ones.
6. **Server Scripts** using removed APIs will throw on first invocation — run the staging copy through every workflow.
7. **Print Formats** referencing removed fields will print blank — test each format.
8. **Reports** with hardcoded SQL against renamed tables/columns will fail — review.

### Common Upgrade Pitfalls

- **Hidden Custom Fields** — a Custom Field with `hidden = 1` set via Property Setter can mask new core fields that occupy the same slot. Re-order with `insert_after`.
- **Permissions drift** — new roles added by the upgrade may not have permission rules. Run **Role Permissions Manager** after upgrade.
- **Workflow state stuck** — workflows with `doc_status` mapping can break if the DocType's submittable behavior changed. Re-save each workflow after upgrade.
- **Report SQL on dropped columns** — Script Reports referencing `tabSales Invoice.customer_name` (instead of joining Customer) will break if the column is dropped in a future version.

### Best Practices for Long-Term Maintainability

- **Prefer Custom Fields over Property Setters** for new properties — they're easier to track and export.
- **Prefer Server Scripts in your app over DB Server Scripts** for production logic — version-controlled, testable, secure.
- **Document every customization** in a `CHANGELOG.md` or wiki page; future maintainers will thank you.
- **Tag fixture exports with the ERPNext version** they were created against.
- **Run `bench doctor` after every customization** to catch permission and schema issues early.
- **Don't override core whitelisted methods unless absolutely necessary** — they may change signature between versions. Wrap with your own method that delegates to core, instead.
- **Use `frappe.log_error` in custom hooks** so failures show up in **Error Log** rather than crashing the form.

## Where to Learn More

- Customize ERPNext: `https://docs.frappe.io/erpnext/customize-erpnext`
- Custom Field: `https://docs.frappe.io/erpnext/custom-field`
- Property Setter: `https://docs.frappe.io/erpnext/property-setter`
- Print Format: `https://docs.frappe.io/erpnext/print-format`
- Workflow: `https://docs.frappe.io/erpnext/workflow`
- Notification: `https://docs.frappe.io/erpnext/notification`
- Email Rule: `https://docs.frappe.io/erpnext/email-rule`
- Auto Repeat: `https://docs.frappe.io/erpnext/auto-repeat`
- Server Script: `https://docs.frappe.io/erpnext/server-script`
- Client Script: `https://docs.frappe.io/erpnext/client-script`
- Custom Scripts: `https://docs.frappe.io/erpnext/custom-scripts`
- Reports: `https://docs.frappe.io/erpnext/reports`
- Query Report: `https://docs.frappe.io/erpnext/query-report`
- Script Reports: `https://docs.frappe.io/erpnext/script-reports`
- Dynamic Links: `https://docs.frappe.io/erpnext/dynamic-links`
- Print Format Settings: `https://docs.frappe.io/erpnext/print-format-settings`
- Print Style: `https://docs.frappe.io/erpnext/print-style`
- Letter Head: `https://docs.frappe.io/erpnext/letter-head`
- Automation: `https://docs.frappe.io/erpnext/automation`

For the framework-level scripting primitives used by every customization (`frappe.ui.form.on`, `frappe.call`, `frappe.whitelist`, `frappe.enqueue`, hooks.py event list), read `../framework/scripting.md`. For DocType creation (which is the foundation under Custom Fields), read `../framework/doctype-guide.md`. For the Python ORM (`frappe.get_doc`, `frappe.db.sql`), read `../framework/python-api.md`. For deployment and bench commands used during fixture export and migration, read `../framework/bench-cli.md`.
