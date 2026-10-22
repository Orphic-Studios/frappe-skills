---
name: "frappe-docs"
description: "Comprehensive knowledge of the entire Frappe/ERPNext ecosystem (Frappe Framework, ERPNext, Frappe HR, CRM, Cloud, Builder, Insights, Print Designer, Wiki, Drive, Learning, Helpdesk). Use this skill whenever the user mentions Frappe, ERPNext, bench commands, DocType, frappe.get_doc, frappe.whitelist, frappe.call, frappe.db.sql, ERPNext modules (Accounts/Stock/Selling/Buying/Manufacturing/HR/Projects/Payroll), Web Forms, Server Scripts, Client Scripts, hooks.py, Print Formats, Workflows, Custom Fields, REST API of Frappe/ERPNext, or any task involving installation, customization, troubleshooting, code generation, or configuration of Frappe-based systems. Also use it when the user asks 'how to' do anything in ERPNext or Frappe Framework, when they hit errors mentioning 'frappe', 'bench', 'doctype', 'tabDocType', 'ValidationError', 'PermissionError', or when they need to write server/client scripts, REST endpoints, or build custom apps on top of Frappe."
---

# Frappe & ERPNext Knowledge Skill

This skill gives you comprehensive working knowledge of the Frappe ecosystem — a full-stack Python/JavaScript web framework and the ERPNext business suite built on top of it. It covers architecture, APIs, code patterns, customization, deployment, and troubleshooting for **all** Frappe products.

## How to Use This Skill

This skill is a **hybrid knowledge base**. Three layers of information, in order of cost:

1. **This SKILL.md** — Always in context. Use it as a router: pick the right reference file or fetch path before doing anything else. Contains the core mental model, decision trees, and a cheatsheet of the most-used APIs.
2. **`references/*.md`** — Loaded on demand. Each file is a deep dive on one domain (framework architecture, ERPNext accounts, REST API, etc.). Read the relevant one before answering deep technical questions or generating non-trivial code.
3. **Live docs at `https://docs.frappe.io/`** — Fetched on demand via web-reader. Use this for the very latest API signatures, version-specific behavior, or edge-case details not covered in the reference files. The reference file `references/docs-index.md` contains a complete URL map.

When in doubt about whether the reference files have enough detail, **fetch the live page** — Frappe ships fast and minor API details drift between versions.

## The Frappe Ecosystem (Mental Model)

```
Frappe Framework          ← the meta-framework (Python + MariaDB + Redis + Node)
   ├── ERPNext            ← full ERP (Accounts, Stock, Selling, Buying, Manufacturing, HR, Projects, CRM)
   ├── Frappe HR          ← standalone HRMS (also bundled inside ERPNext)
   ├── Frappe CRM         ← standalone CRM
   ├── Frappe Helpdesk    ← ticketing
   ├── Frappe Learning    ← LMS
   ├── Frappe Drive       ← file sharing (Nextcloud-style)
   ├── Frappe Insights    ← BI / analytics
   ├── Frappe Builder     ← no-code page builder
   ├── Frappe Print Designer ← drag-drop print format builder
   ├── Frappe Wiki        ← wiki / knowledge base
   ├── Frappe Cloud       ← managed hosting marketplace
   ├── Frappe Lending     ← loan management
   ├── Frappe Studio      ← visual app builder (in development)
   └── Frappe Gantt       ← Gantt chart component
```

**Key relationships:**
- Everything is built **on top of Frappe Framework** — understanding the Framework unlocks everything else.
- ERPNext is the largest app and bundles several others (HR, CRM, Projects, etc.) as modules.
- The standalone apps (Frappe HR, Frappe CRM, etc.) can run independently and are slimmed-down versions of ERPNext modules.

## Decision Tree: Where to Look First

```
What does the user want?
│
├─ Understand a concept / "how does X work?"
│   ├─ Framework concept (DocType, ORM, hooks, web form) → references/framework/architecture.md
│   ├─ ERPNext module (Accounts, Stock, etc.)           → references/erpnext/<module>.md
│   └─ Specific Frappe app (HR, CRM, Builder, etc.)     → references/apps/ecosystem.md
│
├─ Write code
│   ├─ Python server-side (frappe.get_doc, frappe.db)   → references/framework/python-api.md
│   ├─ JS client-side (frappe.call, frappe.ui)          → references/framework/scripting.md
│   ├─ REST API client (curl, fetch, requests)          → references/framework/rest-api.md
│   ├─ New DocType + controller                          → references/framework/doctype-guide.md
│   ├─ Server/Client Script in Desk                      → references/framework/scripting.md
│   ├─ hooks.py, app structure                           → references/framework/architecture.md
│   └─ Custom report / print format / workflow           → references/erpnext/customization.md
│
├─ Configure / install / deploy
│   ├─ bench commands (init, migrate, backup)            → references/framework/bench-cli.md
│   ├─ Production setup (Docker, nginx, supervisor)      → references/framework/webviews-deployment.md
│   ├─ ERPNext setup wizard, company, users              → references/erpnext/overview.md
│   └─ Module-specific config (e.g. chart of accounts)   → references/erpnext/<module>.md
│
├─ Customize / extend
│   ├─ Add a field to existing DocType                   → references/erpnext/customization.md
│   ├─ Change form behavior (Client Script)              → references/framework/scripting.md
│   ├─ Server-side validation (Server Script / hook)     → references/framework/scripting.md + doctype-guide.md
│   ├─ Workflow (state transitions)                      → references/erpnext/customization.md
│   └─ Print format (HTML/Jinja)                         → references/erpnext/customization.md
│
├─ Troubleshoot / debug
│   ├─ bench migrate error, permission error             → references/troubleshooting.md
│   ├─ Performance issue (slow query, slow page)         → references/troubleshooting.md
│   ├─ "frappe.exceptions.X" error                       → references/troubleshooting.md
│   └─ Need to read logs                                 → references/troubleshooting.md
│
└─ Need the very latest / version-specific docs?
    └─ Fetch live from https://docs.frappe.io/...
       URL map: references/docs-index.md
```

## When to Fetch Live Documentation

Fetch live docs via web-reader when **any** of these are true:

- The user names a specific Frappe version (e.g. "in v15, how does...") — version-specific behavior changes.
- The reference file says "see docs for full signature" — some APIs have many optional kwargs.
- The user is asking about a brand-new feature (Frappe ships monthly).
- The user asks "what's the current recommended way to..." — the framework evolves.
- You're not 100% sure of an API name or argument order — better to verify than guess.

**How to fetch:** Use the `page_reader` function (z-ai CLI: `z-ai function -n page_reader -a '{"url": "..."}'`). The base URL is `https://docs.frappe.io/<product>/<path>`. See `references/docs-index.md` for the full URL map.

## Core Mental Model (Always in Context)

These are the things you must internalize before writing any Frappe code:

### 1. DocType is the atom

Everything in Frappe is a **DocType** (a model definition) and a **Document** (an instance of that model). A DocType is itself stored as a Document in the `tabDocType` table — this self-referential design is what makes Frappe dynamically configurable from the Desk UI.

- DocType names are **always singular** (e.g. `Customer`, not `Customers`).
- The DB table is prefixed with `tab` → `tabCustomer`.
- Fields are defined as rows in `tabDocField`, not as columns (this is why adding a field doesn't require a migration).
- A DocType can be a **Standard DocType** (defined in app code as JSON), a **Custom DocType** (created in Desk), or a **Single DocType** (singleton like `System Settings`).
- **Child DocTypes** are sub-records attached to a parent via a Table-type field; stored in their own table but lifecycle-bound to the parent.
- **Virtual DocTypes** have no DB table — data comes from an external source via a controller.

Read: `references/framework/architecture.md` and `references/framework/doctype-guide.md`.

### 2. The ORM is `frappe.get_doc` and friends

```python
doc = frappe.get_doc("Task", "TASK00001")      # fetch by name
doc = frappe.get_doc({"doctype": "Task", "subject": "X"})  # in-memory new
doc = frappe.new_doc("Task")                    # cleaner constructor
doc.subject = "Updated"
doc.insert()                                    # create
doc.save()                                      # update
doc.submit()                                    # workflow submit (if submittable)
doc.cancel()                                    # workflow cancel
doc.delete()                                    # delete (or frappe.delete_doc)
docs = frappe.get_all("Task", filters={"status": "Open"}, fields=["name", "subject"])
```

Key gotchas:
- `frappe.db.get_value` / `get_all` / `get_list` return **dicts or tuples**, not Document objects. Use them for reads; use `get_doc` only when you need to mutate or call methods.
- `frappe.db.sql` is the escape hatch — never use it for writes; use it sparingly for reads.
- `frappe.get_cached_doc` skips the DB if the doc is already in request-local cache.
- All writes go through controller hooks (`validate`, `before_save`, `on_update`, etc.) — see `references/framework/doctype-guide.md`.

Read: `references/framework/python-api.md`.

### 3. Permissions are role-based + field-level + doc-level

Frappe has five permission levels per role per DocType: `read`, `write`, `create`, `delete`, `submit`, `cancel`, `amend`. On top of that:
- **Field-level permissions** restrict which fields a role can read/write.
- **Doc-level permissions** (`Permission Query Conditions`) restrict which rows a role can see (e.g. "only see Customers where `_assign` LIKE %user%").
- **If permission rules apply** (default), `frappe.get_doc` and `frappe.get_all` will silently filter results. Pass `ignore_permissions=True` to bypass (use carefully).

### 4. Server-side vs Client-side code

| Server (Python) | Client (JS) |
|---|---|
| Controller methods on DocType class | Form scripts attached via `frappe.ui.form.on(...)` |
| `hooks.py` event handlers | `frappe.call` → whitelisted Python method |
| `@frappe.whitelist()` decorator exposes methods to the client | `frappe.call({method, args, callback})` |
| Runs in WSGI worker (synchronous) | Runs in browser |
| Use `frappe.enqueue` for long jobs | Use `frappe.msgprint` / `frappe.throw` for UI feedback |

Read: `references/framework/scripting.md`.

### 5. Bench is the CLI

Every Frappe operation outside the Desk UI goes through `bench`:

```bash
bench init frappe-bench          # create a new bench (a Python virtualenv + apps + sites)
cd frappe-bench
bench get-app erpnext            # clone app from GitHub, install in env
bench new-site mysite.localhost  # create a MariaDB DB + site config
bench --site mysite.localhost install-app erpnext
bench start                      # run dev server (web + worker + schedule)
bench migrate                    # apply schema + data migrations (run after every pull)
bench backup                     # take a backup
bench --site X restore path.sql  # restore from backup
```

Read: `references/framework/bench-cli.md`.

## Quick API Cheatsheet (Always in Context)

These are the most-used APIs. Memorize them; everything else is in the reference files.

### Python (server-side)

```python
# CRUD
doc = frappe.get_doc("Task", "TASK00001")          # fetch
doc = frappe.new_doc("Task"); doc.subject = "X"; doc.insert()  # create
doc.save(); doc.submit(); doc.cancel(); doc.delete()

# Reads
frappe.db.get_value("Task", "TASK00001", "subject")             # scalar
frappe.db.get_value("Task", {"status": "Open"}, "name")         # filtered scalar
frappe.get_all("Task", filters={"status": "Open"}, fields=["name", "subject"])
frappe.db.count("Task", filters={"status": "Open"})
frappe.db.exists("Task", "TASK00001")                            # returns name or None
frappe.db.sql("SELECT name FROM tabTask WHERE status=%s", "Open", as_dict=True)

# Whitelisting (expose to client / REST)
@frappe.whitelist()
def my_method(arg1, arg2=None):
    return {"result": arg1}

# Errors / messages
frappe.throw("Not allowed", frappe.PermissionError)
frappe.msgprint("Saved successfully")
frappe.log_error("Custom error title")             # writes to tabError Log

# Auth / context
frappe.session.user                                # current user email
frappe.session.site                                # current site name
frappe.flags.in_test                               # are we in a test?

# Cache
frappe.cache().get_value("key")
frappe.cache().set_value("key", "value", expires_in_sec=3600)
frappe.cache().hset("hash", "field", "value")
frappe.cache().delete_value("key")

# Background jobs
frappe.enqueue("app.path.to.method", queue="long", timeout=600, **kwargs)

# Email
frappe.sendmail(recipients=["a@b.com"], subject="Hi", message="<p>body</p>")

# Translation
frappe._("Hello")                                  # translates to current user's lang

# Date / time
frappe.utils.now()                                 # "2024-01-15 10:30:00.123456"
frappe.utils.nowdate()                             # "2024-01-15"
frappe.utils.add_days("2024-01-15", 7)             # "2024-01-22"
frappe.utils.getdate("2024-01-15")                 # date object

# Rendering
frappe.render_template("path/to/template.html", {"data": x})
```

### JavaScript (client-side)

```javascript
// Form events
frappe.ui.form.on("Task", {
  setup: function(frm) { /* runs once when form loads */ },
  refresh: function(frm) { /* runs on every refresh */ },
  subject: function(frm) { /* runs when subject field changes */ },
  before_save: function(frm) { /* runs before save */ },
  on_submit: function(frm) { /* runs after submit */ }
});

// Server call
frappe.call({
  method: "app.path.to.method",
  args: { key: "value" },
  freeze: true,
  callback: function(r) {
    if (!r.exc) {
      // r.message is the return value
    }
  }
});

// Newer async/await form
const r = await frappe.call({ method: "...", args: {...} });

// UI
frappe.msgprint("Done");
frappe.throw("Error");
frappe.confirm("Are you sure?", () => { /* yes */ }, () => { /* no */ });
frappe.set_route("list", "Task");
frm.set_value("status", "Open");
frm.refresh_field("items");
frm.add_custom_button("Click", () => { /* ... */ });
frm.call("custom_method");  // calls controller method on the doctype
```

### REST API

```bash
# Auth (token)
curl -H "Authorization: token API_KEY:API_SECRET" https://site/api/method/frappe.auth.get_logged_user

# List
curl -H "Authorization: token ..." "https://site/api/resource/Task?filters=[[\"status\",\"=\",\"Open\"]]&fields=[\"name\",\"subject\"]&limit_page_length=100"

# Get one
curl -H "Authorization: token ..." https://site/api/resource/Task/TASK00001

# Create
curl -X POST -H "Authorization: token ..." -H "Content-Type: application/json" \
  -d '{"subject":"New","status":"Open"}' \
  https://site/api/resource/Task

# Update
curl -X PUT -H "Authorization: token ..." -H "Content-Type: application/json" \
  -d '{"status":"Closed"}' \
  https://site/api/resource/Task/TASK00001

# Delete
curl -X DELETE -H "Authorization: token ..." https://site/api/resource/Task/TASK00001

# Call any whitelisted method
curl -X POST -H "Authorization: token ..." \
  -d 'arg1=foo&arg2=bar' \
  https://site/api/method/app.path.to.method
```

### Bench commands

```bash
bench init <dir>                  # create bench
bench get-app <git-url>           # clone + install app
bench new-site <site>             # create site
bench --site <site> install-app <app>
bench start                       # dev server
bench migrate                     # apply migrations (after every update)
bench update                      # pull + migrate + restart
bench backup                      # backup current site
bench --site <site> restore <path>
bench --site <site> set-config admin_password ""
bench mariadb                     # drop into MariaDB shell
bench console                     # drop into Python shell with frappe context
bench doctor                      # diagnose common issues
bench --site <site> clear-cache
bench --site <site> clear-website-cache
```

## Reference Files

When the question goes deeper than what's in this SKILL.md, read the relevant reference file (use the decision tree above to pick the right one):

| Reference file | When to read |
|---|---|
| `references/docs-index.md` | Need the URL map for fetching live docs.frappe.io pages |
| `references/framework/architecture.md` | Understanding bench/sites/apps directory layout, request lifecycle, WSGI, async jobs |
| `references/framework/python-api.md` | Writing Python: `frappe.get_doc`, `frappe.db.*`, `frappe.whitelist`, `frappe.enqueue`, validation hooks |
| `references/framework/rest-api.md` | Building REST clients, authentication, pagination, file uploads |
| `references/framework/doctype-guide.md` | Creating DocTypes, field types, controllers, permissions, child tables, virtual doctypes |
| `references/framework/scripting.md` | Server Scripts, Client Scripts, form events, JS API, hooks.py |
| `references/framework/bench-cli.md` | All `bench` commands reference |
| `references/framework/webviews-deployment.md` | Portal pages, Web Forms, Jinja, production deployment, backups |
| `references/erpnext/overview.md` | ERPNext setup, modules, company, users |
| `references/erpnext/accounts.md` | Accounting: COA, journal entries, payment entry, taxes, multi-currency |
| `references/erpnext/stock.md` | Stock: items, warehouses, stock entry, valuation, serial/batch |
| `references/erpnext/selling-buying.md` | Selling & Buying: orders, deliveries, receipts, invoices |
| `references/erpnext/manufacturing.md` | Manufacturing: BOM, work orders, production plans |
| `references/erpnext/hr-projects.md` | HR, Payroll, Projects, Timesheets |
| `references/erpnext/customization.md` | Custom Fields, Print Formats, Workflows, Notifications, Reports |
| `references/apps/ecosystem.md` | Other Frappe apps: HR, CRM, Cloud, Builder, Insights, etc. |
| `references/troubleshooting.md` | Common errors, debugging, performance, logs |

## Code Generation Rules

When generating Frappe code, follow these conventions:

1. **Always use `frappe.whitelist()`** to expose methods to the client. Without it, the method is private and `frappe.call` from JS will 403.
2. **Always use `frappe.db.escape`** or parameterized queries (`%s` placeholders) when using `frappe.db.sql`. Never f-string user input into SQL.
3. **Use `frappe._()`** for any user-visible string so it gets translated.
4. **Validate inputs early** with `frappe.throw(..., SpecificError)` — don't let bad data reach the DB.
5. **Prefer `frappe.get_all` / `frappe.db.get_all`** over `frappe.db.sql` for simple queries — they handle permissions automatically.
6. **Use `frappe.enqueue` for any task that takes >5 seconds** — the WSGI worker will time out otherwise.
7. **Read the controller hooks** (`validate`, `before_save`, `on_update`, `on_submit`, `on_cancel`, `on_trash`) before adding custom logic — you usually want to hook into existing ones rather than monkey-patch.
8. **Never edit core DocTypes directly** — use Custom Fields, Property Setters, or Server Scripts. Direct edits to `tabDocField` get wiped on the next migration.
9. **Test migrations** on a staging site first — `bench migrate` is destructive in some cases.
10. **Back up before any major change** — `bench backup` is cheap, recovery without a backup isn't.

## Anti-Patterns to Avoid

- **Don't** call `frappe.db.commit()` manually inside a request — Frappe manages the transaction. Use it only in background jobs or scripts.
- **Don't** mutate `frappe.session.user` to impersonate — use `frappe.set_user(...)` / `frappe.session.user = ...` carefully and always restore.
- **Don't** use `time.sleep()` in server code — use `frappe.enqueue` and let the worker handle it.
- **Don't** write JS that calls `window.fetch` directly to `/api/resource/...` — use `frappe.call` so CSRF and auth headers are handled automatically.
- **Don't** edit files under `apps/frappe/` or `apps/erpnext/` directly — fork the app or use customization features. Changes inside `apps/` are lost on `bench update`.
- **Don't** store secrets in `site_config.json` in plain text if the repo is public — use environment variables or `bench --site X set-config key value --secret`.

## Versions

Frappe Framework, ERPNext, and all Frappe apps follow a versioning scheme where the **major version** (12, 13, 14, 15, 16, ...) signals breaking changes. As of 2026:
- **Frappe Framework v16** and **ERPNext v16** are the latest stable releases.
- Python 3.11+ is required; MariaDB 10.8+ or PostgreSQL 14+ supported.
- Node 18+ required for asset building.

When the user doesn't specify a version, assume v15 or v16 (the two currently supported lines). Always check the live docs if a behavior seems version-specific.

## License & Attribution

Frappe Framework and ERPNext are open-source under the **GNU General Public License v3** (GPLv3). The documentation at `https://docs.frappe.io/` is also openly accessible. This skill is a synthesized reference — it condenses and organizes the official documentation for quick agent lookup. For the authoritative and latest version, always refer to the live docs.
