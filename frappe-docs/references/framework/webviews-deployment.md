# Frappe Framework — Web Views, Portal & Deployment

This file covers building user-facing web pages (portal pages, Web Forms), Jinja templating, and production deployment. Use this when the user wants to build a public-facing Frappe site, custom portal pages, or deploy Frappe to production.

## Table of Contents

1. [Portal Pages](#portal-pages)
2. [Web Forms](#web-forms)
3. [Web Views & Routing](#web-views--routing)
4. [Jinja Templating](#jinja-templating)
5. [Website Settings](#website-settings)
6. [Production Deployment](#production-deployment)
7. [Docker Deployment](#docker-deployment)
8. [Monitoring & Backups](#monitoring--backups)
9. [Security Hardening](#security-hardening)

## Portal Pages

Portal pages are user-facing HTML pages served at a URL like `/my-page`. They use Jinja templates and Python controllers. Use them for customer portals, public forms, knowledge bases, and any non-Desk UI.

### Creating a portal page

Portal pages live in `apps/<app>/<app>/templates/pages/`:

```
my_app/
└── templates/
    └── pages/
        ├── my_page/
        │   ├── __init__.py
        │   ├── my_page.py          ← controller
        │   ├── my_page.html        ← main template
        │   └── my_page.js          ← (optional) client JS
        └── my_page_list.py
```

#### `my_page.py` (controller)

```python
import frappe

def get_context(context):
    """Called before rendering the page. Modify context to inject data."""
    # Add data to template context
    context.tasks = frappe.get_all("Task",
        filters={"owner": frappe.session.user, "status": "Open"},
        fields=["name", "subject", "due_date"]
    )

    context.title = "My Tasks"
    context.parents = [{"label": "Home", "route": "/"}]

    # Access query params
    context.filter = frappe.utils.cstr(frappe.request.args.get("filter"))

    # Restrict access
    if frappe.session.user == "Guest":
        frappe.throw(frappe._("Please login"), frappe.PermissionError)

    # Custom no_cache / no_sitemap
    context.no_cache = 1  # don't cache this page
    context.sitemap = False  # don't include in sitemap.xml
```

#### `my_page.html` (template)

```html
{% extends "templates/web.html" %}

{% block header %}
<h1>{{ title }}</h1>
{% endblock %}

{% block page_content %}
<div class="task-list">
    {% if tasks %}
        <table class="table">
            <thead>
                <tr>
                    <th>{{ _("Subject") }}</th>
                    <th>{{ _("Due Date") }}</th>
                    <th>{{ _("Status") }}</th>
                </tr>
            </thead>
            <tbody>
                {% for task in tasks %}
                <tr>
                    <td>{{ task.subject }}</td>
                    <td>{{ frappe.utils.formatdate(task.due_date) }}</td>
                    <td>{{ task.status }}</td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
    {% else %}
        <p>{{ _("No tasks found.") }}</p>
    {% endif %}
</div>
{% endblock %}
```

The page is accessible at `https://site/my-page` (hyphens converted to underscores).

### Available context variables

Default variables available in any Jinja template:

| Variable | Description |
|---|---|
| `frappe` | Framework module |
| `_` | Translation function |
| `frappe.utils` | Utility functions |
| `frappe.db` | Database interface |
| `frappe.session` | Current session |
| `doc` | Current doc (for `Web Page` and dynamic routes) |
| `request` | Flask request object |
| `path` | Current URL path |
| `user` | Current user's email |
| `csrf_token` | CSRF token for forms |
| `website_settings` | Website Settings singleton |
| `brand_html` | Brand HTML from settings |
| `favicon` | Favicon URL |
| `title` | Page title |
| `metatags` | Open Graph / Twitter card tags |
| `parents` | Breadcrumb trail |
| `no_cache` | Set to True to disable caching |
| `sitemap` | Set to False to exclude from sitemap |
| `sidebar_items` | Sidebar navigation |
| `navbar_items` | Top navbar items |

### Dynamic routes

Use `<variable>` in route to capture URL params:

```python
# templates/pages/task/view.py
def get_context(context):
    # Route: /task/<name>
    task_name = frappe.form_dict.name  # captured from URL
    context.task = frappe.get_doc("Task", task_name)

    if not context.task.has_permission("read"):
        frappe.throw(frappe._("Not permitted"))
```

URL pattern defined in `hooks.py`:

```python
# hooks.py
website_route_rules = [
    {"from_route": "/task/<name>", "to_route": "task/view"},
    {"from_route": "/docs/<category>/<doc>", "to_route": "documentation"}
]
```

### Custom 404 / 500 pages

```python
# hooks.py
website_404 = "myapp.pages.error_page.get_404_context"
website_500 = "myapp.pages.error_page.get_500_context"
```

```python
# myapp/pages/error_page.py
def get_404_context(context):
    context.title = "Page Not Found"
    context.message = "The page you're looking for doesn't exist."
    return "templates/404.html"

def get_500_context(context):
    context.title = "Server Error"
    return "templates/500.html"
```

## Web Forms

Web Forms are configurable public forms for non-Desk users to submit data. Useful for contact forms, surveys, applications, etc.

### Creating a Web Form

1. Desk → Web Form → New
2. Set Title, Route (URL slug), DocType (target DocType to insert into)
3. Add fields (selected from the DocType's fields)
4. Configure:
   - **Login Required**: must be logged in
   - **Allow Edit**: users can edit their submissions
   - **Allow Delete**: users can delete their submissions
   - **Allow Multiple**: users can submit multiple records
   - **Allow Comments**: enable comments on submissions
   - **Show Attachments**: allow file uploads
   - **Allow Print**: show print button
   - **Allow Incomplete**: allow partial saves
5. Add Introduction, Success Message, Sidebar items
6. Save → Publish

The form is accessible at `https://site/<route>`.

### Programmatic Web Form

```python
web_form = frappe.get_doc({
    "doctype": "Web Form",
    "title": "Contact Us",
    "route": "contact-us",
    "doc_type": "Lead",
    "login_required": 0,
    "allow_multiple": 1,
    "introduction_text": "Submit your inquiry",
    "success_message": "Thanks for contacting us!",
    "web_form_fields": [
        {"fieldname": "lead_name", "fieldtype": "Data", "label": "Your Name", "reqd": 1},
        {"fieldname": "email_id", "fieldtype": "Data", "label": "Email", "reqd": 1, "options": "Email"},
        {"fieldname": "message", "fieldtype": "Text", "label": "Message", "reqd": 1}
    ]
})
web_form.insert()
```

### Web Form events (hooks)

```python
# hooks.py
webform_list_row = "myapp.webforms.custom_list_row"
webform_long_form = "myapp.webforms.custom_long_form"

# Or use doc_events
doc_events = {
    "Web Form": {
        "on_update": "myapp.webforms.on_webform_update"
    }
}
```

### Accepting submissions via API

```python
@frappe.whitelist(allow_guest=True)
def submit_web_form(web_form_name, data):
    """Submit a Web Form programmatically."""
    web_form = frappe.get_doc("Web Form", web_form_name)
    doc = frappe.new_doc(web_form.doc_type)
    doc.update(json.loads(data))
    doc.insert(ignore_permissions=True)
    return doc.name
```

## Web Views & Routing

Frappe has multiple URL patterns:

| Pattern | Use case |
|---|---|
| `/app/<doctype>` | Desk list view (HTML) |
| `/app/<doctype>/<name>` | Desk form view (HTML) |
| `/api/resource/<doctype>` | REST API |
| `/api/method/<path>` | Method call |
| `/<page>` | Custom Desk Page |
| `/<web_form_route>` | Web Form |
| `/<portal_page>` | Portal page |
| `/<web_page_slug>` | Web Page (CMS content) |
| `/print/<doctype>/<name>` | Print view |
| `/api/method/frappe.client.print` | Print as PDF |

### Website route rules

```python
# hooks.py
website_route_rules = [
    {"from_route": "/old-url", "to_route": "new-url"},
    {"from_route": "/blog/<post>", "to_route": "blog-post"},
    {"from_route": "/products/<category>/<product>", "to_route": "product-detail"}
]

# Redirects (HTTP 301)
website_redirects = [
    {"source": "/old", "target": "/new", "status_code": 301},
    {"source": r"^/blog/(\d+)/(.*)", "target": r"/article/\2", "status_code": 301}
]
```

### Custom URL handler

```python
# hooks.py
website_path_resolver = "myapp.pages.resolve_path"

# myapp/pages.py
def resolve_path(path):
    """Custom URL resolver. Returns context or path."""
    # Look up custom routes in DB
    custom = frappe.db.get_value("Custom Route", {"route": path}, "target")
    if custom:
        return custom
    return path  # default behavior
```

## Jinja Templating

Frappe uses Jinja2 for templates. Templates are loaded from `templates/` directory in each app.

### Available filters

```python
# Built-in Jinja filters + Frappe-specific:
{{ value | frappe_date_format }}        # format date
{{ value | frappe_datetime_format }}    # format datetime
{{ value | money }}                     # format money
{{ value | duration }}                  # format duration (1h 30m)
{{ value | truncate(140) }}             # truncate text
{{ value | strip_html }}                # strip HTML tags
{{ value | slug }}                      # URL-safe slug
{{ value | json_dumps }}                # JSON serialize
{{ value | strip_whitespace }}          # remove whitespace
```

### Template inheritance

```html
<!-- templates/base.html -->
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}{{ title }}{% endblock %}</title>
    {% block head %}{% endblock %}
</head>
<body>
    {% block header %}{% endblock %}
    {% block content %}{% endblock %}
    {% block footer %}{% endblock %}
</body>
</html>
```

```html
<!-- templates/page.html -->
{% extends "templates/base.html" %}

{% block title %}{{ title }} - {{ brand_html }}{% endblock %}

{% block content %}
<div class="container">
    {{ super() }}
    <h1>{{ title }}</h1>
    {% block page_content %}{% endblock %}
</div>
{% endblock %}
```

### Macros (reusable components)

```html
<!-- templates/macros/ui.html -->
{% macro card(title, body, image=None) %}
<div class="card">
    {% if image %}
    <img src="{{ image }}" alt="{{ title }}">
    {% endif %}
    <div class="card-body">
        <h3>{{ title }}</h3>
        <p>{{ body }}</p>
    </div>
</div>
{% endmacro %}

{% macro button(label, type="primary", href=None, size="md") %}
{% if href %}
<a href="{{ href }}" class="btn btn-{{ type }} btn-{{ size }}">{{ label }}</a>
{% else %}
<button class="btn btn-{{ type }} btn-{{ size }}">{{ label }}</button>
{% endif %}
{% endmacro %}
```

```html
<!-- templates/pages/products.html -->
{% from "templates/macros/ui.html" import card, button %}

{% extends "templates/web.html" %}

{% block page_content %}
<div class="row">
    {% for product in products %}
    <div class="col-md-4">
        {{ card(product.name, product.description, product.image) }}
        {{ button("View", "primary", href="/product/" + product.slug, size="sm") }}
    </div>
    {% endfor %}
</div>
{% endblock %}
```

### Rendering templates from Python

```python
# Render a string
html = frappe.render_template("Hello {{ name }}", {"name": "Alice"})

# Render a file (relative to app's templates/ dir)
html = frappe.render_template("templates/emails/welcome.html", {"user": user_doc})

# Render with full context (auto-includes frappe, _, etc.)
html = frappe.render_template(template_string, context, is_path=False)
```

## Website Settings

Configure site-wide settings via Desk → Website → Website Settings.

### Key settings

| Setting | Description |
|---|---|
| `home_page` | Default landing page (e.g. `/home`) |
| `brand_html` | Brand name / logo HTML |
| `favicon` | Favicon URL |
| `apple_touch_icon` | Apple touch icon URL |
| `title_prefix` | Prefix for `<title>` |
| `title_suffix` | Suffix for `<title>` |
| `enable_footer` | Show footer |
| `footer_address` | Address text |
| `footer_logo` | Footer logo URL |
| `copyright` | Copyright text |
| `google_analytics_id` | GA tracking ID |
| `facebook_pixel_id` | Facebook Pixel ID |
| `twitter_handle` | Twitter @handle |
| `default_metatags` | Default OG/Twitter meta tags |
| `robots_txt` | Custom robots.txt content |
| `header_include` | Custom HTML/JS to include in `<head>` |
| `body_include` | Custom HTML/JS to include before `</body>` |
| `navbar_search` | Show search in navbar |
| `navbar_template` | Custom navbar template path |

### Custom navbar / footer

```python
# hooks.py
website_context = {
    "navbar_template": "templates/includes/custom_navbar.html",
    "footer_template": "templates/includes/custom_footer.html"
}

update_website_context = "myapp.website.update_context"
```

```python
# myapp/website.py
def update_context(context):
    """Called on every page render. Add global context."""
    context.user_can_see_prices = frappe.has_permission("Item Price", "read")
    context.user_full_name = frappe.utils.get_fullname(frappe.session.user)
    context.feature_flags = {
        "enable_chat": frappe.db.get_single_value("My App Settings", "enable_chat")
    }
```

### Sitemap

Frappe auto-generates `sitemap.xml` for all published Web Pages and Web Forms. To exclude a page:

```python
# In page controller
def get_context(context):
    context.sitemap = False
```

To add custom URLs:

```python
# hooks.py
website_generator = "myapp.pages.get_sitemap_urls"

# myapp/pages.py
def get_sitemap_urls():
    return [
        {"loc": "https://site.com/products/widget", "lastmod": "2024-08-07"},
        # ...
    ]
```

## Production Deployment

### Recommended architecture

```
Internet
    ↓
[nginx] (reverse proxy, SSL, static files)
    ↓
[gunicorn] (WSGI, N workers)
    ↓
[MariaDB] (database)
    +
[Redis] (cache + queue + socketio)
    +
[celery workers] (background jobs)
    +
[celery beat] (scheduler)
    +
[socketio server] (realtime)
```

### Step-by-step production setup

```bash
# 1. Install prerequisites (Ubuntu 22.04 example)
sudo apt update
sudo apt install -y python3 python3-pip python3-venv \
    mariadb-server mariadb-client redis-server \
    nodejs npm curl git build-essential \
    xvfb libfontconfig libffi-dev liblcms2-dev \
    libldap2-dev liblibsass-dev libmariadb-dev \
    libpq-dev libtiff5-dev libwebp-dev libxml2-dev \
    libxslt1-dev libjpeg-dev zlib1g-dev
sudo npm install -g yarn
sudo pip3 install frappe-bench

# 2. Configure MariaDB
sudo mysql -u root << 'EOF'
ALTER USER 'root'@'localhost' IDENTIFIED BY 'strong_root_password';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

# 3. Configure MariaDB for Frappe
sudo tee /etc/mysql/mariadb.conf.d/90-frappe.cnf > /dev/null << 'EOF'
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
innodb-buffer-pool-size = 2G  # ~50-70% of total RAM
innodb-log-file-size = 512M
innodb-flush-log-at-trx-commit = 1
innodb-flush-method = O_DIRECT
max-connections = 200
EOF

sudo systemctl restart mariadb

# 4. Create frappe user
sudo useradd -m -s /bin/bash frappe
sudo usermod -aG sudo frappe  # for bench setup production
sudo passwd frappe

# 5. Switch to frappe user and create bench
sudo su - frappe
bench init frappe-bench --frappe-branch version-15
cd frappe-bench
bench get-app https://github.com/frappe/erpnext --branch version-15
bench new-site mysite.example.com --install-app erpnext

# 6. Setup production
sudo bench setup production frappe
sudo bench setup lets-encrypt mysite.example.com
sudo bench setup backends  # regenerate supervisor configs

# 7. Verify
sudo supervisorctl status
sudo systemctl status nginx
curl -I https://mysite.example.com
```

### Update production

```bash
# Switch to frappe user
sudo su - frappe
cd ~/frappe-bench

# Backup first
bench --site mysite.example.com backup --with-files

# Update (pull, migrate, build, restart)
bench update

# If something breaks, restore
bench --site mysite.example.com restore \
    sites/mysite.example.com/private/backups/site_*.sql.gz \
    --with-private-files sites/.../private_files.tar \
    --with-public-files sites/.../public_files.tar
```

## Docker Deployment

Frappe provides official Docker images. Use for containerized deployments.

### Quick start with docker-compose

```bash
git clone https://github.com/frappe/frappe_docker.git
cd frappe_docker

# Edit env file
cp .env.example .env
# Edit .env: set SITE_NAME, DB_ROOT_PASSWORD, ADMIN_PASSWORD, etc.

# Start
docker compose -f compose.yaml -p frappe up -d

# Create site
docker compose -p frappe exec backend \
    bench new-site mysite.localhost \
    --db-root-password password123 \
    --admin-password admin123 \
    --install-app erpnext

# Setup SSL (via Traefik, already configured)
# Edit .env: set your domain, LETSENCRYPT_EMAIL
```

### Custom Dockerfile

```dockerfile
# Dockerfile
FROM frappe/erpnext:v15

# Copy your custom app
COPY ./apps/myapp /home/frappe/frappe-bench/apps/myapp

# Install
USER root
RUN cd /home/frappe/frappe-bench && \
    pip install -e apps/myapp && \
    bench build --app myapp

USER frappe
```

### Kubernetes deployment

For production K8s, use Helm charts from https://github.com/frappe/helm. Key considerations:
- One Deployment per service (backend, scheduler, worker-default, worker-short, worker-long, socketio).
- One StatefulSet for MariaDB, Redis.
- PersistentVolumeClaim for `sites/` directory.
- Ingress with TLS termination.
- HorizontalPodAutoscaler on backend deployment (CPU-based scaling).

## Monitoring & Backups

### Health checks

```bash
# Simple HTTP check
curl -fsS https://mysite.example.com/api/method/ping

# With response time
curl -w "@curl-format.txt" -o /dev/null -s https://mysite.example.com

# curl-format.txt:
# time_namelookup:  %{time_namelookup}\n
# time_connect:  %{time_connect}\n
# time_appconnect:  %{time_appconnect}\n
# time_pretransfer:  %{time_pretransfer}\n
# time_redirect:  %{time_redirect}\n
# time_starttransfer:  %{time_starttransfer}\n
# time_total:  %{time_total}\n
```

### Log monitoring

Use `logrotate` to prevent logs growing indefinitely:

```bash
# /etc/logrotate.d/frappe
/home/frappe/frappe-bench/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
```

For centralized logging, ship logs to:
- **ELK** (Elasticsearch + Logstash + Kibana) via Filebeat
- **Loki + Promtail + Grafana**
- **Datadog / NewRelic / Sentry** via their agents

### Sentry integration

```python
# hooks.py
# Add sentry-sdk to your app's pyproject.toml
# Add to site_config.json:
# {
#   "sentry_dsn": "https://xxx@sentry.io/123"
# }

# In app code (custom):
import sentry_sdk
sentry_dsn = frappe.conf.sentry_dsn
if sentry_dsn:
    sentry_sdk.init(dsn=sentry_dsn, environment="production")

# Or use community Frappe Sentry app: bench get-app https://github.com/frappe/sentry
```

### Backups

```bash
# Manual
bench --site mysite.example.com backup --with-files

# Cron (every night at 2 AM)
crontab -e
# Add:
0 2 * * * cd /home/frappe/frappe-bench && bench --site mysite.example.com backup --with-files >> /home/frappe/backup.log 2>&1

# Cleanup old backups (keep last 7)
find /home/frappe/frappe-bench/sites/mysite.example.com/private/backups -name "*.gz" -mtime +7 -delete
find /home/frappe/frappe-bench/sites/mysite.example.com/private/backups -name "*.tar" -mtime +7 -delete
```

### Off-site backup

```bash
# Sync to S3
aws s3 sync /home/frappe/frappe-bench/sites/mysite.example.com/private/backups/ \
    s3://my-bucket/frappe-backups/$(date +%Y-%m-%d)/

# Or rclone to Google Drive / Backblaze
rclone sync /home/frappe/frappe-bench/sites/mysite.example.com/private/backups/ \
    gdrive:frappe-backups/$(date +%Y-%m-%d)/
```

### Backup verification

```bash
# Test restore in a sandbox
bench --site sandbox.localhost restore /tmp/backup.sql.gz --with-files /tmp/files.tar

# Run a smoke test
bench --site sandbox.localhost execute myapp.tests.smoke_test
```

## Security Hardening

### 1. Use HTTPS only

```nginx
# nginx config
server {
    listen 80;
    server_name mysite.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    # SSL config
    ssl_certificate /etc/letsencrypt/live/mysite.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mysite.example.com/privkey.pem;

    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Other security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
```

### 2. Restrict admin access

```python
# Disable Administrator login from non-localhost
# In hooks.py
before_login = "myapp.security.before_login"

# myapp/security.py
def before_login(login_manager):
    if login_manager.user == "Administrator":
        ip = frappe.local.request_ip
        if not ip.startswith("127.") and ip != "::1":
            frappe.throw("Administrator login not allowed from this IP", frappe.AuthenticationError)
```

### 3. Disable Server Scripts in production

```bash
bench --site mysite.example.com set-config disable_server_scripting true
bench restart
```

### 4. Rate limiting

```json
// site_config.json
{
  "rate_limit": {
    "per_minute": 60,
    "per_hour": 600
  }
}
```

### 5. Strong passwords

```python
# hooks.py
password_policy = "myapp.security.validate_password"

# myapp/security.py
def validate_password(password):
    if len(password) < 12:
        frappe.throw("Password must be at least 12 characters")
    if not any(c.isupper() for c in password):
        frappe.throw("Password must contain uppercase letter")
    # ... etc
```

### 6. Two-factor authentication

Enable via Desk → User → Settings → Two Factor Authentication. Configure globally via System Settings → Security → Two Factor Authentication.

### 7. Audit trail

Enable audit logging:

```python
# hooks.py
doc_events = {
    "*": {
        "on_update": "myapp.audit.log_change"
    }
}

# myapp/audit.py
def log_change(doc, method):
    if doc.doctype in ("Error Log", "Activity Log", "Access Log"):
        return  # don't audit the audit

    log = frappe.get_doc({
        "doctype": "Activity Log",
        "user": frappe.session.user,
        "subject": f"{method} on {doc.doctype} {doc.name}",
        "status": "Success"
    })
    log.db_insert(ignore_permissions=True)
```

### 8. Database security

- Use a dedicated DB user per site (don't share root).
- Restrict DB to listen only on `127.0.0.1` (or use Unix socket).
- Enable MariaDB's `audit_log` plugin for query logging.
- Encrypt backups at rest (`gpg --encrypt backup.sql.gz`).

### 9. File upload security

```python
# Restrict file types
# In hooks.py or custom Server Script
@frappe.whitelist()
def validate_file(file_url):
    allowed = [".pdf", ".jpg", ".png", ".docx"]
    if not any(file_url.endswith(ext) for ext in allowed):
        frappe.throw("File type not allowed")

    # Scan with ClamAV (optional)
    import subprocess
    result = subprocess.run(["clamscan", file_url], capture_output=True)
    if result.returncode != 0:
        frappe.throw("File contains malware")
```

### 10. Regular updates

```bash
# Subscribe to security advisories
# https://github.com/frappe/frappe/security/advisories

# Apply security patches within 7 days
bench update --pull --patch --build --backup
```

## Where to Learn More

- Portal pages: https://docs.frappe.io/framework/user/en/portal-pages
- Web Forms: https://docs.frappe.io/framework/user/en/web-form
- Production setup: https://docs.frappe.io/framework/user/en/production-setup
- Jinja: https://docs.frappe.io/framework/user/en/api/jinja
- Docker deployment: https://github.com/frappe/frappe_docker
