# Frappe Framework — Python API Reference

This is the comprehensive reference for server-side Python APIs in Frappe Framework. Use this when writing controller methods, hooks, server scripts, scheduled jobs, or any Python code that runs inside Frappe.

## Table of Contents

1. [Document Operations](#document-operations)
2. [Database Operations](#database-operations)
3. [Query Builder](#query-builder)
4. [Permissions](#permissions)
5. [Validation & Errors](#validation--errors)
6. [Caching](#caching)
7. [Background Jobs](#background-jobs)
8. [Email](#email)
9. [Files & Attachments](#files--attachments)
10. [User & Session](#user--session)
11. [Date/Time Utilities](#datetime-utilities)
12. [Translation](#translation)
13. [Rendering & Templates](#rendering--templates)
14. [HTTP Requests](#http-requests)
15. [Logging](#logging)
16. [Notifications & Realtime](#notifications--realtime)
17. [Miscellaneous Utilities](#miscellaneous-utilities)

## Document Operations

### `frappe.get_doc`

The most-used function in Frappe. Returns a `Document` object.

```python
# Fetch existing by name
doc = frappe.get_doc("Task", "TASK00001")

# Fetch a Single DocType (no name needed)
settings = frappe.get_doc("System Settings")
print(settings.timezone)

# Create new in-memory from dict
doc = frappe.get_doc({
    "doctype": "Task",
    "subject": "New task",
    "status": "Open",
    "items": [
        {"item_code": "ITEM001", "qty": 2}
    ]
})
doc.insert()

# Create new in-memory with kwargs
doc = frappe.get_doc(doctype="User", email_id="a@b.com", first_name="A")
doc.insert()
```

### `frappe.get_cached_doc`

Same as `get_doc` but checks the request-local cache first. Use it when you'll fetch the same doc multiple times in one request.

```python
# Subsequent calls within the same request return cached doc
doc = frappe.get_cached_doc("Task", "TASK00001")
```

Call `frappe.clear_cache()` or `doc.reload()` to force a fresh fetch.

### `frappe.new_doc`

Shorthand for `frappe.get_doc({"doctype": ...})`.

```python
doc = frappe.new_doc("Task")
doc.subject = "New"
doc.insert()
```

### `frappe.get_last_doc`

Returns the most recent document matching filters.

```python
last = frappe.get_last_doc("Task")
last = frappe.get_last_doc("Task", filters={"status": "Open"})
last = frappe.get_last_doc("Task", filters={"status": "Open"}, order_by="creation desc")
```

### `frappe.delete_doc`

Delete a document by name. Handles cascading deletes (comments, attachments, etc.).

```python
frappe.delete_doc("Task", "TASK00001")

# Delete multiple
for name in ["TASK00001", "TASK00002"]:
    frappe.delete_doc("Task", name)

# Force delete (skips validation hooks)
frappe.delete_doc("Task", "TASK00001", force=True)

# Delete with docstatus check
frappe.delete_doc("Task", "TASK00001", ignore_doctypes_on_cancel=True)
```

### `frappe.rename_doc`

Rename a document (changes primary key). Useful for cleaning up after merge.

```python
# Simple rename
frappe.rename_doc("Task", "TASK00001", "TASK00099")

# Merge: deletes old, moves references to existing new
frappe.rename_doc("Customer", "CUST-A", "CUST-B", merge=True)

# Show rename dialog (UI)
frappe.rename_doc("Task", "TASK00001", "TASK00099", show_dialog=True)
```

### `frappe.get_meta`

Returns the `Meta` object for a DocType (cached).

```python
meta = frappe.get_meta("Task")

# Check if field exists
if meta.has_field("priority"):
    ...

# Get field object
field = meta.get_field("priority")
print(field.options)  # e.g. "Low\nMedium\nHigh"

# Get list of fields with specific property
required_fields = meta.get_required_fields()
link_fields = meta.get_link_fields()

# Check permissions
if meta.has_permission("read"):
    ...
```

### Document methods

```python
doc = frappe.get_doc("Task", "TASK00001")

# Lifecycle
doc.insert()                  # create
doc.save()                    # update (runs validate + before_save + on_update)
doc.submit()                  # if submittable, submit (runs before_submit + on_submit)
doc.cancel()                  # cancel a submitted doc (runs before_cancel + on_cancel)
doc.delete()                  # delete (runs on_trash)
doc.rename("NEW-NAME")        # rename

# Reload from DB
doc.reload()

# Field access
doc.subject                   # attribute access
doc.get("subject")            # method access (handles None gracefully)
doc.update({"subject": "New", "status": "Closed"})  # bulk update

# Child table access
for item in doc.items:
    print(item.item_code, item.qty)

doc.append("items", {"item_code": "X", "qty": 1})  # add child
doc.remove(doc.items[0])                            # remove child

# Status
doc.is_new()                  # True if not yet inserted
doc.docstatus                 # 0 = draft, 1 = submitted, 2 = cancelled
doc.get_docstatus()           # same
doc.dirty()                   # has unsaved changes

# Permissions
doc.has_permission("read")    # check current user
doc.has_permission("write", user="a@b.com")
doc.check_permission("read")  # raise PermissionError if no

# Compare to DB
db_doc = doc.get_doc_before_save()
if doc.subject != db_doc.subject:
    frappe.msgprint("Subject changed")

# Run a controller method from JS
@frappe.whitelist()
def my_method(self, arg):
    return f"Hello {arg}"
# JS: frm.call("my_method", { arg: "world" })
```

## Database Operations

The `frappe.db` object is the database interface. Use it for raw reads; use `frappe.get_doc` for writes (to ensure hooks fire).

### Read single values

```python
# By name
subject = frappe.db.get_value("Task", "TASK00001", "subject")

# Multiple fields → returns tuple
name, subject = frappe.db.get_value("Task", "TASK00001", ["name", "subject"])

# As dict
task = frappe.db.get_value("Task", "TASK00001", ["name", "subject"], as_dict=True)

# With filters
name = frappe.db.get_value("Task", {"status": "Open", "priority": "High"}, "name")

# Cross-table filter (using dot notation)
name = frappe.db.get_value("Task", {"project.status": "Open"}, "name")
```

### Read multiple rows

```python
# get_list: respects permissions, returns dicts
tasks = frappe.db.get_list("Task",
    filters={"status": "Open"},
    fields=["name", "subject", "status"],
    order_by="creation desc",
    start=0,
    limit=20
)

# get_all: alias for get_list, defaults to no limit (returns all)
tasks = frappe.get_all("Task", filters={"status": "Open"}, fields=["*"])

# Pluck: returns list of single field values
names = frappe.db.get_list("Task", filters={"status": "Open"}, pluck="name")
# → ["TASK00001", "TASK00002", ...]
```

### Filter operators

Filters can be a dict, list of lists, or SQL string.

```python
# Dict filters (most common)
filters = {"status": "Open", "priority": ["in", ["High", "Medium"]]}

# List of lists (more flexible)
filters = [
    ["Task", "status", "=", "Open"],
    ["Task", "priority", "in", ["High", "Medium"]],
    ["Task", "creation", ">", "2024-01-01"]
]

# Or condition
filters = [
    ["Task", "status", "=", "Open"],
    ["Task", "status", "=", "Working"]
]
# Set "or": ... on the filter (only via Query Builder)

# Operators
# =, !=, >, <, >=, <=, in, not in, like, not like, is, is not,
# between, not between, timespan, previous, next
```

### `frappe.db.sql`

Escape hatch for raw SQL. Always use parameterized queries.

```python
# Simple query
results = frappe.db.sql("SELECT name, subject FROM tabTask WHERE status = %s", "Open")
# → list of tuples

# As dict
results = frappe.db.sql("SELECT name FROM tabTask WHERE status = %s", "Open", as_dict=True)

# As list of single values
results = frappe.db.sql("SELECT name FROM tabTask WHERE status = %s", "Open", as_list=True)
# → [["TASK00001"], ["TASK00002"], ...]

# Pluck (flat list)
results = frappe.db.sql("SELECT name FROM tabTask WHERE status = %s", "Open", as_list=True)
# vs
names = [r[0] for r in results]

# Multiple params
results = frappe.db.sql("""
    SELECT name FROM tabTask
    WHERE status = %s AND priority = %s
""", ("Open", "High"))

# IN clause (escape manually)
names = ["TASK00001", "TASK00002"]
placeholders = ", ".join(["%s"] * len(names))
results = frappe.db.sql(f"""
    SELECT name FROM tabTask
    WHERE name IN ({placeholders})
""", tuple(names))

# UPDATE / DELETE (then commit)
frappe.db.sql("UPDATE tabTask SET status = %s WHERE name = %s", ("Closed", "TASK00001"))
frappe.db.commit()  # required for non-ORM writes in scripts
```

### Writes

```python
# Update a single field
frappe.db.set_value("Task", "TASK00001", "status", "Closed")

# Update multiple fields
frappe.db.set_value("Task", "TASK00001", {
    "status": "Closed",
    "completed_on": frappe.utils.now()
})

# Skip modified/modified_by update
frappe.db.set_value("Task", "TASK00001", "status", "Closed", update_modified=False)

# Bulk update by filter
frappe.db.set_value("Task", {"status": "Open", "priority": "Low"}, "priority", "Medium")

# Insert directly (rare — usually use ORM)
frappe.db.insert({
    "doctype": "Task",
    "subject": "New"
})

# Bulk insert
frappe.db.bulk_insert("tabSomeTable",
    fields=["name", "subject"],
    values=[
        ["A001", "Task A"],
        ["A002", "Task B"]
    ]
)

# Delete
frappe.db.delete("Task", {"status": "Cancelled"})  # by filter
```

### Existence & count

```python
# Exists — returns the name if exists, else None
if frappe.db.exists("Task", "TASK00001"):
    ...

if frappe.db.exists("Task", {"status": "Open", "owner": "a@b.com"}):
    ...

# Count
count = frappe.db.count("Task", filters={"status": "Open"})

# Count with explicit SQL
count = frappe.db.sql("SELECT COUNT(*) FROM tabTask WHERE status = 'Open'")[0][0]
```

### Transactions

```python
# Commit (in scripts / background jobs)
frappe.db.commit()

# Rollback
frappe.db.rollback()

# Savepoint
savepoint = frappe.db.savepoint("before_change")
try:
    # risky operation
    ...
except Exception:
    frappe.db.rollback(save_point=savepoint)

# SQL transaction (auto-commits on success, rolls back on exception)
with frappe.db.transaction():
    # multiple writes
    ...
```

### Indexes

```python
# Add index (one-time, in setup hook)
frappe.db.add_index("Task", ["status", "priority"])

# Drop index
frappe.db.drop_index("Task", "status_priority")

# Show indexes
indexes = frappe.db.sql("SHOW INDEX FROM tabTask")
```

## Query Builder

Frappe includes a fluent query builder (uses SQLAlchemy under the hood). Useful for complex queries without writing raw SQL.

```python
from frappe.query_builder import DocType, Field

# Build a query
Task = DocType("Task")
q = (
    frappe.qb.from_(Task)
    .select(Task.name, Task.subject, Task.status)
    .where(Task.status == "Open")
    .where(Task.priority.isin(["High", "Medium"]))
    .orderby(Task.creation, order=frappe.qb.desc)
    .limit(10)
)
results = q.run(as_dict=True)

# Joins
Project = DocType("Project")
q = (
    frappe.qb.from_(Task)
    .join(Project)
    .on(Task.project == Project.name)
    .select(Task.name, Task.subject, Project.project_name)
    .where(Project.status == "Open")
)
results = q.run(as_dict=True)

# Aggregation
q = (
    frappe.qb.from_(Task)
    .select(Task.status, frappe.qb.count(Task.name).as_("count"))
    .groupby(Task.status)
)
results = q.run(as_dict=True)

# Insert / Update / Delete
q = (
    frappe.qb.into(Task)
    .insert("name", "subject", "status")
    .values("TASK00010", "Test", "Open")
)
q.run()

q = (
    frappe.qb.update(Task)
    .set(Task.status, "Closed")
    .where(Task.name == "TASK00001")
)
q.run()
```

## Permissions

### Check permission

```python
# DocType-level
frappe.has_permission("Task", "read")                       # current user
frappe.has_permission("Task", "write", user="a@b.com")     # specific user

# Document-level
frappe.has_permission("Task", "write", "TASK00001")

# Raise if not permitted
frappe.has_permission("Task", "write", throw=True)

# Get list of permitted doctypes for a user
doctypes = frappe.get_permitted_doctypes(user="a@b.com")
```

### Bypass permissions (rare, careful)

```python
# Per-call
doc.save(ignore_permissions=True)

# Per-block
frappe.flags.ignore_permissions = True
try:
    doc.save()
finally:
    frappe.flags.ignore_permissions = False
```

### Role checks

```python
roles = frappe.get_roles()  # current user
roles = frappe.get_roles("a@b.com")  # specific user

if "Sales Manager" in roles:
    ...

# System Manager is the admin role
if "System Manager" in roles:
    ...

# Check if user is the System User (the global admin user)
if frappe.session.user == "Administrator":
    ...
```

### Permission Query Conditions

For row-level security, define `get_permission_query_conditions` on the controller:

```python
class Task(Document):
    def get_permission_query_conditions(self, user):
        if not user:
            user = frappe.session.user
        if "System Manager" in frappe.get_roles(user):
            return ""  # see all
        return f"`tabTask`.`owner` = {frappe.db.escape(user)}"
```

## Validation & Errors

### Throw exceptions

```python
# Generic
frappe.throw("Subject is required")

# Specific exception types
frappe.throw("Not allowed", frappe.PermissionError)
frappe.throw("Duplicate name", frappe.DuplicateEntryError)
frappe.throw("Invalid value", frappe.ValidationError)
frappe.throw("Not found", frappe.DoesNotExistError)
frappe.throw("Cannot delete submitted doc", frappe.CancelledSubmitError)
frappe.throw("Timeout", frappe.TimeoutError)
frappe.throw("Rate limit", frappe.RateLimitError)

# With title
frappe.throw("Error", title="Validation Failed")

# With HTML message
frappe.throw(f"See <a href='/app/task/{name}'>the task</a>")
```

### Messages

```python
# Info message (continues execution)
frappe.msgprint("Saved successfully")

# With indicator (color)
frappe.msgprint("Done", indicator="green")
frappe.msgprint("Warning", indicator="orange")
frappe.msgprint("Error", indicator="red")

# As alert (auto-dismiss)
frappe.msgprint("Hello", as_table=True)  # render list as table
frappe.msgprint("Hello", raise_exception=frappe.ValidationError)  # also throw

# Realtime notification to all users
frappe.publish_realtime("msgprint", "Hello team", user="a@b.com")
```

### Logging

```python
# Error log (visible in Error Log list in Desk)
frappe.log_error("Custom error title")
frappe.log_error(message="Detailed error", title="Custom title")

# Capture exception with traceback
try:
    risky()
except Exception:
    frappe.log_error("Operation failed")

# Logger
logger = frappe.logger("myapp")
logger.info("Info message")
logger.warning("Warning")
logger.error("Error")
logger.debug("Debug")

# With structured data
logger.info("User logged in", extra={"user": "a@b.com", "ip": "1.2.3.4"})
```

## Caching

See `references/framework/architecture.md` → Caching Layer for details.

```python
frappe.cache().set_value("key", "value", expires_in_sec=3600)
frappe.cache().get_value("key")
frappe.cache().delete_value("key")

# Hash operations
frappe.cache().hset("tasks:status", "TASK00001", "Open")
frappe.cache().hget("tasks:status", "TASK00001")
frappe.cache().hgetall("tasks:status")
frappe.cache().hdel("tasks:status", "TASK00001")

# Incr/decr (atomic)
frappe.cache().incr("counter")
frappe.cache().decr("counter")

# Pattern delete
frappe.cache().delete_keys("tasks:*")
```

## Background Jobs

```python
# Enqueue
frappe.enqueue(
    "myapp.tasks.send_daily_report",
    queue="default",       # "default" | "short" | "long" | "cron"
    timeout=600,           # seconds
    now=False,             # if True, runs synchronously
    job_name="Daily report",
    user="admin@example.com",
    recipient="a@b.com"
)

# In the task function
# myapp/tasks.py
def send_daily_report(recipient):
    # setup is automatic — frappe.session.user is the enqueued user
    data = frappe.get_all("...")
    frappe.sendmail(recipients=[recipient], ...)

# Enqueue after commit (safe — won't enqueue if transaction rolls back)
frappe.enqueue_after_commit("myapp.tasks.do_work", **kwargs)

# Get job status
from frappe.core.doctype.background_job.background_job import get_info
jobs = get_info()
```

## Email

### Send email

```python
# Simple
frappe.sendmail(
    recipients=["a@b.com", "c@d.com"],
    subject="Hello",
    message="<p>This is a test</p>"
)

# With attachments
frappe.sendmail(
    recipients=["a@b.com"],
    subject="Report",
    message="See attached",
    attachments=[{
        "fname": "report.pdf",
        "fcontent": file_content_bytes
    }]
)

# With template (Jinja)
frappe.sendmail(
    recipients=["a@b.com"],
    subject="Welcome",
    template="welcome_email",  # in app/templates/emails/welcome_email.html
    args={"user_name": "Alice"},
    header=["Welcome", "green"]
)

# With delayed delivery
frappe.sendmail(
    recipients=["a@b.com"],
    subject="Reminder",
    message="...",
    send_after=frappe.utils.add_to_date(None, hours=2)
)

# Reference a document (creates Communication record)
doc = frappe.get_doc("Sales Invoice", "INV-001")
frappe.sendmail(
    recipients=["customer@example.com"],
    subject=f"Invoice {doc.name}",
    message="Please find attached",
    reference_doctype=doc.doctype,
    reference_name=doc.name
)
```

### Email queue

`frappe.sendmail` queues emails in `tabEmail Queue`. A scheduler job (every minute) sends them. To send immediately:

```python
frappe.sendmail(..., now=True)  # bypass queue
```

### Email templates

Defined as `Email Template` DocType records. Reference by name:

```python
template = frappe.get_doc("Email Template", "Welcome Email")
frappe.sendmail(
    recipients=[user.email],
    subject=template.subject,
    message=frappe.render_template(template.response, {"user": user})
)
```

## Files & Attachments

```python
from frappe.utils.file_manager import save_file

# Save file from raw content
file_doc = save_file(
    fname="report.pdf",
    fcontent=pdf_bytes,
    dt="Task",
    dn="TASK00001",
    is_private=1  # 1 = private (URL has hash), 0 = public
)
print(file_doc.file_url)  # /private/files/report_<hash>.pdf

# Save from uploaded file path
file_doc = save_file(
    fname="photo.jpg",
    fcontent=open("/tmp/photo.jpg", "rb").read(),
    dt="Task",
    dn="TASK00001"
)

# Get file content
file_doc = frappe.get_doc("File", "FILE-001")
content = file_doc.get_content()  # bytes

# Get attachments for a doc
attachments = frappe.get_all("File",
    filters={"attached_to_doctype": "Task", "attached_to_name": "TASK00001"},
    fields=["name", "file_name", "file_url"]
)

# Delete file
file_doc.delete()  # also removes from disk

# Download from URL
from frappe.utils.file_manager import save_url
file_doc = save_url("https://example.com/doc.pdf", "doc.pdf", "Task", "TASK00001")
```

## User & Session

```python
# Current user
user = frappe.session.user
full_name = frappe.utils.get_fullname(user)
user_email = frappe.get_value("User", user, "email")

# Session data
frappe.session.user              # email
frappe.session.full_name
frappe.session.sid               # session ID
frappe.session.site              # current site name
frappe.session.lang              # current language
frappe.session.csrf_token

# Switch user (impersonate, careful)
old_user = frappe.session.user
frappe.set_user("other@user.com")
# ... do work as other user ...
frappe.set_user(old_user)

# Get user permissions
from frappe.core.doctype.user_permission.user_permission import get_user_permissions
perms = get_user_permissions(user)

# Check user properties
user_doc = frappe.get_doc("User", user)
if user_doc.enabled:
    ...
if user_doc.user_type == "System User":
    ...

# User roles
roles = frappe.get_roles()
```

## Date/Time Utilities

All in `frappe.utils`.

```python
from frappe.utils import (
    now, nowdate, now_datetime, nowtime,
    getdate, get_datetime, get_time,
    add_days, add_months, add_years, add_to_date,
    date_diff, month_diff, time_diff,
    get_first_day, get_last_day,
    get_quarter_start, get_quarter_end,
    get_year_start, get_year_end,
    today, fmt_money
)

now()                    # "2024-08-07 10:30:00.123456"
nowdate()                # "2024-08-07"
now_datetime()           # datetime object
nowtime()                # "10:30:00"

getdate("2024-08-07")    # date(2024, 8, 7)
get_datetime("2024-08-07 10:30:00")  # datetime object

add_days("2024-08-07", 7)        # "2024-08-14"
add_days(today(), -30)           # 30 days ago
add_months("2024-08-07", 3)      # "2024-11-07"
add_years("2024-08-07", 1)       # "2025-08-07"
add_to_date("2024-08-07", days=1, months=1, years=1)  # "2025-09-08"

date_diff("2024-08-14", "2024-08-07")  # 7
month_diff("2024-12-07", "2024-01-07") # 11
time_diff("2024-08-07 12:00:00", "2024-08-07 10:00:00")  # 2 hours

get_first_day("2024-08-15")      # "2024-08-01"
get_last_day("2024-08-15")       # "2024-08-31"
get_quarter_start("2024-08-15")  # "2024-07-01"
get_quarter_end("2024-08-15")    # "2024-09-30"

today()                          # today's date string
fmt_money(1234.5, currency="USD")  # "$ 1,234.50"
```

### Timezone handling

```python
# Convert UTC datetime to user's timezone
frappe.utils.data.convert_utc_to_user_timezone(datetime_obj)

# Get user's timezone
tz = frappe.db.get_value("User", frappe.session.user, "time_zone")
# or from System Settings
tz = frappe.db.get_single_value("System Settings", "time_zone")

# Format datetime for display
frappe.utils.format_datetime(datetime_obj)  # uses user's format
```

## Translation

```python
# Translate
msg = frappe._("Hello")           # translates based on user's language
msg = frappe._("Hello", lang="ar")  # specific language

# Lazy translation (only translates when str()-ed)
msg = frappe._("Hello")  # already lazy by default

# Format with placeholders
msg = frappe._("Task {0} created").format("TASK001")

# Plural
count = 5
msg = frappe._("{0} task").format(count) if count == 1 else frappe._("{0} tasks").format(count)

# Get translations dict for a language
translations = frappe.get_lang_dict("ar")

# Reload translations
frappe.cache().delete_value("lang_<lang>")
```

## Rendering & Templates

### Jinja templates

```python
# Render a string
html = frappe.render_template("Hello {{ name }}", {"name": "Alice"})

# Render a file (relative to app's templates/ dir)
html = frappe.render_template("templates/emails/welcome.html", {"user": user_doc})

# Render with full context (auto-includes frappe, _, etc.)
html = frappe.render_template(template_string, context, is_path=False)
```

Available in Jinja context:
- `frappe` — the framework module
- `_` — translation function
- `frappe.utils` — utility functions
- `frappe.db` — database interface
- `frappe.session` — current session
- `now`, `today`, `fmt_money` — common utilities

### Email templates

```python
template = """
Hello {{ user.first_name }},

Your order {{ order.name }} has been confirmed.

Items:
{% for item in order.items %}
  - {{ item.item_code }}: {{ item.qty }} x {{ item.rate }}
{% endfor %}

Total: {{ order.grand_total }}
"""

html = frappe.render_template(template, {"user": user_doc, "order": order_doc})
```

### Print formats

```python
# Get a print format HTML
html = frappe.get_print("Sales Invoice", "INV-001", print_format="Standard")

# With custom print format
html = frappe.get_print("Sales Invoice", "INV-001", print_format="My Custom Format")

# As PDF
from frappe.utils.pdf import get_pdf
pdf_bytes = get_pdf(html)

# Send as email attachment
frappe.sendmail(
    recipients=["customer@example.com"],
    subject=f"Invoice {name}",
    message="See attached",
    attachments=[{"fname": "invoice.pdf", "fcontent": pdf_bytes}]
)
```

## HTTP Requests

For outgoing HTTP requests, use `requests` (already a dependency).

```python
import requests

# Simple GET
resp = requests.get("https://api.example.com/data")
data = resp.json()

# With auth
resp = requests.get(url, auth=(api_key, api_secret))

# With headers
resp = requests.post(url, json=payload, headers={"Authorization": "Bearer xxx"})

# With timeout (always set one!)
resp = requests.get(url, timeout=30)

# Frappe's wrapper (auto-retries, better error handling)
from frappe.integrations.utils import make_request
resp = make_request("GET", url, headers=headers)
```

## Logging

### Application log

```python
import logging
logger = frappe.logger("myapp")
logger.setLevel(logging.DEBUG)

logger.info("Info")
logger.warning("Warning")
logger.error("Error")
logger.exception("With traceback")  # logs traceback
```

### Error log (visible in Desk)

```python
frappe.log_error(title="My error")  # captures current exception
frappe.log_error(message="Specific message", title="My error")
```

### Where logs live

- `logs/frappe.log` — application log
- `logs/error.log` — unhandled exceptions
- `logs/web.log` — WSGI access log
- `logs/worker.log` — background job log
- `logs/schedule.log` — scheduler log
- `sites/<site>/logs/` — per-site logs

`tabError Log` — DB-backed error log accessible from Desk → search "Error Log".

## Notifications & Realtime

### In-app notifications

```python
# Create a notification record
notif = frappe.new_doc("Notification Log")
notif.subject = "Task completed"
notif.for_user = "user@example.com"
notif.document_type = "Task"
notif.document_name = "TASK00001"
notif.insert()

# Push to user in real-time
frappe.publish_realtime(
    event="notification",
    message={"subject": "Task completed"},
    user="user@example.com"
)
```

### Realtime events

```python
# Send to a user
frappe.publish_realtime(
    event="task_completed",
    message={"task": "TASK00001"},
    user="user@example.com"
)

# Send to all users viewing a doc
frappe.publish_realtime(
    event="doc_updated",
    message={"doctype": "Task", "name": "TASK00001"},
    doctype="Task",
    docname="TASK00001"
)

# Broadcast
frappe.publish_realtime(
    event="system_announcement",
    message={"text": "Maintenance soon"}
)
```

### Toast / alert (client side)

Triggered via `frappe.show_alert` in JS, but you can trigger from server:

```python
frappe.publish_realtime(
    event="show_alert",
    message="Task saved",
    user="user@example.com"
)
```

## Miscellaneous Utilities

### `frappe.utils`

```python
# Strings
frappe.utils.cint("123")        # 123 (int, safe)
frappe.utils.cstr(123)          # "123"
frappe.utils.cfloat("1.5")      # 1.5
frappe.utils.flt("1.234", 2)    # 1.23 (rounded to 2 decimals)
frappe.utils.cbool("true")      # True

# Money / numbers
frappe.utils.fmt_money(1234.56, currency="USD")  # "$ 1,234.56"
frappe.utils.fmt_money(1234.56, 2, "USD")        # same, explicit precision
frappe.utils.money_in_words(1234.56, "USD")      # "One Thousand Two Hundred..."

# Random
frappe.utils.random_string(10)   # "aBcDeFgHiJ"
frappe.utils.generate_hash()     # random hash
frappe.utils.generate_hash("Task", 10)  # deterministic

# URLs
frappe.utils.url_contains_hash(url)
frappe.utils.validate_url(url)
frappe.utils.get_url()           # site base URL, e.g. https://example.com
frappe.utils.get_url("/app/task/1")  # full URL

# Encoding
frappe.utils.encode_params({"a": "b"})  # "a=b"
frappe.utils.decode_params("a=b")       # {"a": "b"}

# Filesystem
frappe.utils.get_files_path()           # sites/<site>/public/files
frappe.utils.get_site_path()            # sites/<site>
frappe.utils.get_bench_path()           # parent of sites/

# Misc
frappe.utils.now()
frappe.utils.today()
frappe.utils.markdown(text)             # md → html
frappe.utils.sanitize_html(html)        # strip dangerous tags
frappe.utils.strip_html_tags(text)
```

### `frappe.flags`

A request-local scratch space. Use it to pass signals between hooks:

```python
# Set
frappe.flags.in_test = True
frappe.flags.ignore_permissions = True
frappe.flags.in_patch = True
frappe.flags.my_custom_flag = "value"

# Read
if frappe.flags.in_test:
    skip_email_sending()
```

### `frappe.enqueue` patterns

For long-running tasks, always enqueue:

```python
@frappe.whitelist()
def generate_report(name):
    # Enqueue instead of running synchronously
    frappe.enqueue(
        "myapp.reports.run_report",
        queue="long",
        timeout=600,
        report_name=name
    )
    return frappe._("Report generation started")
```

### Escaping

```python
# SQL escape (for raw queries with dynamic values)
safe_value = frappe.db.escape("user's input")
frappe.db.sql(f"SELECT * FROM tabTask WHERE name = {safe_value}")

# HTML escape (for templates)
from html import escape
escaped = escape(user_input)

# Strip HTML
text_only = frappe.utils.strip_html_tags(html_string)
```

This concludes the Python API reference. For specific APIs not covered here, check the live docs at `https://docs.frappe.io/framework/user/en/api/<topic>` — see `references/docs-index.md` for the URL map.
