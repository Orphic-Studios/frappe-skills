# Frappe Framework — Bench CLI Reference

`bench` is the command-line interface for managing Frappe installations. Every Frappe operation outside the Desk UI goes through `bench`. This file is the complete reference.

## Table of Contents

1. [Installation & Setup](#installation--setup)
2. [App Management](#app-management)
3. [Site Management](#site-management)
4. [Database Operations](#database-operations)
5. [Migrations & Updates](#migrations--updates)
6. [Background Jobs](#background-jobs)
7. [Cache Management](#cache-management)
8. [Asset Building](#asset-building)
9. [Production Setup](#production-setup)
10. [Backup & Restore](#backup--restore)
11. [Debugging & Diagnostics](#debugging--diagnostics)
12. [Configuration Files](#configuration-files)
13. [Common Workflows](#common-workflows)

## Installation & Setup

### Install bench

```bash
# Prerequisites: Python 3.11+, Node.js 18+, MariaDB 10.8+ (or PostgreSQL 14+), Redis, yarn
# Ubuntu/Debian:
sudo apt install python3 python3-pip python3-venv \
    mariadb-server mariadb-client redis-server \
    nodejs npm curl git \
    xvfb libfontconfig libffi-dev liblcms2-dev \
    libldap2-dev liblibsass-dev libmariadb-dev libpq-dev \
    libtiff5-dev libwebp-dev libxml2-dev libxslt1-dev \
    libjpeg-dev zlib1g-dev

sudo npm install -g yarn

# Install bench
sudo pip3 install frappe-bench

# Verify
bench --version
```

### Initialize a new bench

```bash
bench init frappe-bench
cd frappe-bench

# Custom versions
bench init frappe-bench --frappe-branch version-15
bench init frappe-bench --python python3.11

# Skip assets build (faster init)
bench init frappe-bench --skip-assets
```

This creates:
- `frappe-bench/` directory with apps/, sites/, config/, env/, etc.
- Python virtualenv in `env/`
- Frappe Framework installed in `apps/frappe/`
- Default config files

## App Management

### Install an app

```bash
# From GitHub
bench get-app https://github.com/frappe/erpnext
bench get-app https://github.com/frappe/hrms --branch version-15

# From local path
bench get-app /path/to/my_app

# Custom name (rare)
bench get-app https://github.com/user/repo --name my_custom_app
```

`get-app`:
1. Clones the repo to `apps/<app_name>/`
2. Pip-installs in the bench's virtualenv
3. Registers the app in `sites/apps.txt`

### Install app on a site

```bash
bench --site mysite.localhost install-app erpnext
bench --site mysite.localhost install-app hrms
bench --site mysite.localhost install-app my_custom_app
```

This:
1. Runs the app's `after_install` hook (creates DocTypes, fixtures, etc.)
2. Marks the app as installed for this site in `tabInstalled Application`

### List installed apps

```bash
bench --site mysite.localhost list-apps
# Output:
# frappe 15.x.x
# erpnext 15.x.x
# hrms 15.x.x

# Or check version
bench --site mysite.localhost version
```

### Remove an app

```bash
# Uninstall from site (keeps code)
bench --site mysite.localhost uninstall-app my_custom_app

# Remove code (after uninstall)
bench remove-app my_custom_app
```

### Update apps

```bash
# Pull latest from all apps, migrate, build, restart
bench update

# Pull only
bench update --pull

# Pull + migrate
bench update --pull --patch

# Pull + migrate + build
bench update --pull --patch --build

# Full update with backup
bench update --pull --patch --build --backup

# Skip restart
bench update --no-restart
```

## Site Management

### Create a new site

```bash
bench new-site mysite.localhost

# With options
bench new-site mysite.localhost \
    --db-name mysite_db \
    --db-root-password secret \
    --admin-password admin_secret \
    --mariadb-root-password root_secret

# Install ERPNext during site creation
bench new-site mysite.localhost --install-app erpnext

# Install multiple apps
bench new-site mysite.localhost \
    --install-app frappe \
    --install-app erpnext \
    --install-app hrms
```

### Switch active site

```bash
# Set default site for current bench
bench use mysite.localhost

# Or use --site flag (one-off)
bench --site mysite.localhost console
```

### List sites

```bash
bench site-list
# Output:
# mysite.localhost
# othersite.localhost
```

### Delete a site

```bash
bench --site mysite.localhost drop-site
bench --site mysite.localhost drop-site --archived  # archive instead of delete
```

### Site config

```bash
# Set a config value
bench --site mysite.localhost set-config admin_password "newpass"
bench --site mysite.localhost set-config mail_server "smtp.gmail.com"
bench --site mysite.localhost set-config mail_port 587
bench --site mysite.localhost set-config mail_use_tls 1
bench --site mysite.localhost set-config mail_login "user@gmail.com"
bench --site mysite.localhost set-config mail_password "app_password"
bench --site mysite.localhost set-config mail_from "user@gmail.com"

# Set a secret value (encrypted in site_config.json)
bench --site mysite.localhost set-config mail_password "secret" --as-dict

# Get a config value
bench --site mysite.localhost get-config admin_password

# View full site config
bench --site mysite.localhost get-config

# Remove a config key
bench --site mysite.localhost set-config admin_password "" --as-dict=False
```

### Common site_config.json values

```json
{
  "db_name": "site1_abc",
  "db_user": "site1_abc",
  "db_password": "secret",
  "db_type": "mariadb",
  "db_host": "127.0.0.1",
  "db_port": 3306,
  "host_name": "https://mysite.example.com",
  "admin_password": "...",
  "mail_server": "smtp.gmail.com",
  "mail_port": 587,
  "mail_use_tls": 1,
  "mail_login": "user@gmail.com",
  "mail_password": "app_password",
  "mail_from": "user@gmail.com",
  "disable_server_scripting": false,
  "developer_mode": false,
  "max_file_size": 5242880,
  "rate_limit": {"per_minute": 60, "per_hour": 600},
  "encryption_key": "...",
  "session_expiry": "06:00:00",
  "rest_api_secret": "..."
}
```

### common_site_config.json (bench-level)

Lives at `sites/common_site_config.json`, applies to all sites:

```json
{
  "db_host": "127.0.0.1",
  "db_port": 3306,
  "redis_cache": "redis://localhost:13000",
  "redis_queue": "redis://localhost:11000",
  "redis_socketio": "redis://localhost:13000",
  "webserver_port": 8000,
  "socketio_port": 9000,
  "file_watcher_port": 6787,
  "workers": 4,
  "background_workers": 1,
  "gunicorn_workers": 4,
  "gunicorn_timeout": 120,
  "developer_mode": 0,
  "serve_default_site": true,
  "auto_update": false,
  "frappe_user": "frappe",
  "shallow_clone": false,
  "admin_password": "...",
  "root_password": "...",
  "host_root": "/var/lib/docker"
}
```

## Database Operations

### Direct DB access

```bash
# Drop into MariaDB shell
bench --site mysite.localhost mariadb

# Run a query
bench --site mysite.localhost mariadb -e "SELECT COUNT(*) FROM tabTask"

# Backup DB only
bench --site mysite.localhost backup --db-only

# Restore DB only
bench --site mysite.localhost restore /path/to/backup.sql --db-only
```

### Force DB type

```bash
# PostgreSQL site
bench new-site mysite.localhost --db-type postgres --db-root-password secret
```

### Force DB host

```bash
bench new-site mysite.localhost --db-host db.example.com --db-root-password secret
```

### Reload DB schema cache

```bash
bench --site mysite.localhost reload-doc myapp.tasks.doctype.task
```

## Migrations & Updates

### Run migrations

```bash
# Apply all pending migrations (DocType sync + patches)
bench --site mysite.localhost migrate

# Migrate all sites
bench migrate

# Migrate with verbose
bench --site mysite.localhost migrate --verbose

# Skip patches (only DocType sync)
bench --site mysite.localhost migrate --skip-patches

# Skip search index rebuild
bench --site mysite.localhost migrate --skip-search
```

### Run a specific patch

```bash
bench --site mysite.localhost run-patch myapp.v1_0.migrate_status
```

### Sync a single DocType

```bash
# Reload DocType definition from JSON
bench --site mysite.localhost reload-doc myapp.tasks.doctype.task
```

### Reinstall site (DESTRUCTIVE)

```bash
# Drops all data and re-installs
bench --site mysite.localhost reinstall
```

### Reset site

```bash
# Reset permissions and roles to default
bench --site mysite.localhost reset-permissions
```

## Background Jobs

### Start workers

```bash
# Start dev server (web + worker + scheduler + socketio)
bench start

# Or start workers separately (production)
bench worker --queue default
bench worker --queue short
bench worker --queue long

# Start scheduler
bench schedule
```

### Job management

```bash
# List pending jobs
bench --site mysite.localhost pending-jobs

# Disable scheduler
bench --site mysite.localhost scheduler disable

# Enable scheduler
bench --site mysite.localhost scheduler enable

# Pause scheduler (no new jobs picked up)
bench --site mysite.localhost scheduler pause

# Resume scheduler
bench --site mysite.localhost scheduler resume
```

## Cache Management

### Clear caches

```bash
# Clear cache for one site
bench --site mysite.localhost clear-cache

# Clear website cache (portal pages)
bench --site mysite.localhost clear-website-cache

# Clear cache for all sites
bench clear-cache
```

### Rebuild search index

```bash
bench --site mysite.localhost rebuild-search

# For specific doctype
bench --site mysite.localhost rebuild-search --doctype Task
```

### Reset bench

```bash
# Reset all caches, sessions, search index
bench --site mysite.localhost clear-cache
bench --site mysite.localhost clear-website-cache
bench --site mysite.localhost reload-doc myapp.tasks.doctype.task
bench --site mysite.localhost rebuild-search
```

## Asset Building

### Build assets

```bash
# Build all apps
bench build

# Build one app
bench build --app myapp

# Build specific apps
bench build --app frappe --app erpnext

# Production build (minified, no source maps)
bench build --production

# Watch mode (rebuild on file change)
bench watch
```

### Clean assets

```bash
# Remove all built assets (then run bench build)
bench build --clean
```

### Build translations

```bash
bench --site mysite.localhost compile-translations frappe
bench --site mysite.localhost compile-translations erpnext
bench --site mysite.localhost compile-translations myapp
```

### Download translations

```bash
bench --site mysite.localhost download-translations ar
```

## Production Setup

### Switch to production mode

```bash
# Setup production with supervisor + nginx
sudo bench setup production frappe

# Setup letsencrypt SSL
sudo bench setup lets-encrypt mysite.example.com

# Setup backends (regenerate supervisor config)
bench setup backends

# Setup manager (bench manager UI)
bench setup manager
```

### Restart production services

```bash
# Restart everything (web, workers, scheduler)
bench restart

# Restart specific service
sudo supervisorctl restart frappe-bench-web:frappe-bench-frappe-web
sudo supervisorctl restart frappe-bench-workers:frappe-bench-default-worker
sudo supervisorctl restart frappe-bench-workers:frappe-bench-short-worker
sudo supervisorctl restart frappe-bench-workers:frappe-bench-long-worker
sudo supervisorctl restart frappe-bench-schedule

# Reload nginx
sudo systemctl reload nginx

# Reload supervisor config (after editing)
sudo supervisorctl reread
sudo supervisorctl update
```

### Check status

```bash
# All supervisor processes
sudo supervisorctl status

# Nginx status
sudo systemctl status nginx

# MariaDB status
sudo systemctl status mariadb

# Redis status
sudo systemctl status redis-server
```

## Backup & Restore

### Take a backup

```bash
# Backup current site (DB + files)
bench --site mysite.localhost backup

# Backup with verbose
bench --site mysite.localhost backup --verbose

# Backup DB only
bench --site mysite.localhost backup --db-only

# Backup files only
bench --site mysite.localhost backup --files-only

# Backup with compression
bench --site mysite.localhost backup --compress

# Backup to specific path
bench --site mysite.localhost backup --backup-path /backups/special/
```

Backups are saved to `sites/<site>/private/backups/`:
- `<site>_database_<timestamp>.sql.gz` (DB dump)
- `<site>_private_files_<timestamp>.tar` (private file uploads)
- `<site>_public_files_<timestamp>.tar` (public file uploads)

### Restore from backup

```bash
# Restore (overwrites current site)
bench --site mysite.localhost restore /path/to/database.sql.gz

# Restore with files
bench --site mysite.localhost restore /path/to/database.sql.gz \
    --with-private-files /path/to/private_files.tar \
    --with-public-files /path/to/public_files.tar

# Restore DB only
bench --site mysite.localhost restore /path/to/database.sql.gz --db-only

# Restore with admin password reset
bench --site mysite.localhost restore /path/to/database.sql.gz \
    --admin-password newpassword

# Restore to a different site (creates if needed)
bench --site newsite.localhost restore /path/to/database.sql.gz
```

### Scheduled backups

Add to `hooks.py`:

```python
scheduler_events = {
    "daily": ["frappe.utils.backups.take_backups_daily"],
    "weekly": ["frappe.utils.backups.take_backups_weekly"]
}
```

Or use the built-in scheduler:
- Daily: `frappe.utils.backups.scheduled_backup`
- Weekly: `frappe.utils.backups.scheduled_backup_all_sites`

### Backup rotation

Configure in `site_config.json`:

```json
{
  "backup_limit": 3
}
```

## Debugging & Diagnostics

### Doctor

```bash
# Diagnose common issues
bench doctor

# Check site health
bench --site mysite.localhost doctor
```

### Logs

```bash
# Tail web log
tail -f logs/web.log

# Tail worker log
tail -f logs/worker.log

# Tail scheduler log
tail -f logs/schedule.log

# Tail Frappe app log
tail -f logs/frappe.log

# Tail error log
tail -f logs/error.log

# Per-site logs
tail -f sites/mysite.localhost/logs/*.log
```

### Console

```bash
# Python shell with Frappe context
bench --site mysite.localhost console

# Run a single command
bench --site mysite.localhost execute 'frappe.client.get_count' --kwargs '{"doctype":"Task"}'

# Run a script
bench --site mysite.localhost execute myapp.utils.do_something --args '["arg1"]'
```

### Reset permissions

```bash
bench --site mysite.localhost reset-permissions
```

### Reset cache (when things are weird)

```bash
bench --site mysite.localhost clear-cache
bench --site mysite.localhost clear-website-cache
bench --site mysite.localhost rebuild-search

# If still broken, also:
bench --site mysite.localhost reload-doc frappe.core.doctype.user.user

# Nuclear option: reinstall cache (do not run in production)
bench --site mysite.localhost migrate --skip-fails
```

### Profile slow requests

```bash
# Enable profiling
bench --site mysite.localhost set-config profiling true

# Make a request, then check
bench --site mysite.localhost profiler
```

## Configuration Files

### `apps.txt`

List of installed apps. One per line:

```
frappe
erpnext
hrms
myapp
```

### `sites/currentsite.txt`

The active site name. Set by `bench use`.

### `sites/apps.txt`

Apps available to install on sites (subset of `apps/`).

### `common_site_config.json`

Bench-level config (applies to all sites). See [above](#common_site_configjson-bench-level).

### `site_config.json`

Per-site config (in `sites/<site>/`). See [above](#site_configjson-1).

### `bench/setup/config.py`

Generated supervisor/nginx config files:

- `config/supervisor.conf`
- `config/nginx.conf`
- `config/redis_cache.conf`
- `config/redis_queue.conf`
- `config/redis_socketio.conf`

## Common Workflows

### Setup new ERPNext site from scratch

```bash
bench init frappe-bench --frappe-branch version-15
cd frappe-bench
bench get-app https://github.com/frappe/erpnext --branch version-15
bench new-site mysite.localhost --install-app erpnext
bench --site mysite.localhost set-config developer_mode 1
bench start
```

Visit http://mysite.localhost:8000 → login with Administrator / admin password.

### Install Frappe HR alongside ERPNext

```bash
bench get-app https://github.com/frappe/hrms --branch version-15
bench --site mysite.localhost install-app hrms
bench --site mysite.localhost migrate
```

### Deploy a custom app

```bash
# In development
bench get-app /path/to/myapp
bench --site mysite.localhost install-app myapp
bench --site mysite.localhost migrate

# From git
bench get-app https://github.com/myorg/myapp
bench --site mysite.localhost install-app myapp
```

### Update to latest version

```bash
# Backup first!
bench --site mysite.localhost backup

# Pull + patch + build + restart
bench update

# If migrations fail, restore from backup
bench --site mysite.localhost restore sites/mysite.localhost/private/backups/database.sql.gz
```

### Move site to new server

```bash
# On old server
bench --site mysite.localhost backup --with-files
# Copy the .sql.gz and .tar files to new server

# On new server
bench init newbench
cd newbench
bench get-app erpnext
bench new-site mysite.localhost --install-app erpnext
bench --site mysite.localhost restore /path/to/database.sql.gz \
    --with-private-files /path/to/private_files.tar \
    --with-public-files /path/to/public_files.tar

bench --site mysite.localhost migrate
bench --site mysite.localhost clear-cache
```

### Recover from failed update

```bash
# Check what failed
bench --site mysite.localhost doctor
cat logs/error.log | tail -100

# If a patch failed, skip it temporarily
bench --site mysite.localhost set-config skip_failing_patches true
bench --site mysite.localhost migrate

# If migrations are stuck (lock file)
ls sites/mysite.localhost/locks/
rm sites/mysite.localhost/locks/migration.lock  # CAREFUL

# If site is broken
bench --site mysite.localhost restore /path/to/last_good_backup.sql.gz
```

### Setup SSL with Let's Encrypt

```bash
# Prerequisites: domain pointing to server, port 80 open
sudo bench setup lets-encrypt mysite.example.com

# Auto-renew (cron entry added automatically)
# Check: sudo crontab -l
```

### Multi-site setup

```bash
bench init frappe-bench
cd frappe-bench
bench get-app erpnext

# Create multiple sites
bench new-site site1.example.com --install-app erpnext
bench new-site site2.example.com --install-app erpnext

# Each site is isolated, but they share the bench (apps, code)
# Switch active site
bench use site1.example.com

# Or operate per-site
bench --site site1.example.com console
bench --site site2.example.com console

# Setup production (all sites via single nginx config)
sudo bench setup production frappe
```

### Disable Server Scripts in production

```bash
bench --site mysite.localhost set-config disable_server_scripting true
bench restart
```

### Enable developer mode (faster dev iteration)

```bash
bench --site mysite.localhost set-config developer_mode 1
bench --site mysite.localhost clear-cache
```

Effects of developer mode:
- DocTypes are not minified on save (readable JSON).
- Templates are reloaded on each request (no cache).
- Server Scripts are reloaded on each request.
- Asset bundling is disabled.
- More verbose error messages.

### Check bench version

```bash
bench --version
# Output: 5.x.x

# Check Frappe version
bench --site mysite.localhost version
# Output: 15.x.x
```

## Troubleshooting Common Issues

### `bench` command not found

```bash
# Add pip bin to PATH
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
source ~/.bashrc

# Or install with --user
pip3 install --user frappe-bench
```

### Permission denied

```bash
# Files owned by root, can't write
sudo chown -R $USER:$USER frappe-bench/

# Or use bench fix-perms
bench fix-permissions
```

### MariaDB connection refused

```bash
# Check MariaDB is running
sudo systemctl status mariadb
sudo systemctl start mariadb

# Check root password
sudo mariadb -u root -p

# Reset root password
sudo systemctl stop mariadb
sudo mysqld_safe --skip-grant-tables &
mariadb -u root
> UPDATE mysql.user SET authentication_string=PASSWORD('newpass') WHERE User='root';
> FLUSH PRIVILEGES;
> exit
sudo systemctl start mariadb
```

### Redis connection refused

```bash
sudo systemctl status redis-server
sudo systemctl start redis-server
```

### Port already in use

```bash
# Find what's using port 8000
sudo lsof -i :8000

# Kill it
sudo kill -9 <PID>

# Or use a different port
bench start --port 8001
```

### Migration fails with "Tablestorage engine doesn't support"

```bash
# MariaDB needs InnoDB, not MyISAM
bench --site mysite.localhost mariadb -e "ALTER TABLE tabTask ENGINE=InnoDB;"
```

### Site shows 404

```bash
# Check currentsite.txt
cat sites/currentsite.txt

# Or set explicitly
bench use mysite.localhost
```

### Worker jobs stuck

```bash
# Check worker process
sudo supervisorctl status | grep worker

# Restart workers
sudo supervisorctl restart frappe-bench-workers:frappe-bench-default-worker
sudo supervisorctl restart frappe-bench-workers:frappe-bench-short-worker
sudo supervisorctl restart frappe-bench-workers:frappe-bench-long-worker

# Clear queue
redis-cli -n 0 flushdb   # queue DB
redis-cli -n 1 flushdb   # cache DB
```

## Where to Learn More

- Live docs: https://docs.frappe.io/framework/user/en/bench/bench-commands
- Production setup: https://docs.frappe.io/framework/user/en/production-setup
- Troubleshooting: https://docs.frappe.io/framework/user/en/debugging
