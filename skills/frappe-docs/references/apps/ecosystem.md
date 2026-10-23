# Frappe Ecosystem — Apps Beyond ERPNext

ERPNext is the largest Frappe app, but the Frappe ecosystem includes a dozen other first-party apps that ship independently. Each one targets a domain that ERPNext only partially covers (HR, CRM, Helpdesk, LMS, BI, file sharing, page building) or a need that ERPNext does not address at all (managed hosting, loans, desktop accounting). Use this file whenever the user asks about a specific Frappe app that is **not** ERPNext and **not** the Framework itself. For ERPNext modules, read `../erpnext/overview.md` and the per-module files. For Framework concepts shared by all apps (DocType, hooks, REST, bench), read `../framework/architecture.md` and `../framework/python-api.md`.

## Table of Contents

1. [Ecosystem at a Glance](#ecosystem-at-a-glance)
2. [Frappe HR](#frappe-hr)
3. [Frappe CRM](#frappe-crm)
4. [Frappe Helpdesk](#frappe-helpdesk)
5. [Frappe Learning (LMS)](#frappe-learning-lms)
6. [Frappe Drive](#frappe-drive)
7. [Frappe Insights](#frappe-insights)
8. [Frappe Builder](#frappe-builder)
9. [Frappe Print Designer](#frappe-print-designer)
10. [Frappe Wiki](#frappe-wiki)
11. [Frappe Cloud](#frappe-cloud)
12. [Frappe Lending](#frappe-lending)
13. [Frappe Studio](#frappe-studio)
14. [Frappe Gantt](#frappe-gantt)
15. [Frappe Books](#frappe-books)
16. [Choosing Between Bundled and Standalone](#choosing-between-bundled-and-standalone)
17. [Where to Learn More](#where-to-learn-more)

## Ecosystem at a Glance

| App | Standalone? | Bundled in ERPNext? | Install repo | Brief purpose |
|---|---|---|---|---|
| Frappe HR | Yes | Yes (as `hr`/`payroll` modules) | `frappe/hrms` | Employee lifecycle, attendance, leave, payroll, expense claims, appraisals |
| Frappe CRM | Yes | No (ERPNext has its own CRM module) | `frappe/crm` | Lead → Opportunity → Deal pipeline with Kanban and email sync |
| Frappe Helpdesk | Yes | No (ERPNext has Issue, but Helpdesk is rebuilt) | `frappe/helpdesk` | Ticketing with SLA, agents, knowledge base, canned responses |
| Frappe Learning (LMS) | Yes | No | `frappe/lms` | Courses, lessons, quizzes, batches, paid enrollments, certificates |
| Frappe Drive | Yes | No | `frappe/drive` | File sharing and collaboration (Nextcloud-style) |
| Frappe Insights | Yes | No | `frappe/insights` | BI/analytics: data sources, SQL queries, dashboards, charts |
| Frappe Builder | Yes | No | `frappe/builder` | No-code visual page builder for websites and web apps |
| Frappe Print Designer | Yes | No | `frappe/print_designer` | Drag-drop print format builder (replaces HTML print formats) |
| Frappe Wiki | Yes | No | `frappe/wiki` | Wiki / knowledge base with spaces, revisions, sidebar |
| Frappe Cloud | SaaS | N/A (it is the hosting platform) | `frappe/cloud` (self-host) or use frappecloud.com | Managed Frappe hosting marketplace |
| Frappe Lending | Yes | Yes (as `loan_management` module in ERPNext) | `frappe/lending` | Loan applications, repayment schedules, disbursements, interest accrual |
| Frappe Studio | In development | No | `frappe/studio` | Visual app builder (drag-drop DocTypes and forms) |
| Frappe Gantt | Library | N/A | `frappe/gantt` | Reusable Gantt chart JS component |
| Frappe Books | Desktop app | No | `frappe/books` | Offline-first small-business accounting (Tauri, not Frappe Framework) |

**Install pattern** is the same for all framework-based apps:

```bash
bench get-app https://github.com/frappe/<repo>
bench --site <site> install-app <app_name>
bench --site <site> migrate
```

The `<app_name>` is the Python package name (usually matches the repo name with underscores, e.g. `hrms`, `crm`, `helpdesk`, `lms`, `drive`, `insights`, `builder`, `print_designer`, `wiki`, `lending`).

## Frappe HR

Frappe HR (previously **ERPNext HRMS**, rebranded in 2023) is a full HR and payroll system. It runs as a standalone Frappe app and is also bundled inside ERPNext as the `HR` and `Payroll` modules. The standalone version is a slimmer install (no stock, no accounting dependencies) and receives feature updates faster — ERPNext pulls from the same codebase on a slight lag.

### What It Does

Manages the entire employee lifecycle: recruitment, onboarding, attendance, leave, shifts, payroll, expense claims, appraisals, training, and offboarding. Supports biometric attendance integration, multi-company payrolls, and country-specific tax computations (Indian TDS, US W-2 styled, etc.).

### Standalone vs ERPNext-Bundled

| Aspect | Standalone (`hrms`) | ERPNext module |
|---|---|---|
| Install footprint | ~5 DocType modules only | All of ERPNext |
| Updates | Independent of ERPNext release cadence | Tied to ERPNext release |
| Code repository | `frappe/hrms` | Vendored into `frappe/erpnext` via subtree |
| Data model | Identical | Identical |
| Upgrade path | `bench update --pull` on hrms only | Full ERPNext upgrade |

If the user only needs HR and is cost-sensitive about server resources, install standalone. If they already run ERPNext, the HR module is already there — no extra install needed.

### Top DocTypes

| DocType | Description |
|---|---|
| `Employee` | The employee master; links to User, Branch, Department, Designation, Grade |
| `Attendance` | Daily attendance record per employee; status Present/Absent/Half Day/Work From Home |
| `Leave Application` | Employee requests leave; auto-deducts from `Leave Ledger Entry` |
| `Leave Type` | Defines leave policies (casual, sick, earned, compensatory) with carry-forward rules |
| `Holiday List` | Calendar of holidays for a given year, attached to Leave Period and Shift |
| `Salary Structure` | Template of earnings and deductions (component → formula or amount) |
| `Salary Slip` | Generated per employee per month; the actual pay slip |
| `Payroll Entry` | Bulk-generates salary slips for a Payroll Period + Department/Branch |
| `Expense Claim` | Employee expense reimbursement request; ties to cost center / project |
| `Appraisal` | Performance review with goals, ratings, and self-assessment |
| `Shift Type` | Shift definition with auto-attendance rules and biometric fetch config |
| `Employee Onboarding` / `Employee Separation` | Process templates that generate task boards for HR |
| `Job Applicant` / `Job Offer` | Recruitment pipeline |
| `Attendance Request` | For regularizing missed punches or OD (on-duty) |
| `Leave Policy Assignment` | Bulk-allocate leave quotas to employees per Leave Period |

### Common Workflows

#### Payroll Run (monthly)

```text
1. Ensure Salary Structure Assignment exists for each active employee for the month.
2. Create Payroll Entry → set Company, Payroll Period, Branch/Department filters.
3. Click "Create Salary Slips" (background job generates one slip per employee).
4. Review slips in Salary Slip list — adjust inputs (attendance, leave without pay).
5. Click "Submit Salary Slips" → all slips become Submitted.
6. Click "Make Bank Entry" → creates a Journal Entry debiting Salary Payable.
7. (Optional) "Make Payment Entry" → bank transfer to employee accounts.
```

#### Leave application with auto-approval

Configure a `Leave Policy` with `Leave Policy Assignment` for each employee. Submit a `Leave Application`; if the leave balance allows and the approver is set to "Reports to" with auto-approval enabled, the application submits itself and writes to the `Leave Ledger Entry`.

#### Biometric attendance

1. Configure `Shift Type` with `Auto Attendance` enabled and set `Fetch Hours from Device`.
2. Use `Employee Checkin` DocType — feed from the device's API or CSV import.
3. The scheduler (`frappe.hr.doctype.shift_type.shift_type.process_auto_attendance`) marks Attendance records based on check-in/log thresholds.

### How to Install

```bash
# Standalone
bench get-app hrms
bench --site mysite.localhost install-app hrms
bench --site mysite.localhost migrate

# Inside ERPNext (already installed if you installed erpnext)
bench --site mysite.localhost install-app erpnext
```

### Common Integrations

- **Biometric devices** — ZKTeco, eSSL, Hikvision. Frappe HR provides an abstract `HRSettings.biometric_integration` flag and a `fetch_biometric_attendance` hook. Vendors ship apps that implement the `Employee Checkin` insertion.
- **Payroll bank files** — generates SEPA XML, NACHA, Indian NEFT/RTGS files via `Payroll Entry → Make Bank Entry`.
- **Slack/Email notifications** — via Notification records on Attendance, Leave Application, Expense Claim.
- **Payroll tax calculators** — India (`hrms.regional.india.utils`), US, Saudi Arabia, UAE ship region-specific salary components.

### Where to Learn More

- Live docs: `https://docs.frappe.io/hr`
- GitHub: `https://github.com/frappe/hrms`

## Frappe CRM

Standalone CRM rebuilt in 2024 to replace the older ERPNext CRM module. It uses a modern Vue/React-style frontend and a Kanban-first UX. ERPNext's CRM module (`Lead`, `Opportunity`, `Quotation`) still exists but receives fewer features; Frappe CRM is the active development focus.

### What It Does

Manages leads, opportunities, deals, contacts, and organizations through a pipeline view. Syncs email and call logs, automates follow-ups, and exposes a customizable API for custom stages and fields.

### Standalone vs ERPNext-Bundled

Frappe CRM is **standalone only**. ERPNext has its own `CRM` module (Lead → Opportunity → Quotation) but the two are not interchangeable. Key differences:

| Feature | Frappe CRM (standalone) | ERPNext CRM module |
|---|---|---|
| `Deal` DocType | Yes (replaces Opportunity for many flows) | No (uses Opportunity) |
| Pipeline UI | Modern Kanban with drag-drop | Tree-style stages |
| Email sync | Built-in IMAP+SMTP with per-agent inbox | Email Account (Frappe framework) |
| Twilio calling | Native | Via third-party app |
| Quotations | Not native (use Frappe Sales if needed) | Native, links to Sales Order |

### Top DocTypes

| DocType | Description |
|---|---|
| `Lead` | Pre-qualification contact; converts to Deal or Opportunity |
| `Deal` | Qualified opportunity with value, expected close date, probability |
| `Contact` | Person record; can belong to multiple Organizations |
| `Organization` | Company/account record; links Contacts and Deals |
| `Call Log` | Inbound/outbound call record; integrates with Twilio |
| `Email Template` | Reusable email body with Jinja variables |
| `Pipeline` | Stage configuration for a Deal pipeline |
| `Pipeline Stage` | Individual stage (e.g. New, Qualified, Demo, Closed Won) |
| `Communication` | Generic message log (email, call, note) attached to any doc |
| `Automation Rule` | Trigger-based action (e.g. "on Deal stage change → assign to owner") |

### Common Workflows

#### Lead to Deal conversion

```text
1. Lead captured via Web Form, API, or manual entry.
2. Lead owner qualifies → click "Convert to Deal" → creates Deal + Contact + Organization in one transaction.
3. Deal moved through Pipeline stages via drag-drop in Kanban.
4. On "Closed Won", automation rule fires: assigns Account Manager, creates follow-up tasks.
```

#### Email sync

```text
1. Configure Email Account in CRM → IMAP server, SMTP server, agent assignment rule.
2. CRM polls inbox every 5 minutes; each email becomes a Communication linked to Lead/Deal/Contact.
3. Replies sent from CRM are sent via SMTP and logged as Communications.
```

#### Call logging with Twilio

1. Set up a Twilio account and add credentials in CRM Settings.
2. Click the call icon next to a Lead/Contact → browser initiates a Twilio call.
3. The call is recorded; `Call Log` is created automatically with duration and recording URL.

### How to Install

```bash
bench get-app https://github.com/frappe/crm
bench --site mysite.localhost install-app crm
bench --site mysite.localhost migrate
```

### Common Integrations

- **Twilio** — click-to-call and call logging.
- **Gmail/Outlook** — IMAP import, SMTP send.
- **Calendly** — embed scheduling links on Lead forms.
- **Zapier/Make** — generic webhook integration via CRM's REST API.
- **WhatsApp** — via third-party apps in the Frappe Cloud marketplace.

### Where to Learn More

- Live docs: `https://docs.frappe.io/crm`
- GitHub: `https://github.com/frappe/crm`

## Frappe Helpdesk

Helpdesk is a ticketing system rebuilt in 2023 to replace the older ERPNext `Issue` DocType flow. It introduces agents, SLAs, a knowledge base, and a modern customer-facing portal.

### What It Does

Receives tickets via email, web portal, or API; routes them to agents based on rules; tracks SLA breach timers; provides canned responses and a knowledge base for self-service.

### Standalone vs ERPNext-Bundled

Frappe Helpdesk is **standalone only**. ERPNext has the older `Issue` DocType (still maintained for backward compatibility). Frappe Helpdesk uses `Ticket` (different DocType name) and a richer data model. Do not install both on the same site — they will conflict on UI real estate.

### Top DocTypes

| DocType | Description |
|---|---|
| `Ticket` | The core ticket record; subject, description, status, priority |
| `Agent` | User who handles tickets; tied to Agent Group and SLAs |
| `Agent Group` | Team of agents (e.g. Support L1, Billing, Engineering) |
| `SLA` | Service Level Agreement with response/resolution time targets |
| `Service Level Agreement` | Per-customer SLA assignment (premium vs standard) |
| `Ticket Priority` | Urgent / High / Medium / Low with SLA multipliers |
| `Canned Response` | Pre-written reply with merge fields |
| `Knowledge Base Article` | Self-service article; grouped by Category |
| `Knowledge Base Category` | Tree of categories shown in customer portal |
| `Ticket Type` | Classification (Bug, How-to, Billing, Feature Request) |
| `Faq` | Short Q&A shown in portal |
| `Assignment Rule` | Rule-based auto-assignment (round-robin, load-balanced) |

### Common Workflows

#### Inbound email to ticket

```text
1. Configure Email Account with helpdesk@company.com → IMAP polling.
2. Each new email creates a Ticket with subject = email subject, description = body.
3. Assignment Rule assigns based on keywords or round-robin.
4. SLA timer starts counting response time.
5. Agent replies via Helpdesk → email sent to customer → Communication logged.
6. SLA "First Response" timer stops on first agent reply.
7. Ticket resolved → "Resolution Time" SLA stops.
```

#### Escalation

If the SLA deadline is breached:

1. The scheduler checks SLA breaches every 5 minutes.
2. On breach, escalates per the SLA's `Escalation Rule` — typically reassigns to the Agent Group's manager.
3. Sends a notification email to the manager and the customer (configurable).

### How to Install

```bash
bench get-app https://github.com/frappe/helpdesk
bench --site mysite.localhost install-app helpdesk
bench --site mysite.localhost migrate
```

### Common Integrations

- **Email** — IMAP for inbound, SMTP for outbound.
- **Slack** — ticket creation notifications via webhook.
- **Jira** — sync tickets to Jira issues (via marketplace app).
- **Customer portals** — embedded in websites built with Frappe Builder.

### Where to Learn More

- Live docs: `https://docs.frappe.io/helpdesk`
- GitHub: `https://github.com/frappe/helpdesk`

## Frappe Learning (LMS)

Frappe Learning is a learning management system (LMS) for selling and delivering courses, running cohort-based batches, and issuing certificates. It powers Frappe School's own course delivery.

### What It Does

Lets you create courses with lessons, quizzes, and exercises; enroll students individually or in batches; charge for access via Stripe or Razorpay; track progress; and issue certificates on completion.

### Top DocTypes

| DocType | Description |
|---|---|
| `Course` | The course master; title, intro, video, pricing |
| `Chapter` | Grouping of lessons within a course |
| `Lesson` | Individual content unit (Markdown, video, exercise, quiz) |
| `Quiz` | Set of questions with auto-grading |
| `Quiz Question` | Question + options + correct answer(s) |
| `Batch` | Cohort with start/end date, seat limit, instructors |
| `Enrollment` | Student → Course or Batch mapping with progress |
| `Course Evaluator` | Person who reviews student submissions (mentors) |
| `LMS Certificate` | Issued when student completes all required lessons |
| `LMS Settings` | Single doctype: payment gateway, branding, social links |

### Common Workflows

#### Free course with self-enrollment

```text
1. Create Course → add Chapters → add Lessons (Markdown with code blocks).
2. Set pricing to "Free" → students can self-enroll via portal.
3. Each lesson completion writes to Enrollment.progress.
4. On 100% completion, automation rule issues an LMS Certificate.
```

#### Paid cohort (batch) with Stripe

```text
1. Create Course → mark Paid → set price in LMS Settings → connect Stripe.
2. Create Batch → set start date, end date, seats, instructors.
3. Student visits batch page → clicks Enroll → Stripe checkout.
4. On Stripe webhook (payment succeeded), Enrollment created.
5. Instructor sees batch roster; lessons unlock by date or by student progress.
6. On batch end + student completion, certificate issued.
```

### How to Install

```bash
bench get-app https://github.com/frappe/lms
bench --site mysite.localhost install-app lms
bench --site mysite.localhost migrate
```

### Common Integrations

- **Stripe / Razorpay** — paid course checkout.
- **Frappe Discussion** — cohort chat (separate app, optional).
- **YouTube/Vimeo** — embed videos in lessons.
- **GitHub** — auto-grade coding exercises by reading PR submissions.

### Where to Learn More

- Live docs: `https://docs.frappe.io/lms`
- GitHub: `https://github.com/frappe/lms`

## Frappe Drive

Frappe Drive is a file sharing and collaboration app, conceptually similar to Nextcloud or Google Drive. It is built on the Frappe Framework and uses the framework's `File` DocType as its underlying storage, with a custom UI for browsing.

### What It Does

Provides per-user and per-team file storage with folder hierarchies, granular sharing (per user, per role, public link), and realtime collaboration on documents. Designed for self-hosted use where data sovereignty matters.

### Top DocTypes

| DocType | Description |
|---|---|
| `File` | The framework File DocType, extended with Drive-specific metadata |
| `Drive Entity` | A Drive-side wrapper: can be a file or a folder, with parent/child relationships |
| `Drive Folder` | Folder with sharing and quota settings |
| `Drive Document` | Realtime collaborative text doc (Yjs-based CRDT) |
| `Drive Favourite` | Bookmark record (starred items) |
| `Drive User` | Per-user settings: default folder, quota, recent items |
| `DocShare` | Framework-level record used by Drive to share any entity |

### Common Workflows

#### Upload and share

```text
1. User opens Drive → drags files into a folder.
2. Each upload creates a Drive Entity (parent = folder).
3. Right-click → "Share" → choose users, roles, or public link with optional password + expiry.
4. Recipient sees shared item in their "Shared with me" view.
```

#### Realtime document collaboration

```text
1. User creates a "New Document" in Drive → opens a rich-text editor.
2. User shares with collaborators → all see each other's cursors in realtime.
3. Edits propagate via Socket.io with Yjs CRDT for conflict-free merging.
4. Document autosaves to the DB; revisions are tracked.
```

### How to Install

```bash
bench get-app https://github.com/frappe/drive
bench --site mysite.localhost install-app drive
bench --site mysite.localhost migrate
```

### Common Integrations

- **ERPNext attachments** — Drive files can be attached to any ERPNext doc via the file uploader (with configuration).
- **Frappe Insights** — Drive storage metadata can be queried as a data source.
- **Webhooks** — file events trigger notification rules.

### Storage Quotas

Set per-user or per-role quotas in **Drive Settings**. When the limit is exceeded, uploads fail with a clear error. Quotas are calculated as the sum of `file_size` for `owner = <user>` across all `tabFile` rows.

### Where to Learn More

- Live docs: `https://docs.frappe.io/drive`
- GitHub: `https://github.com/frappe/drive`

## Frappe Insights

Frappe Insights is a business intelligence (BI) and analytics tool. It connects to external databases (or to the local Frappe site itself), runs SQL queries visually, and renders dashboards with charts.

### What It Does

Lets non-developers build dashboards without writing code. Power users can write SQL directly. Designed to compete with Metabase and Apache Superset, but with a Frappe-native UX and the same DocType/permissions model.

### Top DocTypes

| DocType | Description |
|---|---|
| `Data Source` | Connection to a database (MariaDB, PostgreSQL, SQLite, Frappe DB, BigQuery, Snowflake via drivers) |
| `Database Table` | Imported table/view from a data source |
| `Query` | A saved SQL query with parameters and visualizations |
| `Query Result` | Cached result of a query run; refreshable |
| `Dashboard` | A grid of charts and numbers |
| `Dashboard Chart` | Individual chart bound to a Query |
| `Number Card` | Single-value KPI card |
| `Insights Settings` | Global settings: default refresh interval, share permissions |
| ` Insights Data Source` | (older name) Alias for Data Source |

### Common Workflows

#### Build a sales dashboard from ERPNext data

```text
1. Create Data Source → select "Frappe DB" → it auto-detects tables in the same site.
2. Or use the MariaDB/PostgreSQL connector to point at an external replica.
3. Create Query → join `tabSales Invoice` and `tabCustomer` via the visual builder, or write SQL.
4. Save query → choose visualization type (bar, line, pie, heatmap, scatter).
5. Add chart to Dashboard → arrange on grid.
6. Set scheduled refresh (hourly/daily) so the cached Query Result stays fresh.
7. Share dashboard with a role or a specific user via Dashboard permissions.
```

#### Scheduled refresh

In Dashboard or Query, set `Refresh Frequency` (5 min, 1 hour, 1 day). A scheduler job (`insights.api.run_scheduled_refresh`) re-runs all queries marked as refreshable. Results are cached in `tabQuery Result` and served without hitting the source DB.

### Supported Databases

| Database | Driver | Notes |
|---|---|---|
| MariaDB | `pymysql` | Native, fastest for ERPNext sites |
| PostgreSQL | `psycopg2` | Native, full type support |
| SQLite | `sqlite3` | Useful for testing and small datasets |
| MySQL | `pymysql` | Same driver, different dialect flag |
| BigQuery | `google-cloud-bigquery` | Third-party driver, billed separately |
| Frappe DB | (internal) | Reads from the current site's tables directly |

### How to Install

```bash
bench get-app https://github.com/frappe/insights
bench --site mysite.localhost install-app insights
bench --site mysite.localhost migrate
```

### Common Integrations

- **ERPNext** — use as the primary data source for finance/stock dashboards.
- **External data warehouses** — connect to BigQuery/Snowflake via drivers.
- **Frappe Dashboards** — Insights charts can be embedded in ERPNext Workspace via an iframe block.

### Where to Learn More

- Live docs: `https://docs.frappe.io/insights`
- GitHub: `https://github.com/frappe/insights`

## Frappe Builder

Frappe Builder is a no-code visual page builder for building websites and web app pages without writing HTML/CSS. Pages built with Builder render on the Frappe Framework portal and can use server-side data via `frappe.call`.

### What It Does

Provides a WYSIWYG editor where you compose pages from blocks (hero, columns, gallery, form, etc.). Each block has style controls (color, spacing, typography) and can be bound to Frappe data sources. Outputs responsive HTML/CSS without committing templates.

### Top DocTypes

| DocType | Description |
|---|---|
| `Builder Page` | A single page; URL, blocks, theme, scripts |
| `Block` | A unit of layout: container, text, image, button, form, code |
| `Component` | Reusable block definition; can be parametrized |
| `Builder Theme` | Site-wide design tokens: colors, fonts, spacing |
| `Builder Settings` | Global config: default theme, publishing workflow |
| `Builder Page Component` | Mapping: page → components used |

### Common Workflows

#### Build a landing page

```text
1. Create Builder Page → set URL (e.g. /landing).
2. Drag a Hero block → set heading, subheading, CTA button.
3. Drag a Columns block → add 3 feature cards with icons.
4. Drag a Form block → bind to a Web Form (lead capture).
5. Style: pick theme color, fonts, spacing via the right sidebar.
6. Publish → page live at https://yoursite.localhost/landing.
7. (Optional) Set as homepage in Builder Settings.
```

#### Reusable component

```text
1. Create Component "Pricing Card" with props: title, price, features[], cta_url.
2. Use Component in any Builder Page → pass props in the block settings.
3. Update the Component once → all usages auto-update.
```

### How to Install

```bash
bench get-app https://github.com/frappe/builder
bench --site mysite.localhost install-app builder
bench --site mysite.localhost migrate
```

### Common Integrations

- **Frappe Web Forms** — embed forms in Builder pages.
- **Frappe Wiki** — link to wiki articles from Builder navigation.
- **ERPNext** — show product/dynamic data via `frappe.call` blocks.

### Where to Learn More

- Live docs: `https://docs.frappe.io/builder`
- GitHub: `https://github.com/frappe/builder`

## Frappe Print Designer

Frappe Print Designer is a drag-drop print format builder. It replaces writing HTML/Jinja print formats by hand (covered in `../erpnext/customization.md`). Outputs a structured layout that renders identically to HTML, PDF, and email.

### What It Does

Provides a canvas where you drag fields, headers, footers, tables, and images onto a page. Supports conditional sections (show/hide based on doc values), repeating rows for child tables, and custom CSS per element. Exports as a JSON-serialized layout stored in the `Print Format` DocType.

### Top DocTypes

| DocType | Description |
|---|---|
| `Print Format` | Framework DocType, extended with `print_designer` field holding the layout JSON |
| `Print Designer Element` | A layout element: text, table, image, barcode, signature |
| `Print Designer Settings` | Global: default paper size, fonts, headers/footers |

### Common Workflows

#### Build a custom invoice

```text
1. Open Sales Invoice → click Print → "Edit Print Format" → "Open in Print Designer".
2. Drag a Header block → add company logo (image), name, address (dynamic fields).
3. Drag a Customer block → bind to doc.customer_name, doc.customer_address.
4. Drag a Table block → bind to doc.items → set columns (item_code, qty, rate, amount).
5. Drag a Footer block → add totals (grand_total) + payment terms.
6. Add conditional section: "Show bank details only if doc.status == 'Unpaid'".
7. Save → preview → set as default print format for Sales Invoice.
```

#### Conditional rendering

Use the visibility expression on any element. The expression is a Jinja-like Python expression evaluated against the doc context:

| Expression | Effect |
|---|---|
| `doc.status == "Paid"` | Show only on paid invoices |
| `doc.total > 10000` | Show only on large invoices |
| `doc.is_return == 1` | Show only on credit notes |
| `doc.customer_group == "VIP"` | Show only for VIP customers |

### Exporting

Print formats built with Print Designer export as part of a Fixtures export (read `../erpnext/customization.md#fixtures-exporting-customizations`) — they survive migration when imported into another site.

### How to Install

```bash
bench get-app https://github.com/frappe/print_designer
bench --site mysite.localhost install-app print_designer
bench --site mysite.localhost migrate
```

### Common Integrations

- **ERPNext** — primary use case; all ERPNext DocTypes support Print Designer formats.
- **Frappe HR** — payslip and attendance print formats.
- **Frappe CRM** — quote/estimate print formats.

### Where to Learn More

- Live docs: `https://docs.frappe.io/print-designer`
- GitHub: `https://github.com/frappe/print_designer`

## Frappe Wiki

Frappe Wiki is a wiki and knowledge base app for Frappe sites. It organizes content into spaces, each with its own sidebar, and tracks page revisions with a publish workflow.

### What It Does

Lets you build an internal or public knowledge base with hierarchical pages. Pages support Markdown, code blocks, images, and links. Editors draft changes; reviewers approve and publish. Old revisions are kept for audit.

### Top DocTypes

| DocType | Description |
|---|---|
| `Wiki Page` | A single wiki article; Markdown content + metadata |
| `Wiki Space` | Top-level grouping (e.g. Engineering, HR Policies) with its own sidebar |
| `Wiki Sidebar` | Tree of pages within a space; controls navigation |
| `Wiki Page Revision` | Versioned content; each save creates a new revision |
| `Wiki Settings` | Global: default space, comments on/off, theme |
| `Wiki Page Patch` | Proposed edit awaiting review (used in publish workflow) |

### Common Workflows

#### Create and publish a page

```text
1. Pick (or create) a Wiki Space → set the sidebar root.
2. Add a Wiki Page → write Markdown content → Save.
3. (If workflow enabled) Page is in "Draft" → submit for review.
4. Reviewer opens the patch → approve → Wiki Page Revision created and page goes live.
5. Old revision retained → can be reverted via "Revisions" tab.
```

#### Sidebar structure

The sidebar is a flat list of `Wiki Sidebar` records, each with a `parent_wiki_page` for nesting. Reordering is done by drag-drop in the sidebar editor — Frappe Wiki writes the new positions to `lft`/`rgt` columns on the tree.

### How to Install

```bash
bench get-app https://github.com/frappe/wiki
bench --site mysite.localhost install-app wiki
bench --site mysite.localhost migrate
```

### Common Integrations

- **Frappe Helpdesk** — link wiki articles to ticket types for self-service deflection.
- **ERPNext** — embed wiki pages in Workspaces as quick-reference material.
- **Frappe Builder** — link to wiki from Builder navigation menus.

### Where to Learn More

- Live docs: `https://docs.frappe.io/wiki`
- GitHub: `https://github.com/frappe/wiki`

## Frappe Cloud

Frappe Cloud is the managed hosting platform run by Frappe. It is a SaaS, not an installable app — you sign up at `frappecloud.com` and provision sites, benches, and apps through a control panel. The platform itself is also open-source (`frappe/cloud`) if you want to self-host the marketplace.

### What It Does

Provides one-click Frappe site provisioning, automatic backups, SSL certificates, marketplace app installs, version upgrades, and per-site billing. Eliminates the operational overhead of running `bench`, nginx, supervisor, and MariaDB yourself.

### Top DocTypes (visible in the Frappe Cloud dashboard)

| DocType | Description |
|---|---|
| `Site` | A Frappe site with its own DB, subdomain, and plan |
| `Bench` | A group of sites sharing an app version (a deploy unit) |
| `Plan` | Resource tier (CPU/RAM/storage) + price |
| `Marketplace App` | Installable app listing (ERPNext, HR, CRM, etc.) |
| `Site App` | App installed on a specific site |
| `Invoice` | Monthly billing record |
| `Subscription` | Plan + billing cycle tied to a Site or Bench |
| `Backup` | Per-site backup record with restore URL |
| `TLS Certificate` | Auto-managed Let's Encrypt certificate per domain |
| `Release Group` | Group of apps bundled into a bench version |

### Common Workflows

#### Provision a new ERPNext site

```text
1. Sign up at frappecloud.com → add a payment method.
2. Click "New Site" → choose ERPNext → pick a plan.
3. Site is provisioned in ~5 minutes: ERPNext installed, subdomain assigned, SSL issued.
4. Run the setup wizard in the new site (company, currency, etc.).
```

#### Install a marketplace app on an existing site

```text
1. Open site dashboard → "Apps" tab.
2. Browse Marketplace → click "Install" next to Frappe HR.
3. Frappe Cloud runs bench get-app + install-app + migrate on the bench.
4. Site restarts; app appears in Desk.
```

#### Custom domain + SSL

```text
1. Site dashboard → "Domains" → add domain (e.g. erp.mycompany.com).
2. Update DNS to CNAME to <site>.frappecloud.com.
3. Frappe Cloud detects the CNAME → issues Let's Encrypt cert → reconfigures nginx.
4. Site accessible at custom domain over HTTPS.
```

#### Automated backups

- **Daily automatic backups** — every site, retained 7 days (free) or 30+ days (paid plans).
- **On-demand backup** — trigger from dashboard before risky operations.
- **Off-site backup** — push to your own S3 bucket via the Backup Settings.

### Pricing & Plans

Plans are tiered by CPU/RAM/storage. See `https://frappecloud.com/pricing` for current tiers. Plans are billed per site per month (or per bench for dedicated benches). Apps from the Marketplace may carry their own subscription fees (set by the app author).

### Security

- All sites run on isolated Docker containers.
- TLS forced; HSTS enabled.
- Per-site DB credentials (not shared across sites).
- Optional 2FA for the Frappe Cloud dashboard login.
- Marketplace apps are reviewed before publication; unsigned apps are not allowed.

### Self-Hosting the Marketplace

The Frappe Cloud code (`frappe/cloud`) lets you run your own private marketplace on your own infrastructure. Use this when you want the Frappe Cloud UX but cannot use the public cloud (data residency, internal billing, custom app catalog). The self-hosted marketplace requires Kubernetes or Docker Swarm and significant ops investment.

### Where to Learn More

- Website: `https://frappecloud.com`
- Docs: `https://frappecloud.com/docs`
- GitHub: `https://github.com/frappe/cloud`

## Frappe Lending

Frappe Lending is a loan management system for non-banking financial companies (NBFCs), micro-finance institutions, and internal employee loan programs. Also bundled inside ERPNext as the `Loan Management` module.

### What It Does

Manages loan applications, disbursements, repayment schedules, interest accrual, and recovery. Supports term loans, demand loans, and overdraft facilities with simple or compound interest.

### Standalone vs ERPNext-Bundled

Like Frappe HR, Frappe Lending ships both standalone and as an ERPNext module. The standalone version is slimmer and updates faster.

### Top DocTypes

| DocType | Description |
|---|---|
| `Loan` | The loan contract: principal, rate, tenure, repayment schedule |
| `Loan Application` | Customer request for a loan; links to Loan on approval |
| `Loan Type` | Loan product definition: rate, mode of interest, repayment method |
| `Loan Security` | Collateral pledged against a loan (gold, property, securities) |
| `Loan Security Type` | Type of collateral with pledge/release ratios |
| `Loan Disbursement` | Disbursement record; multiple tranches possible |
| `Loan Repayment` | Customer payment record; auto-adjusts against schedule |
| `Loan Repayment Schedule` | Generated schedule of due dates and amounts |
| `Loan Interest Accrual` | Periodic interest accrual entry (per Loan Type frequency) |
| `Loan Write Off` | Write-off record for bad loans |
| `Process Loan Interest Accrual` | Bulk job: accrue interest for all active loans |
| `Loan Demand` | Demand for repayment raised against a loan |

### Common Workflows

#### Term loan lifecycle

```text
1. Customer submits Loan Application → set Loan Type, principal, tenure.
2. Loan officer reviews → approves with terms → creates Loan.
3. Loan generates Loan Repayment Schedule (EMI breakdown).
4. Loan Disbursement created → funds transferred to customer.
5. Each period, Process Loan Interest Accrual runs → creates Loan Interest Accrual entries.
6. Customer pays → Loan Repayment created → allocated to interest first, then principal.
7. On full repayment, Loan status → "Closed".
8. (If default) → Loan Write Off after defined NPA period.
```

#### Interest types

| Mode | Calculation |
|---|---|
| Simple Interest | `interest = principal × rate × time` |
| Compound (monthly) | Interest on outstanding balance, recomputed monthly |
| Flat Rate | Fixed interest on original principal for full tenure |
| Reducing Balance | Interest on remaining principal after each EMI |

### How to Install

```bash
# Standalone
bench get-app https://github.com/frappe/lending
bench --site mysite.localhost install-app lending
bench --site mysite.localhost migrate
```

### Common Integrations

- **ERPNext Accounts** — loan disbursements and repayments post Journal Entries.
- **Bank APIs** — for EMI auto-debit (via custom integrations).
- **SMS/Email** — repayment reminders via Notification.

### Where to Learn More

- Live docs: `https://docs.frappe.io/lending`
- GitHub: `https://github.com/frappe/lending`

## Frappe Studio

Frappe Studio is a visual app builder (in active development as of 2025). It aims to let non-developers compose DocTypes, forms, workflows, and reports via drag-drop, then export the result as a Frappe app.

### What It Does

(Planned) Lets you sketch an app's data model, design forms, configure workflows, and generate print formats — all from a visual editor. Output is a standard Frappe app that can be installed on any site.

### Status

Frappe Studio is **not production-ready**. It is included here for awareness; do not recommend it for production apps yet. For now, build apps the standard way (described in `../framework/doctype-guide.md`).

### Where to Learn More

- GitHub: `https://github.com/frappe/studio`

## Frappe Gantt

Frappe Gantt is a reusable JavaScript Gantt chart component, not a full Frappe app. It powers the Gantt view in ERPNext Projects, Frappe HR shift planning, and other places where timeline visualization is needed.

### What It Does

Renders an interactive Gantt chart from a JSON data structure. Supports drag-to-resize, dependency arrows, critical path highlighting, and view modes (Day/Week/Month).

### How to Use

```javascript
// In a custom Page or Workspace
const tasks = [
  { id: "Task 1", name: "Design", start: "2025-01-01", end: "2025-01-05", progress: 50 },
  { id: "Task 2", name: "Develop", start: "2025-01-06", end: "2025-01-15", dependencies: "Task 1" },
];
const gantt = new Gantt("#gantt-container", tasks, {
  view_mode: "Day",
  on_click: (task) => frappe.set_route("Form", "Task", task.id),
});
```

### Where to Learn More

- GitHub: `https://github.com/frappe/gantt`
- npm: `@frappe/gantt`

## Frappe Books

Frappe Books is a desktop accounting application for small businesses. It is **not** built on Frappe Framework — it is a separate Tauri/Rust desktop app with a Vue frontend, designed for offline-first use without a server.

### What It Does

Provides invoicing, expense tracking, journal entries, and basic financial reports for freelancers and small businesses. Data is stored locally in SQLite; optionally synced across devices via a sync server.

### How It Differs from ERPNext

| Aspect | Frappe Books | ERPNext |
|---|---|---|
| Architecture | Desktop app (Tauri) | Web app (Frappe Framework) |
| Storage | Local SQLite + optional sync | MariaDB / PostgreSQL |
| Multi-user | Limited (sync-based) | Full RBAC |
| Modules | Invoicing, expenses, basic reports | Full ERP (Stock, HR, Manufacturing, etc.) |
| Install | Download from website | Self-host or use Frappe Cloud |
| Open-source | Yes (GPLv3) | Yes (GPLv3) |

Use Frappe Books when the user wants a lightweight desktop accounting tool for a single business owner. Use ERPNext when they need multi-user, multi-module ERP.

### Where to Learn More

- Website: `https://frappebooks.com`
- GitHub: `https://github.com/frappe/books`

## Choosing Between Bundled and Standalone

When an app is available both as an ERPNext module and as a standalone install (HR, Lending), apply this decision tree:

```text
Do you already run ERPNext in production?
├─ Yes → Use the bundled module. Installing standalone alongside causes
│        namespace collisions and double-migrations.
└─ No  → Are you sure you need ERPNext at all?
         ├─ If only HR/Payroll needed → install Frappe HR standalone.
         │                              Resource footprint is ~40% smaller.
         ├─ If only Loans needed      → install Frappe Lending standalone.
         └─ If you need ≥3 modules    → install ERPNext; it bundles HR, Loans,
                                        Projects, CRM, etc.
```

### Gotchas

- **Installing HR standalone alongside ERPNext** is not supported and will break on the next migration — both register the same DocTypes.
- **Mixing standalone and ERPNext versions** (e.g. ERPNext v15 with HR v16) breaks — Frappe apps in the same bench must share the framework major version.
- **Frappe CRM vs ERPNext CRM module** — pick one. Both expose a `Lead` DocType; installing both on the same site causes UI conflicts (two CRM menus).
- **Frappe Helpdesk vs ERPNext Issues** — same issue; pick one.

### Recommended Stack for Common Use Cases

| Use case | Recommended stack |
|---|---|
| Mid-size company needing HR + Accounts + Stock | ERPNext (uses bundled HR + CRM) |
| Software company needing CRM + Helpdesk + Wiki | Frappe CRM + Frappe Helpdesk + Frappe Wiki (no ERPNext) |
| Training company selling courses | Frappe Learning + Frappe Builder (no ERPNext) |
| NBFC doing loans only | Frappe Lending standalone |
| Embedded BI for ERPNext | ERPNext + Frappe Insights |
| Customer portal with knowledge base | ERPNext + Frappe Wiki + Frappe Builder |
| Quick website for a service business | Frappe Builder + Frappe Wiki |
| All-in-one managed hosting | Frappe Cloud (ERPNext + add apps from Marketplace) |

## Where to Learn More

- **Frappe ecosystem overview**: `https://frappe.io/ecosystem`
- **Frappe Cloud Marketplace** (live app catalog): `https://frappecloud.com/marketplace`
- **Frappe GitHub org** (all app source): `https://github.com/frappe`
- **Frappe Forum** (community Q&A): `https://discuss.frappe.io`
- **Frappe School** (free courses on each app): `https://frappe.school`
- For ERPNext-specific customization patterns, see `../erpnext/customization.md`.
- For Framework concepts shared by all apps (DocType, hooks, REST, bench), see `../framework/architecture.md` and `../framework/bench-cli.md`.
- For troubleshooting any of these apps, see `../troubleshooting.md`.
