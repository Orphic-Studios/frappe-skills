# ERPNext — Selling & Buying Modules

The Selling and Buying modules together cover the **order-to-cash** and **procure-to-pay** cycles. They share many DocTypes (Pricing Rule, Payment Terms Template, Tax templates) and reference each other heavily (a Purchase Order can drop-ship directly to a Sales Order). Use this file for any question about customers, suppliers, quotations, sales orders, sales invoices, delivery notes, purchase orders, purchase receipts, purchase invoices, pricing, payment terms, subscriptions, sales commissions, RFQs, and the Lead→Opportunity→Quotation→Sales Order pipeline. For the GL impact of these transactions, see `accounts.md`. For stock movement mechanics, see `stock.md`.

## Table of Contents

1. [Customer Master](#customer-master)
2. [Customer Group & Territory](#customer-group--territory)
3. [Supplier Master](#supplier-master)
4. [Lead → Opportunity → Quotation → Sales Order](#lead--opportunity--quotation--sales-order)
5. [Quotation](#quotation)
6. [Sales Order](#sales-order)
7. [Sales Invoice](#sales-invoice)
8. [Delivery Note](#delivery-note)
9. [Purchase Order](#purchase-order)
10. [Purchase Receipt](#purchase-receipt)
11. [Purchase Invoice](#purchase-invoice)
12. [Pricing Rule](#pricing-rule)
13. [Price Lists](#price-lists)
14. [Payment Terms Template & Payment Schedule](#payment-terms-template--payment-schedule)
15. [Subscription / Auto-Repeat](#subscription--auto-repeat)
16. [Sales Person & Sales Commission](#sales-person--sales-commission)
17. [Procurement Tracker](#procurement-tracker)
18. [Request for Quotation & Supplier Quotation](#request-for-quotation--supplier-quotation)
19. [Common Errors & Troubleshooting](#common-errors--troubleshooting)
20. [Where to Learn More](#where-to-learn-more)

## Customer Master

`Customer` is the master record for everyone you sell to. One record per legal entity; multiple ship-to addresses handled via the `Address` DocType linked dynamically.

### Key Fields

| Field | Purpose |
|---|---|
| `customer_name` | Primary key; appears on transactions. |
| `customer_type` | `Company` or `Individual` — affects tax and print format. |
| `customer_group` | Tree-based classification; drives default pricing & tax. |
| `territory` | Tree-based geographic classification; drives sales analytics. |
| `customer_pos_id` | POS identifier; auto-generated for POS-created customers. |
| `default_currency` | Pre-selected on Sales Orders for this customer. |
| `default_price_list` | Pre-selected Price List. |
| `default_sales_partner` / `default_commission_rate` | For commission tracking. |
| `tax_id` | GSTIN/VAT ID; printed on invoices. |
| `customer_details` | Free text notes. |
| `language` | Print language for invoices/quotations. |
| `image` | Logo / photo. |
| `default_company` | In multi-company setups, the company you normally bill this customer from. |

### Customer Accounts

Each customer needs a **Receivable Account**. ERPNext creates it automatically when you save the Customer — the account is the company's `receivable_account` (set in `Company`) prefixed with the customer name. To customize per-customer accounts (e.g. for multi-currency), edit the **Account** child table on the Customer master:

```python
cust = frappe.get_doc({
    "doctype": "Customer",
    "customer_name": "Acme Customer",
    "customer_group": "All Customer Groups",
    "territory": "All Territories",
    "default_currency": "USD",
    "accounts": [
        {"company": "Acme", "account": "Debtors USD - ACME"},
    ],
})
cust.insert()
```

### Contacts & Addresses

Contacts and Addresses are **dynamic link** DocTypes — they're not children of Customer, they're standalone records linked via a polymorphic field. One Contact can be linked to multiple Customers (e.g. a purchasing agent who works for two companies).

Setup pattern:

1. Create the Customer.
2. In the **Address & Contact** section, click **+ Address** and **+ Contact**.
3. ERPNext auto-links the new records.

For bulk imports, import the Customer first, then import Address/Contact with the `link_doctype=Customer` and `link_name=<customer name>` columns.

### Customer Credit Limits

On the **Credit Limits** child table:

| Field | Effect |
|---|---|
| `company` | Per-company limit. |
| `credit_limit` | Maximum outstanding receivable. |
| `bypass_credit_limit_check` | Role that can override. |

When a new Sales Order/Invoice would push the receivable past the limit, ERPNext blocks submission unless a user with the bypass role approves.

## Customer Group & Territory

Both are tree DocTypes. Use them for analytics and for **defaulting** tax templates, price lists, and sales partners.

### Customer Group

- Tree rooted at `All Customer Groups`.
- Common pattern: `All Customer Groups → Retail → Wholesale → VIP` or `Domestic → North / South / East / West`.
- Per-group fields: `default_price_list`, `default_tax_template`, `default_sales_partner`.

### Territory

- Tree rooted at `All Territories`.
- Common pattern: `All Territories → India → Maharashtra → Mumbai`.
- Used by **Sales Person** assignments and **Territory Target** reports.

### Best Practice

Mirror the company's **commercial** segmentation in Customer Group and **geographic** segmentation in Territory. Do not mix them (e.g. "Mumbai VIP" as a Customer Group) — you lose analytical flexibility.

## Supplier Master

`Supplier` mirrors Customer for the buying side. Key differences:

| Field | Purpose |
|---|---|
| `supplier_name` | Primary key. |
| `supplier_type` | `Company` or `Individual`. |
| `supplier_group` | Tree classification. |
| `default_currency` | Pre-selected on Purchase Orders. |
| `default_price_list` | Buying-type Price List. |
| `tax_id` / `gst_category` (India) | For tax compliance. |
| `is_subcontractor` | Marks the supplier as a subcontractor (used by Manufacturing Subcontracting flow). |
| `account` (child table) | Payable account per company. |

### Allowed Items

The **Allowed Items** child table restricts which items this supplier can be Purchase-Ordered for. Useful for vendor-managed inventory and approved-vendor lists. Leave empty to allow all items.

### Supplier Scorecard

Enable the **Supplier Scorecard** module (`Buying Settings → maintain_supplier_scorecard`) to compute monthly scores based on delivery time, quality, and pricing. Scores drive the **Approved Supplier** list.

## Lead → Opportunity → Quotation → Sales Order

This is the canonical CRM-to-Sales pipeline in ERPNext. Each step is a separate DocType, linked by parent references.

### Lead

`Lead` is a pre-customer prospect. Captures contact info, source (campaign, referral), and interest. A Lead has no receivables, no transactions — it's the top of the funnel.

| Field | Purpose |
|---|---|
| `lead_name`, `company_name`, `source`, `status` | Identity. |
| `contact_info` | Phone, email, address. |
| `lead_owner` | Sales rep responsible. |
| `type` | `Client` or `Channel Partner`. |

### Opportunity

When a Lead expresses concrete interest (a specific product/service, a budget, a timeframe), convert to Opportunity. Multiple Opportunities can come from one Lead.

Opportunity has an **Items** child table (the products being discussed), an estimated value, and a `sales_stage` field tracking pipeline position (`Prospecting`, `Qualification`, `Proposal`, `Negotiation`, `Closed Won`, `Closed Lost`).

### Quotation

From an Opportunity, create a **Quotation** to send a formal price quote. The Quotation has a `quotation_to` field (`Customer` or `Lead`) — you can quote without converting the Lead.

### Sales Order

When the customer accepts the Quotation, click **Create → Sales Order**. The Quotation is marked `Ordered`, and the Sales Order inherits items, taxes, and terms.

### Pipeline Status Summary

| Stage | DocType | Status When Won |
|---|---|---|
| Suspect | (none — marketing lists) | — |
| Lead | `Lead` | `Converted` |
| Opportunity | `Opportunity` | `Closed Won` |
| Quotation | `Quotation` | `Ordered` |
| Sales Order | `Sales Order` | (active `To Deliver and Bill`) |
| Delivery Note | `Delivery Note` | Submitted |
| Sales Invoice | `Sales Invoice` | Submitted |

## Quotation

`Quotation` is a non-binding price proposal. It is submittable (so it appears in the customer's quotation history and counts against your analytics) but does not create GL entries or stock movements.

### Quotation Fields

| Field | Purpose |
|---|---|
| `quotation_to` | `Customer` or `Lead`. Determines the party fields. |
| `party_name` | Customer or Lead. |
| `customer_name` / `lead_name` | Auto-filled display name. |
| `order_type` | `Sales` (default), `Maintenance`, `Shopping Cart`. |
| `transaction_date` | Quotation date. |
| `valid_till` | Quotation expiry — past this date, ERPNext flags the quote. |
| `items` | The quoted items (table). |
| `taxes_and_charges` | Tax template. |
| `total_taxes_and_charges` | Computed. |
| `grand_total` | Computed. |
| `payment_schedule` | Payment terms (see below). |
| `terms` | Terms & Conditions text. |

### Status Workflow

`Draft → Submitted → Ordered / Lost / Expired / Cancelled`.

- **Ordered** — when a Sales Order is created from it.
- **Lost** — manual mark with a reason; useful for funnel analytics.
- **Expired** — `valid_till` is past; can be re-activated.

## Sales Order

`Sales Order` is the binding commitment to deliver. It triggers procurement (via **Material Request**), production (via **Work Order**), and delivery. It is the central planning document.

### Key Fields

| Field | Purpose |
|---|---|
| `transaction_date` | Order date. |
| `delivery_date` | Promised delivery date — drives production scheduling. |
| `customer`, `customer_name` | Party. |
| `company` | The selling company (multi-company). |
| `currency`, `conversion_rate` | For multi-currency. |
| `items` | Child table — item, qty, rate, warehouse, delivery_date (per row), against_packed_item. |
| `taxes` | Tax template rows. |
| `apply_discount_on` | `Grand Total` or `Net Total`. |
| `discount_amount` | Flat discount. |
| `payment_schedule` | Payment terms. |
| `sales_partner`, `commission_rate` | For commission. |
| `set_warehouse` | Default warehouse for all items. |
| `project` | Link to Projects module for project-based selling. |
| `po_no`, `po_date` | Customer's PO reference (B2B). |
| `is_pos` / `pos_profile` | If true, generates POS invoice on submit. |

### Sales Order Lifecycle

```
Draft → Submitted → To Deliver and Bill
   ├── Delivery Note → Delivered
   ├── Sales Invoice → Billed
   └── (if all delivered and billed) → Completed
```

ERPNext tracks per-row status: `delivered_qty`, `billed_qty`, `produced_qty` (if linked to Work Order).

### Production & Procurement Links

From a submitted Sales Order:

- **Create → Work Order** — if the item is manufactured (has a BOM).
- **Create → Material Request** — to procure raw materials or out-of-stock items.
- **Create → Purchase Order** — drop-ship directly to the customer (skips your warehouse).
- **Create → Delivery Note** — ship from stock.
- **Create → Sales Invoice** — bill the customer.
- **Create → Payment Request** — request payment from customer.

### Service / Project Sales Orders

For services (no items), check `update_stock = 0` and add items of type `Service`. If billing is milestone-based, use the **Payment Schedule** child table to define multiple billing milestones with percentages and dates.

## Sales Invoice

`Sales Invoice` is the legally binding accounting voucher. It posts GL Entries (debit Receivable, credit Sales/Tax), updates the customer's outstanding, and (if `update_stock = 1`) moves inventory.

### Key Fields

| Field | Purpose |
|---|---|
| `customer`, `customer_name` | Party. |
| `company`, `currency`, `conversion_rate` | Multi-company/currency. |
| `posting_date`, `due_date` | Due date computed from Payment Terms. |
| `items` | Items sold (or service items). |
| `update_stock` | If checked, moves stock like a Delivery Note. |
| `is_pos` | POS invoice — auto-creates Payment Entry. |
| `is_return` | Marks as Credit Note. |
| `po_no`, `po_date` | Customer PO reference. |
| `taxes_and_charges`, `taxes` | Tax template rows. |
| `payment_schedule` | Payment milestones. |
| `advances` | Allocated advance payments. |
| `write_off_amount` | Small uncollectible remainder. |
| `against_income_account` | Income account override (per invoice). |
| `set_cost_center` | Cost center override. |
| `pos_profile`, `pos_cash_entry` | POS details. |

### Sales Invoice Lifecycle

```
Draft → Submitted
   ├── (no stock) Customer owes amount → Payment Entry receives
   └── (with stock) Stock moved + Customer owes → Payment Entry receives
```

### Advance Payment Allocation

When a Sales Invoice is created for a customer with open advances:

1. The **Advance Payments** section appears.
2. Click **Get Advances Received** — populates the table with unallocated Payment Entries.
3. Set `allocated_amount` per row.
4. Submit. ERPNext creates a Journal Entry linking the advance to the invoice.

### POS (Point of Sale)

A POS invoice has `is_pos = 1` and a `pos_profile`. ERPNext auto-creates a **Payment Entry** against it on submit, posting the cash/card received. See **POS Profile** DocType for cash drawer, payment methods, and shift management.

## Delivery Note

`Delivery Note` moves stock out of the warehouse to the customer. It is the physical shipment record. A Sales Invoice may or may not be generated separately.

### Key Fields

| Field | Purpose |
|---|---|
| `customer`, `customer_name` | Party. |
| `company` | Selling company. |
| `posting_date`, `posting_time` | Shipment date/time. |
| `items` | Item rows with `warehouse`, `qty`, `serial_no`, `batch_no`. |
| `lr_no`, `lr_date` | Lorry receipt / carrier reference. |
| `transporter`, `driver`, `vehicle` | Fleet module integration. |
| `shipping_address` | The ship-to address (different from billing if needed). |
| `against_sales_order` / `against_delivery_note` | Parent references. |

### Lifecycle

```
Draft → Submitted (stock moved out) → (Sales Invoice created) → Closed
        ↓
        can be cancelled → reverses stock movement
```

### Delivery Note → Sales Invoice

A common pattern: ship first (Delivery Note), then invoice (Sales Invoice). The Sales Invoice's items inherit `against_delivery_note` references, ensuring no double-counting of stock.

### Shipment Integration

For courier integrations, use the **Shipment** DocType — fetches rates from providers (FedEx, UPS, etc. via the **Shipment Gateway**), prints labels, and tracks shipments. The Delivery Note links to the Shipment via the `shipment_id` field.

## Purchase Order

`Purchase Order` is the binding commitment to a supplier. It triggers goods receipt (via **Purchase Receipt**) and billing (via **Purchase Invoice**).

### Key Fields

| Field | Purpose |
|---|---|
| `supplier`, `supplier_name` | Party. |
| `company`, `currency`, `conversion_rate` | Multi-currency. |
| `transaction_date`, `schedule_date` | Order date and promised delivery date. |
| `items` | Child table — item, qty, rate, warehouse, schedule_date per row. |
| `taxes`, `taxes_and_charges` | Tax template. |
| `payment_schedule` | Payment terms. |
| `set_warehouse` | Default target warehouse. |
| `apply_discount_on`, `discount_amount` | Discount. |
| `supplier_address`, `shipping_address` | Supplier billing / delivery address. |
| `is_subcontracted` | Marks as subcontracting PO (links to **Subcontracting Order** in v15+). |
| `project` | Project link. |

### Lifecycle

```
Draft → Submitted → To Receive and Bill
   ├── Purchase Receipt → Received
   ├── Purchase Invoice → Billed
   └── (all received and billed) → Completed
```

### Drop-Ship from Sales Order

From a Sales Order, click **Create → Purchase Order** and select **Drop Ship**. ERPNext creates a PO that ships directly to the customer — the Delivery Note is bypassed (or created by the supplier's system). On PO Receipt, a Delivery Note is auto-generated in your system to close the loop with the Sales Order.

## Purchase Receipt

`Purchase Receipt` is the goods-in voucher. Posts Stock Ledger Entries (+qty in warehouse) and GL Entries (Dr Stock Asset, Cr Stock Received But Not Billed) if perpetual inventory is on.

### Key Fields

| Field | Purpose |
|---|---|
| `supplier`, `supplier_name` | Party. |
| `company` | Buying company. |
| `posting_date`, `posting_time` | Receipt date. |
| `items` | Item rows with `warehouse`, `qty`, `rejected_warehouse`, `qty_rejected`, `serial_no`, `batch_no`. |
| `set_warehouse`, `set_rejected_warehouse` | Default warehouses. |
| `purchase_order` | Parent PO. |
| `bill_no`, `bill_date` | Supplier's invoice reference (if invoiced in same step). |
| `shipping_rule` | Shipping cost allocation. |
| `apply_putaway_rule` | Auto-distribute items to warehouses by capacity. |

### Quality Inspection

If an item requires inspection (`inspection_required_before_purchase` on Item), the Purchase Receipt cannot be submitted until a Quality Inspection is created and submitted. Rejected quantities go to `rejected_warehouse`.

### Lifecycle

```
Draft → Submitted (stock in) → Purchase Invoice → Closed
        ↓
        can be cancelled → reverses stock
```

## Purchase Invoice

`Purchase Invoice` is the supplier's bill. It books the payable and (if `update_stock = 1` and no Purchase Receipt was created) also moves stock.

### Key Fields

Similar to Sales Invoice but reversed. Important specifics:

| Field | Purpose |
|---|---|
| `bill_no`, `bill_date` | Supplier's invoice number and date — required for tax compliance. |
| `update_stock` | If checked, behaves like Purchase Receipt + Invoice combined (skips separate GRN). |
| `is_paid` | If checked, generates a Payment Entry on submit (single-step pay-and-invoice). |
| `allocate_advances` | Allocate supplier advances. |
| `taxes_and_charges` | Purchase tax template (input taxes). |
| `against_expense_account` | Expense account override. |
| `is_return` | Marks as Debit Note (return to supplier). |

### Lifecycle

```
Draft → Submitted (payable booked) → Payment Entry (paid) → Closed
```

## Pricing Rule

`Pricing Rule` is the dynamic pricing engine. It applies discounts, surcharges, free items, or fixed rates based on conditions. See `stock.md` for the full field reference. The Selling/Buying-specific highlights:

### Selling-Specific Examples

```python
# 10% off for VIP customers on the "Premium" brand
frappe.get_doc({
    "doctype": "Pricing Rule",
    "title": "VIP Premium Brand Discount",
    "apply_on": "Brand",
    "brands": [{"brand": "Premium"}],
    "applicable_for": "Customer Group",
    "customer_groups": [{"customer_group": "VIP"}],
    "selling": 1,
    "discount_percentage": 10,
    "valid_from": "2026-01-01",
    "valid_upto": "2026-12-31",
    "company": "Acme",
}).insert()
```

```python
# Buy 3, Get 1 Free on WIDGET-001
frappe.get_doc({
    "doctype": "Pricing Rule",
    "title": "BOGO Widgets",
    "apply_on": "Item Code",
    "items": [{"item_code": "WIDGET-001"}],
    "selling": 1,
    "min_qty": 3,
    "free_item": "WIDGET-001",
    "free_item_qty": 1,
    "free_item_rate": 0,
    "company": "Acme",
}).insert()
```

### Buying-Specific Examples

```python
# 5% discount from preferred supplier
frappe.get_doc({
    "doctype": "Pricing Rule",
    "title": "Preferred Supplier Discount",
    "apply_on": "Item Code",
    "items": [{"item_code": "RAW-001"}],
    "applicable_for": "Supplier",
    "suppliers": [{"supplier": "Acme Supplier"}],
    "buying": 1,
    "discount_percentage": 5,
}).insert()
```

## Price Lists

`Price List` is the catalog container. Each list has:

| Field | Effect |
|---|---|
| `currency` | Currency of all Item Prices in this list. |
| `selling` / `buying` | Direction. A list is one or the other, not both. |
| `enabled` | Soft toggle. |
| `applicable_for` (optional) | Restrict to specific customer/supplier. |

### Multi-Currency Selling Pattern

For international sales, create parallel price lists:

- **Standard Selling (USD)** — base prices in USD.
- **EUR Export (EUR)** — fixed EUR prices.
- **INR Domestic (INR)** — fixed INR prices.

Avoid using the conversion-rate-based automatic translation; fixed prices per market are more predictable.

## Payment Terms Template & Payment Schedule

`Payment Terms Template` defines reusable payment terms (e.g. "30% advance, 70% on delivery"). Apply it to a Sales Order, Sales Invoice, Purchase Order, or Purchase Invoice.

### Anatomy

A template has a child table of **Payment Terms** rows, each with:

| Field | Effect |
|---|---|
| `payment_term` | Link to `Payment Term` master (defines the description). |
| `invoice_portion` | Percentage of total (e.g. 30). |
| `due_date` / `days_until_due` | When this portion is due. |
| `payment_amount` | Auto-computed from invoice_portion × total. |
| `description` | Free text. |

### Payment Schedule

When a template is applied to a transaction, the **Payment Schedule** child table is populated with the installments and due dates. Each row drives a separate aging bucket in the AR/AP Aging report.

### Examples

| Template | Rows |
|---|---|
| 100% on receipt | 1 row, 100%, due on invoice date. |
| 2/10 Net 30 | 1 row, 100%, due +30 days. Configure early-payment discount separately. |
| Advance + On Delivery | 2 rows: 30% advance, 70% on delivery date. |
| Milestone billing | N rows, each tied to a milestone date. |

## Subscription / Auto-Repeat

The `Subscription` DocType (formerly `Auto Repeat`) automates recurring transactions. Use it for retainer contracts, monthly service invoices, etc.

### Setup

1. Create a base document (e.g. a Sales Invoice) as a template.
2. Create a **Subscription** referencing the base document.
3. Configure:

| Field | Effect |
|---|---|
| `reference_doctype` | Sales Invoice, Sales Order, Purchase Invoice, Purchase Order, etc. |
| `reference_document` | The template document. |
| `start_date`, `end_date` | Subscription period. |
| `frequency` | Daily, Weekly, Monthly, Quarterly, Half-Yearly, Yearly, or custom cron. |
| `repeat_on_day` | Day of month for monthly frequencies. |
| `submit_on_creation` | Auto-submit the generated document. |
| `notify_by_email` | Send notification on each generation. |
| `cancelled_sub_doc_on_failure` | Auto-cancel if generation fails. |

### How It Works

The scheduler (`erpnext.support.doctype.subscription`) runs every minute and generates new documents at the scheduled times. The generated document is a copy of the template with updated `posting_date` and a new `name`.

### Pitfalls

- **Template changes do not propagate** — the scheduler copies the template at subscription start. Editing the template later only affects future subscriptions, not existing ones. Cancel and recreate to change terms.
- **Submitting on creation can fail validation** — if the template references a stale Customer/Item, the auto-submitted invoice fails. Set `submit_on_creation = 0` for safety until you trust the data.
- **Subscription cancellation** — canceling the subscription does NOT cancel already-generated documents.

## Sales Person & Sales Commission

The **Sales Person** DocType (tree) tracks who closed each deal. Link on Sales Order, Sales Invoice, Quotation via the `sales_team` child table (each row = a sales person + commission %).

### Commission Calculation

```python
# Sales Team on a Sales Invoice
invoice = frappe.get_doc("Sales Invoice", "SINV-00123")
for sp in invoice.sales_team:
    print(sp.sales_person, sp.allocated_percentage, sp.commission_rate, sp.incentives)
```

- `allocated_percentage` — credit attribution (e.g. 60/40 split between two reps).
- `commission_rate` — percent of net total.
- `incentives` — flat incentive.

### Commission Reports

- **Sales Person Target Allocation** — set monthly/yearly targets per Sales Person.
- **Sales Person-wise Transaction Summary** — actual sales vs target.
- **Sales Commission Report** — calculated commission per invoice per sales person.

### Best Practice

Mirror your **organizational sales hierarchy** in the Sales Person tree (manager → rep). Set targets at the manager level and let ERPNext roll up actuals.

## Procurement Tracker

The **Procurement Tracker** report consolidates the Material Request → Purchase Order → Purchase Receipt → Purchase Invoice flow into a single dashboard. Use it to see at-a-glance:

- Open Material Requests not yet converted to POs.
- Open POs past their `schedule_date`.
- Received quantities vs ordered.
- Pending supplier invoices.

Access via **Buying → Reports → Procurement Tracker**. It is a Script Report — you can add custom columns via a custom Script Report (see `customization.md`).

## Request for Quotation & Supplier Quotation

### Request for Quotation (RFQ)

`Request for Quotation` is sent to multiple suppliers for the same items. Each supplier's response becomes a `Supplier Quotation`. The buyer then picks the best (or splits across suppliers) and creates Purchase Orders.

### Workflow

1. From a Material Request (or standalone), click **Create → Request for Quotation**.
2. Add suppliers via the **Suppliers** child table.
3. Submit. ERPNext emails each supplier their RFQ (a PDF + portal link).
4. Suppliers reply with prices via the Supplier Portal or you enter them manually in `Supplier Quotation` records.
5. Compare via the **RFQ Comparison** report — side-by-side table of all supplier quotes.
6. From the chosen Supplier Quotation, click **Create → Purchase Order**.

### Supplier Quotation

`Supplier Quotation` is one supplier's response to an RFQ. It is non-binding (does not commit you) and tracks the offered rates. Multiple Supplier Quotations can link to one RFQ.

### Pitfalls

- **RFQ suppliers must have valid email** — without email, the portal link cannot be sent.
- **Quote expiry** — set `valid_till` on the Supplier Quotation so stale quotes don't get auto-picked.
- **Item UOM mismatch** — RFQ items and Supplier Quotation items must be in the same UOM (or use UOM Conversion) for comparison to be meaningful.

## Common Errors & Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `Customer X has outstanding beyond credit limit` | New invoice pushes balance over `credit_limit`. | Get a payment first, raise the limit, or get bypass-role approval. |
| `Sales Order X has unfulfilled items; cannot close` | Trying to close an SO with non-zero `delivered_qty` or `billed_qty` left. | Cancel related Delivery Notes/Invoices first, or set `skip_delivery_note` / `close` the SO with the **Close** button. |
| `Item WIDGET-001 not found in Price List Y` | Item Price record missing for that combination. | Create the Item Price, or set the customer's `default_price_list` to a list that has the item. |
| `Cannot create Sales Invoice; Delivery Note is Draft` | Trying to bill before the Delivery Note is submitted. | Submit the Delivery Note first. |
| `Purchase Order supplier currency mismatch` | Supplier's `default_currency` differs from PO currency. | Change PO currency or update supplier master. |
| `Cannot cancel Purchase Receipt; linked Purchase Invoice exists` | Self-explanatory. | Cancel the PI first. |
| `Delivery Note has unconfirmed Stock Reservation` | Reservation not converted to actual delivery. | Release the reservation or convert to Delivery Note. |
| `Payment Schedule total does not match grand total` | Rounded percentages off by a few cents. | Adjust the last row's amount by the difference. |
| `Subscription failed; template has invalid Item` | Item referenced in the template was disabled. | Re-enable the item, edit the template, or cancel the subscription. |
| `Sales Commission cannot exceed 100%` | Sum of `allocated_percentage` on sales_team exceeds 100. | Adjust allocations. |
| `Tax template's accounts missing cost center` | Tax row has no cost center and the company default is unset. | Set cost center on the tax template row or on the Company. |
| `Quotation conversion creates Sales Order with mismatched currency` | Quotation currency ≠ customer's default currency. | Edit the SO's currency after conversion or fix the customer's default. |
| `Drop-ship PO not auto-creating Delivery Note` | The PO's `is_drop_ship` flag or the related SO has an issue. | Verify both records have the right links; manually create DN if needed. |
| `RFQ email not sent to supplier` | Supplier email missing or **Email Account** not configured. | Add email on supplier master, configure outgoing email. |

### Debugging Tips

- **Sales / Purchase Order status is wrong** — check the per-row `delivered_qty` / `billed_qty`. ERPNext computes the parent status from these.
- **Pricing Rule not applying** — open the Sales Order, click **Pricing Rule** button on the toolbar — shows which rule matched and why.
- **Payment Terms not appearing on invoice** — verify the template is set on the customer's `payment_terms` field, or apply manually on the invoice.
- **Subscription stuck** — open the Subscription, check the **Subscription Update** log (child table) — each generation attempt is logged there.

## Where to Learn More

### Selling
- Selling intro: `https://docs.frappe.io/erpnext/selling-intro`
- Customer: `https://docs.frappe.io/erpnext/customer`
- Quotation: `https://docs.frappe.io/erpnext/quotation`
- Sales Order: `https://docs.frappe.io/erpnext/sales-order`
- Sales Invoice: `https://docs.frappe.io/erpnext/sales-invoice`
- POS: `https://docs.frappe.io/erpnext/pos`
- Point of Sale: `https://docs.frappe.io/erpnext/point-of-sale`
- Sales analytics: `https://docs.frappe.io/erpnext/sales-analytics`
- Sales Person target: `https://docs.frappe.io/erpnext/sales-person-target`
- Selling settings: `https://docs.frappe.io/erpnext/selling-settings`

### Buying
- Buying intro: `https://docs.frappe.io/erpnext/buying-intro`
- Supplier: `https://docs.frappe.io/erpnext/supplier`
- Supplier Quotation: `https://docs.frappe.io/erpnext/supplier-quotations`
- Purchase Order: `https://docs.frappe.io/erpnext/purchase-order`
- Purchase Invoice: `https://docs.frappe.io/erpnext/purchase-invoice`
- Purchase Receipt: `https://docs.frappe.io/erpnext/purchase-receipt`
- Buying settings: `https://docs.frappe.io/erpnext/buying-settings`
- Procurement Tracker: `https://docs.frappe.io/erpnext/procurement-tracker`
- RFQ: `https://docs.frappe.io/erpnext/request-for-quotation`

### Cross-Module
- Item: `https://docs.frappe.io/erpnext/item`
- Item pricing: `https://docs.frappe.io/erpnext/item-pricing`
- Address: `https://docs.frappe.io/erpnext/address`
- Contacts: `https://docs.frappe.io/erpnext/contacts`
- CRM: `https://docs.frappe.io/erpnext/crm`
- Lead: `https://docs.frappe.io/erpnext/lead`
- Opportunity: `https://docs.frappe.io/erpnext/opportunity`

For the framework scripting patterns used to customize these DocTypes (validate hooks, button additions, custom fields), read `../framework/scripting.md` and `customization.md`. For the GL impact of these transactions (revenue recognition, tax posting, multi-currency), read `accounts.md`. For stock movement mechanics (warehouses, serials, batches, valuation), read `stock.md`.
