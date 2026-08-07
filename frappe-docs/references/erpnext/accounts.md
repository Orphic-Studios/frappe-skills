# ERPNext — Accounting Module

The Accounts module is the financial backbone of ERPNext. Every other module eventually posts to the General Ledger through it. Use this file when answering questions about chart of accounts, journal entries, payments, taxes, multi-currency, financial statements, fixed-asset depreciation, budgeting, or any accounting report. For the buying/selling transactional DocTypes (Sales/Purchase Invoice) that link back here, see `selling-buying.md`; for the setup checklist, see `overview.md`.

## Table of Contents

1. [Chart of Accounts](#chart-of-accounts)
2. [Accounting Setup Checklist](#accounting-setup-checklist)
3. [Fiscal Year & Accounting Period](#fiscal-year--accounting-period)
4. [Journal Entry](#journal-entry)
5. [Payment Entry](#payment-entry)
6. [Sales & Purchase Invoices (Accounting View)](#sales--purchase-invoices-accounting-view)
7. [Taxes & Charges Templates](#taxes--charges-templates)
8. [Cost Center Hierarchy](#cost-center-hierarchy)
9. [Multi-Currency Accounting](#multi-currency-accounting)
10. [Opening Balances](#opening-balances)
11. [Financial Statements](#financial-statements)
12. [Regional Tax Setup (GST/VAT)](#regional-tax-setup-gstvat)
13. [Advance Payments](#advance-payments)
14. [Credit Notes & Debit Notes](#credit-notes--debit-notes)
15. [Budgeting](#budgeting)
16. [Fixed Asset Depreciation](#fixed-asset-depreciation)
17. [Accounting Reports](#accounting-reports)
18. [Common Errors & Troubleshooting](#common-errors--troubleshooting)
19. [Where to Learn More](#where-to-learn-more)

## Chart of Accounts

The Chart of Accounts (COA) is a tree of `Account` records rooted in five top-level groups, one per **root type**:

| Root Type | Normal Balance | Appears On | Examples |
|---|---|---|---|
| `Asset` | Debit | Balance Sheet | Cash, Bank, Debtors, Inventory, Fixed Assets |
| `Liability` | Credit | Balance Sheet | Creditors, Bank Loans, Taxes Payable |
| `Equity` | Credit | Balance Sheet | Share Capital, Retained Earnings |
| `Income` | Credit | Profit & Loss | Sales, Service Income, Interest Earned |
| `Expense` | Debit | Profit & Loss | Cost of Goods Sold, Salaries, Rent |

### Tree Structure

Each `Account` has a `parent_account` and an `is_group` flag (group accounts cannot be transacted; only leaf accounts can). The tree is rooted at exactly five group accounts created automatically when the company is set up:

```
Application of Funds (Assets)        ← root group
   ├── Current Assets
   │   ├── Cash
   │   ├── Bank Accounts
   │   │   └── Acme Bank - ACME       ← leaf, transactable
   │   ├── Debtors
   │   └── Stock Assets
   └── Fixed Assets
Sources of Funds (Liabilities)
   ├── ...
Equity
Income
Expenses
```

### Creating Accounts

#### Via Desk

1. Open **Chart of Accounts** (Accounts → General Ledger → Chart of Accounts).
2. Click **Add Account**.
3. Pick parent (must be a group).
4. Set `account_name`, `account_type` (optional but recommended), `balance_must_be` (Debit/Credit).
5. Save. The auto-generated name appends the company abbr: `Cash - ACME`.

#### Via Python

```python
account = frappe.get_doc({
    "doctype": "Account",
    "account_name": "Petty Cash",
    "parent_account": "Current Assets - ACME",
    "company": "Acme",
    "account_type": "Cash",
    "is_group": 0,
})
account.insert()
```

### Account Types

The `account_type` field drives special behavior. Set it correctly — leaving it blank disables features like bank reconciliation and receivables tracking:

| Account Type | Behavior |
|---|---|
| `Cash` | Treated as liquid; appears in cash flow statement. |
| `Bank` | Enables Bank Reconciliation; appears in payment entry dropdown. |
| `Cash` / `Bank` | Both appear as selectable accounts in Payment Entry's `paid_from` / `paid_to`. |
| `Receivable` | Required for Customer ledger; auto-created per customer via "Receivables Group". |
| `Payable` | Required for Supplier ledger; auto-created per supplier via "Payables Group". |
| `Tax` | Used by tax templates; shows up in tax reports. |
| `Cost of Goods Sold` | Reserved for COGS; ERPNext auto-posts here when stock is sold (perpetual inventory). |
| `Stock Adjustment` | Auto-posted on stock reconciliation. |
| `Stock Received But Not Billed` | GRN suspense account. |
| `Fixed Asset` | Required for asset capitalization. |
| `Accumulated Depreciation` | Counter-asset for depreciation. |
| `Capital Work in Progress` | Assets under construction. |
| `Temporary` | Used by year-end closing. |

### Pitfalls

- **Each account name must be unique within the company** — including the abbr suffix. ERPNext appends `- ACME` automatically; do not add it yourself.
- **Group accounts cannot be transacted** — if a Journal Entry lists a group account, it errors with "Cannot book entry against group account".
- **Renaming an account** with `rename_doc` does not update historical GL entries — but ERPNext uses the account name as the primary key in `tabGL Entry`, so renames via the standard API do propagate. Use the rename via `Account → Rename` UI to be safe.
- **Changing root_type after transactions exist** breaks every financial statement. Restructure the COA before going live; afterward, create new accounts and migrate.

## Accounting Setup Checklist

After Company setup (see `overview.md`), walk through this checklist before the first transaction. Each step links to a later section in this file.

1. **Verify the Chart of Accounts** — open Chart of Accounts tree, confirm the five root groups exist and the leaf accounts match your business.
2. **Create Fiscal Year** (`Fiscal Year`) and any **Accounting Periods** you want to lock (e.g. monthly closes).
3. **Set up Bank Accounts** — create the bank ledger account (Account Type = Bank) and a `Bank Account` master linked to it.
4. **Configure Taxes** — create at least one `Sales Taxes and Charges Template` and one `Purchase Taxes and Charges Template`. See [Taxes](#taxes--charges-templates).
5. **Set up Cost Centers** — at minimum create a `Main` cost center as the root.
6. **Set up Currency Exchange Rate** providers if multi-currency (`Accounts Settings → Currency Exchange Rate`). See [Multi-currency](#multi-currency-accounting).
7. **Set up Number Series** — verify each transactable DocType's numbering series is sensible. Default series are usually fine.
8. **Enter Opening Balances** via `Journal Entry` with `voucher_type = Opening Entry`. See [Opening Balances](#opening-balances).
9. **Enable Accounts Settings flags** as needed (perpetual inventory, book advance payments, etc.).
10. **Configure Regional Compliance** if applicable (GST, VAT). See [Regional Tax Setup](#regional-tax-setup-gstvat).

## Fiscal Year & Accounting Period

### Fiscal Year

`Fiscal Year` records cover a span of dates. They are global (not per-company) but can be restricted to specific companies via the `Companies` child table. Create new years before the start date so the year-end closing process can be scheduled.

```python
fy = frappe.get_doc({
    "doctype": "Fiscal Year",
    "year": "2026",
    "year_start_date": "2026-01-01",
    "year_end_date": "2026-12-31",
    "companies": [{"company": "Acme"}],
})
fy.insert()
```

ERPNext posts transactions to a fiscal year based on the **posting date** of the transaction, not the creation date. A Journal Entry dated 2025-12-31 created in 2026 belongs to FY 2025.

### Accounting Period

`Accounting Period` is a finer-grained lock. Use it to **freeze** a month or quarter after the books are closed:

| Field | Effect |
|---|---|
| `start_date` / `end_date` | The period range. |
| `closed` | When checked, no new Journal Entries, Payment Entries, or Invoices can post in this range. |
| `companies` | Restrict to specific companies. |
| `period_name` | Free text; use a clear convention like `April 2026`. |

To re-open a period, edit and uncheck `closed` — but always do this with the accountant's approval.

### Period Closing Voucher

At fiscal year-end, run `Period Closing Voucher` to transfer P&L balances to the retained earnings account. The voucher:

1. Calculates net P&L for the period.
2. Creates a Journal Entry debiting expense accounts (or crediting income) to zero them.
3. Credits (or debits) the retained earnings account specified.

Run it **once** per fiscal year. Cancel and re-create if you discover an error before the next year's books are also closed.

## Journal Entry

`Journal Entry` is the most flexible accounting voucher — every other voucher (Payment Entry, Sales Invoice, Purchase Invoice) eventually creates GL Entries equivalent to a Journal Entry. Use it for:

- Manual adjustments (depreciation, accruals, provisions).
- Opening balances.
- Year-end closing.
- Inter-company transfers (when paired with `Inter Company Entry` voucher type).

### Voucher Types

ERPNext ships multiple `voucher_type` values. The choice does not change the GL posting mechanics — all produce `GL Entry` rows — but it changes the **narration**, the **default accounts**, and how the entry shows up in reports.

| Voucher Type | When to Use | Notes |
|---|---|---|
| `Journal Entry` | Default for general adjustments. | |
| `Inter Company Entry` | Transactions between sister companies. | Requires Inter Company Settings. |
| `Bank Entry` | Bank-specific adjustments. | Auto-picks bank-type accounts in dropdown. |
| `Cash Entry` | Cash-specific adjustments. | Auto-picks cash-type accounts. |
| `Credit Note` | Manual credit to a customer (not from a Sales Invoice). | Pair with `against_invoice` field for proper allocation. |
| `Debit Note` | Manual debit to a supplier. | Pair with `against_invoice`. |
| `Opening Entry` | First-time setup of opening balances. | See [Opening Balances](#opening-balances). |
| `Depreciation Entry` | Manual depreciation; asset module auto-creates these. | |
| `Exchange Rate Revaluation` | Revalue foreign-currency balances at month-end. | See [Multi-currency](#multi-currency-accounting). |
| `Write Off Entry` / `Write Back Entry` | Bad debt write-offs or recoveries. | |

### Anatomy of a Journal Entry

A Journal Entry has:

- A **header** (date, voucher type, company, narration).
- A child table **Journal Entry Account** rows — at least two rows, and `total_debit == total_credit`.
- Optionally a **reference** (cheque number, payee, etc.) for bank entries.

```python
je = frappe.get_doc({
    "doctype": "Journal Entry",
    "voucher_type": "Journal Entry",
    "posting_date": "2026-01-15",
    "company": "Acme",
    "narration": "Audit adjustment for prepaid insurance",
    "accounts": [
        {"account": "Insurance Expense - ACME", "debit_in_account_currency": 1200},
        {"account": "Prepaid Insurance - ACME", "credit_in_account_currency": 1200},
    ],
})
je.insert()
je.submit()
```

### Multi-Currency Journal Entries

If any account has a non-company currency (set on the Account master), set `account_currency`, `debit_in_account_currency`, `credit_in_account_currency`, and let ERPNext compute `debit` / `credit` in the company currency using the day's exchange rate (from `Currency Exchange`). Override `exchange_rate` if you need to force a specific rate.

### Common Journal Entry Pitfalls

- **Unbalanced entry** — `total_debit` and `total_credit` must match to the cent. ERPNext refuses to submit otherwise.
- **Posting to a group account** — always pick a leaf.
- **Posting to a foreign-currency account without setting `exchange_rate`** — the company-currency totals will be wrong.
- **Forgetting to set `cost_center`** on each row — every expense/income row should have one or default applies.
- **Using `Administrator` to bypass party balance checks** — hides data quality issues. Always post as the right role.

## Payment Entry

`Payment Entry` is the modern replacement for the older "Payment to Invoice" / "Payment Voucher" flow. Use it for every cash/bank movement: customer receipts, supplier payments, internal transfers, and refunds. It replaced the older `Payment to Invoice` DocType in v11 and is now the only recommended voucher.

### Payment Types

| `payment_type` | paid_from | paid_to | Use |
|---|---|---|---|
| `Receive` | Debtor account (or Bank if refund) | Bank/Cash | Customer pays you. |
| `Pay` | Bank/Cash | Creditor account (or Bank if refund) | You pay supplier. |
| `Internal Transfer` | Bank/Cash A | Bank/Cash B | Move between your own accounts. |

### Allocating Against Invoices

The heart of Payment Entry is the **Payment References** child table (`references`). Each row links the payment to an outstanding invoice:

```python
pe = frappe.get_doc({
    "doctype": "Payment Entry",
    "payment_type": "Receive",
    "party_type": "Customer",
    "party": "Acme Customer",
    "company": "Acme",
    "paid_amount": 500,
    "paid_from": "Debtors - ACME",
    "paid_to": "Acme Bank - ACME",
    "references": [
        {
            "reference_doctype": "Sales Invoice",
            "reference_name": "SINV-00123",
            "allocated_amount": 500,
        }
    ],
})
pe.insert()
pe.submit()
```

The `allocated_amount` on each row reduces the invoice's outstanding balance. ERPNext enforces:

- Total allocated ≤ total payment.
- Allocated amount ≤ invoice outstanding.
- Reference belongs to the same party.

### Multi-Invoice Allocation

One Payment Entry can allocate against many invoices. The unallocated remainder (the "advance") sits on the party's account as an open credit until consumed by a future invoice or a separate **Reconcile** action.

### Internal Transfers

For `Internal Transfer`, do not set `party_type` / `party`. Both `paid_from` and `paid_to` must be Bank/Cash accounts.

### Exchange (Currency Swap)

Set `payment_type = Internal Transfer` with `paid_from` in one currency and `paid_to` in another. ERPNext records a currency gain/loss automatically based on the exchange rate differential.

### Common Payment Entry Pitfalls

- **Party's account missing** — every customer/supplier needs a receivable/payable account. ERPNext auto-creates these on master creation; if missing, the "Party Account" picker is empty.
- **Unallocated amount** — if `paid_amount` ≠ sum of `references.allocated_amount`, the difference becomes an advance. Often this is intentional, but verify.
- **Posting date outside the fiscal year** — ERPNext blocks by default. Re-open the period or re-date.
- **Bank reconciliation** — match the Payment Entry's `reference_no` and `reference_date` to the bank statement line. The `Bank Reconciliation` tool uses these fields.

## Sales & Purchase Invoices (Accounting View)

The Selling/Buying modules create `Sales Invoice` and `Purchase Invoice` documents. From an accounting perspective, both:

- Post `GL Entry` rows when submitted.
- Update the party's receivable/payable balance.
- Recognize income/expense (P&L).
- Recognize tax liabilities.
- Optionally book stock movement (if perpetual inventory is on and an Item has `valuation_rate`).

See `selling-buying.md` for the full transactional flow. The accounting-specific aspects:

### GL Posting Pattern (Sales Invoice)

For a Sales Invoice totalling 1000 + 18% tax, with perpetual inventory on and COGS = 600:

| Account | Debit | Credit |
|---|---|---|
| Debtors (Customer) | 1180 | |
| Sales | | 1000 |
| Output Tax (Sales Tax Payable) | | 180 |
| Cost of Goods Sold | 600 | |
| Stock Asset (Inventory) | | 600 |

The last two rows are auto-generated by the **perpetual inventory** feature. Without perpetual inventory, only the first three rows post.

### Accounting-Related Invoice Fields

| Field | Purpose |
|---|---|
| `is_pos` | Marks the invoice as Point-of-Sale — auto-creates a Payment Entry against it. |
| `update_stock` | If checked, the invoice moves stock directly (skipping Delivery Note). |
| `write_off_amount` | Writes off a small uncollectible remainder — book to a configured `write_off_account`. |
| `advance_paid` | Auto-populated; reflects allocated advances. |
| `group_same_items` | Consolidates duplicate item rows for printing. |
| `set_posting_time` | Allows back-dating; requires `Accounts Settings → Allow Accounting Entry Creation Before Posting Date`. |
| `account_for_change_amount` | Where to put rounding differences in cash transactions. |

## Taxes & Charges Templates

Taxes are defined via templates — reusable groups of tax rows. Create one template per tax regime you commonly apply.

### Sales Taxes and Charges Template

Each template contains child rows of `Sales Taxes and Charges`, each representing one tax line:

| Field | Effect |
|---|---|
| `charge_type` | `Actual` (fixed amount), `On Net Total`, `On Previous Row Total`, `On Previous Row Amount`, `On Item Quantity`. |
| `account_head` | The Tax-type Account to book to (e.g. "Output VAT - ACME"). |
| `rate` | Percent (e.g. `18` for 18% GST). |
| `description` | Printed on the invoice. |
| `included_in_print_rate` | If checked, the tax is bundled in the item price (tax-inclusive). |
| `row_id` | For "On Previous Row" types, which previous row to compute on. |
| `cost_center` | Required for the GL posting. |

### Compound Tax (Tax on Tax)

To compute VAT on a price that already includes Excise, create two rows:

1. Excise — `charge_type = On Net Total`, `rate = 12`.
2. VAT — `charge_type = On Previous Row Total`, `row_id = 1`, `rate = 5`.

### Tax-Inclusive Pricing

When `included_in_print_rate` is checked on a tax row, the item's printed price includes the tax. ERPNext back-calculates the net amount for accounting purposes. This is the typical configuration for B2C businesses in tax-inclusive jurisdictions (e.g. EU VAT).

### Purchase Taxes and Charges Template

Mirrors the Sales version, with `Input` accounts instead of `Output`. Common pattern: one template for standard-rated purchases, one for zero-rated, one for exempt.

### Pitfalls

- **Wrong account type** — a tax account must have `account_type = Tax`. Without it, the tax report will skip it.
- **Missing cost center** — each row needs a cost center; without it the GL Entry has null cost center and breaks cost-center reports.
- **Inconsistent included_in_print_rate across rows** — pick one convention per template. Mixing causes rounding errors.

## Cost Center Hierarchy

`Cost Center` is a tree DocType rooted per company. Use it for **managerial accounting**: tracking profitability by department, project, or product line independently of the GL.

```python
cc = frappe.get_doc({
    "doctype": "Cost Center",
    "cost_center_name": "Engineering",
    "parent_cost_center": "Main - ACME",
    "company": "Acme",
    "is_group": 0,
})
cc.insert()
```

### Default Cost Center

Set on `Company → Default Cost Center`. Every transaction without an explicit cost center falls back to this.

### Cost Center on Transactions

- **Journal Entry** — each `Journal Entry Account` row has its own `cost_center`.
- **Sales/Purchase Invoice** — each item row has a `cost_center` (defaults to the header's `cost_center`).
- **Payment Entry** — cost center on the header.
- **Stock Entry** — cost center on each item row.

### Distributed Cost Centers

Use the **Distributed Cost Center** child table on transactions to split one amount across multiple cost centers (e.g. 60% Engineering / 40% Marketing). ERPNext creates separate GL Entries per allocation.

## Multi-Currency Accounting

ERPNext supports multi-currency accounting with these building blocks:

1. **Account Currency** — each Account has an optional `account_currency`. If blank, it inherits the company currency.
2. **Party Currency** — each Customer/Supplier has a `default_currency`. New invoices for that party default to it.
3. **Currency Exchange** — daily exchange rates fetched via a provider (e.g. exchangerate.host) or entered manually.

### Setup

1. Enable **Multi-Currency Accounting** in `Accounts Settings`.
2. Configure the **Currency Exchange Rate Provider** (or set rates manually in `Currency Exchange`).
3. Create **Receivable/Payable accounts in foreign currency** — set `account_currency` on the Account master. ERPNext uses a single "Debtors" account; the currency is on the customer's `default_currency` field, not on the account itself. To track each currency separately, create separate accounts like "Debtors USD" and "Debtors EUR".
4. On each invoice/payment, set the `exchange_rate` field — auto-filled from `Currency Exchange` but overridable.

### Exchange Gain / Loss

When a foreign-currency invoice is settled at a different rate than the one used at invoice time, ERPNext books the difference:

| Account | Source |
|---|---|
| `Exchange Gain / Loss Booked` | Configured in `Accounts Settings → Exchange Gain / Loss Account`. |
| `Realized Exchange Gain/Loss` | Auto-created when the payment is reconciled. |
| `Unrealized Exchange Gain/Loss` | Created by the **Exchange Rate Revaluation** Journal Entry at month-end. |

### Exchange Rate Revaluation

At period close, run **Exchange Rate Revaluation**:

1. Open Accounts → Exchange Rate Revaluation.
2. Pick the As-Of date and company.
3. ERPNext lists all foreign-currency accounts and their revalued balances.
4. Submit to create a Journal Entry of type `Exchange Rate Revaluation` that books the unrealized gain/loss.

This is reversible — cancel the JE if you need to re-run.

### Pitfalls

- **Mixing currencies in a single account** — always create separate accounts per currency for cleaner reporting.
- **Forgetting to revalue at month-end** — financial statements will be in the wrong currency equivalent.
- **Manually editing `exchange_rate` on a submitted invoice** — submit a Credit/Debit Note instead; do not amend.

## Opening Balances

ERPNext loads opening balances via `Journal Entry` with `voucher_type = Opening Entry`. The entry must be dated the day **before** your go-live date (e.g. go-live 2026-04-01 → opening entry dated 2026-03-31).

### Steps

1. **Chart of Accounts** — already in place.
2. **Customers/Suppliers opening** — open each Customer and Supplier master, click **Opening Entry** button. Or do it all from one Journal Entry using the `party` and `party_type` columns.
3. **Stock opening** — use **Stock Reconciliation** (`stock.md`), not Journal Entry. The reconciliation posts the GL equivalent automatically if perpetual inventory is on.
4. **Fixed assets opening** — create **Asset** records with `is_existing_asset = 1` and `capitalized_on` before go-live; ERPNext creates the GL entries on submission.
5. **Bank opening** — Journal Entry with Bank account.
6. **Retained earnings** — auto-balances via `Company → Retained Earnings Account`. If trial balance does not balance, the difference goes here.

### The "Opening Entry" Helper

For each Customer/Supplier, the master record has an **Opening Entry** button that opens a wizard. It generates a Journal Entry in the background. This is preferred over manual entry because it ensures the `party_account_currency` and `party` fields are set correctly.

### Pitfalls

- **Posting dated in the live period** — opening entries must be back-dated; otherwise they distort the live P&L.
- **Forgetting tax liability opening** — outstanding GST/VAT payable must be opened as a credit balance on the Tax account.
- **Stock opening without perpetual inventory** — if perpetual inventory is off, Stock Reconciliation does NOT create GL entries. Open the inventory GL via a separate Journal Entry to `Stock Asset - ACME`.

## Financial Statements

ERPNext generates three primary statements on demand:

| Statement | DocType / Report | Source |
|---|---|---|
| **Balance Sheet** | Report `Balance Sheet` | All `Asset`, `Liability`, `Equity` accounts. |
| **Profit & Loss** | Report `Profit and Loss Statement` | All `Income`, `Expense` accounts within the date range. |
| **Cash Flow** | Report `Cash Flow` | Cash/Bank accounts categorized by `Cash Flow` block. |

### Period Choices

Each statement supports:

- **Fiscal Year** — pick a year.
- **Monthly / Quarterly / Half-Yearly / Yearly** — granularity of columns.
- **Consolidated** — across companies (multi-company setups only).
- **Cost Center filter** — restrict to one cost center or its children.

### Custom Financial Statements

Use the **Financial Statements Custom** tool (search "Custom Financial Statement") to create your own layout: pick which accounts go in which row, set formulas, and customize column structure. Saved as `Financial Statement` records.

## Regional Tax Setup (GST/VAT)

ERPNext ships regional compliance in `erpnext.regional.<country>`. Setup is mostly automatic once the Company's `country` and `tax_id` fields are set, but each pack requires additional configuration.

### India GST

1. **GST Settings** — open the DocType, set your GSTIN, file format, e-Invoice credentials.
2. **GST Account** — each `Account` of type `Tax` gets a `gst_treatment` field (`Taxable`, `Nil-Rated`, `Exempt`, `Non-GST`).
3. **HSN Code** — each Item needs an `hsn_code` for GSTR-1.
4. **Customer/Supplier GSTIN** — set on the party master.
5. **Reports** — GSTR-1, GSTR-3B auto-generate from submitted invoices.

### UAE / KSA VAT

1. **VAT Setting** — set your TRN, default VAT account.
2. **VAT Account** — Tax-type account with regional metadata.
3. **Reports** — VAT 201 return auto-generates.

### USA (1099)

- **1099 Settings** — define box mappings.
- **Supplier Master** — mark `is_1099_vendor = 1`, set the box.
- **Reports** — 1099-NEC, 1099-MISC auto-generate.

### Custom Region

For a region ERPNext does not support, replicate the pattern:

1. Create the tax account.
2. Build a Sales/Purchase Tax Template.
3. Use the **Tax and Charges** reports for periodic returns.

## Advance Payments

An advance payment is money received (or paid) before the corresponding invoice. ERPNext treats advances as a separate open credit on the party's ledger.

### Receiving an Advance

1. Create a **Payment Entry** with `payment_type = Receive`, party = Customer.
2. **Do not** add any `references` rows.
3. Submit. The amount sits as an unallocated advance on the customer's ledger.

### Allocating the Advance

When the invoice is created:

1. Open the Sales Invoice.
2. Under **Advance Payments** section, click **Get Advances Received**.
3. Pick the advance(s) to allocate.
4. Save & submit. ERPNext creates a Journal Entry linking the advance to the invoice, zeroing the advance balance.

### Book Advance Payments as Liability

Enable this in `Accounts Settings → Book Advance Payments as Liability` to post advances to a separate liability account instead of netting against receivables. This is required by some accounting standards (e.g. IFRS 15 for certain contract liabilities).

## Credit Notes & Debit Notes

Use these to reverse or adjust an already-submitted invoice **without** cancelling it (e.g. partial returns, post-billing discounts).

### Credit Note (Sales)

1. Open the original Sales Invoice.
2. Click **Create → Credit Note**.
3. ERPNext opens a new Sales Invoice with `is_return = 1` and the same line items.
4. Adjust quantities (e.g. 2 of 5 items returned).
5. Submit. ERPNext reduces the customer's receivable and reverses the income/tax/COGS.

### Debit Note (Purchase)

The mirror — open the Purchase Invoice, **Create → Debit Note**, with `is_return = 1`.

### Pitfalls

- **Stock impact** — by default, Credit/Debit Notes do **not** move stock. Enable `update_stock` if you need stock reversal (e.g. customer returns goods).
- **Tax reversal** — the note reverses the tax on the returned quantity only. Verify the tax template matches the original.
- **Partial returns** — set the right quantity per row; do not reduce rates.

## Budgeting

ERPNext supports **Cost Center budgets** for expense control. Use it to enforce caps on monthly/quarterly/annual spending.

### Setup

1. **Budget** DocType — pick Company, Cost Center, Fiscal Year.
2. Add child rows per Account with monthly amounts.
3. Set `action_if_annual_budget_exceeded` and `action_if_monthly_budget_exceeded` to `Stop` (block) or `Warn` (allow with a message).
4. Submit.

### Mechanics

When a Journal Entry or Purchase Invoice is submitted and the cumulative expense on an account crosses the budgeted amount, ERPNext:

- **Stop** → throws and refuses to submit.
- **Warn** → shows a warning but submits.

Budgets are evaluated against actuals in `tabGL Entry` for the matching period.

### Pitfalls

- **Budgets only check on submit, not on save** — drafts can hold unrealistic amounts.
- **Budgets do not account for committed spends** (open POs). Use the **Budget vs Actual** report for forecasting.

## Fixed Asset Depreciation

The **Asset** module (`erpnext.assets.doctype.asset`) handles fixed-asset lifecycle: capitalization, depreciation, and disposal.

### Setup

1. **Item** — create an Item with `is_fixed_asset = 1`. Set `asset_category` and `asset_naming_series`.
2. **Asset Category** — define default accounts (Fixed Asset Account, Accumulated Depreciation Account, Depreciation Expense Account), default depreciation method, and frequency.
3. **Finance Book** (optional) — for parallel depreciation books (e.g. tax vs accounting). Create one per parallel book.
4. **Asset** — purchase or capitalize an asset, link to the Item.

### Depreciation Methods

| Method | Formula |
|---|---|
| `Straight Line` | (Cost - Salvage) / Useful Life |
| `Double Declining` | 2 × Straight-line rate × Book value |
| `Written Down Value` | Book value × fixed rate |
| `Manual` | You enter each period's amount |

### Auto-Depreciation

On the Asset record, under **Finance Book Details**, set:

- `frequency_of_depreciation` (Months, Years, Days).
- `total_number_of_depreciations`.
- `depreciation_start_date`.

Submit the Asset. ERPNext creates a **Depreciation Schedule** child table. The scheduler posts a **Journal Entry** of `voucher_type = Depreciation Entry` on each scheduled date.

### Asset Disposal

Two paths:

- **Sale** — `Asset → Sell Asset` button creates a Sales Invoice; on submit, the asset is retired and gain/loss booked.
- **Scrap** — `Asset → Scrap Asset` retires the asset with no consideration.

### Pitfalls

- **Past depreciation** — if you create an asset mid-life (e.g. existing asset brought onto the books), set `is_existing_asset = 1` and `capitalized_on` correctly; ERPNext computes remaining depreciation from there.
- **Disposal before schedule completes** — cancel future depreciation JEs before scrapping or the books will over-depreciate.
- **Multi-finance-book** — each finance book computes depreciation independently. Verify both before year-end close.

## Accounting Reports

The most-used reports under **Accounts → Reports**:

| Report | Purpose |
|---|---|
| **General Ledger** | All GL Entries for a date range, optionally filtered by account/party/voucher. |
| **Trial Balance** | Closing balances per account, debit/credit, on a date. |
| **Balance Sheet** | As-of position. |
| **Profit and Loss Statement** | Period performance. |
| **Cash Flow** | Movement of cash by category. |
| **Accounts Receivable** | Outstanding per customer, with aging buckets. |
| **Accounts Payable** | Outstanding per supplier, with aging buckets. |
| **AR Aging** / **AP Aging** | Aging report (0-30, 31-60, 61-90, 90+). |
| **Bank Reconciliation** | Match Payment Entries against bank statement lines. |
| **Bank Clearance** | Bulk-clear multiple bank transactions. |
| **GSTR-1 / GSTR-3B** (India) | Tax returns. |
| **VAT 201** (UAE) | VAT return. |
| **Budget vs Actual** | Compare budgeted vs posted per cost center. |
| **Asset Depreciation Schedule** | Per-asset depreciation schedule. |
| **Sales Register / Purchase Register** | All submitted invoices in a period. |
| **TDS Deduction** (India) | Tax deducted at source per supplier. |

Each report is a Query Report or Script Report — both can be extended with custom filters or columns. See `customization.md`.

## Common Errors & Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `Account X has currency USD but company currency is INR. Please set account currency to USD` | Mismatched account currency config. | Edit the account master; set `account_currency`. |
| `Cost Center is mandatory for Account Type Expense/Income` | Row missing cost center. | Set on each Journal Entry Account row. |
| `Total Debit must be equal to Total Credit` | Unbalanced Journal Entry. | Recheck arithmetic; round to the cent. |
| `Cannot book entry against group account` | Account with `is_group = 1` used in a transaction. | Pick a leaf account. |
| `Payment Entry has unallocated amount` | `paid_amount` > sum of `references.allocated_amount`. | Either add another reference or accept the advance. |
| `Fiscal Year X does not exist for posting date Y` | FY not created or company not linked. | Create the FY, or extend its date range. |
| `Accounting Period X is closed` | Locked period. | Re-open the period via `Accounting Period` list. |
| `Receivable / Payable account not found for party X` | Party has no default currency account. | Set on the Party master under "Account" section. |
| `Asset is already fully depreciated` | Trying to post more depreciation. | Cancel the schedule or extend life. |
| `GSTR-1 shows zero for an invoice with tax` | Tax account has no `account_type = Tax` or no `gst_treatment` set. | Edit the account and tax template. |
| `Customer outstanding is wrong` | Payment allocated to wrong invoice, or JE created manually instead of via Payment Entry. | Re-allocate via the **Payment Reconciliation** tool. |
| `Bank balance does not match statement` | Un-reconciled Payment Entries. | Run **Bank Reconciliation** periodically. |
| `Period Closing Voucher cannot be submitted; outstanding documents exist` | Open drafts in the period. | Cancel or submit them first. |
| `Cannot cancel submitted document with linked JV` | Asset depreciation JE blocks cancellation. | Cancel the JEs first. |

### Debugging Tips

- **Show GL Entries** — every transaction has a **General Ledger** button on the form. Click it to see the posted entries.
- **Repost Accounting Ledger** — if GL Entries are missing/corrupt, use the **Repost Accounting Ledger** tool (search in Awesome Bar) to regenerate.
- **Payment Reconciliation** — tool that auto-matches payments to invoices based on amount and date; great for cleaning up messy ledgers.
- **Reconcile Payment Entries** — for multi-invoice matching when one payment covers many invoices.

## Where to Learn More

- Accounting intro: `https://docs.frappe.io/erpnext/accounting-introduction`
- Accounting entries: `https://docs.frappe.io/erpnext/accounting-entries`
- Chart of Accounts: `https://docs.frappe.io/erpnext/chart-of-accounts`
- Journal Entry: `https://docs.frappe.io/erpnext/journal-entry`
- Payment Entry: `https://docs.frappe.io/erpnext/payment-entry`
- Advance payment entry: `https://docs.frappe.io/erpnext/advance-payment-entry`
- Cost Center: `https://docs.frappe.io/erpnext/cost-center`
- Multi-currency accounting: `https://docs.frappe.io/erpnext/multi-currency-accounting`
- Opening balance: `https://docs.frappe.io/erpnext/opening-balance`
- Fiscal Year: `https://docs.frappe.io/erpnext/fiscal-year`
- Financial statements: `https://docs.frappe.io/erpnext/financial-statements`
- GST setup: `https://docs.frappe.io/erpnext/gst-setup`
- Credit Note: `https://docs.frappe.io/erpnext/credit-note`
- Debit Note: `https://docs.frappe.io/erpnext/debit-note`
- Budgeting: `https://docs.frappe.io/erpnext/budgeting`
- Fixed asset depreciation: `https://docs.frappe.io/erpnext/fixed-asset-depreciation-entry`
- Accounts settings: `https://docs.frappe.io/erpnext/accounts-settings`

For the framework APIs used by all accounting DocTypes (e.g. `frappe.get_doc`, `gl_entry` posting helpers, `validate` hooks), read `../framework/python-api.md` and `../framework/doctype-guide.md`. For customization patterns (custom tax templates, automated JE posting, custom reports), read `customization.md`.
