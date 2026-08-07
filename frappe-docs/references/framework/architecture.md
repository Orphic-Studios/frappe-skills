# Frappe Framework — Architecture

This file covers the architectural foundations of Frappe Framework. Read it before writing any non-trivial Frappe code or designing a custom app.

## Table of Contents

1. [What is Frappe Framework](#what-is-frappe-framework)
2. [The Bench → App → Site Model](#the-bench--app--site-model)
3. [Directory Structure](#directory-structure)
4. [The DocType System](#the-doctype-system)
5. [Request Lifecycle](#request-lifecycle)
6. [Database Layer](#database-layer)
7. [Caching Layer](#caching-layer)
8. [Background Jobs](#background-jobs)
9. [Realtime Events](#realtime-events)
10. [Authentication & Sessions](#authentication--sessions)
11. [Asset Bundling](#asset-bundling)
12. [Hooks System](#hooks-system)
13. [WSGI & Production Server](#wsgi--production-server)

## What is Frappe Framework

Frappe Framework is a full-stack Python web framework optimized for building database-driven business applications. It is the foundation on which ERPNext, Frappe HR, Frappe CRM, and all other Frappe products are built. The framework provides:

- **Schema-as-data**: Database tables are described by DocType records (which themselves live in a database table). Adding a field does not require writing SQL or migration scripts.
- **Auto-generated UI**: List views, form views, and report views are generated from the DocType metadata. No HTML/CSS needed for basic CRUD.
- **REST API out of the box**: Every DocType gets REST endpoints automatically at `/api/resource/<doctype>`.
- **Role-based access control**: Permissions are declarative, defined per DocType per role.
- **Server-side Python + Client-side JavaScript**: Python runs in WSGI workers; JS runs in the browser and calls back via `frappe.call`.
- **Background workers**: Long-running tasks are queued to Redis and processed by `bench worker`.
- **Realtime**: WebSocket-based notifications via Socket.io.
- **Web views**: Optional portal pages and Web Forms for non-Desk users.

The framework is opinionated about conventions: singular DocType names, `tab`-prefixed tables, snake_case fieldnames, lower_case module paths. Following these conventions unlocks all the auto-magic.

## The Bench → App → Site Model

Frappe uses a three-tier container model:

```
bench/                          ← "bench" = a deployable unit
├── apps/                       ← code repositories (git clones)
│   ├── frappe/
│   ├── erpnext/
│   └── my_custom_app/
├── sites/                      ← databases + per-site config
│   ├── currentsite.text        ← pointer to the active site
│   ├── site1.localhost/
│   │   ├── site_config.json    ← DB credentials, site settings
│   │   ├── private/files/      ← user-uploaded private files
│   │   ├── public/files/       ← user-uploaded public files
│   │   ├── locks/              ← advisory locks
│   │   └── logs/               ← per-site logs
│   └── site2.localhost/
├── config/                     ← bench-level config (redis, supervisor, nginx)
├── env/                        ← Python virtualenv
├── logs/                       ← bench-level logs
└── node_modules/               ← JS dependencies
```

**Bench** = the runtime environment. Holds the virtualenv, apps, and sites. One bench can host multiple sites, and each site can have its own installed set of apps.

**App** = a Python package providing DocTypes, controllers, hooks, and assets. Installed via `bench get-app <git_url>` and `bench --site X install-app <app_name>`. Apps are shared across all sites in the bench; sites decide which apps to install.

**Site** = a single database + per-site configuration + file storage. Sites are isolated from each other. Switching the active site is done with `bench use <site>` or `--site <name>` flag.

### Common bench commands

```bash
bench init mybench               # create a new bench
cd mybench
bench get-app https://github.com/frappe/erpnext
bench new-site mysite.localhost
bench --site mysite.localhost install-app erpnext
bench --site mysite.localhost install-app my_custom_app
bench start                      # dev server on port 8000
bench use mysite.localhost       # set default site
```

### Multi-site considerations

- Each site has its own DB, but apps are shared at the bench level.
- Site config (`site_config.json`) holds per-site secrets (DB password, mail credentials, etc.).
- The `Host` header in HTTP requests determines which site handles the request.
- Background jobs are per-site (the worker reads the site from the job metadata).

## Directory Structure

### Bench directory

Shown above — `apps/`, `sites/`, `config/`, `env/`, `logs/`, `node_modules/`.

### App directory (inside `apps/<app_name>/`)

```
my_app/
├── my_app/                     ← Python package
│   ├── __init__.py
│   ├── hooks.py                ← the central hook configuration file
│   ├── modules.txt             ← declared modules (used by module def)
│   ├── patches.txt             ← data migrations
│   ├── tasks.py                ← celery tasks (optional)
│   ├── overrides/              ← override framework / ERPNext classes
│   ├── templates/
│   │   ├── pages/              ← portal pages (.html + .py)
│   │   └── includes/           ← Jinja includes
│   └── <module>/               ← one folder per module (Accounts, Stock, etc.)
│       ├── __init__.py
│       ├── doctype/            ← DocType definitions
│       │   └── <doctype_name>/
│       │       ├── __init__.py
│       │       ├── <doctype_name>.py          ← controller class
│       │       ├── <doctype_name>.json        ← DocType schema (fields, perms)
│       │       └── <doctype_name>.js          ← (optional) form script
│       ├── print_format/       ← print format templates
│       ├── report/             ← script reports
│       └── page/               ← custom Desk pages
├── setup.py                     ← Python package metadata
├── pyproject.toml
├── package.json                 ← JS dependencies
├── yarn.lock
└── README.md
```

### DocType folder

Each DocType lives in `my_app/my_app/<module>/doctype/<doctype_name_lower_camel>/<doctype_name_lower_camel>.{py,json,js}`. The folder name is the doctype name converted to lowercase with underscores, e.g. `Task` → `task`, `SalesOrder` → `sales_order`.

The `<doctype_name>.json` file is the schema. The `<doctype_name>.py` file contains the controller class (subclass of `frappe.model.document.Document`).

### Site directory

```
sites/<site_name>/
├── site_config.json            ← DB credentials, host_name, mail settings
├── private/
│   ├── files/                  ← private attachments
│   └── backups/                ← site backups
├── public/files/               ← public attachments
├── assets/                     ← symlinked from apps/ at deploy time
└── logs/
    ├── web.log                 ← WSGI access log
    ├── worker.log              ← background job log
    ├── schedule.log            ← cron-like scheduler log
    ├── frappe.log              ← application log
    └── error.log               ← unhandled exceptions
```

## The DocType System

A DocType is the schema for a kind of document. It defines:

- **Fields**: each field has a `fieldname`, `fieldtype`, `label`, `options`, and many meta-fields (hidden, read_only, depends_on, etc.).
- **Naming**: how new documents get their `name` (primary key). Options: by field, by series (e.g. `TASK-.#####`), by set_by_user, or auto-generated hash.
- **Permissions**: which roles can read/write/create/delete/submit/cancel/amend.
- **Controllers**: Python class with hooks (`validate`, `before_save`, `on_update`, `on_submit`, `on_cancel`, `on_trash`).
- **Views**: list view settings, form layout, default sort, etc.
- **Is Submittable**: whether the doctype supports a workflow with draft → submitted → cancelled states.
- **Is Tree**: whether the doctype has a parent-child tree structure (e.g. Chart of Accounts).
- **Module**: which module the doctype belongs to (modules are top-level organizational units).

### How DocTypes map to the database

- A Standard DocType (e.g. `Task`) creates a table `tabTask`.
- Fields become columns in that table. The mapping of `fieldtype` → SQL type:
  - `Data` → `varchar(140)` (or longer if `length` is set)
  - `Int` → `int`
  - `Float` → `decimal(21,9)`
  - `Currency` → `decimal(21,9)`
  - `Date` → `date`
  - `Datetime` → `datetime(6)`
  - `Text`, `Long Text`, `Small Text` → `text`
  - `Code` → `longtext`
  - `Link` → `varchar(140)` (foreign key reference, but no actual FK constraint)
  - `Table` (child) → does not create a column; instead, child records are stored in a separate table named `tab<child_doctype>`
  - `Attach`, `Attach Image` → `text` (stores a file URL)
  - `Select` → `varchar(140)`
  - `Check` → `int`
  - `Section Break`, `Column Break`, `Tab Break` → no column (UI only)
  - `HTML` → no column (renders custom HTML in form)
  - `Button` → no column (renders a button)
  - `Read Only` → `varchar(...)` or computed display

- The metadata about fields itself lives in `tabDocField`. That's why adding a field is just inserting a row in `tabDocField` (and `bench migrate` adds the column to the target table).
- Permissions live in `tabCustom Role` (a child of DocRole on the DocType).

### DocType JSON structure (simplified)

```json
{
  "doctype": "DocType",
  "name": "Task",
  "module": "Tasks",
  "naming_rule": "Expression",
  "autoname": "hash",
  "is_submittable": 0,
  "fields": [
    {
      "fieldname": "subject",
      "fieldtype": "Data",
      "label": "Subject",
      "reqd": 1,
      "in_list_view": 1
    },
    {
      "fieldname": "status",
      "fieldtype": "Select",
      "label": "Status",
      "options": "Open\nWorking\nCompleted\nCancelled",
      "default": "Open"
    },
    {
      "fieldname": "items",
      "fieldtype": "Table",
      "label": "Items",
      "options": "Task Item"
    }
  ],
  "permissions": [
    {
      "role": "All",
      "read": 1,
      "write": 1,
      "create": 1,
      "delete": 1
    }
  ]
}
```

### Controller class

```python
# my_app/tasks/doctype/task/task.py
import frappe
from frappe.model.document import Document

class Task(Document):
    # ====== Lifecycle hooks ======
    def validate(self):
        # runs on every save (before write to DB)
        if not self.subject:
            frappe.throw("Subject is required")

    def before_save(self):
        # runs after validate, before DB write
        self.title = self.subject[:140]

    def before_insert(self):
        # runs only on creation, before validate
        pass

    def on_update(self):
        # runs after DB write
        frappe.sendmail(recipients=[self.owner], subject=f"Task {self.name} updated",
                        message=f"Status: {self.status}")

    def on_submit(self):
        # runs when submittable DocType is submitted
        pass

    def on_cancel(self):
        # runs when submittable DocType is cancelled
        pass

    def on_trash(self):
        # runs before delete
        pass

    # ====== Custom methods ======
    @frappe.whitelist()
    def mark_complete(self):
        self.status = "Completed"
        self.save()
        return "ok"

    # ====== Permissions hook ======
    def get_permission_query_conditions(self, user=None):
        # return a SQL fragment to filter list view
        if not user:
            user = frappe.session.user
        return f"`tabTask`.`owner` = '{user}'"

    def has_permission(self, ptype="read", user=None, verbose=False):
        # return True/False to allow/deny a specific action
        return True
```

### Types of DocType

| Type | Description | Example |
|---|---|---|
| **Standard** | Regular table-backed doctype | `Task`, `Customer` |
| **Single** | Singleton (only one record) | `System Settings`, `Stock Settings` |
| **Child** | Sub-record attached to a parent via Table field | `Sales Invoice Item` |
| **Tree** | Hierarchical records with parent/children | `Account`, `Warehouse` |
| **Virtual** | No DB table; data from external source via controller | Custom API-backed doctypes |

## Request Lifecycle

A typical HTTP request goes through these stages:

1. **Web server** (nginx/gunicorn) receives the request and routes to the WSGI app.
2. **WSGI app** reads the `Host` header to determine which site to serve. If the host doesn't match any site, returns 404.
3. **Site context** is set up: DB connection opened, `frappe.local.site` set, site config loaded into `frappe.conf`.
4. **Authentication middleware** reads the session cookie or `Authorization` header and populates `frappe.session.user`. If no auth, the user is `Guest`.
5. **CSRF check** for POST/PUT/DELETE requests.
6. **URL routing**:
   - `/api/method/<path>` → calls the whitelisted Python function at that dotted path.
   - `/api/resource/<doctype>[/<name>]` → REST CRUD on the DocType.
   - `/app/<doctype>` → Desk list view (HTML).
   - `/app/<doctype>/<name>` → Desk form view (HTML).
   - `/<page_name>` → custom Desk Page.
   - `/<route>` → portal page (if matched by a Web Route).
7. **Method execution**: the matched handler runs. Database writes are buffered; only committed if no exception.
8. **Response**: JSON for API calls, HTML for web views. `frappe.response` accumulates data; `frappe.build_response` serializes.
9. **Cleanup**: DB connection returned to pool, request-local cache cleared, transaction committed or rolled back.

### Transactions

- Each request is wrapped in a single DB transaction.
- `frappe.db.commit()` is called automatically at the end of successful requests.
- `frappe.db.rollback()` is called if any exception bubbles up.
- In background jobs (Celery workers), you must call `frappe.db.commit()` manually because the request lifecycle doesn't apply.
- In scripts (bench console, hooks), you also manage transactions manually.

## Database Layer

Frappe supports both **MariaDB** (default, recommended) and **PostgreSQL**. The ORM abstracts away differences, but raw SQL may need adjustment for portability.

### Connection setup

- `frappe.db` is the global database interface. It's a `Database` instance bound to the current site.
- Connection details come from `site_config.json`:
  ```json
  {
    "db_name": "site1_abc",
    "db_user": "site1_abc",
    "db_password": "secret",
    "db_type": "mariadb",     // or "postgres"
    "db_host": "127.0.0.1",
    "db_port": 3306
  }
  ```

### Reading data

```python
# Get a single value
subject = frappe.db.get_value("Task", "TASK00001", "subject")
subject, status = frappe.db.get_value("Task", "TASK00001", ["subject", "status"])

# Get with filters
name = frappe.db.get_value("Task", {"status": "Open", "priority": "High"}, "name")

# Get a dict
task = frappe.db.get_value("Task", "TASK00001", ["name", "subject", "status"], as_dict=True)

# Get multiple rows
tasks = frappe.db.get_list("Task",
    filters={"status": "Open"},
    fields=["name", "subject", "status"],
    order_by="creation desc",
    limit=10,
    start=0
)

# Count
count = frappe.db.count("Task", filters={"status": "Open"})

# Exists
exists = frappe.db.exists("Task", "TASK00001")  # returns name or None
exists = frappe.db.exists("Task", {"status": "Open", "owner": "a@b.com"})

# Raw SQL (use parameterized)
results = frappe.db.sql("""
    SELECT name, subject
    FROM tabTask
    WHERE status = %s AND owner = %s
    ORDER BY creation DESC
    LIMIT 10
""", ("Open", "a@b.com"), as_dict=True)
```

### Writing data

```python
# Update a single field
frappe.db.set_value("Task", "TASK00001", "status", "Closed")

# Update multiple fields
frappe.db.set_value("Task", "TASK00001", {"status": "Closed", "completed_on": today()})

# Bypass timestamps (use sparingly)
frappe.db.set_value("Task", "TASK00001", "status", "Closed", update_modified=False)

# Insert via ORM (preferred)
doc = frappe.new_doc("Task")
doc.subject = "New task"
doc.insert()

# Bulk insert (faster than per-doc insert)
frappe.db.bulk_insert("tabTask", fields=["name", "subject"], values=[["TASK00010", "A"], ["TASK00011", "B"]])
```

### SQL execution rules

- **Always** use `%s` placeholders with parameters. Never f-string or `%` format user input into SQL — SQL injection risk.
- For `IN (...)` queries, use `frappe.db.escape` to safely inline lists:
  ```python
  names = ["TASK00001", "TASK00002"]
  frappe.db.sql(f"""
      SELECT * FROM tabTask
      WHERE name IN ({", ".join(f"{frappe.db.escape(n)}" for n in names)})
  """)
  ```
- `as_dict=True` returns list of dicts; `as_list=True` returns list of tuples; default returns list of tuples.

### Indexes

- Frappe auto-creates indexes on `name` (primary key), `parent` (for child tables), `creation`, `modified`, `modified_by`, `owner`, `docstatus`, and `_user_tags`.
- For custom indexes, add them in the `custom_index` field of `tabDocField` or via a migration patch.
- For high-volume DocTypes (e.g. `tabGL Entry`), Frappe adds extra indexes on common filter columns.

## Caching Layer

Frappe uses **Redis** for caching, queues, and realtime events.

### Cache interface

```python
# String values
frappe.cache().set_value("my_key", "my_value", expires_in_sec=3600)
val = frappe.cache().get_value("my_key")

# Hash values
frappe.cache().hset("tasks:status", "TASK00001", "Open")
val = frappe.cache().hget("tasks:status", "TASK00001")
frappe.cache().hdel("tasks:status", "TASK00001")

# Lists
frappe.cache().lpush("queue:tasks", "task_id_1")
val = frappe.cache().rpop("queue:tasks")

# Sets
frappe.cache().sadd("active_users", "user@example.com")
is_active = frappe.cache().sismember("active_users", "user@example.com")

# Delete
frappe.cache().delete_value("my_key")

# Clear all (careful!)
frappe.cache().delete_keys("tasks:*")

# Increment
frappe.cache().incr("counter:page_views")
```

### Cache namespaces

- `frappe.cache()` returns a `RedisWrapper` that prefixes keys with the site name automatically. So `set_value("foo", ...)` on site A doesn't collide with site B.
- Use `frappe.cache().make_method_path("myapp", "mymodule", "key")` to namespace by app.
- Cross-site cache (rare): `frappe.cache().get_redis_connection()` bypasses the wrapper.

### What to cache

- **Expensive computed values** (e.g. dashboard aggregations, search indexes).
- **Session-scoped user preferences** (with a TTL).
- **Pre-computed reports** that don't change often.
- **Don't cache** anything that requires up-to-the-second accuracy (e.g. document status).

## Background Jobs

Use `frappe.enqueue` for any task that:
- Takes more than ~5 seconds.
- Makes external HTTP calls.
- Sends emails to many recipients.
- Processes large data files.

```python
# Enqueue a function
frappe.enqueue(
    "myapp.tasks.send_daily_report",
    queue="default",          # or "short", "long", "cron"
    timeout=600,              # seconds
    now=False,                # if True, runs synchronously
    job_name="Daily report",
    user="admin@example.com",  # run as this user
    **kwargs                   # passed to the function
)

# The function itself
# myapp/tasks.py
def send_daily_report(recipient):
    doc = frappe.get_doc(...)
    frappe.sendmail(recipients=[recipient], ...)
```

### Queues

Frappe defines 4 queues by default:
- `default` — general tasks (timeout < 300s)
- `short` — quick tasks (timeout < 5min)
- `long` — long-running tasks (timeout up to 30min)
- `cron` — scheduled jobs

Each queue is consumed by a separate `bench worker` process. Configure worker counts in `common_site_config.json`:

```json
{
  "workers": {
    "default": 1,
    "short": 2,
    "long": 1
  }
}
```

### Scheduled jobs

Defined in `hooks.py`:

```python
scheduler_events = {
    "all": [
        "myapp.tasks.cleanup"
    ],
    "hourly": [
        "myapp.tasks.hourly_sync"
    ],
    "daily": [
        "myapp.tasks.daily_report"
    ],
    "weekly": [
        "myapp.tasks.weekly_backup"
    ],
    "monthly": [
        "myapp.tasks.monthly_close"
    ],
    "cron": {
        "*/15 * * * *": [
            "myapp.tasks.fifteen_min_check"
        ],
        "0 9 * * 1": [
            "myapp.tasks.monday_morning"
        ]
    }
}
```

## Realtime Events

Frappe uses Socket.io for realtime notifications from server to client.

```python
# Emit to a specific user
frappe.publish_realtime(
    event="task_completed",
    message={"task": "TASK00001"},
    user="user@example.com"
)

# Emit to all users viewing a doctype
frappe.publish_realtime(
    event="doc_updated",
    message={"doctype": "Task", "name": "TASK00001"},
    doctype="Task",
    docname="TASK00001"
)

# Emit to all users (broadcast)
frappe.publish_realtime(
    event="system_announcement",
    message={"text": "Maintenance in 10 min"}
)
```

On the client:

```javascript
frappe.realtime.on("task_completed", (data) => {
    frappe.show_alert(`Task ${data.task} completed`);
});
```

The Socket.io server runs on port 9000 (default). In production, nginx proxies `/socket.io` to it.

## Authentication & Sessions

### Three auth mechanisms

1. **Session-based (cookie)** — default for Desk and portal. After `/login`, a session cookie is set. `frappe.session.user` is populated from the cookie.
2. **Token-based (API key/secret)** — for REST API. Generate from User → Settings → API Access. Pass `Authorization: token api_key:api_secret` header.
3. **OAuth2 access token** — for third-party apps. Configure OAuth client in `OAuth Client` doctype. Pass `Authorization: Bearer access_token` header.

### Login flow

```python
# Programmatic login (rare in production, useful for tests)
frappe.local.login_manager.login(user_id="user@example.com", password="...")
frappe.local.login_manager.login_as("user@example.com")  # bypass password
```

### Permission checks

```python
# Check current user's permission
frappe.has_permission("Task", "read")                # current user
frappe.has_permission("Task", "write", "TASK00001")  # for a specific doc
frappe.has_permission("Task", "create", user="a@b.com")

# Bypass permissions (use carefully)
with frappe.flags.ignore_permissions = True:
    doc.save()

frappe.flags.ignore_permissions = True
try:
    doc.save()
finally:
    frappe.flags.ignore_permissions = False

# Or per-call
doc.save(ignore_permissions=True)
```

### Roles

```python
# Get user's roles
roles = frappe.get_roles()

# Check if user has a role
if "Sales Manager" in frappe.get_roles():
    ...

# Check if user has any of a set of roles
if frappe.utils.has_common(frappe.get_roles(), ["Sales Manager", "Sales User"]):
    ...
```

## Asset Bundling

Frappe bundles JS/CSS using Webpack (via `bench build`).

### App-level assets

```
my_app/public/
├── js/
│   ├── my_app.js              ← main bundle entry
│   └── custom.js
├── css/
│   └── my_app.css
└── dist/                      ← generated bundles
```

### Declaring bundles in hooks.py

```python
# hooks.py
app_include_js = "/assets/my_app/js/my_app.js"
app_include_css = "/assets/my_app/css/my_app.css"

# DocType-specific (only loaded on that doctype's form)
doctype_js = {
    "Task": "public/js/task_custom.js",
    "Customer": "public/js/customer_custom.js"
}

doctype_list_js = {
    "Task": "public/js/task_list_custom.js"
}
```

### Building

```bash
bench build                      # build all apps
bench build --app my_app         # build one app
bench watch                      # rebuild on file change (dev mode)
```

## Hooks System

`hooks.py` is the central configuration file for an app. Frappe reads it on startup to wire up:

- **Event handlers** (`doc_events`, `boot_session`, `before_save`)
- **Scheduled jobs** (`scheduler_events`)
- **URL routes** (`override_whitelisted_methods`, `website_route_rules`)
- **Asset bundles** (`app_include_js`, `doctype_js`)
- **Page redirects** (`update_website_context`)
- **Email hooks** (`email_conflict_message`)

### Most-used hooks

```python
# hooks.py

# DocEvents: hook into any DocType's lifecycle
doc_events = {
    "*": {                              # all doctypes
        "on_update": "myapp.utils.log_changes"
    },
    "Sales Order": {
        "on_submit": "myapp.orders.handle_so_submit",
        "on_cancel": "myapp.orders.handle_so_cancel",
        "validate": "myapp.orders.validate_so"
    }
}

# Boot session: inject data into /api/method/frappe.boot.get_bootinfo
boot_session = "myapp.boot.get_boot_info"

# Whitelisted method overrides
override_whitelisted_methods = {
    "frappe.client.get": "myapp.custom_client.get"
}

# Website context (for portal pages)
website_route_rules = [
    {"from_route": "/old-path", "to_route": "new-page"}
]

update_website_context = "myapp.website.update_context"

# Scheduled jobs
scheduler_events = {
    "daily": ["myapp.tasks.daily_cleanup"],
    "cron": {"0 * * * *": ["myapp.tasks.hourly"]}
}

# Fixture data (exported on each migrate)
fixtures = ["Custom Field", "Property Setter", {"dt": "Print Format", "filters": [["standard", "Yes"]]}]

# App install hooks
after_install = "myapp.setup.after_install"
before_uninstall = "myapp.setup.before_uninstall"
after_migrate = "myapp.setup.after_migrate"

# Required apps (this app requires these to be installed first)
required_apps = ["erpnext"]
```

## WSGI & Production Server

In production, Frappe runs under:

- **gunicorn** (WSGI server) — handles HTTP requests
- **celery** workers — background jobs
- **celery beat** — scheduler
- **Socket.io** — realtime
- **redis** — cache + queue
- **mariadb** or **postgres** — database
- **nginx** — reverse proxy, serves static files

`bench setup production` generates:

- `/etc/nginx/conf.d/frappe-bench.conf` — nginx config
- `/etc/supervisor/conf.d/frappe-bench.conf` — supervisor config (manages gunicorn + workers)
- systemd timer for `bench schedule` (the beat process)

### Production checks

- Run `bench setup production <user>` to switch from dev to production mode.
- Run `bench setup lets-encrypt <site>` to install SSL via certbot.
- Run `bench setup backends` to regenerate supervisor configs.
- Run `bench setup manager` to install the bench manager UI.
- Always run `bench update --pull --patch --build --backup` after pulling new code.

### Common production issues

- **502 Bad Gateway**: gunicorn died → check `logs/web.log` and `logs/supervisor.log`.
- **504 Timeout**: request took too long → either increase gunicorn timeout (`common_site_config.json` → `gunicorn_workers`, `gunicorn_timeout`) or move work to background job.
- **Stuck migrations**: another `bench migrate` is running → check `sites/<site>/locks/`.
- **Permission errors**: file ownership wrong → `bench fix-perms`.
