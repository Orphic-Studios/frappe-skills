# Frappe Docs Index — URL Map for Live Fetches

This file is the **URL map** for fetching live documentation from `https://docs.frappe.io/`. Use it when you need the very latest API signatures, version-specific behavior, or edge-case details not covered in the bundled reference files.

## How to Fetch a Live Page

Use the `page_reader` function via z-ai CLI:

```bash
z-ai function -n page_reader -a '{"url": "https://docs.frappe.io/framework/user/en/api/document"}' -o /tmp/page.json
```

Or in JS:

```javascript
const zai = await ZAI.create();
const result = await zai.functions.invoke('page_reader', {
  url: 'https://docs.frappe.io/framework/user/en/api/document'
});
// result.data.html contains the page HTML
// result.data.title is the page title
```

The HTML returned contains the full page chrome (nav, header, footer). To extract just the article content, look for the main content `<div>` — usually has class `markdown-section` or similar. Strip nav/footer with regex.

## Base URLs by Product

| Product | Base URL | Notes |
|---|---|---|
| Frappe Framework | `https://docs.frappe.io/framework/user/en/` | Most API docs are here |
| ERPNext | `https://docs.frappe.io/erpnext/` | Each topic is a flat slug |
| Frappe HR (HRMS) | `https://docs.frappe.io/hr/` | Also bundled in ERPNext |
| Frappe CRM | `https://docs.frappe.io/crm/` | |
| Frappe Cloud | `https://docs.frappe.io/cloud/` | |
| Frappe Drive | `https://docs.frappe.io/drive/` | |
| Frappe Learning (LMS) | `https://docs.frappe.io/learning/` | |
| Frappe Insights | `https://docs.frappe.io/insights/` | |
| Frappe Builder | `https://docs.frappe.io/builder/` | |
| Frappe Print Designer | `https://docs.frappe.io/print-designer/` | |
| Frappe Wiki | `https://docs.frappe.io/wiki/` | |
| Frappe Helpdesk | `https://docs.frappe.io/helpdesk/` | |
| Frappe Education | `https://docs.frappe.io/education/` | |
| Frappe Lending | `https://docs.frappe.io/lending/` | |
| Books | `https://docs.frappe.io/books/` | Frappe Books (desktop accounting) |
| Customer Guide | `https://docs.frappe.io/customer-guide/` | For Frappe Cloud customers |
| Partner Guide | `https://docs.frappe.io/partner-guide/` | For Frappe partners |

## Frappe Framework — Full URL Map

### Basics (`/framework/user/en/basics/`)

| Topic | URL |
|---|---|
| Why Framework | `/framework/user/en/basics/why` |
| Apps | `/framework/user/en/basics/apps` |
| Architecture | `/framework/user/en/basics/architecture` |
| Directory Structure | `/framework/user/en/basics/directory-structure` |
| Sites | `/framework/user/en/basics/sites` |
| DocTypes | `/framework/user/en/basics/doctypes` |
| Asset Bundling | `/framework/user/en/basics/asset-bundling` |
| Static Assets | `/framework/user/en/basics/static-assets` |
| Users and Permissions | `/framework/user/en/basics/users-and-permissions` |
| Site Config | `/framework/user/en/basics/site_config` |
| Virtual DocField | `/framework/user/en/basics/virtual_docfield` |

### API (`/framework/user/en/api/`)

| Topic | URL |
|---|---|
| Document | `/framework/user/en/api/document` |
| Database | `/framework/user/en/api/database` |
| REST | `/framework/user/en/api/rest` |
| Query Builder | `/framework/user/en/api/query-builder` |
| Form | `/framework/user/en/api/form` |
| List | `/framework/user/en/api/list` |
| Page | `/framework/user/en/api/page` |
| Dialog | `/framework/user/en/api/dialog` |
| Py Dialog | `/framework/user/en/api/py-dialog` |
| Jinja | `/framework/user/en/api/jinja` |
| Realtime | `/framework/user/en/api/realtime` |
| Background Jobs | `/framework/user/en/api/background_jobs` |
| Server Calls | `/framework/user/en/api/server-calls` |
| Full-text Search | `/framework/user/en/api/full-text-search` |
| Controls | `/framework/user/en/api/controls` |
| Tree | `/framework/user/en/api/tree` |
| Chart | `/framework/user/en/api/chart` |
| Scanner | `/framework/user/en/api/scanner` |
| Logging | `/framework/user/en/api/logging` |
| Utils | `/framework/user/en/api/utils` |
| JS Utils | `/framework/user/en/api/js-utils` |

### Bench (`/framework/user/en/bench/`)

| Topic | URL |
|---|---|
| Bench Commands | `/framework/user/en/bench/bench-commands` |
| Frappe Commands | `/framework/user/en/bench/frappe-commands` |
| Extending the CLI | `/framework/user/en/bench/extending-the-cli` |
| Reference | `/framework/user/en/bench/reference` |
| Resources | `/framework/user/en/bench/resources` |
| Guides | `/framework/user/en/bench/guides` |

### Desk (`/framework/user/en/desk/`)

| Topic | URL |
|---|---|
| Attachments | `/framework/user/en/desk/attachments` |
| Printing | `/framework/user/en/desk/printing` |
| Reports | `/framework/user/en/desk/reports` |
| Scripting | `/framework/user/en/desk/scripting` |
| Workspace | `/framework/user/en/desk/workspace` |

### Python API (`/framework/user/en/python-api/`)

| Topic | URL |
|---|---|
| Hooks | `/framework/user/en/python-api/hooks` |
| Language | `/framework/user/en/python-api/language` |
| Response | `/framework/user/en/python-api/response` |
| Routing and Rendering | `/framework/user/en/python-api/routing-and-rendering` |
| Search | `/framework/user/en/python-api/search` |

### Tutorial (`/framework/user/en/tutorial/`)

| Topic | URL |
|---|---|
| Install and Setup Bench | `/framework/user/en/tutorial/install-and-setup-bench` |
| Create a Site | `/framework/user/en/tutorial/create-a-site` |
| Create an App | `/framework/user/en/tutorial/create-an-app` |
| Create a DocType | `/framework/user/en/tutorial/create-a-doctype` |
| DocType Features | `/framework/user/en/tutorial/doctype-features` |
| Types of DocType | `/framework/user/en/tutorial/types-of-doctype` |
| Controller Methods | `/framework/user/en/tutorial/controller-methods` |
| Form Scripts | `/framework/user/en/tutorial/form-scripts` |
| What's Next | `/framework/user/en/tutorial/whats-next` |

### Guides (`/framework/user/en/guides/`)

Major sub-sections (each has many pages):
- `app-development/` — building custom apps
- `automated-testing/` — testing patterns
- `basics/` — additional basics
- `caching/` — caching strategies
- `data/` — data import/export
- `database-settings/` — DB config
- `deployment/` — production setup
- `desk/` — Desk UI customization
- `integration/` — third-party integrations
- `portal-development/` — portal pages
- `reports-and-printing/` — reports & print formats

### Other Framework Topics

| Topic | URL |
|---|---|
| Installation | `/framework/user/en/installation` |
| Prerequisites | `/framework/user/en/prerequisites` |
| Production Setup | `/framework/user/en/production-setup` |
| Database Migrations | `/framework/user/en/database-migrations` |
| Debugging | `/framework/user/en/debugging` |
| Profiling | `/framework/user/en/profiling` |
| Translations | `/framework/user/en/translations` |
| Testing | `/framework/user/en/testing` |
| UI Testing | `/framework/user/en/ui-testing` |
| Audit Trail | `/framework/user/en/audit-trail` |
| Rate Limiting | `/framework/user/en/rate-limiting` |
| Logging | `/framework/user/en/logging` |
| Web Form | `/framework/user/en/web-form` |
| Portal Pages | `/framework/user/en/portal-pages` |
| Discussions | `/framework/user/en/discussions` |
| Email Groups | `/framework/user/en/email-groups` |
| Form Tours | `/framework/user/en/form-tours` |
| Integrations | `/framework/user/en/integration` |
| OAuth Service | `/framework/user/en/using_frappe_as_oauth_service` |
| Microsoft Email OAuth | `/framework/user/en/microsoft-email-oauth` |
| How to Contribute | `/framework/user/en/how_to_contribute` |

## ERPNext — Full URL Map (Selected)

ERPNext docs use **flat slugs** under `/erpnext/`. There are 700+ pages. Below are the most useful entry points. Search the live site if you need a specific topic.

### Setup & Administration
- `/erpnext/accounts-setup-checklist`
- `/erpnext/setting-up`
- `/erpnext/articles/setup/setup-wizard`
- `/erpnext/adding-users`
- `/erpnext/administrator`
- `/erpnext/accounts-settings`
- `/erpnext/global-defaults`
- `/erpnext/print-settings`
- `/erpnext/system-configuration`

### Accounting
- `/erpnext/accounting-introduction`
- `/erpnext/accounting-entries`
- `/erpnext/accounting-setup-checklist`
- `/erpnext/chart-of-accounts`
- `/erpnext/chart-of-cost-centers`
- `/erpnext/journal-entry`
- `/erpnext/payment-entry`
- `/erpnext/advance-payment-entry`
- `/erpnext/accounts-receivable-and-payable`
- `/erpnext/accounts-receivables`
- `/erpnext/accounting-dimensions`
- `/erpnext/accounting-period`
- `/erpnext/accounting-reports`
- `/erpnext/accounting-of-inventory-stock`
- `/erpnext/accounting-for-bad-debts`
- `/erpnext/accounting-migration-overview`
- `/erpnext/accounting-workflows-by-business-type`
- `/erpnext/fiscal-year`
- `/erpnext/financial-statements`
- `/erpnext/gst-setup`
- `/erpnext/multi-currency-accounting`
- `/erpnext/booking-accounting-entries-for-the-point-of-sale`
- `/erpnext/creating-payment-request`
- `/erpnext/credit-control`
- `/erpnext/credit-note`
- `/erpnext/debit-note`
- `/erpnext/opening-balance`
- `/erpnext/tax-records`
- `/erpnext/withholding-payment`
- `/erpnext/cost-center`
- `/erpnext/budgeting`
- `/erpnext/fixed-asset-depreciation-entry`

### Stock / Inventory
- `/erpnext/stock-introduction`
- `/erpnext/item`
- `/erpnext/item-attributes`
- `/erpnext/item-pricing`
- `/erpnext/warehouse`
- `/erpnext/stock-entry`
- `/erpnext/stock-reconciliation`
- `/erpnext/stock-settings`
- `/erpnext/inventory-settings`
- `/erpnext/stock-reservation`
- `/erpnext/serial-no`
- `/erpnext/batch`
- `/erpnext/batch-splitting`
- `/erpnext/valuation-method`
- `/erpnext/stock-balance-report`
- `/erpnext/stock-ledger`
- `/erpnext/landed-cost-voucher`
- `/erpnext/quality-inspection`
- `/erpnext/quality-inspection-procedure`
- `/erpnext/purchase-receipt`
- `/erpnext/delivery-note`
- `/erpnext/delivery-note-settings`

### Selling
- `/erpnext/selling-intro`
- `/erpnext/customer`
- `/erpnext/quotation`
- `/erpnext/sales-order`
- `/erpnext/sales-invoice`
- `/erpnext/pos`
- `/erpnext/point-of-sale`
- `/erpnext/sales-analytics`
- `/erpnext/installation-note`
- `/erpnext/sales-person-target`
- `/erpnext/sales-stage`
- `/erpnext/selling-settings`

### Buying
- `/erpnext/buying-intro`
- `/erpnext/supplier`
- `/erpnext/supplier-quotations`
- `/erpnext/purchase-order`
- `/erpnext/purchase-invoice`
- `/erpnext/purchase-receipt`
- `/erpnext/buying-settings`
- `/erpnext/procurement-tracker`
- `/erpnext/request-for-quotation`

### Manufacturing
- `/erpnext/manufacturing-introduction`
- `/erpnext/bill-of-materials`
- `/erpnext/work-order`
- `/erpnext/production-plan`
- `/erpnext/job-card`
- `/erpnext/routing`
- `/erpnext/operation`
- `/erpnext/workstation`
- `/erpnext/manufacturing-settings`
- `/erpnext/subcontracting`

### HR / Payroll
- `/erpnext/human-resources`
- `/erpnext/employee`
- `/erpnext/employee-attendance`
- `/erpnext/leave-management`
- `/erpnext/leave-application`
- `/erpnext/leave-allocation`
- `/erpnext/leave-policy`
- `/erpnext/holiday-list`
- `/erpnext/payroll-entry`
- `/erpnext/salary-structure`
- `/erpnext/salary-slip`
- `/erpnext/expense-claim`
- `/erpnext/employee-onboarding`
- `/erpnext/employee-separation`
- `/erpnext/shift-management`
- `/erpnext/appraisal`

### Projects
- `/erpnext/projects`
- `/erpnext/project`
- `/erpnext/task`
- `/erpnext/timesheet`
- `/erpnext/issue`
- `/erpnext/project-template`

### CRM
- `/erpnext/crm`
- `/erpnext/lead`
- `/erpnext/opportunity`
- `/erpnext/customer`

### Customization
- `/erpnext/customize-erpnext`
- `/erpnext/custom-field`
- `/erpnext/print-format`
- `/erpnext/workflow`
- `/erpnext/email-rule`
- `/erpnext/notification`
- `/erpnext/auto-repeat`
- `/erpnext/server-script`
- `/erpnext/client-script`
- `/erpnext/custom-script`
- `/erpnext/property-setter`
- `/erpnext/reports`
- `/erpnext/query-report`
- `/erpnext/script-reports`
- `/erpnext/custom-scripts`
- `/erpnext/dynamic-links`

### Other ERPNext Topics
- `/erpnext/amazon_integration`
- `/erpnext/shopify_integration`
- `/erpnext/woocommerce_integration`
- `/erpnext/contacts`
- `/erpnext/address`
- `/erpnext/print-format-settings`
- `/erpnext/automation`
- `/erpnext/print-style`
- `/erpnext/letter-head`
- `/erpnext/cheque-print`
- `/erpnext/label-printing`

## Other Frappe Apps — Top-Level URLs

### Frappe HR (`/hr/`)
- `/hr/employee-lifecycle`
- `/hr/shift-management`
- `/hr/leave-management`
- `/hr/attendance`
- `/hr/payroll`
- `/hr/expense-claim`
- `/hr/appraisal`
- `/hr/recruitment`

### Frappe CRM (`/crm/`)
- `/crm/leads`
- `/crm/deals`
- `/crm/contacts`
- `/crm/organizations`
- `/crm/call-logs`
- `/crm/email-template`

### Frappe Cloud (`/cloud/`)
- `/cloud/getting-started`
- `/cloud/sites`
- `/cloud/backups`
- `/cloud/bench`
- `/cloud/marketplace`
- `/cloud/billing`
- `/cloud/security`

### Frappe Drive (`/drive/`)
- `/drive/getting-started`
- `/drive/sharing`
- `/drive/storage`

### Frappe Learning (`/learning/`)
- `/learning/getting-started`
- `/learning/courses`
- `/learning/lessons`
- `/learning/quizzes`
- `/learning/certifications`

### Frappe Insights (`/insights/`)
- `/insights/getting-started`
- `/insights/data-sources`
- `/insights/queries`
- `/insights/dashboards`
- `/insights/charts`

### Frappe Builder (`/builder/`)
- `/builder/getting-started`
- `/builder/pages`
- `/builder/components`
- `/builder/blocks`

### Frappe Print Designer (`/print-designer/`)
- `/print-designer/getting-started`
- `/print-designer/templates`

### Frappe Wiki (`/wiki/`)
- `/wiki/getting-started`
- `/wiki/spaces`
- `/wiki/pages`

## Tips for Efficient Fetching

1. **Batch fetch** when you need multiple pages — they're independent calls.
2. **Cache results** — re-fetching the same page within a session wastes tokens. Store fetched HTML in `/tmp/frappe_cache/<slug>.html`.
3. **Strip the chrome** — pages include nav, sidebar, footer. Look for the main content div (usually `.markdown-section` or `<article>`).
4. **Fall back to search** — if you don't know the exact slug, fetch `https://docs.frappe.io/<product>` and grep the link list for keywords.
5. **Use the GitHub source** — the docs source is at `https://github.com/frappe/frappe_docs` (for the docs site itself) and the per-product doc folders inside each app repo. Raw markdown is sometimes easier to parse than the rendered HTML.

## When to Skip Live Fetch

Don't fetch live docs if:
- The question is about a **fundamental concept** (DocType, ORM, hooks) — these rarely change; the bundled reference is sufficient.
- The user is asking for **opinion/best-practice** — live docs won't help.
- The user is on an **old version** (v12, v13) — the live docs always show the latest, which may mislead.

Do fetch live docs if:
- The user mentions a **specific version number**.
- You're unsure whether an API has been **renamed or deprecated**.
- The user asks about a **brand-new feature** (released in the last 6 months).
- The bundled reference is **incomplete** and the user needs the full signature.
