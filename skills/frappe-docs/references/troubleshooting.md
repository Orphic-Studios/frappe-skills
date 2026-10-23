# Frappe & ERPNext — Troubleshooting Guide

This file is the **first stop for diagnosing any Frappe or ERPNext problem** — installation failures, migration errors, permission issues, slow pages, broken PDFs, stuck queues, 502s in production, and everything in between. Read it before reaching for GitHub issues or the forum. For framework concepts (DocType, hooks, REST) referenced here, read `../framework/architecture.md` and `../framework/python-api.md`. For bench commands used in fixes, read `../framework/bench-cli.md`. For ERPNext-specific customization pitfalls, read `../erpnext/customization.md`.

## Table of Contents

1. [Diagnostic Mindset](#diagnostic-mindset)
2. [Logs & Where to Find Them](#logs--where-to-find-them)
3. [Common Errors by Category](#common-errors-by-category)
   - [Installation / Setup Errors](#installation--setup-errors)
   - [Migration Errors](#migration-errors)
   - [Permission Errors](#permission-errors)
   - [DocType Errors](#doctype-errors)
   - [Performance Issues](#performance-issues)
   - [Email Issues](#email-issues)
   - [Background Job Issues](#background-job-issues)
   - [Asset / JS Issues](#asset--js-issues)
   - [Print / PDF Issues](#print--pdf-issues)
   - [Backup / Restore Issues](#backup--restore-issues)
   - [Production-Specific Issues](#production-specific-issues)
4. [Debugging Techniques](#debugging-techniques)
5. [Performance Tuning](#performance-tuning)
6. [Recovery Procedures](#recovery-procedures)
7. [Asking for Help](#asking-for-help)
8. [Error → Cause → Fix Reference Table](#error--cause--fix-reference-table)
9. [Where to Learn More](#where-to-learn-more)

## Diagnostic Mindset

Approach Frappe issues systematically. Skipping straight to a fix often makes things worse — Frappe's tight coupling between DB schema, metadata cache, and code means a symptom in one place can have a root cause elsewhere.

### The 5-Step Method

```text
1. REPRODUCE — Trigger the error reliably. "Sometimes it fails" is not enough.
   If you cannot reproduce, you cannot verify the fix.

2. ISOLATE   — Narrow the scope:
               - Same error on other sites in the same bench? → bench-level issue.
               - Same error with a different user?             → permission issue.
               - Same error in the API (curl)?                 → server-side.
               - Works in API but breaks in UI?                 → JS/asset issue.

3. CHECK LOGS — See the Logs table below. The error message in the browser is
                usually a sanitized version of the real traceback. The real
                traceback is in error.log or the worker log.

4. TEST FIX   — Apply the smallest possible change. Avoid "nuke and pave"
                (dropping DB, reinstalling app) until you have exhausted
                targeted fixes — destructive recovery loses data.

5. VERIFY     — Reproduce the original trigger. Confirm the error is gone.
                Then run `bench migrate --test` and `bench run-tests` for the
                affected module to catch regressions.
```

### Always Back Up First

```bash
bench --site <site> backup --with-files
```

A backup takes seconds. Recovery without one takes hours. Run this before any non-trivial fix — migrations, schema edits, permission rule changes, app installs.

### Check the Obvious First

Before deep-diving, verify:

- Is `bench start` actually running? (dev mode)
- Is `supervisorctl status` showing all workers running? (production)
- Is `bench --site X doctor` clean?
- Is the site you're hitting the one you think? (`bench use` to confirm)
- Is the user logged in as the role you expect?
- Did you run `bench migrate` after the last `bench update`?
- Did you run `bench build` after changing JS/CSS?
- Is the cache stale? (`bench clear-cache` fixes 30% of weird UI bugs)

## Logs & Where to Find Them

Logs are split between bench-level (`logs/`) and site-level (`sites/<site>/logs/`). Knowing which log to read halves the debugging time.

### Log File Locations

| Path | Contains | When to check |
|---|---|---|
| `logs/web.log` | WSGI access log (one line per request) | Slow requests, 404s, 500s by URL |
| `logs/web.error.log` | WSGI error log (tracebacks from web requests) | Any HTTP 500 |
| `logs/worker.log` | Background job output (stdout + errors) | Failed `frappe.enqueue` jobs |
| `logs/worker.error.log` | Background job exceptions (tracebacks) | Stuck queues, silent job failures |
| `logs/schedule.log` | Scheduler (`bench schedule`) output | Cron-like jobs not running |
| `logs/schedule.error.log` | Scheduler exceptions | Auto-repeat, SLA breaches, daily reports failing |
| `logs/frappe.log` | Application-level log (`frappe.logger`) | Custom `frappe.log_error()` output |
| `logs/error.log` | All unhandled exceptions (best first stop) | Mysterious errors with no clear source |
| `sites/<site>/logs/error.log` | Per-site error log (same format) | Multi-site benches |
| `logs/bench.log` | bench CLI command output | `bench update` / `bench migrate` failures |
| `logs/install.log` | App install / migration steps | First-time install issues |
| `sites/<site>/private/backups/` | Backup files (SQL + files) | Recovery procedures |
| `~/bench Logs` (Frappe Cloud) | Same logs via dashboard | Frappe Cloud-hosted sites |
| DB log (`bench mariadb` → `SHOW PROCESSLIST`) | Live DB queries | Locked tables, long queries |
| Redis (`redis-cli monitor`) | Live cache + queue operations | Cache thrash, queue starvation |

### Reading Logs Efficiently

```bash
# Tail the error log continuously while reproducing
tail -f logs/error.log

# Filter for tracebacks only
grep -A 50 "Traceback" logs/error.log | less

# Find the most recent error
ls -lt logs/*.log | head -5

# Find all errors in the last hour
grep "$(date -d '1 hour ago' +'%Y-%m-%d %H')" logs/error.log

# Get the error log path for the current site (programmatically)
bench --site <site> console << 'EOF'
import frappe
print(frappe.get_site_path("logs", "error.log"))
EOF
```

### The Error Log DocType

Frappe also stores errors in the `tabError Log` table. View them in Desk → Error Log. Each entry has:

- `method` — the function that raised the error
- `traceback` — full Python traceback
- `relates_to` — the document that triggered it (if any)
- `seen` — count of occurrences (auto-grouped)

Purge old entries with:

```bash
bench --site <site> execute frappe.core.doctype.error_log.error_log.clear_error_logs
```

## Common Errors by Category

### Installation / Setup Errors

#### `pip install` failures during `bench get-app`

**Symptoms:** `bench get-app erpnext` fails with `error: Microsoft Visual C++ 14.0 is required` (Windows) or `fatal error: Python.h: No such file or directory` (Linux).

**Cause:** Missing build dependencies for compiling Python packages with C extensions (e.g. `pycurl`, `lxml`, `mysqlclient`).

**Fix:**

```bash
# Ubuntu/Debian
sudo apt install python3-dev build-essential libssl-dev libffi-dev \
    libxml2-dev libxslt1-dev zlib1g-dev libmariadb-dev-compat \
    libldap2-dev libsasl2-dev

# macOS (Xcode command line tools)
xcode-select --install
brew install openssl mariadb-connector-c

# Then retry
bench get-app erpnext
```

#### MariaDB connection refused

**Symptom:** `Access denied for user '_username'@'localhost'` or `Can't connect to MySQL server on '127.0.0.1'`.

**Cause:** Wrong DB credentials in `site_config.json`, MariaDB not running, or `bind-address` blocking the connection.

**Fix:**

```bash
# 1. Verify MariaDB is running
sudo systemctl status mariadb
sudo systemctl start mariadb

# 2. Verify credentials
bench mariadb  # should drop into MariaDB shell

# 3. Reset the site's DB password
bench --site <site> set-config db_password <new_password>
mysql -u root -p -e "ALTER USER '<db_user>'@'localhost' IDENTIFIED BY '<new_password>'; FLUSH PRIVILEGES;"

# 4. Check bind-address (should be 127.0.0.1 for local)
sudo grep bind-address /etc/mysql/mariadb.conf.d/50-server.cnf
```

#### Redis connection refused

**Symptom:** `Error 111 connecting to 127.0.0.1:11000. Connection refused.`

**Cause:** Redis not running, or `redis_cache`/`redis_queue` services down.

**Fix:**

```bash
# Dev mode: bench start spawns Redis automatically. If it crashes, check ports.
redis-cli -p 11000 ping  # should return PONG
redis-cli -p 11001 ping  # queue socket

# Production mode: start via supervisor or systemd
sudo systemctl status redis-server
bench setup supervisor  # regenerate supervisor configs
sudo supervisorctl restart all

# Common cause: stale PID files after a hard reboot
rm /tmp/redis-11000.pid /tmp/redis-11001.pid 2>/dev/null
```

#### Node version mismatch

**Symptom:** `bench build` fails with `Error: You are using an outdated version of Node` or weird webpack errors.

**Cause:** Frappe requires Node 18+. Using the system Node (often too old) instead of `nvm`-managed Node.

**Fix:**

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc

# Install and use Node 18
nvm install 18
nvm use 18
nvm alias default 18

# Verify
node -v  # should print v18.x.x
npm -v

# Rebuild assets
bench build
```

### Migration Errors

#### `Table '<table>' already exists`

**Symptom:** `bench migrate` fails with `(_mysql_exceptions.OperationalError) (1050, "Table '<table>' already exists")`.

**Cause:** A previous migration was interrupted mid-way, leaving a half-created table. The migration tries to `CREATE TABLE` but the table is there.

**Fix:**

```bash
# Inspect the table — if empty, drop it and re-migrate
bench mariadb
> SHOW CREATE TABLE `<table>`;
> DROP TABLE `<table>`;
> exit

bench --site <site> migrate
```

If the table has data you need, you have a deeper issue. Restore from the pre-migration backup and re-run cleanly.

#### `Duplicate column name '<column>'`

**Symptom:** Migration fails with `(_mysql_exceptions.OperationalError) (1060, "Duplicate column name '<column>'")`.

**Cause:** A Custom Field was added manually (or by an old migration) with the same column name as a new core field. The migration tries to `ALTER TABLE ADD COLUMN` but the column exists.

**Fix:**

```sql
-- Find the offending Custom Field
SELECT * FROM `tabCustom Field` WHERE fieldname='<column>';

-- Either delete it (if the core field supersedes it) or rename it
DELETE FROM `tabCustom Field` WHERE name='<custom_field_id>';

-- Then re-migrate
```

#### Foreign key constraint failure

**Symptom:** Migration fails with `Cannot delete or update a parent row: a foreign key constraint fails`.

**Cause:** A DocType is being deleted but documents of another DocType reference it via a `Link` field.

**Fix:**

```bash
# 1. Find what references the DocType
bench --site <site> execute frappe.core.doctype.doctype.doctype.get_docfields_linked_with --doctype '<TargetDocType>'

# 2. Either delete the linking documents or convert the Link field to Data
# 3. Re-run migrate
```

#### Charset / collation mismatch

**Symptom:** Migration fails with `Illegal mix of collations (...) for operation '='` or text appears as `???` in the UI.

**Cause:** Database tables have mixed collations (`utf8mb4_general_ci` vs `utf8mb4_unicode_ci`). Often happens after a restore from a dump taken on a different MariaDB version.

**Fix:**

```bash
# Convert all tables to utf8mb4_unicode_ci (Frappe's default)
bench mariadb
> SELECT CONCAT('ALTER TABLE `', table_name, '` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
  FROM information_schema.tables
  WHERE table_schema = '<your_db_name>' AND table_collation != 'utf8mb4_unicode_ci';

# Copy the output, run it. Then:
bench --site <site> migrate
```

#### Patch fails: `ModuleNotFoundError`

**Symptom:** `bench migrate` shows `Executing <app>.patches.v<x>_<name>...` then fails with `ModuleNotFoundError: No module named '<app>'`.

**Cause:** A patch references an app that was removed from the bench but is still listed in `patches.txt`.

**Fix:**

```bash
# Option 1: Reinstall the missing app
bench get-app https://github.com/frappe/<app>
bench --site <site> install-app <app>

# Option 2: Skip the patch (only if you understand the consequences)
bench mariadb
> DELETE FROM `tabPatch Log` WHERE patch = '<app>.patches.v<x>_<name>';
> exit

# Re-run migrate
```

### Permission Errors

#### `frappe.exceptions.PermissionError: Not permitted`

**Symptom:** A whitelisted method throws PermissionError even though the user has the role.

**Cause:** Frappe enforces permissions on every `frappe.get_doc` / `frappe.db.get_value` call by default. If the user lacks read permission on the DocType, the call fails silently or throws.

**Fix:**

```python
# Option A: Explicitly bypass permissions (use carefully — security risk)
doc = frappe.get_doc("Sales Invoice", name, ignore_permissions=True)

# Option B: Add the role to the user via Desk → User → Roles
# Option C: Add a User Permission limiting the user's scope
# Option D: Set permlevel permissions on the DocType → Role Permissions Manager

# Always whitelisted methods should declare which permissions they need:
@frappe.whitelist()
def my_method(name):
    doc = frappe.get_doc("Sales Invoice", name)  # will enforce read perm
    return doc.customer

# OR explicitly:
@frappe.whitelist()
def my_method(name):
    if not frappe.has_permission("Sales Invoice", "read", name):
        frappe.throw("Not permitted", frappe.PermissionError)
```

#### User cannot see documents they should see

**Cause:** `Permission Query Conditions` on the DocType restricts rows. Or the user is missing the role.

**Diagnose:**

```python
# In bench console
from frappe.permissions import get_permission_query_conditions
print(get_permission_query_conditions("Sales Invoice"))
# This prints the WHERE clause applied to the user — examine it.

# Check user roles
print(frappe.get_roles(frappe.session.user))

# Check User Permissions (filters that restrict by Company, Territory, etc.)
frappe.get_all("User Permission", filters={"user": frappe.session.user})
```

#### "Role required" error on submit

**Cause:** The DocType is submittable, and the user role lacks `submit` permission (only `write` is not enough).

**Fix:** Open Role Permissions Manager → find the DocType → check the `Submit` checkbox for the role.

### DocType Errors

#### `frappe.exceptions.DuplicateEntryError`

**Symptom:** Saving a new document fails with `DuplicateEntryError: <DocType> <name>`.

**Cause:** The `name` (primary key) already exists in the table. This happens when:

- The naming series counter is out of sync (rare)
- A document was deleted but the name was manually reused
- Custom naming logic generated a duplicate

**Fix:**

```bash
# Reset the naming series counter
bench --site <site> console
>>> from frappe.model.naming import revert_series_last
>>> revert_series_last("TASK-.#####", "TASK-00123")  # rolls back the counter

# Or update the counter directly:
bench mariadb
> UPDATE `tabSeries` SET current = (SELECT MAX(CAST(SUBSTRING(name, 6) AS UNSIGNED)) FROM `tabTask` WHERE name LIKE 'TASK-%') WHERE name='TASK-.#####';
```

#### `Unknown column '<field>' in 'field list'`

**Symptom:** After adding a Custom Field (or pulling an app update), reads/writes fail with `Unknown column '<field>'`.

**Cause:** The field is in `tabDocField` (metadata) but the corresponding column was never added to the table. Usually because `bench migrate` wasn't run after adding the field.

**Fix:**

```bash
# Run migrate to sync schema
bench --site <site> migrate

# If migrate doesn't add the column (rare), force it:
bench mariadb
> ALTER TABLE `tab<Task>` ADD COLUMN `<field>` VARCHAR(140);
```

#### `ValueError: invalid literal for int() with base 10`

**Symptom:** Saving a document fails with this ValueError.

**Cause:** A `Select` or `Data` field is being assigned to an `Int` field via `fetch_from` or custom code. Common with checkbox-style values stored as "Yes"/"No" instead of 0/1.

**Fix:**

```python
# In the controller or Server Script, normalize the value
def validate(self):
    if isinstance(self.some_flag, str):
        self.some_flag = 1 if self.some_flag.lower() in ("yes", "true", "1") else 0
```

#### `ValidationError: <message>` from custom validation

**Symptom:** Document fails validation with a custom message.

**Cause:** A `validate` hook or Server Script is throwing. The traceback shows which one.

**Fix:**

```python
# Look at the traceback in error.log to identify the source
# Common: Server Script that runs on validate hook

# To disable a misbehaving Server Script:
# Desk → Server Script → find the offending one → uncheck "Enabled"

# Or via Python:
script = frappe.get_doc("Server Script", "my-validation-script")
script.disabled = 1
script.save()
```

### Performance Issues

#### Slow page load (form takes >5s to open)

**Diagnose:**

1. Open browser DevTools → Network tab → reload the form. Look at the slowest request (usually `frappe.desk.form.load.getdoc`).
2. Check `logs/web.log` for the request duration.
3. Use `EXPLAIN` on the slow query:

```sql
EXPLAIN SELECT * FROM `tabSales Invoice` WHERE name = 'SINV-0001';
```

Look for `ALL` in the `type` column → means full table scan → missing index.

**Common causes & fixes:**

| Cause | Fix |
|---|---|
| Missing index on a Link field | Add the field to `search_fields` in the DocType → migrate |
| Too many Custom Fields with `fetch_from` | Each adds a sub-query → reduce or denormalize |
| `on_load` Server Script runs heavy logic | Move to `on_update` or background job |
| Large `Section Break` with too many child rows | Paginate child tables via `limit_list_length` |
| Stale metadata cache | `bench clear-cache` |
| Slow DB queries | Add DB indexes (see Performance Tuning) |

#### Slow report / list view

**Cause:** The List View fetches all matching rows then paginates in Python. With 100k+ rows, this is slow.

**Fix:**

- Reduce the number of `in_list_view` columns.
- Set `order_by` on an indexed column.
- Add filters that use indexed columns.
- For reports, switch from Query Report to Script Report with a custom SQL using `LIMIT` and `OFFSET`.

#### High CPU usage

**Diagnose:**

```bash
top -c          # find the python/gunicorn process
htop -p $(pgrep -f gunicorn)
# Look for the request being processed in logs/web.log
```

**Common causes:** A long-running request blocking the WSGI worker; a runaway `while True` loop in a Server Script; a report generating millions of rows; a scheduler job that never exits.

**Fix:** Kill the runaway request, identify the endpoint, and refactor to use `frappe.enqueue` if it should be a background job.

#### Memory leak

**Symptom:** Gunicorn worker RSS grows over hours/days, eventually OOM-killed.

**Cause:** Most often a circular reference in custom code holding memory; or a global variable that accumulates.

**Fix:**

```bash
# Tune gunicorn to recycle workers periodically
# In common_site_config.json:
{
  "gunicorn_workers": 4,
  "max_requests": 1000,         # recycle worker after 1000 requests
  "max_requests_jitter": 100
}

# Restart
bench setup supervisor && sudo supervisorctl restart all
```

#### Connection pool exhaustion

**Symptom:** `(OperationalError) (1040, 'Too many connections')` intermittently.

**Cause:** Too many WSGI workers × concurrent requests > MariaDB `max_connections`.

**Fix:**

```bash
# Increase MariaDB max_connections (carefully — each costs RAM)
sudo tee -a /etc/mysql/mariadb.conf.d/90-custom.cnf <<EOF
[mysqld]
max_connections = 500
EOF
sudo systemctl restart mariadb

# Reduce gunicorn workers if over-provisioned
# Rule of thumb: workers = (2 × CPU cores) + 1
bench set-config gunicorn_workers 4
```

### Email Issues

#### Mail not sending

**Diagnose:**

1. Desk → Email Queue → check for stuck entries.
2. Desk → Email Domain → verify SMTP settings → "Test SMTP Connection".
3. Check `logs/worker.log` for the email worker.

**Common causes:**

| Cause | Fix |
|---|---|
| Email Queue stuck | Run `bench --site X execute frappe.email.doctype.email_queue.email_queue.send_queue` |
| SMTP credentials wrong | Update Email Domain → test connection |
| Sender domain not verified (in provider) | Add DNS records (SPF, DKIM, DMARC) |
| Rate-limited by provider | Reduce `Email Account` → `Sync Settings` → `Pause` |
| Worker not running | `sudo supervisorctl restart all` |

#### Email queue stuck

```bash
# Force-flush the queue
bench --site <site> console << 'EOF'
from frappe.email.doctype.email_queue.email_queue import send_queue
send_queue()
EOF

# If specific emails are stuck due to bad recipients, mark them as failed:
bench mariadb
> UPDATE `tabEmail Queue` SET status='Failed' WHERE status='Not Sent' AND modified < NOW() - INTERVAL 1 DAY;
```

#### SMTP `Authentication required` error

**Cause:** SMTP server requires authentication but `Email Domain` has no credentials, or the credentials are for a different account.

**Fix:** Desk → Email Domain → set `SMTP Server`, `SMTP Username`, `SMTP Password` → save → "Test SMTP Connection".

### Background Job Issues

#### Jobs not running at all

**Diagnose:**

```bash
# Check if worker is running
sudo supervisorctl status
# Look for: frappe-bench-workers:running

# Check Redis queue
redis-cli -p 11001 LLEN frappe:default
redis-cli -p 11001 LLEN frappe:long
redis-cli -p 11001 LLEN frappe:short
# Non-zero means jobs are queued but not being processed
```

**Common causes:**

| Cause | Fix |
|---|---|
| Worker died | `sudo supervisorctl restart frappe-bench-workers:frappe-bench-worker-1` |
| Redis not running | `sudo systemctl start redis-server` |
| Site not in `sites/currentsite.txt` (for scheduler) | `bench use <site>` |
| Scheduler disabled | `bench --site <site> scheduler enable` |
| Worker can't connect to DB | Check `site_config.json` DB password |

#### Stuck queue (jobs pile up)

**Cause:** One long-running job is blocking the single-threaded worker (RQ is single-threaded per worker process).

**Fix:**

```bash
# Find the stuck job
redis-cli -p 11001 KEYS "rq:job:*" | head -20
redis-cli -p 11001 LINDEX frappe:long 0  # oldest job in long queue

# Inspect a job
redis-cli -p 11001 HGETALL "rq:job:<id>"

# Flush the queue (destructive — only if jobs are safe to lose)
redis-cli -p 11001 FLUSHDB
# Then restart workers
sudo supervisorctl restart frappe-bench-workers:*
```

#### Worker died (Silent failures)

**Symptom:** Background jobs stop running without obvious error in logs.

**Cause:** Worker hit OOM (out-of-memory) and was killed by the kernel. Check `dmesg`:

```bash
dmesg | grep -i "killed process"
```

**Fix:** Increase server RAM, reduce `max_requests` to recycle workers, or split heavy jobs into chunks via `frappe.enqueue` with `timeout=3600`.

### Asset / JS Issues

#### 404 on JS files after deploy

**Symptom:** Browser shows `GET /assets/erpnext/js/... 404` in console.

**Cause:** Assets weren't built, or the symlink in `sites/assets/` is broken.

**Fix:**

```bash
# Rebuild assets
bench build

# If symlinks are broken (common after manual file moves):
bench setup requirements --python
bench build

# Hard refresh browser (Ctrl+Shift+R) to bypass cache
```

#### JS console errors after upgrade

**Symptom:** Desk UI is broken, console shows red errors.

**Cause:** Browser cached old JS. The new HTML references new asset hashes.

**Fix:**

```bash
bench --site <site> clear-website-cache
bench --site <site> clear-cache

# Then hard-refresh (Ctrl+Shift+R) or open in incognito
```

#### Webpack build errors

**Symptom:** `bench build` fails with webpack errors like `Module not found` or `SyntaxError`.

**Cause:** Node modules out of sync, or custom JS imports a non-existent module.

**Fix:**

```bash
# Clean and reinstall Node modules
rm -rf node_modules yarn.lock
yarn install

# Clear webpack cache
rm -rf apps/*/public/dist/*

# Rebuild
bench build
```

### Print / PDF Issues

#### PDF generation fails

**Symptom:** Clicking "PDF" or "Print → PDF" shows an error like `wkhtmltopdf failed`.

**Cause:** `wkhtmltopdf` binary missing or wrong version, or the print format has a syntax error.

**Fix:**

```bash
# Install wkhtmltopdf with patched Qt (Frappe's recommended version)
# Ubuntu:
sudo apt install wkhtmltopdf

# Verify
wkhtmltopdf --version
# Should be 0.12.x with patched qt

# If using a print format with Jinja syntax errors, check error.log
tail -f logs/error.log

# Test the PDF from CLI to bypass the web UI
bench --site <site> execute frappe.utils.print_format.download_pdf --args '["Sales Invoice", "SINV-0001", "Standard"]'
```

#### Missing fonts in PDF

**Symptom:** PDF renders but special characters (currency symbols, Arabic, Chinese) show as boxes.

**Cause:** `wkhtmltopdf` can't find the font on the server.

**Fix:**

```bash
# Install fonts (Ubuntu)
sudo apt install fonts-noto fonts-noto-cjk fonts-noto-color-emoji fonts-dejavu-core

# Restart the worker that runs wkhtmltopdf
sudo supervisorctl restart frappe-bench-workers:*

# Or use Frappe's PDF font embedding (v15+) via Print Designer → Settings → Fonts
```

#### Broken print layout

**Cause:** Custom HTML Print Format uses absolute positioning or unsupported CSS (flexbox is partially supported; grid is not).

**Fix:** Use simple table-based layouts. Test with `wkhtmltopdf input.html output.pdf` locally to isolate Frappe from print format issues.

### Backup / Restore Issues

#### Restore fails with `Access denied`

**Symptom:** `bench --site X restore backup.sql` fails with `Access denied for user`.

**Cause:** The new site's DB user lacks permissions, or the DB password in `site_config.json` doesn't match.

**Fix:**

```bash
# Recreate the DB user with proper permissions
bench mariadb
> CREATE DATABASE IF NOT EXISTS `<db_name>`;
> CREATE USER '<db_user>'@'localhost' IDENTIFIED BY '<password>';
> GRANT ALL PRIVILEGES ON `<db_name>`.* TO '<db_user>'@'localhost';
> FLUSH PRIVILEGES;
> exit

# Retry restore
bench --site <site> restore /path/to/backup.sql
```

#### Restore fails with charset mismatch

**Symptom:** Restore fails with `Unknown collation 'utf8mb4_0900_ai_ci'` (MySQL 8 dump restored on MariaDB 10.x).

**Cause:** Source and target MariaDB/MySQL versions have different default collations.

**Fix:**

```bash
# Convert the dump file's collation strings
sed -i 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g' backup.sql
sed -i 's/CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci/CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci/g' backup.sql

# Retry restore
bench --site <site> restore backup.sql
```

#### Missing tables after restore

**Symptom:** Restore completes but Desk shows "Table not found" errors.

**Cause:** Some tables were excluded from the dump (rare; usually happens with partial dumps or `--ignore-table` flags).

**Fix:**

```bash
# Find which tables are missing by comparing the dump to expected tables
bench mariadb < <db_name> -e "SHOW TABLES;" > current_tables.txt
grep "CREATE TABLE" backup.sql | awk '{print $3}' | tr -d '`' > dump_tables.txt
diff current_tables.txt dump_tables.txt

# Re-run migrate to recreate missing tables
bench --site <site> migrate
```

### Production-Specific Issues

#### 502 Bad Gateway

**Symptom:** Browser shows 502 Bad Gateway (nginx).

**Cause:** Gunicorn (WSGI) worker is not responding — either crashed, stuck, or not started.

**Fix:**

```bash
# Check gunicorn
sudo supervisorctl status
# frappe-bench-web:frappe-bench-web-1 RUNNING (should be)

# If not running, restart
sudo supervisorctl restart frappe-bench-web:*

# Check gunicorn error log
tail -f logs/gunicorn.error.log

# Common cause: OOM killed gunicorn → check dmesg
dmesg | grep -i "killed process"
```

#### 504 Gateway Timeout

**Symptom:** Browser shows 504 Gateway Timeout (nginx).

**Cause:** Gunicorn took too long to respond (default 60s nginx timeout, default 120s gunicorn timeout).

**Fix:**

```bash
# Identify the slow request
grep "request took" logs/gunicorn.error.log

# Option A: Fix the slow endpoint (preferred)
# Option B: Increase timeouts (band-aid)

# In nginx config (sites-available/<site>):
# proxy_read_timeout 300s;
# proxy_connect_timeout 300s;

# In common_site_config.json:
# "gunicorn_timeout": 300

# Then reload
sudo systemctl reload nginx
bench setup supervisor && sudo supervisorctl restart frappe-bench-web:*
```

#### Supervisor not restarting workers

**Symptom:** `sudo supervisorctl restart all` returns immediately but nothing restarts.

**Cause:** Supervisor config is stale (apps changed but `bench setup supervisor` wasn't run).

**Fix:**

```bash
# Regenerate supervisor config
bench setup supervisor --yes

# Reload supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart all
```

#### Nginx config drift

After adding a new site, nginx must be regenerated:

```bash
bench setup nginx --yes
sudo systemctl reload nginx
```

## Debugging Techniques

### bench console

Drop into a Python shell with full Frappe context. Use this to test queries, debug documents, and prototype fixes:

```bash
bench --site <site> console
>>> frappe.db.get_value("Sales Invoice", "SINV-0001", "customer")
'Acme Corp'
>>> doc = frappe.get_doc("Sales Invoice", "SINV-0001")
>>> doc.validate()  # runs validation without saving
>>> doc.save(ignore_permissions=True)
>>> frappe.db.commit()  # commit changes manually in console
```

### bench execute

Run a single function from the CLI. Useful for testing whitelisted methods or scheduler entry points:

```bash
bench --site <site> execute frappe.email.doctype.email_queue.email_queue.send_queue

# With arguments (JSON list)
bench --site <site> execute my_app.api.do_something --args '["arg1", "arg2"]'

# With kwargs (JSON object)
bench --site <site> execute my_app.api.do_something --kwargs '{"verbose": true}'
```

### frappe.log_error

Add structured error logging in custom code:

```python
try:
    risky_operation()
except Exception:
    frappe.log_error("Risk operation failed", "MyApp Risk Op")
    # The traceback + context is saved to tabError Log
    # View in Desk → Error Log → filter by method "MyApp Risk Op"
```

### Profiling

Identify slow code paths:

```python
import cProfile, pstats

profiler = cProfile.Profile()
profiler.enable()

# Code to profile
frappe.get_all("Sales Invoice", limit=1000)

profiler.disable()
stats = pstats.Stats(profiler)
stats.sort_stats("cumulative").print_stats(20)
```

For SQL profiling, enable the slow query log:

```bash
# In MariaDB config
[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
```

### Browser DevTools

For client-side issues:

1. **Console tab** — JS errors (red). Click the error to see the stack trace.
2. **Network tab** — failed requests (red), slow requests (long bar). Right-click → "Copy as cURL" to replay server-side.
3. **Application tab** → Local Storage / Cookies — stale session data.
4. **Sources tab** — set breakpoints in custom JS. Map `frappe.call` callbacks.
5. **Performance tab** — record a session to find slow JS rendering.

### Network panel deep dive

For "the form is slow" issues:

1. Reload the form with Network tab open and "Preserve log" checked.
2. Sort by Time descending.
3. The slowest request is usually `frappe.desk.form.load.getdoc`.
4. Right-click → Copy → Copy as cURL.
5. Run the cURL on the server to bypass the browser.
6. If still slow, the bottleneck is server-side (DB query, validation).
7. If fast on the server, the bottleneck is client-side (JS rendering, network latency).

## Performance Tuning

### Database Indexes

Frappe auto-indexes `name` (PK), `parent`, `parenttype`, `parentfield`, `idx`, `creation`, `modified`, `modified_by`, `owner`, `docstatus`. For other fields you query on, add custom indexes:

```python
# In a custom app's hooks.py or migration patch
frappe.db.add_index("Sales Invoice", ["customer", "posting_date"])
frappe.db.add_index("Sales Invoice Item", ["item_code", "posting_date"])
```

Or via Custom Field → set `in_list_view` and `search_index` = 1.

### Query Optimization

```python
# BAD: fetches all rows then filters in Python
docs = frappe.get_all("Sales Invoice", fields=["*"])
open_invoices = [d for d in docs if d.status == "Unpaid"]

# GOOD: filter in SQL
open_invoices = frappe.get_all("Sales Invoice",
    filters={"status": "Unpaid"},
    fields=["name", "customer", "grand_total"])

# BAD: N+1 queries
for name in frappe.get_all("Sales Invoice", pluck="name"):
    doc = frappe.get_doc("Sales Invoice", name)
    print(doc.customer)

# GOOD: single query
for row in frappe.get_all("Sales Invoice", fields=["name", "customer"]):
    print(row.customer)
```

### Caching Strategies

```python
# Cache expensive computation
@frappe.cache().cached(ttl=300, key="my_app:expensive_calc")
def get_expensive_data():
    return frappe.db.sql("SELECT ...")

# Manual cache control
def get_settings():
    val = frappe.cache().get_value("my_app:settings")
    if val is None:
        val = frappe.db.get_single_value("MyApp Settings", "config")
        frappe.cache().set_value("my_app:settings", val, expires_in_sec=3600)
    return val

# Invalidate on save
def on_update(self):
    frappe.cache().delete_value("my_app:settings")
```

### Worker Sizing

```bash
# Gunicorn (web workers): rule of thumb (2 × CPU cores) + 1
# For 4 CPU cores: 9 workers
bench set-config gunicorn_workers 9

# RQ workers: 1 per queue is default; scale up for high-throughput sites
# In common_site_config.json:
{
  "workers": {
    "default": 2,
    "short": 1,
    "long": 1
  }
}

# Regenerate supervisor and restart
bench setup supervisor --yes
sudo supervisorctl update
sudo supervisorctl restart all
```

### Redis Pool Sizing

If you see Redis `Connection pool exhausted` errors:

```bash
# In common_site_config.json:
{
  "redis_socket_timeout": 5,
  "max_connections": 200
}

# Increase Redis maxclients in /etc/redis/redis.conf:
# maxclients 10000
```

### MariaDB Tuning

```ini
# /etc/mysql/mariadb.conf.d/90-tuning.cnf
[mysqld]
innodb_buffer_pool_size = 4G        # 60-70% of total RAM
innodb_log_file_size = 512M
innodb_flush_log_at_trx_commit = 2  # faster writes, slight durability tradeoff
innodb_flush_method = O_DIRECT
query_cache_type = 0                 # query cache is often slower on modern MariaDB
query_cache_size = 0
tmp_table_size = 64M
max_heap_table_size = 64M
```

After changes: `sudo systemctl restart mariadb`.

## Recovery Procedures

### Restore from Backup

```bash
# 1. Find the latest backup
ls -lt sites/<site>/private/backups/

# 2. Restore (database + files)
bench --site <site> restore /path/to/backup.sql
# Files are auto-restored from the .tar.gz in the same directory

# 3. If restore target site doesn't exist, create it first
bench new-site <site> --force --source-db /path/to/backup.sql

# 4. Run migrate to apply any pending patches
bench --site <site> migrate

# 5. Clear cache
bench --site <site> clear-cache
```

### Recover from Failed Migration

If `bench migrate` fails mid-way and leaves the site in a broken state:

```bash
# 1. DO NOT run migrate again until you've identified the cause
# 2. Restore from the pre-migration backup (you DID take one, right?)
bench --site <site> restore /path/to/pre_migration_backup.sql

# 3. Identify and fix the migration issue (see Migration Errors section)
# 4. Re-run migrate
bench --site <site> migrate

# If patches are stuck in the Patch Log table:
bench mariadb
> DELETE FROM `tabPatch Log` WHERE patch LIKE '<problematic_patch>';
> exit

# 5. Verify site health
bench --site <site> doctor
bench --site <site> migrate  # should complete cleanly
```

### Fix Broken DocType

If a DocType's metadata is corrupt (fields missing, table missing, controller broken):

```bash
# 1. Clear the metadata cache
bench --site <site> clear-cache
bench --site <site> clear-website-cache

# 2. Force reload DocType from JSON (for Standard DocTypes)
bench --site <site> execute frappe.modules.import_file.import_files --args '["erpnext", "erpnext/accounts/doctype/sales_invoice"]'

# 3. Re-sync schema
bench --site <site> migrate

# 4. If a custom field is causing issues, find and disable it:
bench mariadb
> UPDATE `tabCustom Field` SET hidden=1 WHERE dt='<DocType>' AND fieldname='<field>';
> exit
bench --site <site> clear-cache
```

### Fix Corrupt Cache

When the site behaves erratically (wrong field labels, missing fields, phantom errors):

```bash
# Clear all cache layers
bench --site <site> clear-cache
bench --site <site> clear-website-cache

# If still broken, flush Redis entirely (drops all queues too — be careful in production)
redis-cli -p 11000 FLUSHALL
redis-cli -p 11001 FLUSHALL

# Restart workers
sudo supervisorctl restart frappe-bench-workers:*
sudo supervisorctl restart frappe-bench-web:*

# Rebuild assets
bench build
```

## Asking for Help

When self-diagnosis fails, ask the community. Frappe has an active forum and Discord, plus GitHub issues for bugs.

### Writing a Good GitHub Issue

A good issue gets answered in hours. A bad one rots for weeks. Include:

```markdown
## Description
[1-2 sentences: what happened, what you expected]

## Steps to Reproduce
1. Go to '...'
2. Click on '....'
3. See error

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens, including the exact error message]

## Environment
- Frappe Framework version: [run `bench version`]
- ERPNext version: [...]
- App versions: [...]
- OS: [e.g. Ubuntu 22.04]
- MariaDB version: [run `bench mariadb` → `SELECT VERSION();`]
- Node version: [run `node -v`]
- Browser: [e.g. Chrome 120]
- Is this on Frappe Cloud? [yes/no]

## Logs
```
[Paste the full traceback from logs/error.log — not just the error message]
```

## Screenshots
[If UI-related, attach screenshots]

## Possible Root Cause (optional)
[Your hypothesis — helps maintainers prioritize]
```

### What to Include

- **Always** include the version of every installed app (`bench version`).
- **Always** include the full traceback from `error.log` — not the sanitized browser message.
- **Always** include steps to reproduce. "It doesn't work" is not reproducible.
- **Never** include credentials, customer data, or PII.
- **Prefer** a screenshot or screen recording for UI issues.
- **Test** on the latest version before reporting — your bug may already be fixed.

### Where to Seek Help

| Channel | When to use | URL |
|---|---|---|
| Frappe Forum | General questions, "how do I..." | `https://discuss.frappe.io` |
| GitHub Issues | Confirmed bugs in Frappe apps | `https://github.com/frappe/frappe/issues` |
| GitHub Issues (ERPNext) | Confirmed bugs in ERPNext | `https://github.com/frappe/erpnext/issues` |
| GitHub Issues (other apps) | Bugs in HR/CRM/etc. | `https://github.com/frappe/<app>/issues` |
| Discord | Real-time chat, quick questions | `https://frappe.io/community` |
| Frappe Cloud Support | Issues specific to Frappe Cloud | Email support@frappe.io |
| Stack Overflow | Public Q&A (smaller audience) | Tag: `erpnext`, `frappe` |
| Paid Support | Production-down issues | `https://frappe.io/support` |

### Response Time Expectations

- **Forum**: 12–72 hours for community response.
- **GitHub Issues**: 1–7 days for triage; longer for non-critical bugs.
- **Discord**: Minutes to hours, but no SLA.
- **Paid Support**: Hours, per SLA.

For production-down issues on Frappe Cloud, use the in-dashboard live chat — it bypasses the public queue.

## Error → Cause → Fix Reference Table

A condensed reference of the most common Frappe errors. Use this for quick lookup; the detailed sections above have more context.

| Error message (or pattern) | Likely cause | Fix |
|---|---|---|
| `Access denied for user 'root'@'localhost'` | Wrong DB root password during `bench new-site` | Reset MySQL root password: `sudo mysqladmin -u root password 'newpass'` |
| `Can't connect to MySQL server on '127.0.0.1 (111)` | MariaDB not running | `sudo systemctl start mariadb` |
| `Can't connect to Redis on 127.0.0.1:11000` | Redis not running | `sudo systemctl start redis-server` or `bench start` |
| `ModuleNotFoundError: No module named 'frappe'` | Virtualenv not activated, or bench not in PATH | `source env/bin/activate` from bench root |
| `ImportError: cannot import name 'X' from 'frappe'` | Code uses an API removed in current Frappe version | Check migration guide at `docs.frappe.io`; update code |
| `bench: command not found` | bench CLI not in PATH | `export PATH=$PATH:~/.local/bin` and add to `~/.bashrc` |
| `frappe.exceptions.PermissionError: Not permitted` | User lacks role or row permission | Add role in Desk → User, or use `ignore_permissions=True` carefully |
| `frappe.exceptions.ValidationError: <msg>` | Custom validate hook failed | Check traceback in `error.log`; disable Server Script if needed |
| `frappe.exceptions.DuplicateEntryError: <DocType> <name>` | Naming series collision or counter out of sync | `bench mariadb` → `UPDATE tabSeries SET current=... WHERE name='<series>'` |
| `Unknown column '<field>' in 'field list'` | Custom Field added but migration not run | `bench --site <site> migrate` |
| `Table '<table>' already exists` | Interrupted migration left half-created table | Drop table in MariaDB, re-run migrate |
| `Duplicate column name '<column>'` | Custom Field conflicts with new core field | Delete the Custom Field, re-run migrate |
| `Cannot delete or update a parent row: foreign key constraint` | DocType being deleted has linked documents | Delete linking docs first or convert Link to Data field |
| `Illegal mix of collations` | Mixed `utf8mb4_general_ci` and `utf8mb4_unicode_ci` | `ALTER TABLE ... CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci` |
| `OperationalError: (2006, MySQL server has gone away)` | Long-running job hit `wait_timeout` | Set `wait_timeout=28800` in MariaDB config; or reconnect in job |
| `Too many connections` | DB connection pool exhausted | Increase `max_connections` in MariaDB or reduce gunicorn workers |
| `OperationalError: (1205, Lock wait timeout exceeded)` | Long transaction holds row lock | Find and kill: `SHOW PROCESSLIST; KILL <id>;` |
| `psycopg2.OperationalError: FATAL: password authentication failed` (PostgreSQL) | Wrong PG password in site_config.json | `bench --site <site> set-config db_password <new>` |
| `redis.exceptions.ConnectionError: Error 111` | Redis not running | `sudo systemctl start redis-server` |
| `rq.queue.Queue is not defined` | Worker version mismatch | `bench setup requirements --python` then restart workers |
| `Email Queue: status='Not Sent'` stuck | Worker not picking up queue | `bench execute frappe.email.doctype.email_queue.email_queue.send_queue` |
| `SMTPAuthenticationError: 535` | Wrong SMTP credentials | Update Email Domain → test SMTP |
| `wkhtmltopdf failed (exit code -11)` | Segfault in wkhtmltopdf (often font/render issue) | Install `fonts-noto` package; use Print Designer format |
| `wkhtmltopdf: command not found` | Binary not installed | `sudo apt install wkhtmltopdf` (use patched Qt version) |
| `Error: Cannot find module 'webpack'` | Node modules not installed | `yarn install` in bench root |
| `Error: Node version mismatch` | Old Node.js | Install Node 18+ via nvm |
| `bench build` fails with `SyntaxError: Unexpected token` | JS syntax not supported by Node version | Upgrade Node; or check custom JS for ES6+ in unsupported context |
| `GET /assets/erpnext/js/... 404` | Assets not built or symlink broken | `bench build` |
| `502 Bad Gateway` | Gunicorn not running or crashed | `sudo supervisorctl restart frappe-bench-web:*` |
| `504 Gateway Timeout` | Request took longer than 60s | Optimize endpoint or increase nginx/gunicorn timeout |
| `Scheduler is disabled for site` | Scheduler explicitly disabled | `bench --site <site> scheduler enable` |
| `PermissionError: [Errno 13] Permission denied: '/path'` | Filesystem permissions wrong | `sudo chown -R <user>:<user> frappe-bench/` |
| `FileNotFoundError: .../config/nginx.conf` | Nginx config not generated | `bench setup nginx --yes` |
| `OSError: [Errno 24] Too many open files` | `ulimit -n` too low | `ulimit -n 65535` and add to `/etc/security/limits.conf` |
| `KeyError: 'frappe'` in console | Site not set | `bench use <site>` or pass `--site <site>` |
| `Could not find site <name>` | Site directory doesn't exist | `bench new-site <name>` or check `sites/` directory |
| `frappe.exceptions.DoesNotExistError: <DocType> <name>` | Document was deleted between fetch and use | Re-fetch or handle the exception |
| `ValidationError: Row #<n>: <field> is mandatory` | Child table row missing required field | Fill the field in the child row before save |
| `TypeError: '<DocType>' object is not iterable` | Code expects list, got single doc | Use `frappe.get_all` for lists; `frappe.get_doc` for single |
| `RecursionError: maximum recursion depth exceeded` | `on_update` hook triggers another `save` infinitely | Use `frappe.flags.in_patch` or guard with `if not self.flags.skip_hook` |

## Where to Learn More

- **Frappe Framework troubleshooting docs**: `https://frappeframework.com/docs/user/en/troubleshooting`
- **ERPNext docs**: `https://docs.frappe.io/erpnext`
- **Frappe Forum (search first — most issues are already answered)**: `https://discuss.frappe.io`
- **GitHub Issues (search before posting)**: `https://github.com/frappe/frappe/issues?q=`
- **Frappe Cloud Status page**: `https://status.frappecloud.com`
- For bench command reference, see `../framework/bench-cli.md`.
- For framework architecture (request lifecycle, workers, scheduler), see `../framework/architecture.md`.
- For Python API patterns (validation, hooks, error handling), see `../framework/python-api.md`.
- For ERPNext customization pitfalls (Custom Fields, Print Formats, Server Scripts), see `../erpnext/customization.md`.
- For app-specific gotchas, see `../apps/ecosystem.md`.
