# ERPNext — Overview, Setup & Administration

ERPNext is a full-featured Enterprise Resource Planning (ERP) system built on the Frappe Framework. It bundles accounting, inventory, sales, purchasing, manufacturing, HR, payroll, projects, CRM, and asset management into a single integrated application. Use this file as the entry point for any ERPNext question that spans modules, setup, users, or company configuration. For module-specific depth, jump to `accounts.md`, `stock.md`, `selling-buying.md`, `manufacturing.md`, or `customization.md` in the same folder.

## Table of Contents

1. [What Is ERPNext](#what-is-erpnext)
2. [Modules Overview](#modules-overview)
3. [Setup Wizard Walkthrough](#setup-wizard-walkthrough)
4. [Company Setup](#company-setup)
5. [Users & Roles](#users--roles)
6. [System Settings](#system-settings)
7. [Global Defaults](#global-defaults)
8. [Data Import](#data-import)
9. [Data Export](#data-export)
10. [Multi-Company Setup](#multi-company-setup)
11. [Branch vs Cost Center vs Department](#branch-vs-cost-center-vs-department)
12. [Language & Regional Settings](#language--regional-settings)
13. [Common Pitfalls](#common-pitfalls)
14. [Where to Learn More](#where-to-learn-more)

## What Is ERPNext

ERPNext is an open-source ERP application (GPLv3) maintained by Frappe Technologies and the community. It is the largest Frappe app and ships as a single Python package called `erpnext` that you install on top of a Frappe Framework bench. Once installed, it provides:

- A **Desk UI** (the back-office interface) where users create and submit documents.
- **~600 DocTypes** covering every business domain, organized into modules.
- **REST and JSON-RPC APIs** exposing every DocType and every whitelisted method.
- **Regional compliance packs** (GST for India, VAT for UAE/KSA, 1099 for US, etc.) selected automatically based on the company's country.
- A **Portal** (customer/supplier/employee self-service) and a **POS** interface.

Architecturally, ERPNext is just a Frappe app — every concept in `../framework/architecture.md` (DocTypes, controllers, hooks, bench CLI) applies. The difference between "Frappe Framework" and "ERPNext" questions is one of scope: Framework questions are about the platform; ERPNext questions are about the business DocTypes and workflows layered on top.

### Version Considerations

ERPNext follows the Frappe Framework version cadence. As of 2026, **v15** and **v16** are the supported lines. Older v13 installs still exist in the wild but receive no security patches. Always confirm the version with the user before suggesting module behavior, because:

- v14 introduced the new **Workspace** (replacing the old Desk modules).
- v15 made **Subcontracting** a first-class flow with separate DocTypes.
- v16 reorganized the **HR** module into the standalone **Frappe HR** app (still installable inside ERPNext).

When the user does not specify a version, assume v15 or v16.

## Modules Overview

ERPNext is organized into modules. Each module is a Python sub-package under `erpnext.<module>` and groups related DocTypes, reports, and workspaces. The table below lists every built-in module and points to the reference file that covers it.

| Module | Purpose | Reference File |
|---|---|---|
| **Accounts** | Chart of accounts, journal entries, payments, taxes, financial statements | `accounts.md` |
| **Stock** | Items, warehouses, stock entries, valuation, serial/batch | `stock.md` |
| **Selling** | Customers, quotations, sales orders, sales invoices, delivery notes | `selling-buying.md` |
| **Buying** | Suppliers, RFQs, purchase orders, purchase receipts, purchase invoices | `selling-buying.md` |
| **Manufacturing** | BOM, work orders, job cards, production plans, routing | `manufacturing.md` |
| **HR & Payroll** | Employees, attendance, leaves, payroll, expense claims, appraisals | `hr-projects.md` (in this skill) |
| **Projects** | Projects, tasks, timesheets, issues | `hr-projects.md` |
| **CRM** | Leads, opportunities, sales pipeline | (covered briefly in `selling-buying.md`) |
| **Assets** | Fixed asset registration, depreciation, disposal | `accounts.md` (depreciation) |
| **Quality** | Quality inspection, quality inspection criteria | `stock.md` (linked from there) |
| **Helpdesk** | Tickets, SLAs, service level agreements | (Frappe Helpdesk app) |
| **Education** | Student, program, course, fees, attendance | (Frappe Education app) |
| **Agriculture** | Crops, land, livestock | (legacy; minimal coverage) |
| **Nonprofit** | Memberships, donors, chapters, volunteer | (legacy) |
| **Loans** | Loan applications, disbursement, repayment schedules | (Frappe Lending app) |
| **Healthcare** | Patient, practitioner, appointments, prescriptions | (legacy module) |
| **Hospitality** | Hotel room bookings, restaurant tables | (legacy) |
| **Restaurant** | Restaurant menu, table orders, KOT | (legacy) |

### Core vs Optional Modules

The first eight modules in the table above (Accounts through Projects) are **core** — they are always installed with ERPNext and almost every customer uses them. The others are installed on demand:

- **Assets** is core but is typically enabled only by companies tracking fixed assets.
- **Quality**, **Helpdesk**, **Education**, **Agriculture**, **Nonprofit**, **Loans**, **Healthcare**, **Hospitality**, and **Restaurant** are domain-specific and frequently replaced by the standalone Frappe apps (Frappe Helpdesk, Frappe Learning, Frappe Lending, etc.) for new installations.

Use the **Modules** field in `System Settings` to hide modules the customer does not use. Hiding does not uninstall the code; it removes them from the Desk and the search index.

## Setup Wizard Walkthrough

When you create a fresh site and install ERPNext (`bench --site X install-app erpnext`), the first user to log in is greeted by the **Setup Wizard**. The wizard collects the minimum data needed to make ERPNext usable: language, country, company, chart of accounts, user, and a few regional defaults. Skipping the wizard leaves the site in an unusable state — every DocType that needs a Company will refuse to save.

### Wizard Steps (v15 / v16)

| Step | Field | Why It Matters |
|---|---|---|
| 1. Language | `language` | Sets the default translation file. Also drives date/number format unless overridden. |
| 2. Country | `country` | Selects regional compliance pack (GST, VAT, etc.), tax template defaults, and currency. |
| 3. Company name | `company_name`, `company_abbr` | Creates the first `Company` record. The abbreviation (e.g. `WT` for "Widgets Co") prefixes the company's auto-generated ledger accounts (e.g. `WT-Cash`). |
| 4. Chart of Accounts | `chart_of_accounts` | Picks a COA template from `erpnext.accounts.doctype.account.chart_of_accounts`. Templates exist for ~100 countries. |
| 5. Fiscal year | `fiscal_year_start`, `fiscal_year_end` | Creates the first `Fiscal Year` record. |
| 6. Bank account | `bank_name`, `account_no` | Creates a bank ledger account under "Bank Accounts" and a `Bank Account` master. |
| 7. Organization brand | `company_logo`, `domain` | Domain (e.g. "Manufacturing", "Services") pre-toggles module visibility. |
| 8. First user | `email`, `first_name`, `last_name`, `password` | Promotes this user to System Manager and sets them as the default company contact. |
| 9. Taxes | `sales_tax_rate`, `purchase_tax_rate` | Generates a default Sales/Purchase Tax template. |
| 10. Customers & Suppliers | `customers`, `suppliers` | Optional — you can import these later. |
| 11. Items | `items` | Optional — sample item masters. |

### Programmatic Setup

You can skip the wizard programmatically. This is useful for automated test sites:

```python
import frappe
from frappe.desk.page.setup_wizard.setup_wizard import setup_complete

setup_complete({
    "language": "English",
    "country": "United States",
    "timezone": "America/New_York",
    "currency": "USD",
    "first_name": "Admin",
    "last_name": "User",
    "email": "admin@example.com",
    "password": "strongpassword",
    "company_name": "Acme Corp",
    "company_abbr": "ACME",
    "domain": "Manufacturing",
    "chart_of_accounts": "Standard with Numbers",
    "fiscal_year_start_date": "2026-01-01",
    "fiscal_year_end_date": "2026-12-31",
    "bank_name": "Acme Bank",
    "account_no": "1234567890",
    "sales_tax": "0",
    "purchase_tax": "0",
})
```

After `setup_complete` runs, the wizard is marked complete and users land on the Desk home page.

## Company Setup

The `Company` DocType (`erpnext.accounts.doctype.company`) is the apex of every ERPNext installation. Almost every transactable DocType (Sales Invoice, Purchase Order, Stock Entry, Journal Entry, etc.) requires a Company field. The company is also the boundary for:

- **Chart of Accounts** — each company has its own COA tree.
- **Cost Centers** — each company has its own cost center tree.
- **Warehouses** — each warehouse belongs to exactly one company.
- **Fiscal Years** — fiscal years are global, but the periods within them are tracked per company.
- **Number Series** — most numbering series (e.g. `ACC-SINV-YYYY-`) are scoped per company.

### Company Fields You Must Configure

| Field | Purpose | Gotcha |
|---|---|---|
| `company_name` | Full legal name. | Cannot be changed after transactions exist — rename carefully. |
| `abbr` | 1-5 character abbreviation. | Becomes part of every account name (`Cash - ACME`). Changing it renames hundreds of accounts. |
| `country` | Drives regional compliance. | Cannot be unset after first transaction. |
| `default_currency` | Used when no currency is specified on transactions. | Changing this after multi-currency is enabled is destructive. |
| `default_finance_book` | Required if you use multiple finance books (e.g. for parallel depreciation). | Create the Finance Book first, then link. |
| `tax_id` | GSTIN/VAT ID. | Printed on invoices; required for e-invoicing integrations. |
| `enable_perpetual_inventory` | Links stock movement to GL postings automatically. | Disable only if you keep stock out of the GL (rare). |
| `default_hr_employee` | The default employee record for the HR module. | Set after onboarding the admin user as an Employee. |

### Chart of Accounts Template

The COA is a tree of `Account` records rooted in five top-level groups: **Application of Funds (Assets)**, **Sources of Funds (Liabilities)**, **Equity**, **Income**, and **Expenses**. ERPNext ships ~100 country-specific templates in `erpnext/accounts/chart_of_accounts/<country>/<template>.json`. To pick one at company creation:

```python
from erpnext.accounts.doctype.company.company import create_company
doc = frappe.get_doc({
    "doctype": "Company",
    "company_name": "Acme",
    "abbr": "ACME",
    "default_currency": "USD",
    "country": "United States",
    "chart_of_accounts": "Standard with Numbers",
    "domain": "Manufacturing",
})
doc.insert()
```

The `chart_of_accounts` field accepts any installed template name. To list all available templates:

```python
from erpnext.accounts.chart_of_accounts.chart_of_accounts import get_charts_for_country
charts = get_charts_for_country("United States")
# → ["Standard with Numbers", "Standard", ...]
```

### Fiscal Year and Accounting Period

After the company exists, create at least one `Fiscal Year` covering the current operating period. Fiscal years are global (not per-company), but you can restrict them to specific companies via the `Companies` child table. Create an `Accounting Period` if you want to **lock** postings for a sub-period (e.g. a closed month) — once locked, no new Journal Entry can post to it without un-locking.

## Users & Roles

ERPNext reuses the Frappe Framework user system (`User` DocType in `tabUser`). There is no separate "ERPNext user" — the same record authenticates against Desk, Portal, REST API, and Web Forms. The difference between a Frappe-only site and an ERPNext site is the set of **roles** available:

| Standard ERPNext Role | Permissions |
|---|---|
| `Accounts Manager` / `Accounts User` | Create/post journal entries, payments, invoices. |
| `Sales Manager` / `Sales User` | Customers, quotations, sales orders, sales invoices. |
| `Purchase Manager` / `Purchase User` | Suppliers, purchase orders, purchase invoices. |
| `Stock Manager` / `Stock User` | Items, warehouses, stock entries, stock reconciliation. |
| `Manufacturing Manager` / `Manufacturing User` | BOM, work orders, production plans. |
| `HR Manager` / `HR User` | Employee, attendance, leave, payroll. |
| `Projects User` | Projects, tasks, timesheets. |
| `Item Manager` | Item master (often split from Stock Manager). |
| `Fleet Manager` | Vehicles, vehicle log. |
| `Academics User` | Education module. |

### The "User = Employee" Link

ERPNext assumes a 1:1 mapping between a `User` and an `Employee`. The link is stored on the Employee record (`user_id` field). Without it, the user cannot:

- Submit expense claims.
- Appear on the attendance roster.
- Be paid via payroll.
- Show up in project timesheets.

Always create the Employee record for any user who needs HR features. The Setup Wizard does this automatically for the first admin user.

### Role via Desk

1. Open the User record.
2. Under **Roles**, add the role(s) needed.
3. Save.

### Role via API

```python
user = frappe.get_doc("User", "alice@example.com")
user.append("roles", {"role": "Sales User"})
user.append("roles", {"role": "Stock User"})
user.save(ignore_permissions=True)
```

### Permission Management Best Practices

- Use **Role Permissions Manager** (search in Awesome Bar) to customize what each role can do per DocType.
- For row-level security (e.g. "Sales User sees only their own customers"), set **Permission Query Conditions** in the DocType's permission table — never write a custom list view.
- For field-level security (e.g. "Cost rate visible only to HR"), use **Field-Level Permissions** (the `permlevel` column on each field).
- Read `../framework/doctype-guide.md` for the full permissions deep dive.

## System Settings

`System Settings` is a Single DocType controlling framework-wide behavior. Open it via Awesome Bar → "System Settings". The most-tuned fields for ERPNext installations:

| Setting | Effect |
|---|---|
| `country` | Drives default timezone, currency, and date format. |
| `timezone` | Affects every `DateTime` field stored without explicit tz. |
| `currency` | Fallback currency; usually overridden per-company. |
| `date_format` / `time_format` | Display format; data is stored as `YYYY-MM-DD HH:MM:SS` regardless. |
| `number_format` | Decimal and thousands separator. |
| `first_day_of_the_week` | Affects calendar widgets and weekly reports. |
| `app_name` | Branding — changes "ERPNext" to your product name in the navbar. |
| `disable_document_share` | Blocks the "Share" button on documents — useful for regulated environments. |
| `apply_strict_transaction_permission` | Enforces per-transaction permission checks (slower but stricter). |
| `backup_limit` | Number of automatic backups to retain. |
| `enable_scheduler` | Toggles the cron-style scheduler (auto-repeat, scheduled jobs). |
| `deny_multiple_sessions` | Forces one session per user. |

Always set `country` and `timezone` first — many downstream defaults derive from them.

## Global Defaults

`Global Defaults` is another Single DocType (separate from System Settings). It holds the **current** values that the framework falls back to when a user does not specify them:

| Field | Purpose |
|---|---|
| `default_company` | Used when creating documents where Company is not mandatory at the form level. |
| `default_currency` | Fallback currency when none is on the company or customer. |
| `default_country` | Fallback for tax templates and address formatting. |
| `default_fiscal_year` | Pre-selected on every transactional DocType. |
| `default_letter_head` | Printed on every print format unless overridden. |
| `default_terms` | Default Terms & Conditions text appended to sales/purchase documents. |
| `default_customer_group`, `default_supplier_group`, `default_territory`, `default_item_group` | Used when creating new master records without specifying a group. |

**Pitfall:** if you change `default_company` after transactions exist, existing records keep their original company — only new records pick up the new default.

## Data Import

ERPNext imports CSV/XLSX files via the **Data Import** workspace (`Data Import` DocType). Use it for bulk creation of masters (Customers, Suppliers, Items) or transactions (Opening Invoices, Journal Entries). The Import/Export tool replaces the older `Data Import Tool` (removed in v13).

### Workflow

1. Navigate to the DocType list view (e.g. **Customer List**).
2. Click **Menu → Import** (top right).
3. Download the **template** — choose "With Sample Data" or "Blank Template".
4. Fill in the CSV/XLSX.
5. Upload the file.
6. Click **Start Import**.

The import runs in the background. Watch the `Data Import` record's status field (`Pending` → `In Progress` → `Success` / `Partial Success` / `Error`). Click the status to see row-level errors.

### Template Format Conventions

| Cell Format | Meaning |
|---|---|
| `Customer Name` (plain header) | Direct field on the DocType. |
| `Customer Group:Customer Group Name` | Link field — value must match an existing record's name. |
| `Address:Address Line 1` | Child-table field (Address is a child of Customer via dynamic link). |
| `Items:Item Code` | Repeat-header for child rows; subsequent rows with blank parent columns are treated as additional children. |
| `*` prefix in header | Required field. |
| `~~` prefix in header | Field is skipped (useful when re-importing exported data). |

### Programmatic Import

For repeatable ETL pipelines, skip the UI and use the API:

```python
from frappe.core.doctype.data_import.data_import import import_file

import_file("Customer", "/path/to/customers.csv", "Insert", console=True)
```

For more control, iterate rows yourself and use `frappe.get_doc(...).insert()` — but you lose the automatic error reporting and rollback-on-failure semantics of the Data Import tool.

### Common Import Errors

| Error | Cause | Fix |
|---|---|---|
| `Row 5: Customer Group "VIP" not found` | Link target does not exist. | Create the Customer Group first or fix the spelling. |
| `Row 12: Mandatory field Item Code missing` | Required column blank. | Fill in or remove `*` from template. |
| `Row 22: Duplicate value Customer Name "Acme"` | `unique` constraint hit. | Use `Update` mode instead of `Insert`, or rename. |
| `Row 30: Date format invalid: "03/15/2026"` | Wrong date format for site setting. | Convert to `YYYY-MM-DD` or change the site date format. |

## Data Export

Three export mechanisms cover every need:

### Report Builder (List View Export)

Click the **Menu → Export** on any list view. Choose:

- **Field Type** — All fields, mandatory only, or custom selection.
- **File Type** — Excel or CSV.
- **Filter** — current list filters are applied.
- **Distinct** — dedupe rows.

### Query Report Export

Open any Query Report (e.g. **General Ledger**). Run it with filters, then **Menu → Export → Excel/CSV**. The export honors the active filters and column visibility.

### Custom Script Export

For scheduled exports or pipelines, write a whitelisted method and call it via API:

```python
import frappe
import csv
from frappe.utils import cstr

@frappe.whitelist()
def export_customers_to_csv():
    customers = frappe.get_all("Customer",
        fields=["name", "customer_name", "customer_group", "territory"])

    frappe.response["filename"] = "customers.csv"
    frappe.response["filecontent"] = (
        "name,customer_name,customer_group,territory\n"
        + "\n".join(",".join(cstr(v) for v in c.values()) for c in customers)
    )
    frappe.response["type"] = "download"
```

Call via `curl https://site/api/method/my_app.export_customers_to_csv` with auth header.

## Multi-Company Setup

ERPNext supports multiple companies on a single site. Each company gets its own COA, cost centers, warehouses, and number series, while users, modules, and customizations are shared. Use multi-company when:

- You operate two legal entities that share back-office staff.
- You want consolidated reports across subsidiaries.
- You are an accountant serving multiple clients from one install (rare — Frappe Cloud's per-site model is usually better).

### Setup Steps

1. Create the second `Company` record (full COA, abbr, currency).
2. Create warehouses for the new company — each warehouse's `Company` field must point to it.
3. Create `Cost Center` records under the new company.
4. Generate **number series** for every transactable DocType with the new company's abbr prefix (e.g. `ACME2-SINV-2026-`).
5. Add the new Company to the user's **Allowed Companies** list (User → Allowed Companies).
6. Set the user's **Default Company** preference.

### Inter-Company Transactions

When one of your companies sells to another, use the **Inter Company Transaction** feature:

1. Create a Sales Invoice in Company A.
2. Click **Create → Inter Company Purchase Invoice**.
3. ERPNext generates a Purchase Invoice in Company B with reversed tax lines.

This requires the **Inter Company Settings** (`Accounts Settings → Inter Company`) and properly configured **Inter Company Link** records mapping each Customer to a Supplier (and vice versa).

### Consolidation

Use the **Consolidated Financial Statement** report to merge results across companies. Currency translation uses the average exchange rate for the period (configurable in `Accounts Settings`).

### Pitfalls of Multi-Company

- **Stock cannot be transferred between companies** with a simple Stock Entry — that's a Sale + Purchase pair. Use the **Material Transfer with Stock Entry** only when both warehouses are in the same company.
- **Default Company** on `Global Defaults` is global — users see only that company's data unless they switch in the top-right company picker. Configure permissions so each user's default matches their primary employer.
- **Number series collisions** — each company must have its own series; sharing causes gaps and audit confusion.
- **Cost center cross-references** — a Sales Invoice for Company A cannot use a Cost Center belonging to Company B.

## Branch vs Cost Center vs Department

These three hierarchies are often confused. They serve different purposes and you usually need all three.

| Dimension | DocType | Tree | Used By | Purpose |
|---|---|---|---|---|
| **Branch** | `Branch` | Flat list | HR, Stock, Projects | Physical or organizational location (e.g. "Mumbai Office", "NY Warehouse"). |
| **Cost Center** | `Cost Center` | Tree (rooted per company) | Accounts | Where revenue/expense is booked for managerial accounting. |
| **Department** | `Department` | Tree | HR, Projects | Organizational unit (e.g. "Engineering", "Sales"). Maps to an Employee. |

### How They Interact

- An **Employee** belongs to one **Department** and is posted to one **Branch**.
- A **Sales Invoice** can be tagged with a **Cost Center** (and optionally a Branch via custom field).
- **Journal Entries** can split a single transaction across multiple **Cost Centers** using the `Cost Center` column in the accounts table.
- **Stock Entries** move inventory between **Warehouses**, which themselves belong to a Branch (via the warehouse's `Branch` field).

### Best Practices

- Do **not** mirror your org chart in Cost Centers — that's what Department is for. Cost Centers should reflect **profit/cost responsibility**, not reporting hierarchy.
- Create one **"Main"** Cost Center as the root per company; allocate everything to it by default. Add children only when you need to track profitability of a sub-unit.
- Use **Accounting Dimensions** (Accounts Settings → Accounting Dimensions) to add custom analytical axes beyond Branch/Cost Center/Project — e.g. "Geography", "Product Line".

## Language & Regional Settings

Language and regional settings cascade through three layers:

1. **System Settings** — site-wide defaults.
2. **User** — per-user override (User → Language).
3. **Customer / Supplier / Lead** — per-party override (used for printed documents like invoices and quotations).

### Configuring Languages

The site ships with ~80 language packs. New translations are contributed via the [weblate project](https://translate.frappe.io). Add a custom translation:

```python
# Add a single custom translation
frappe.db.set_value("Translation",
    {"source_text": "Customer", "language": "de"},
    "translated_text", "Kunde",
    if_exists=True)
```

For bulk edits, export the `Translation` DocType via Data Export, edit, and re-import.

### Regional Compliance Packs

ERPNext ships per-country compliance in `erpnext.regional`. The pack is auto-selected based on the company's `country` field:

| Country | Compliance Pack |
|---|---|
| India | GST, e-Invoice, e-Way Bill, GSTR-1/3B reports |
| UAE / Saudi Arabia | VAT 201 return, FTA audit file |
| United States | 1099 reports, US payroll |
| Brazil | NF-e, SPED |
| France | FEC (Fichier des Écritures Comptables) |
| Germany | DATEV, ELSTER |
| Italy | SDI e-invoicing, FatturaPA |

When the country is set on a Company for the first time, ERPNext installs the regional DocTypes and reports. Removing the country does **not** uninstall them.

### Date, Number, and Currency Format

These are derived from the language/country but can be overridden in `System Settings`:

| Format Field | Example Values |
|---|---|
| `date_format` | `dd-mm-yyyy`, `mm/dd/yyyy`, `yyyy-mm-dd` |
| `time_format` | `HH:mm:ss`, `HH:mm` |
| `number_format` | `#,###.##` (US), `#.###,##` (DE), `##,##,###.##` (IN) |
| `currency_symbol` | `$`, `€`, `₹`, `¥` |
| `currency_precision` | `2` (most), `0` (JPY), `3` (KWD) |

Always verify these after a fresh install — a wrong date format causes imports to fail mysteriously.

## Common Pitfalls

- **Skipping the Setup Wizard** leaves the site unusable. Even if you intend to script everything, run `setup_complete()` at least once.
- **Renaming a Company** after transactions exist propagates to hundreds of ledger accounts — schedule downtime and clear the cache afterward (`bench --site X clear-cache`).
- **Changing `default_currency`** on a Company after multi-currency is enabled re-creates currency exchange records and can corrupt historical reporting. Avoid.
- **Forgetting to enable the Scheduler** (`System Settings → Enable Scheduler`) — auto-repeat, scheduled reports, and email digests silently stop.
- **Using `Administrator` for daily work** — Administrator bypasses permission checks, masking role bugs. Create a real user with proper roles instead.
- **Importing transactions before masters** — Sales Invoices need Customer, Item, Tax template, and Cost Center to all exist. Import masters first.
- **Enabling `enable_perpetual_inventory` after stock has been built up** creates a one-time GL adjustment. Plan this with the accountant.
- **Hiding modules you don't use** does not uninstall their code. A user who knows the route can still navigate. Use role permissions for hard enforcement.
- **Mixing `data_format` and `date_format`** — note the typo `data_format` exists in some old code paths; modern ERPNext uses `date_format`.
- **Setting `default_company` without setting user's Allowed Companies** — users will fail to create transactions because the company picker returns nothing.

## Where to Learn More

- ERPNext docs home: `https://docs.frappe.io/erpnext/`
- Setup wizard: `https://docs.frappe.io/erpnext/articles/setup/setup-wizard`
- Setting up: `https://docs.frappe.io/erpnext/setting-up`
- Adding users: `https://docs.frappe.io/erpnext/adding-users`
- System configuration: `https://docs.frappe.io/erpnext/system-configuration`
- Global defaults: `https://docs.frappe.io/erpnext/global-defaults`
- Accounts setup checklist: `https://docs.frappe.io/erpnext/accounts-setup-checklist`
- Data import (Frappe Framework, applies to ERPNext): `https://docs.frappe.io/framework/user/en/guides/data/data-import`
- Customize ERPNext: `https://docs.frappe.io/erpnext/customize-erpnext`

For deeper Framework concepts (bench, sites, DocType mechanics), read `../framework/architecture.md` and `../framework/bench-cli.md`. For Python ORM and hooks, read `../framework/python-api.md`.
