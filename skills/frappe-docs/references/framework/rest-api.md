# Frappe Framework — REST API Reference

Frappe Framework auto-generates REST endpoints for every DocType. You can also expose arbitrary Python methods. This file is the complete reference.

## Table of Contents

1. [Authentication](#authentication)
2. [Resource Endpoints (CRUD)](#resource-endpoints-crud)
3. [Method Endpoints](#method-endpoints)
4. [Query Parameters](#query-parameters)
5. [Filtering](#filtering)
6. [Pagination](#pagination)
7. [File Upload](#file-upload)
8. [Error Responses](#error-responses)
9. [Special Endpoints](#special-endpoints)
10. [Examples](#examples)

## Authentication

Three mechanisms are supported.

### 1. Token-based (recommended for API clients)

Each user can generate an API Key + Secret pair from their User record (Settings → API Access → Generate Keys). The token is `api_key:api_secret`.

```bash
curl -H "Authorization: token API_KEY:API_SECRET" \
  https://example.com/api/method/frappe.auth.get_logged_user
```

```python
import requests
resp = requests.get(
    "https://example.com/api/resource/Task",
    headers={"Authorization": "token API_KEY:API_SECRET"}
)
```

```javascript
fetch("https://example.com/api/resource/Task", {
    headers: { Authorization: "token API_KEY:API_SECRET" }
})
```

### 2. Password-based (session cookie)

Use `/api/method/login` to start a session. Save cookies for subsequent requests.

```bash
# Login (cookie jar saved to file)
curl --cookie-jar cookies.txt -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"usr":"user@example.com","pwd":"password"}' \
  https://example.com/api/method/login

# Subsequent requests reuse cookie
curl --cookie cookies.txt https://example.com/api/resource/Task
```

Response:

```json
{
  "message": "Logged In",
  "home_page": "/app",
  "full_name": "John Doe",
  "dashboard_route": "/sites"
}
```

### 3. OAuth2 access token

Configure OAuth2 client in Desk → OAuth → OAuth Client. Use the standard OAuth2 flow to get an access token.

```bash
curl -H "Authorization: Bearer ACCESS_TOKEN" \
  https://example.com/api/resource/Task
```

### Logout

```bash
curl --cookie cookies.txt https://example.com/api/method/logout
```

## Resource Endpoints (CRUD)

Base path: `/api/resource/<doctype>[/<name>]`

### List documents

```bash
# All tasks (default 20 per page)
GET /api/resource/Task

# Specific fields
GET /api/resource/Task?fields=["name","subject","status"]

# With filters
GET /api/resource/Task?filters=[["status","=","Open"],["priority","=","High"]]

# As dict-style filters (URL-encoded JSON)
GET /api/resource/Task?filters=%7B%22status%22%3A%20%22Open%22%7D

# Pagination
GET /api/resource/Task?limit_page_length=100&limit_start=200

# Sort
GET /api/resource/Task?order_by=creation%20desc
```

Response:

```json
{
  "data": [
    {
      "name": "TASK00001",
      "subject": "First task",
      "status": "Open"
    },
    {
      "name": "TASK00002",
      "subject": "Second task",
      "status": "Open"
    }
  ]
}
```

### Get one document

```bash
GET /api/resource/Task/TASK00001
```

Response:

```json
{
  "data": {
    "name": "TASK00001",
    "owner": "admin@example.com",
    "creation": "2024-08-07 10:30:00",
    "modified": "2024-08-07 10:30:00",
    "docstatus": 0,
    "subject": "First task",
    "status": "Open",
    "items": [
      {"name": "ITEM001", "item_code": "X", "qty": 2}
    ]
  }
}
```

### Create

```bash
POST /api/resource/Task
Content-Type: application/json

{
  "subject": "New task",
  "status": "Open",
  "items": [
    {"item_code": "X", "qty": 2}
  ]
}
```

Response:

```json
{
  "data": {
    "name": "TASK00010",
    "subject": "New task",
    "status": "Open",
    "items": [...]
  }
}
```

### Update

```bash
PUT /api/resource/Task/TASK00001
Content-Type: application/json

{
  "status": "Closed"
}
```

### Delete

```bash
DELETE /api/resource/Task/TASK00001
```

### Run DocType method

```bash
# Calls the controller method on the doc
POST /api/resource/Task/TASK00001/?run_method=mark_complete
```

Or use the method endpoint pattern:

```bash
POST /api/method/frappe.client.run_doc_method
Content-Type: application/json

{
  "dt": "Task",
  "dn": "TASK00001",
  "method": "mark_complete"
}
```

## Method Endpoints

Call any whitelisted Python method via its dotted path.

```bash
POST /api/method/<dotted.path.to.method>
GET  /api/method/<dotted.path.to.method>
```

The dotted path follows `<app>.<module>.<function>` or `<app>.<module>.<Class>.<method>` (instance methods on controllers can be called by passing the docname).

### Passing arguments

For GET requests, use query parameters:

```bash
GET /api/method/frappe.client.get?doctype=Task&name=TASK00001
```

For POST requests, use either form-encoded body or JSON:

```bash
# Form-encoded
curl -X POST -d "arg1=foo" -d "arg2=bar" \
  https://example.com/api/method/myapp.api.do_something

# JSON body
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"arg1":"foo","arg2":"bar"}' \
  https://example.com/api/method/myapp.api.do_something
```

### Whitelisting

A method must be decorated with `@frappe.whitelist()` to be callable via REST:

```python
import frappe

@frappe.whitelist()
def do_something(arg1, arg2=None):
    return {"result": arg1, "arg2": arg2}

@frappe.whitelist()
def with_files(arg1):
    # args can also be files
    return {"size": len(frappe.request.files)}
```

### Calling controller methods

To call a method on a specific document:

```python
# myapp/tasks/doctype/task/task.py
class Task(Document):
    @frappe.whitelist()
    def mark_complete(self, comment=None):
        self.status = "Completed"
        self.save()
        return "ok"
```

```bash
curl -X POST \
  -H "Authorization: token ..." \
  -d "comment=Done" \
  https://example.com/api/method/myapp.tasks.doctype.task.task.mark_complete
```

Wait — that's calling a method on the class, not an instance. To call on an instance:

```bash
# Use frappe.client.run_doc_method
POST /api/method/frappe.client.run_doc_method
{
  "dt": "Task",
  "dn": "TASK00001",
  "method": "mark_complete",
  "args": {"comment": "Done"}
}
```

## Query Parameters

Common parameters for list endpoints:

| Param | Description | Example |
|---|---|---|
| `fields` | JSON array of field names | `["name","subject"]` |
| `filters` | JSON filter expression | `[["status","=","Open"]]` |
| `or_filters` | JSON filter (OR) | `[["status","=","Open"],["priority","=","High"]]` |
| `order_by` | `field ASC\|DESC` | `creation desc` |
| `limit_start` | Offset (default 0) | `20` |
| `limit_page_length` | Page size (default 20, max 500) | `100` |
| `view` | Name of a saved view | `Open Tasks` |
| `group_by` | Group by field | `status` |
| `distinct` | Return distinct rows | `true` |

## Filtering

### Dict-style filters

URL-encoded JSON object:

```bash
?filters={"status":"Open","priority":"High"}
```

### List-of-lists filters

More powerful, supports all operators:

```bash
?filters=[["status","=","Open"],["priority","in",["High","Medium"]]]
```

### Operators

| Operator | Description |
|---|---|
| `=`, `!=` | Equal / not equal |
| `>`, `<`, `>=`, `<=` | Comparison |
| `like`, `not like` | SQL LIKE (use `%` wildcard) |
| `in`, `not in` | List membership |
| `is`, `is not` | NULL check (`is set` / `is not set`) |
| `between`, `not between` | Range (dates) |
| `timespan` | Predefined period (`today`, `yesterday`, `this week`, `this month`, `last month`, `this quarter`, `this year`, `last year`) |
| `previous` | Previous N days (`previous 7 days`) |
| `next` | Next N days (`next 7 days`) |

### Cross-table filters

Use dot notation to filter on linked DocTypes:

```bash
?filters=[["project.status","=","Open"]]
```

This filters Tasks whose linked Project has status=Open.

## Pagination

```bash
# Page 1 (default)
GET /api/resource/Task?limit_page_length=20&limit_start=0

# Page 2
GET /api/resource/Task?limit_page_length=20&limit_start=20

# Get all (careful — may be slow)
GET /api/resource/Task?limit_page_length=0
```

**Note:** `limit_page_length=0` returns ALL records, but the framework may cap it for safety. To get all records in batches, loop:

```python
import requests

API = "https://example.com/api/resource"
HEADERS = {"Authorization": "token KEY:SECRET"}

def fetch_all(doctype):
    page_size = 500
    offset = 0
    while True:
        resp = requests.get(
            f"{API}/{doctype}",
            headers=HEADERS,
            params={"limit_page_length": page_size, "limit_start": offset}
        )
        data = resp.json().get("data", [])
        if not data:
            break
        yield from data
        if len(data) < page_size:
            break
        offset += page_size

for task in fetch_all("Task"):
    print(task["name"])
```

## File Upload

### Via multipart form

```bash
curl -X POST \
  -H "Authorization: token ..." \
  -F "file=@/path/to/file.pdf" \
  -F "is_private=1" \
  -F "doctype=Task" \
  -F "docname=TASK00001" \
  https://example.com/api/method/upload_file
```

Response:

```json
{
  "message": {
    "name": "FILE-001",
    "file_name": "file.pdf",
    "file_url": "/private/files/file_<hash>.pdf",
    "is_private": 1
  }
}
```

### Via base64

```bash
curl -X POST \
  -H "Authorization: token ..." \
  -H "Content-Type: application/json" \
  -d '{
    "cmd": "frappe.handler.upload_file",
    "filename": "test.txt",
    "content_base64": "SGVsbG8gd29ybGQ=",
    "doctype": "Task",
    "docname": "TASK00001"
  }' \
  https://example.com/
```

### Download

```bash
# Public file
curl https://example.com/files/document.pdf -o document.pdf

# Private file (requires auth)
curl -H "Authorization: token ..." \
  https://example.com/private/files/document_<hash>.pdf -o document.pdf
```

## Error Responses

Errors return appropriate HTTP status codes with a JSON body:

```json
{
  "exc_type": "PermissionError",
  "exception": "frappe.exceptions.PermissionError",
  "_server_messages": "[\"{\\\"message\\\":\\\"Not permitted\\\",\\\"title\\\":\\\"Message\\\"}\"]",
  "_error_message": "Not permitted"
}
```

Common status codes:
- `200` — Success
- `400` — Bad request (validation error)
- `401` — Unauthorized (no auth or invalid token)
- `403` — Forbidden (authenticated but not permitted)
- `404` — Not found
- `409` — Conflict (e.g., duplicate name)
- `413` — Payload too large (file upload exceeded limit)
- `417` — Expectation failed (CSRF token missing)
- `429` — Rate limit exceeded
- `500` — Server error (logged to `tabError Log`)

## Special Endpoints

### Login / Logout

```bash
POST /api/method/login      # body: {usr, pwd}
GET  /api/method/logout
```

### User info

```bash
GET /api/method/frappe.auth.get_logged_user
GET /api/method/frappe.auth.get_user_details
```

### System info

```bash
GET /api/method/frappe.client.get_count?doctype=Task
GET /api/method/frappe.client.get_count?doctype=Task&filters=[["status","=","Open"]]
```

### Generic client methods

Frappe provides generic helpers at `frappe.client.*`:

```bash
# Get a single doc
GET /api/method/frappe.client.get?doctype=Task&name=TASK00001

# Get list
GET /api/method/frappe.client.get_list?doctype=Task&fields=["name"]&filters=[["status","=","Open"]]

# Get count
GET /api/method/frappe.client.get_count?doctype=Task

# Insert
POST /api/method/frappe.client.insert
{ "doc": {"doctype":"Task","subject":"New"} }

# Update
POST /api/method/frappe.client.set_value
{ "doctype":"Task","name":"TASK00001","fieldname":"status","value":"Closed" }

# Save (existing doc, with body)
POST /api/method/frappe.client.save
{ "doc": {"doctype":"Task","name":"TASK00001","status":"Closed"} }

# Submit
POST /api/method/frappe.client.submit
{ "doclist": [{"doctype":"Task","name":"TASK00001"}] }

# Cancel
POST /api/method/frappe.client.cancel
{ "doctype":"Task","name":"TASK00001" }

# Delete
POST /api/method/frappe.client.delete
{ "doctype":"Task","name":"TASK00001" }

# Rename
POST /api/method/frappe.client.rename
{ "doctype":"Task","old_name":"TASK00001","new_name":"TASK00099" }

# Get value (single)
GET /api/method/frappe.client.get_value?doctype=Task&fieldname=status&name=TASK00001

# Get print format HTML
GET /api/method/frappe.client.print?doctype=Task&name=TASK00001&print_format=Standard

# Run server method on a doc
POST /api/method/frappe.client.run_doc_method
{ "dt":"Task","dn":"TASK00001","method":"mark_complete" }
```

### Search

```bash
# Universal search (across all doctypes)
GET /api/method/frappe.desk.search.search_link?doctype=Task&txt=keyword&limit=10
```

### Bulk operations

```bash
POST /api/method/frappe.client.insert_many
{ "docs": [{"doctype":"Task","subject":"A"},{"doctype":"Task","subject":"B"}] }
```

## Examples

### Python client

```python
import requests

API = "https://example.com/api"
AUTH = ("api_key", "api_secret")  # basic auth also works
HEADERS = {"Authorization": f"token {AUTH[0]}:{AUTH[1]}"}

# Create a task
resp = requests.post(
    f"{API}/resource/Task",
    headers=HEADERS,
    json={"subject": "Test", "status": "Open"}
)
task = resp.json()["data"]

# List tasks
resp = requests.get(
    f"{API}/resource/Task",
    headers=HEADERS,
    params={
        "fields": '["name","subject"]',
        "filters": '[["status","=","Open"]]',
        "limit_page_length": 50
    }
)
tasks = resp.json()["data"]

# Update
requests.put(
    f"{API}/resource/Task/{task['name']}",
    headers=HEADERS,
    json={"status": "Closed"}
)

# Delete
requests.delete(
    f"{API}/resource/Task/{task['name']}",
    headers=HEADERS
)

# Call custom method
requests.post(
    f"{API}/method/myapp.api.calculate_stats",
    headers=HEADERS,
    json={"start_date": "2024-01-01", "end_date": "2024-12-31"}
)
```

### JavaScript client (browser)

```javascript
// From within Frappe Desk (auth handled automatically)
frappe.call({
  method: "frappe.client.get_list",
  args: {
    doctype: "Task",
    fields: ["name", "subject"],
    filters: [["status", "=", "Open"]],
    limit_page_length: 50
  },
  callback: r => console.log(r.message)
});

// File upload
const formData = new FormData();
formData.append("file", fileInput.files[0]);
formData.append("doctype", "Task");
formData.append("docname", "TASK00001");

fetch("/api/method/upload_file", {
  method: "POST",
  body: formData,
  headers: {
    "X-Frappe-CSRF-Token": frappe.csrf_token
  }
});
```

### curl examples

```bash
# CRUD cycle
TOKEN="api_key:api_secret"
BASE="https://example.com/api"

# Create
NEW=$(curl -s -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"subject":"Test task","status":"Open"}' \
  $BASE/resource/Task | jq -r .data.name)

echo "Created: $NEW"

# Read
curl -s -H "Authorization: token $TOKEN" \
  $BASE/resource/Task/$NEW | jq .

# Update
curl -s -X PUT \
  -H "Authorization: token $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"Closed"}' \
  $BASE/resource/Task/$NEW | jq .

# Delete
curl -s -X DELETE \
  -H "Authorization: token $TOKEN" \
  $BASE/resource/Task/$NEW
```

### Pagination with cursor

For very large datasets, use the Query Builder with cursors:

```python
import requests

# Stream all rows in batches
batch_size = 500
offset = 0
while True:
    resp = requests.get(
        f"{BASE}/resource/LargeTable",
        headers=HEADERS,
        params={"limit_page_length": batch_size, "limit_start": offset}
    )
    rows = resp.json()["data"]
    if not rows:
        break
    for row in rows:
        process(row)
    if len(rows) < batch_size:
        break
    offset += batch_size
```

## Best Practices

1. **Always set timeouts** on outgoing requests — Frappe's web workers will hang otherwise.
2. **Use token auth** for server-to-server, session auth for browser-based.
3. **Batch operations** — `insert_many` is much faster than 100 separate `POST /resource/...` calls.
4. **Respect rate limits** — Frappe has built-in rate limiting on login and some endpoints; configure additional limits in `site_config.json` if needed.
5. **Handle errors gracefully** — check `r.exc` and `_server_messages` in response.
6. **Don't expose admin tokens** in client-side JS — proxy through your own backend.
7. **Use HTTPS** in production — tokens are sent in clear text over HTTP.
8. **Cache read responses** when possible — Frappe doesn't set Cache-Control headers by default.

## Versioning

Frappe doesn't version its REST API by URL path (no `/api/v2/...`). Instead, behavior is tied to the framework version installed on the site. Always check the framework version if your client depends on specific behavior:

```bash
GET /api/method/frappe.client.version
# → "16.x.x"
```
