# Frappe Framework — DocType Guide

DocTypes are the core building block of every Frappe application. This guide covers everything from creating a DocType to writing its controller, defining fields, permissions, and advanced patterns.

## Table of Contents

1. [What is a DocType](#what-is-a-doctype)
2. [Creating a DocType](#creating-a-doctype)
3. [Field Types](#field-types)
4. [Field Properties](#field-properties)
5. [Naming Conventions](#naming-conventions)
6. [Controllers and Lifecycle Hooks](#controllers-and-lifecycle-hooks)
7. [Permissions](#permissions)
8. [Child Tables](#child-tables)
9. [Submittable DocTypes](#submittable-doctypes)
10. [Tree DocTypes](#tree-doctypes)
11. [Virtual DocTypes](#virtual-doctypes)
12. [Single DocTypes](#single-doctypes)
13. [Customizing Existing DocTypes](#customizing-existing-doctypes)
14. [Migrations and Patches](#migrations-and-patches)

## What is a DocType

A DocType is both:
1. A **schema definition** (which fields, what types, what permissions).
2. A **Python class** (the controller) that defines behavior.

The schema is stored as a row in `tabDocType`, and the field definitions as rows in `tabDocField`. When you save a DocType, Frappe:
- Creates/updates a database table `tab<DoctypeName>`.
- Generates a Python controller class (or loads an existing one).
- Refreshes the metadata cache.
- Updates the auto-generated REST endpoints.

## Creating a DocType

### Via Desk UI

1. Search "DocType" in the Awesome Bar.
2. Click "Add New".
3. Fill in: Name (singular, PascalCase), Module, Naming Rule.
4. Add fields.
5. Set permissions.
6. Save.

### Via app code (recommended for production)

Create the file `<app>/<app>/<module>/doctype/<doctype_lower>/<doctype_lower>.json`:

```json
{
  "actions": [],
  "allow_rename": 1,
  "autoname": "hash",
  "creation": "2024-08-07 10:00:00.000000",
  "doctype": "DocType",
  "engine": "InnoDB",
  "field_order": [
    "title",
    "status",
    "priority",
    "column_break_1",
    "due_date",
    "assigned_to",
    "section_break_items",
    "items"
  ],
  "fields": [
    {
      "fieldname": "title",
      "fieldtype": "Data",
      "in_list_view": 1,
      "label": "Title",
      "reqd": 1,
      "unique": 1
    },
    {
      "fieldname": "status",
      "fieldtype": "Select",
      "label": "Status",
      "options": "Open\nIn Progress\nCompleted\nCancelled",
      "default": "Open",
      "in_list_view": 1
    },
    {
      "fieldname": "priority",
      "fieldtype": "Select",
      "label": "Priority",
      "options": "Low\nMedium\nHigh\nUrgent",
      "default": "Medium"
    },
    {
      "fieldname": "column_break_1",
      "fieldtype": "Column Break"
    },
    {
      "fieldname": "due_date",
      "fieldtype": "Date",
      "label": "Due Date"
    },
    {
      "fieldname": "assigned_to",
      "fieldtype": "Link",
      "label": "Assigned To",
      "options": "User"
    },
    {
      "fieldname": "section_break_items",
      "fieldtype": "Section Break",
      "label": "Items"
    },
    {
      "fieldname": "items",
      "fieldtype": "Table",
      "label": "Items",
      "options": "Task Item"
    }
  ],
  "index_web_pages_for_search": 1,
  "links": [],
  "modified": "2024-08-07 10:00:00.000000",
  "modified_by": "Administrator",
  "module": "Tasks",
  "name": "Task",
  "naming_rule": "Expression",
  "owner": "Administrator",
  "permissions": [
    {
      "create": 1,
      "delete": 1,
      "email": 1,
      "export": 1,
      "print": 1,
      "read": 1,
      "report": 1,
      "role": "System Manager",
      "share": 1,
      "write": 1
    },
    {
      "create": 1,
      "read": 1,
      "role": "Tasks User",
      "write": 1
    }
  ],
  "search_fields": "title,status,priority",
  "sort_field": "modified",
  "sort_order": "DESC",
  "states": [],
  "title_field": "title",
  "track_changes": 1
}
```

And the controller `<app>/<app>/<module>/doctype/<doctype_lower>/<doctype_lower>.py`:

```python
import frappe
from frappe.model.document import Document

class Task(Document):
    def validate(self):
        if self.due_date and self.due_date < frappe.utils.today():
            frappe.throw("Due date cannot be in the past", frappe.ValidationError)

    def on_update(self):
        # Notify assigned user
        if self.assigned_to and self.has_value_changed("assigned_to"):
            frappe.sendmail(
                recipients=[self.assigned_to],
                subject=f"Task assigned: {self.title}",
                message=f"You have been assigned to task {self.name}"
            )

    @frappe.whitelist()
    def mark_complete(self):
        self.status = "Completed"
        self.save()
```

After creating the files, run `bench migrate` to apply.

## Field Types

| Field Type | DB Type | Use Case | Example |
|---|---|---|---|
| `Data` | `varchar(140)` | Short text | Name, title |
| `Data` (with `length`) | `varchar(N)` | Custom-length text | Code (length=20) |
| `Text` | `text` | Multi-line text | Description |
| `Long Text` | `longtext` | Very long text | Notes |
| `Small Text` | `text` | Shorter multi-line | Comments |
| `Code` | `longtext` | Code blocks (with syntax highlight) | JavaScript, Python |
| `HTML Editor` | `text` | Rich text editor | Email body |
| `Markdown Editor` | `text` | Markdown editor | README |
| `Int` | `int` | Integer | Quantity |
| `Float` | `decimal(21,9)` | Decimal number | Rate |
| `Currency` | `decimal(21,9)` | Money amount | Total |
| `Percent` | `decimal(21,9)` | Percentage (0-100) | Discount |
| `Date` | `date` | Date only | Due date |
| `Datetime` | `datetime(6)` | Date + time | Created on |
| `Time` | `time` | Time only | Start time |
| `Check` | `int` | Boolean (0/1) | Is active |
| `Select` | `varchar(140)` | Dropdown | Status |
| `Link` | `varchar(140)` | Foreign key to another DocType | Customer |
| `Dynamic Link` | `varchar(140)` | Link to a doctype specified by another field | Party (Party Type + Party) |
| `Table` (child) | — | Sub-records in a child table | Invoice items |
| `Table MultiSelect` | — | Multi-select via child table | Tags |
| `Attach` | `text` | File URL (single) | Document |
| `Attach Image` | `text` | Image URL (single, with preview) | Photo |
| `Section Break` | — | UI: vertical section | — |
| `Column Break` | — | UI: horizontal column | — |
| `Tab Break` | — | UI: tabbed section | — |
| `HTML` | — | Custom HTML in form (no DB column) | Banner |
| `Button` | — | Clickable button (no DB column) | Run action |
| `Color` | `varchar(140)` | Color picker | Brand color |
| `Color` (Hex) | `varchar(7)` | Hex color | — |
| `Signature` | `longtext` | Signature pad | Approval signature |
| `Password` | `text` | Password (encrypted) | API secret |
| `Read Only` | `varchar(...)` | Display only | Computed value |
| `Geolocation` | `text` | Map + coordinates | Address location |
| `Duration` | `decimal(21,9)` | Time duration | 1h 30min |
| `Datetime` (Local) | `datetime(6)` | Displayed in user TZ | — |
| `Icon` | `varchar(140)` | Icon picker | Menu icon |
| `Autocomplete` | `varchar(140)` | Typeahead with custom options | Tags |
| `JSON` | `longtext` | JSON value | Metadata |
| `Virtual` (with `is_virtual`) | — | No DB column; computed | Full name |

### Field type → DB column mapping notes

- `Section Break`, `Column Break`, `Tab Break`, `HTML`, `Button` create **no column** — they're UI-only.
- `Link` stores the **name** of the linked doc, not a real FK constraint.
- `Table` (child) stores no column on the parent; child rows live in their own table with a `parent` column.
- `Read Only` does create a column (so you can query it).
- `Virtual` fields (`is_virtual: 1` in v15+) have no column — computed via controller property.

## Field Properties

Each field has many meta-properties. Most-used:

| Property | Description |
|---|---|
| `label` | Display label |
| `fieldname` | Programmatic name (snake_case) |
| `fieldtype` | One of the types above |
| `options` | For Select: `\n`-separated options. For Link/Table: target DocType name. For HTML: raw HTML. |
| `reqd` | 1 if required |
| `read_only` | 1 if non-editable |
| `hidden` | 1 if hidden from form |
| `default` | Default value |
| `description` | Help text under field |
| `in_list_view` | 1 if shown in list view |
| `in_standard_filter` | 1 if shown in standard filter dropdown |
| `in_global_search` | 1 if searchable globally |
| `in_preview` | 1 if shown in list preview popup |
| `search_index` | 1 if indexed |
| `unique` | 1 if value must be unique across rows |
| `no_copy` | 1 if not copied when duplicating doc |
| `allow_on_submit` | 1 if editable after submission (only for submittable doctypes) |
| `fetch_from` | Dot path to auto-fetch value, e.g. `customer.customer_name` |
| `fetch_if_empty` | 1 if fetch_from should only override empty values |
| `depends_on` | Conditional display, e.g. `eval:doc.status=="Open"` |
| `mandatory_depends_on` | Conditional required |
| `read_only_depends_on` | Conditional read-only |
| `permlevel` | Permission level (0-9) |
| `ignore_user_permissions` | 1 if user permission checks should be bypassed for this Link field |
| `show_dashboard` | 1 if shown in dashboard |
| `column_index` | Layout hint |
| `width` | For list view column width |
| `translatable` | 1 if value should be translated (default 1 for Select options) |
| `is_virtual` | 1 if virtual (no DB column) |
| `length` | For Data field: max length |
| `precision` | For Float/Currency: decimal places |
| `non_negative` | 1 if value must be ≥ 0 |
| `remember_last_selected_value` | 1 if form should default to last selected |

### Conditional display (`depends_on`)

```json
{
  "fieldname": "rejection_reason",
  "fieldtype": "Text",
  "label": "Rejection Reason",
  "depends_on": "eval:doc.status==\"Rejected\"",
  "mandatory_depends_on": "eval:doc.status==\"Rejected\""
}
```

### Auto-fetch (`fetch_from`)

```json
{
  "fieldname": "customer_name",
  "fieldtype": "Data",
  "label": "Customer Name",
  "fetch_from": "customer.customer_name",
  "read_only": 1
}
```

When the `customer` Link field is set, `customer_name` is auto-populated from the linked Customer's `customer_name` field.

## Naming Conventions

How new documents get their `name` (primary key):

| Rule | Setting | Example |
|---|---|---|
| Set by user | `naming_rule: "Set by user"` + `autoname: null` | User types name in form |
| By field | `naming_rule: "By fieldname"` + `autoname: "field:customer_name"` | Uses the value of `customer_name` field |
| By series | `naming_rule: "By "Naming Series""` + `autoname: "naming_series:"` + field `naming_series` with options like `CUST-.YYYY.-` | `CUST-2024-0001` |
| Expression | `naming_rule: "Expression"` + `autoname: "format:{first_name}-{####}"` | `John-0001` |
| Hash | `naming_rule: "Expression"` + `autoname: "hash"` | Random 32-char hash |
| Random | `naming_rule: "Expression"` + `autoname: "random"` | Short random string |
| Prompt | `naming_rule: "Expression"` + `autoname: "prompt"` | Asks user for name on each save |
| Auto Increment | `naming_rule: "Auto Increment"` + `autoname: "autoincrement"` | 1, 2, 3, ... |

### Format expressions

Use `{field}` placeholders and `#` for digits:

- `format:{customer_name}-{#####}` → `Acme Corp-00001`
- `format:{first_name}.{last_name}` → `john.doe`
- `format:TASK-{YYYY}-{#####}` → `TASK-2024-00001`

### Allow rename

```json
{
  "allow_rename": 1
}
```

If 1, users can rename docs via the form's "Rename" button.

## Controllers and Lifecycle Hooks

The controller class extends `frappe.model.document.Document` and overrides lifecycle methods:

```python
import frappe
from frappe.model.document import Document

class Task(Document):
    # ====== Before ======
    def before_insert(self):
        # Runs only on create, before validate
        # Useful for setting defaults
        pass

    def validate(self):
        # Runs on every save (create + update)
        # Main validation logic goes here
        if self.due_date and self.due_date < frappe.utils.today():
            frappe.throw("Due date cannot be in the past")

    def before_save(self):
        # Runs after validate, before DB write
        # Use to set derived fields
        self.title = (self.title or "").strip()

    def before_submit(self):
        # Runs before submission (only for submittable doctypes)
        pass

    def before_cancel(self):
        # Runs before cancellation
        pass

    # ====== After ======
    def on_update(self):
        # Runs after every save (create + update)
        # Use for side effects: notifications, caching
        frappe.cache().delete_value(f"task:{self.name}")

    def on_update_after_submit(self):
        # Runs after save when doc is already submitted
        # Only fires if allow_on_submit fields were changed
        pass

    def on_submit(self):
        # Runs after successful submission
        frappe.sendmail(
            recipients=[self.assigned_to],
            subject=f"Task {self.name} submitted",
            message="..."
        )

    def on_cancel(self):
        # Runs after cancellation
        # Reverse any side effects of on_submit
        pass

    def on_trash(self):
        # Runs before delete
        # Clean up related records, attachments, etc.
        frappe.db.delete("Communication", {
            "reference_doctype": self.doctype,
            "reference_name": self.name
        })

    def after_delete(self):
        # Runs after delete
        pass

    def on_rename(self, old_name, new_name):
        # Runs after rename
        # Update references in other tables if needed
        pass

    # ====== Auto-created hooks ======
    def autoname(self):
        # Custom naming logic (overrides DocType's naming rule)
        # Set self.name to the desired name
        self.name = f"{self.customer_name[:3].upper()}-{frappe.utils.random_string(5)}"

    # ====== Custom methods ======
    @frappe.whitelist()
    def mark_complete(self, comment=None):
        """Mark this task as complete."""
        self.status = "Completed"
        self.save()
        if comment:
            self.add_comment("Comment", comment)
        return self.name

    # ====== Permission hooks ======
    def get_permission_query_conditions(self, user=None):
        """Return SQL fragment to filter list view."""
        if not user:
            user = frappe.session.user
        if "System Manager" in frappe.get_roles(user):
            return ""  # see all
        return f"`tabTask`.`owner` = {frappe.db.escape(user)}"

    def has_permission(self, ptype="read", user=None, verbose=False):
        """Return True/False for a specific permission check."""
        if not user:
            user = frappe.session.user
        if "System Manager" in frappe.get_roles(user):
            return True
        if ptype in ("read", "write"):
            return self.owner == user or self.assigned_to == user
        return False

    # ====== Virtual fields (v15+) ======
    @property
    def is_overdue(self):
        """Virtual field — accessible as doc.is_overdue, no DB column."""
        return bool(self.due_date and self.due_date < frappe.utils.today())
```

### Hook execution order on save (create)

1. `before_insert`
2. `autoname` (if defined)
3. `validate`
4. `before_save`
5. **DB write** (insert)
6. `on_update`
7. **Commit** (if no exceptions)

### Hook execution order on save (existing)

1. `validate`
2. `before_save`
3. **DB write** (update)
4. `on_update`
5. **Commit**

### Hook execution order on submit

1. `validate`
2. `before_save`
3. `before_submit`
4. **DB write** (update docstatus to 1)
5. `on_update`
6. `on_submit`
7. **Commit**

### Hook execution order on cancel

1. `before_cancel`
2. **DB write** (update docstatus to 2)
3. `on_cancel`
4. **Commit**

### Hook execution order on delete

1. `on_trash`
2. **DB delete** (cascading to child tables, comments, attachments)
3. `after_delete`
4. **Commit**

### Comparing to previous value

```python
def validate(self):
    if self.has_value_changed("status"):
        # status was changed in this save
        old_status = self.get_doc_before_save().status
        new_status = self.status
        # log or notify
        frappe.logger().info(f"Status: {old_status} → {new_status}")
```

`get_doc_before_save()` returns a snapshot of the doc as it was in the DB before this save. Available during `validate`, `before_save`, `on_update`.

## Permissions

### DocType-level permissions

Defined in the `permissions` array of the DocType JSON:

```json
"permissions": [
  {
    "role": "System Manager",
    "read": 1, "write": 1, "create": 1, "delete": 1,
    "submit": 1, "cancel": 1, "amend": 1,
    "print": 1, "email": 1, "report": 1, "export": 1,
    "import": 1, "share": 1, "set_user_permissions": 1
  },
  {
    "role": "Sales User",
    "read": 1, "write": 1, "create": 1,
    "if_owner": 1  # only if they own the doc
  },
  {
    "role": "Sales Manager",
    "read": 1, "write": 1, "delete": 1, "submit": 1, "cancel": 1,
    "permlevel": 0
  }
]
```

Permission fields:
- `read`, `write`, `create`, `delete` — basic CRUD
- `submit`, `cancel`, `amend` — for submittable doctypes
- `print`, `email`, `report`, `export`, `import` — additional actions
- `share` — can share with other users
- `set_user_permissions` — can set User Permissions
- `if_owner` — restrict to docs owned by the user

### Field-level permissions (`permlevel`)

Group fields into permission levels (0-9):

```json
{
  "fieldname": "cost_price",
  "fieldtype": "Currency",
  "label": "Cost Price",
  "permlevel": 1
}
```

In DocType permissions, add a separate permission row per level:

```json
{
  "role": "Sales Manager",
  "permlevel": 1,
  "read": 1, "write": 1
}
```

Users without level-1 read permission won't see the `cost_price` value (it'll show as `***`).

### Document-level permissions (User Permissions)

Define which specific documents a user can access:

```python
# Setup via Desk → User Permissions
# e.g. user can only see Customers where territory == "West"

# Check programmatically
from frappe.core.doctype.user_permission.user_permission import get_user_permissions
perms = get_user_permissions(user)
# perms = {
#   "Customer": [{"doc": "CUST-A", "value": "West"}],
#   "Territory": [{"doc": "West", "value": "West"}]
# }
```

### Permission Query Conditions

For row-level filtering in list views:

```python
class Task(Document):
    def get_permission_query_conditions(self, user=None):
        if not user:
            user = frappe.session.user
        if "System Manager" in frappe.get_roles(user):
            return ""
        return f"`tabTask`.`owner` = {frappe.db.escape(user)}"
```

### `has_permission` hook

For complex per-doc, per-action checks:

```python
class Task(Document):
    def has_permission(self, ptype="read", user=None, verbose=False):
        if not user:
            user = frappe.session.user
        if "System Manager" in frappe.get_roles(user):
            return True
        if ptype == "read":
            return self.owner == user or self.assigned_to == user
        if ptype == "write":
            return self.owner == user and self.status != "Completed"
        if ptype == "delete":
            return False  # never allow delete via this hook
        return False
```

## Child Tables

Child tables are sub-records attached to a parent via a `Table`-type field. Each child row has its own row in the child DocType's table.

### Creating a child DocType

Create a normal DocType but with `istable: 1`:

```json
{
  "doctype": "DocType",
  "name": "Task Item",
  "module": "Tasks",
  "istable": 1,
  "fields": [
    {"fieldname": "item_code", "fieldtype": "Link", "options": "Item", "label": "Item", "reqd": 1},
    {"fieldname": "qty", "fieldtype": "Float", "label": "Quantity", "reqd": 1, "default": 1},
    {"fieldname": "rate", "fieldtype": "Currency", "label": "Rate"},
    {"fieldname": "amount", "fieldtype": "Currency", "label": "Amount", "read_only": 1}
  ]
}
```

### Using in parent

```json
{
  "fieldname": "items",
  "fieldtype": "Table",
  "label": "Items",
  "options": "Task Item"
}
```

### Working with child rows in controller

```python
class Task(Document):
    def validate(self):
        total = 0
        for item in self.items:
            # Auto-calculate amount
            item.amount = item.qty * item.rate
            total += item.amount
        self.total_amount = total

    def before_save(self):
        # Remove empty rows
        self.items = [item for item in self.items if item.item_code]
```

### Adding/removing child rows

```python
doc = frappe.get_doc("Task", "TASK00001")

# Add a child
doc.append("items", {
    "item_code": "ITEM001",
    "qty": 2,
    "rate": 100
})

# Remove a child (by reference)
doc.remove(doc.items[0])

# Remove by filter
doc.items = [item for item in doc.items if item.qty > 0]

doc.save()
```

### Child table controller hooks

Child DocTypes can have controllers too:

```python
class TaskItem(Document):
    def validate(self):
        if self.qty <= 0:
            frappe.throw("Quantity must be positive")
        self.amount = flt(self.qty) * flt(self.rate)
```

These fire when the parent is saved (each child is validated before the parent).

## Submittable DocTypes

A submittable DocType has a 3-state lifecycle: Draft (0) → Submitted (1) → Cancelled (2).

### Configuration

```json
{
  "is_submittable": 1
}
```

Or set in Desk: DocType → "Is Submittable" checkbox.

### Behaviors

- Draft docs can be edited freely.
- Submitted docs are locked (only `allow_on_submit` fields can be edited).
- Cancelling a submitted doc creates a cancelled record (docstatus=2). The doc is not deleted — it remains in the DB.
- Submitted docs typically drive downstream effects (e.g. Sales Invoice submission creates GL Entries).
- Amendments: to amend a cancelled doc, click "Amend" → creates a new draft with the same data.

### Hooks

```python
class SalesInvoice(Document):
    def before_submit(self):
        # Final validation before submission
        if not self.items:
            frappe.throw("Cannot submit empty invoice")

    def on_submit(self):
        # Create GL entries, update stock, etc.
        self.make_gl_entries()
        self.update_stock_ledger()

    def before_cancel(self):
        # Reverse any side effects
        self.cancel_gl_entries()
        self.reverse_stock_ledger()

    def on_cancel(self):
        # Mark as cancelled in external systems
        self.notify_external_system_of_cancellation()
```

## Tree DocTypes

Tree DocTypes have a parent-child hierarchy (e.g. Chart of Accounts, Warehouse).

### Configuration

```json
{
  "is_tree": 1,
  "nsm_parent_field": "parent_account"
}
```

`nsm_parent_field` is the fieldname that holds the parent reference.

### Working with trees

```python
account = frappe.get_doc("Account", "Cash")
parent = account.parent_account  # parent's name
children = frappe.db.get_list("Account", filters={"parent_account": "Cash"})

# Get all descendants (descendants only, not the node itself)
descendants = frappe.db.get_list("Account", filters={"parent_account": ["descendants of", "Cash"]})

# Get ancestors
ancestors = frappe.db.get_list("Account", filters={"name": ["ancestors of", "Cash"]})

# Get tree
tree = frappe.db.get_tree("Account", "Cash")
```

### Tree fields

Tree DocTypes usually have:
- `parent_<name>` — Link to parent of same DocType
- `old_parent` — for tracking moves
- `lft`, `rgt` — Nested Set Model boundaries (auto-maintained)

## Virtual DocTypes

Virtual DocTypes have no database table — data comes from an external source via the controller. Available since v13.

### Configuration

```json
{
  "doctype": "DocType",
  "name": "External User",
  "module": "Users",
  "is_virtual": 1,
  "fields": [
    {"fieldname": "email", "fieldtype": "Data", "label": "Email", "reqd": 1},
    {"fieldname": "first_name", "fieldtype": "Data", "label": "First Name"},
    {"fieldname": "last_name", "fieldtype": "Data", "label": "Last Name"}
  ]
}
```

### Controller

```python
import frappe
from frappe.model.document import Document

class ExternalUser(Document):
    # No DB table — override get/set methods

    @staticmethod
    def get_list(args):
        # args: filters, or_filters, fields, order_by, limit_start, limit_page_length
        # Fetch from external API
        import requests
        resp = requests.get("https://api.example.com/users", timeout=30)
        users = resp.json()

        # Apply filters (you have to do this manually)
        for f in args.get("filters") or []:
            # ... filter logic
            pass

        # Return list of dicts
        return [
            {"name": u["id"], "email": u["email"], "first_name": u["first"], "last_name": u["last"]}
            for u in users
        ]

    @staticmethod
    def get_count(args):
        # Return integer
        return len(ExternalUser.get_list(args))

    @staticmethod
    def get_stats(args):
        # Return dict of stats
        return {}

    @staticmethod
    def get_list_args():
        # Return default args
        return {}
```

Use cases:
- Read-only views of external API data.
- Aggregations of multiple tables.
- Computed/virtual records (e.g. "Open Invoices" view).

Limitations:
- No writes (you can override `db_insert`, `db_update`, `db_delete` if you really need to, but it's complex).
- No standard form view (need custom Page).
- No child tables.

## Single DocTypes

Single DocTypes have exactly one record (no name needed). Used for settings.

### Configuration

```json
{
  "doctype": "DocType",
  "name": "Task Settings",
  "module": "Tasks",
  "issingle": 1,
  "fields": [
    {"fieldname": "default_priority", "fieldtype": "Select", "options": "Low\nMedium\nHigh", "label": "Default Priority"},
    {"fieldname": "auto_assign", "fieldtype": "Check", "label": "Auto-assign new tasks"}
  ]
}
```

### Usage

```python
settings = frappe.get_doc("Task Settings")
print(settings.default_priority)  # "Medium"

settings.default_priority = "High"
settings.save()  # saves to tabSingles table (not a per-row table)

# Or use db helpers
frappe.db.set_single_value("Task Settings", "default_priority", "High")
val = frappe.db.get_single_value("Task Settings", "default_priority")
```

## Customizing Existing DocTypes

You usually don't want to modify core DocTypes directly (changes get wiped on `bench update`). Use these customization mechanisms:

### Custom Fields

Add fields to existing DocTypes without modifying the original schema:

```python
# Create via code
field = frappe.get_doc({
    "doctype": "Custom Field",
    "dt": "Task",
    "fieldname": "custom_priority_color",
    "fieldtype": "Color",
    "label": "Priority Color",
    "insert_after": "priority"
})
field.insert()

# Or via fixtures
# hooks.py:
fixtures = ["Custom Field"]
# Run: bench export-fixtures
```

Custom fields appear in `tabCustom Field` and are merged into the DocType's metadata at runtime. The DB column is added to `tabTask` (with `custom_` prefix by default, but you can omit it).

### Property Setters

Change a property of an existing field without modifying the JSON:

```python
frappe.get_doc({
    "doctype": "Property Setter",
    "doctype_or_field": "DocField",
    "doc_type": "Task",
    "field_name": "subject",
    "property": "reqd",
    "property_type": "Check",
    "value": "1"
}).insert()
```

Use cases: hide a field, change a label, set a default, etc.

### Server Scripts

Run Python code on DocType events without writing a custom app:

- Desk → Server Script → New
- Select DocType and event (before_insert, validate, on_update, etc.)
- Write Python code in the script editor

Server Scripts are stored in `tabServer Script` and are evaluated at runtime. They're a quick way to add behavior without deploying code, but they have security implications — disable in production if not needed.

### Client Scripts

Same idea but for client-side JavaScript:

- Desk → Client Script → New
- Select DocType
- Write JS that runs on form events

### Form Scripts (deprecated)

Older alternative to Client Scripts. Defined as JS files in `apps/<app>/<app>/<module>/doctype/<doctype>/<doctype>.js`:

```javascript
frappe.ui.form.on("Task", {
    refresh: function(frm) {
        frm.add_custom_button("Click me", () => alert("Hi"));
    },
    priority: function(frm) {
        if (frm.doc.priority === "Urgent") {
            frm.set_value("due_date", frappe.datetime.add_days(frappe.datetime.get_today(), 1));
        }
    }
});
```

## Migrations and Patches

When you change a DocType's schema (add/remove fields), `bench migrate` applies the changes:

```bash
bench --site mysite.localhost migrate
```

This:
1. Syncs DocType JSON files to DB (creates/alters tables).
2. Runs any pending patches.
3. Rebuilds website cache.

### Writing a patch

For data migrations (not schema changes):

```python
# apps/myapp/myapp/patches/v1_0/migrate_task_status.py
import frappe

def execute():
    tasks = frappe.get_all("Task", filters={"status": "Done"}, pluck="name")
    for name in tasks:
        frappe.db.set_value("Task", name, "status", "Completed", update_modified=False)
```

Register in `apps/myapp/myapp/patches.txt`:

```
# app: myapp
v1_0.migrate_task_status
v1_0.add_default_priority
```

Or in `hooks.py`:

```python
patches = [
    "v1_0.migrate_task_status",
    "v1_0.add_default_priority"
]
```

Run patches:

```bash
bench --site mysite.localhost migrate
# or
bench --site mysite.localhost run-patch myapp.v1_0.migrate_task_status
```

### Pre/Post-migration hooks

```python
# hooks.py
before_migrate = "myapp.setup.before_migrate"
after_migrate = "myapp.setup.after_migrate"
```

Useful for clearing caches, sending notifications, etc.

This concludes the DocType guide. For more, see:
- Live docs: https://docs.frappe.io/framework/user/en/basics/doctypes
- API docs: https://docs.frappe.io/framework/user/en/api/document
- Tutorial: https://docs.frappe.io/framework/user/en/tutorial/create-a-doctype
