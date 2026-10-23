# ERPNext — Stock / Inventory Module

The Stock module tracks every physical item movement in ERPNext. It is the backbone of inventory valuation, warehouse management, and the audit trail (`Stock Ledger Entry`) that feeds the General Ledger when perpetual inventory is enabled. Use this file for any question about items, warehouses, stock entries, valuation, serial/batch tracking, pricing rules, or stock reports. For the purchasing/selling transactions that move stock (Purchase Receipt, Delivery Note), see `selling-buying.md`. For the GL impact of stock movements, see `accounts.md`.

## Table of Contents

1. [Item Master](#item-master)
2. [Item Groups](#item-groups)
3. [Warehouses](#warehouses)
4. [Stock Settings](#stock-settings)
5. [Stock Entry](#stock-entry)
6. [Delivery Note & Purchase Receipt](#delivery-note--purchase-receipt)
7. [Serial No](#serial-no)
8. [Batch](#batch)
9. [Valuation Methods](#valuation-methods)
10. [Stock Reconciliation](#stock-reconciliation)
11. [Stock Ledger Entries](#stock-ledger-entries)
12. [Landed Cost Voucher](#landed-cost-voucher)
13. [Quality Inspection](#quality-inspection)
14. [Stock Reservation](#stock-reservation)
15. [Pricing (Item Price, Price List, Pricing Rule)](#pricing-item-price-price-list-pricing-rule)
16. [Stock Reports](#stock-reports)
17. [Barcode & QR Code Setup](#barcode--qr-code-setup)
18. [Putaway Rules](#putaway-rules)
19. [Common Errors & Troubleshooting](#common-errors--troubleshooting)
20. [Where to Learn More](#where-to-learn-more)

## Item Master

The `Item` DocType (`erpnext.stock.doctype.item`) is the master record for everything you stock — goods, services, raw materials, finished goods, consumables, or fixed assets. One record per sellable/procurable thing.

### Key Fields

| Field | Purpose | Notes |
|---|---|---|
| `item_code` | Short unique code (e.g. `WIDGET-001`). | Primary identifier; printed on every transaction. |
| `item_name` | Human-readable name. | Can differ from code. |
| `item_group` | Tree-based classification (e.g. "Raw Materials → Steel"). | Required; drives several reports. |
| `stock_uom` | Unit of measure for stock (e.g. `Nos`, `Kg`, `Litre`). | Cannot be changed after transactions exist. |
| `description` | Long description; printed on transactions. | Supports Jinja for dynamic content. |
| `brand` | Optional brand. | Flat list, used for filtering. |
| `valuation_rate` | Computed; do not edit directly. | Updated by Stock Ledger. Use **Item Price** for sales price. |
| `is_stock_item` | If unchecked, item has no inventory (services, expenses). | Required `0` for service items. |
| `include_item_in_manufacturing` | Whether it appears in BOMs. | Set to 1 for raw materials. |
| `has_batch_no` / `has_serial_no` | Enable batch/serial tracking. | Cannot be changed after stock movement. |
| `is_fixed_asset` | Marks the item as an asset class. | See `accounts.md`. |
| `default_warehouse` | Pre-selected on transactions. | Optional. |
| `default_supplier` | Pre-selected on Purchase Order. | Optional. |
| `min_order_qty` / `safety_stock` / `reorder_level` | Drive Material Request suggestions. | See Production Plan in `manufacturing.md`. |
| `lead_time_days` | Average procurement lead time. | Used in projected quantity. |
| `end_of_life` | Date after which item cannot be transacted. | Useful for obsolescence management. |
| `disabled` | Soft delete — hides from pickers. | |

### Item Variants

If the same base product comes in multiple variants (e.g. color/size), enable **Item Variants**:

1. Define **Item Attributes** (`Color`, `Size`, etc.) with their allowed values.
2. On the parent Item (a "Template"), check `has_variants = 1` and add the attributes.
3. Generate **Item Variants** — ERPNext creates a child Item per attribute combination.

Template items are **not transactable**. Only variants are. Variants inherit most fields from the template; you can override pricing per variant.

### UOM Conversions

The `UOM Conversion Detail` child table defines how the stock UOM relates to other UOMs:

```python
item = frappe.get_doc({
    "doctype": "Item",
    "item_code": "ROPE-001",
    "item_name": "Nylon Rope",
    "stock_uom": "Metre",
    "uoms": [
        {"uom": "Box", "conversion_factor": 50},
        {"uom": "Roll", "conversion_factor": 100},
    ],
})
```

A Box contains 50 Metres; a Roll contains 100. When a Sales Order specifies quantity in Boxes, ERPNext stores both quantities.

### Pitfalls

- **Changing `stock_uom` after transactions** is destructive. ERPNext blocks it; you can override with `stock_uom` toggle, but every prior `Stock Ledger Entry` becomes inconsistent.
- **Disabling `has_serial_no` after serials exist** orphans the serial records.
- **Setting `valuation_rate` manually** — it's a computed field. To set opening valuation, use **Stock Reconciliation**.
- **Item code with special characters** (`/`, `&`) — pickers will treat them as URL separators. Use alphanumerics + dashes.

## Item Groups

`Item Group` is a tree DocType. Use it for:

- Filtering reports (Stock Balance by Group, Sales by Group).
- Defaulting accounts (each group can have its own Income / Expense / Stock Asset accounts).
- Defaulting tax templates and cost centers per group.

### Default Accounts per Group

On the `Item Group` record, set:

- `income_account` — overrides the company default for Sales Invoices with items in this group.
- `expense_account` — overrides for Purchase Invoices.
- `default_cost_center` — overrides per-row cost center on transactions.

This is a powerful pattern: set up group-based accounting (e.g. "Spares" posts to a different income account than "Services") without custom scripts.

## Warehouses

`Warehouse` is a tree DocType. Each warehouse belongs to a Company and (optionally) a parent warehouse. Use group warehouses to roll up quantities without transacting against them.

### Key Fields

| Field | Purpose |
|---|---|
| `warehouse_name` | Display name (e.g. "Mumbai Stores"). |
| `parent_warehouse` | Tree parent; must be a group. |
| `is_group` | 1 = group (cannot transact); 0 = leaf. |
| `company` | Required; locks the warehouse to one company. |
| `warehouse_type` | Optional — `Stock`, `Transit`, `Supplier Warehouse`, `Customer Warehouse`, `Scrap`. |
| `account` | Linked ledger account for perpetual inventory. Required if perpetual inventory is on. |
| `branch` | Optional. Used for branch-level reports. |

### Common Patterns

- **Stores** — leaf warehouse for raw materials and consumables.
- **Finished Goods** — leaf warehouse for saleable output.
- **Work In Progress** — leaf warehouse for materials issued to production.
- **Transit Warehouse** — type `Transit`; used as the through-point in inter-warehouse transfers so reports can show "in transit".
- **Supplier Warehouse** — type `Supplier Warehouse`; used for subcontracting to track raw materials sent to a subcontractor.

### Pitfalls

- **Mixing companies in one tree** — every warehouse's company must match the parent's.
- **Stock in a group warehouse** — group warehouses cannot hold stock; ERPNext blocks the transaction.
- **Deleting a warehouse with stock** — fails. Move stock out first via Stock Entry.

## Stock Settings

`Stock Settings` (Single DocType) controls module-wide behavior. The most-tuned fields:

| Setting | Effect |
|---|---|
| `default_warehouse` | Fallback when no warehouse is on the transaction. |
| `item_naming_by` | `Item Code` (manual) or `Naming Series` (auto). |
| `default_stock_uom` | Used when creating new items from UI. |
| `auto_insert_price_list_rate_if_missing` | On Sales/Purchase transactions, creates an Item Price if missing. |
| `allow_negative_stock` | If unchecked, blocks stock issues that would drive balance below zero. **Keep off** for clean audits. |
| `auto_create_stock_entry_on_purchase_receipt` | Creates a Stock Entry from each Purchase Receipt (rarely used). |
| `show_barcode_field` | Adds a barcode scan field on stock transactions. |
| `default_valuation_method` | `FIFO` (default), `Moving Average`, or `LIFO` (where allowed). |
| `use_serial_no_fields` | Toggles the scan-based serial entry UI. |
| `raise_on_stock_transfer_mismatch` | Strict check on company match in transfers. |
| `set_qty_in_transactions_based_on_serial_no_input` | For serialized items, auto-set quantity from scanned serials. |
| `is_group_warehouse_for_repack` | Allow Repack entries to use group warehouses. |

Always set `default_valuation_method` early — changing it after transactions exist requires a one-time recalculation.

## Stock Entry

`Stock Entry` is the universal stock-movement voucher. Use it for any movement that is **not** part of a Sales/Purchase cycle: issues to production, transfers between warehouses, receipts from production, repacks, subcontracting, and initial stock loading.

### Purposes (Entry Types)

| `purpose` | Source → Target | Use |
|---|---|---|
| `Material Issue` | Stores → (consumed, no target) | Issue materials to a department, project, or expense. |
| `Material Receipt` | (no source) → Stores | Receive stock from a non-PO source (e.g. samples, donations). |
| `Material Transfer` | Warehouse A → Warehouse B | Move between warehouses (same company). |
| `Material Transfer for Manufacture` | Stores → WIP | Issue raw materials to a Work Order. |
| `Manufacture` | WIP/Raw → Finished Goods | Record production output (auto-generated by Work Order). |
| `Repack` | Item A → Item B | Convert one item into another (e.g. boxes into individual units). |
| `Subcontract` | Stores → Supplier Warehouse | Send raw materials to a subcontractor (used by the Subcontracting flow). |

### Anatomy

```python
se = frappe.get_doc({
    "doctype": "Stock Entry",
    "stock_entry_type": "Material Transfer",
    "posting_date": "2026-01-15",
    "company": "Acme",
    "from_warehouse": "Stores - ACME",
    "to_warehouse": "Production - ACME",
    "items": [
        {
            "item_code": "RAW-001",
            "qty": 10,
            "s_warehouse": "Stores - ACME",
            "t_warehouse": "Production - ACME",
            "basic_rate": 100,        # source valuation
            "allow_zero_valuation_rate": 0,
        }
    ],
})
se.insert()
se.submit()
```

### Stock Entry vs Stock Entry Type

In v14+, the field is `stock_entry_type` (link to `Stock Entry Type` DocType), not `purpose`. The `purpose` field is auto-derived. You can create your own `Stock Entry Type` for custom flows (e.g. "Sample Issue").

### Transfer with Different Companies

Material Transfer requires both warehouses in the **same company**. For inter-company moves, use a Sales + Purchase cycle (or the Inter Company Transaction feature — see `overview.md`).

### Perpetual Inventory GL Postings

If `Company → enable_perpetual_inventory` is on, submitting a Stock Entry posts GL Entries:

| Purpose | GL Effect |
|---|---|
| Material Receipt | Dr Stock Asset, Cr Stock Adjustment (or specified account). |
| Material Issue | Dr Stock Adjustment (or expense), Cr Stock Asset. |
| Material Transfer | Dr Stock Asset (target wh), Cr Stock Asset (source wh). |
| Repack | Cr source items at their valuation, Dr target items at new valuation. |
| Manufacture | Cr raw materials, Dr finished goods at BOM cost. |

## Delivery Note & Purchase Receipt

These vouchers belong to the Selling/Buying modules (`selling-buying.md`) but they are the primary stock inflow/outflow mechanisms in the normal trading cycle. Briefly:

- **Purchase Receipt** — stock inflow from a supplier against a Purchase Order. Posts `Stock Ledger Entry` (warehouse +) and (if perpetual inventory on) GL: Dr Stock Asset, Cr Stock Received But Not Billed. The Purchase Invoice that follows reverses the GRN suspense and books the payable.
- **Delivery Note** — stock outflow to a customer against a Sales Order. Posts SLE (warehouse -) and GL: Dr COGS, Cr Stock Asset.

Both documents have an `Items` child with `warehouse`, `qty`, `serial_no`, `batch_no`, `rate`. They are submittable and cancellable; cancelling reverses all SLEs and GL Entries.

See `selling-buying.md` for the full order-to-cash and procure-to-pay flows.

## Serial No

`Serial No` is a master record per individual serialized unit. Enable on the Item master with `has_serial_no = 1`. Each stock movement then requires a serial-number list (newline-separated in the `serial_no` field of the Stock Entry / Purchase Receipt / Delivery Note item row).

### Lifecycle

1. **Created** — automatically when a Purchase Receipt or Material Receipt is submitted with serials.
2. **Tracked** — the `Stock Ledger Entry` references the serial. The serial's `warehouse` field reflects current location.
3. **Moved** — every Stock Entry that touches the serial updates its `warehouse` field.
4. **Delivered** — Delivery Note sets `warehouse = null` and `status = Delivered`.
5. **Returned** — Credit Note with `update_stock = 1` reactivates the serial.

### Pitfalls

- **Duplicate serials** — `serial_no` is unique per item. If you import existing stock, de-dupe first.
- **Serial batch mismatch** — a serial cannot be in two batches. If you use both, pick one batch per serial at receipt.
- **Manual creation** — usually not needed; let ERPNext create on receipt. Manual creation only makes sense for opening stock.

## Batch

`Batch` tracks groups of items by production/run lot. Enable on the Item master with `has_batch_no = 1`. Optionally configure:

| Field | Behavior |
|---|---|
| `create_new_batch` | Auto-create a batch on Purchase Receipt / Manufacture. |
| `batch_number_series` | Naming pattern, e.g. `BATCH-.#####` |
| `batch_expiry` and `shelf_life_in_days` | Auto-computes expiry on creation. |

### FEFO Picking

Set `Stock Settings → pick_serial_batch_based_on = FEFO` (First Expiry, First Out) for expiry-managed inventory. Picking lists and POS auto-suggest batches accordingly.

### Batch Splitting

Use **Batch Splitting** Stock Entry (Stock Entry Type `Repack` with same source/target item, different batches) to split a large batch into smaller ones for traceability.

## Valuation Methods

Each Item has a `valuation_method` (defaults to `Stock Settings → default_valuation_method`). The choice drives how `valuation_rate` is recalculated after every stock movement.

| Method | Formula | Use Case |
|---|---|---|
| **FIFO** (default) | Cost of oldest remaining inventory is used first. | Most natural; matches typical warehouse flow. |
| **Moving Average** | Weighted average over remaining inventory. | Stable prices; simpler bookkeeping. |
| **LIFO** | Cost of newest inventory used first. | Disallowed under IFRS; only for US GAAP. |

### How ERPNext Picks the Rate

On a Material Issue or Delivery:

- **FIFO** — consumes from the oldest in-stock "queue" first.
- **Moving Average** — uses the current weighted average.
- **LIFO** — consumes from the newest "queue" first.

The Stock Ledger Entry stores `incoming_rate`, `outgoing_rate`, `qty_after_transaction`, and `stock_value` per row, allowing the `Stock Balance` report to show current valuation at any moment.

### Changing Valuation Method

You can change per-item via the Item master. ERPNext does **not** retroactively recompute historical SLEs — only future movements use the new method. To restate history, use the **Repost Item Valuation** tool (search Awesome Bar).

## Stock Reconciliation

`Stock Reconciliation` is the "set the truth" voucher: it forces the warehouse quantity and valuation to match a physical count. Use it for:

- Opening stock loading.
- Period-end physical count adjustments.
- Correcting cumulative drift from prior errors.

### Workflow

1. Open **Stock Reconciliation → New**.
2. Pick the Company, Warehouse, Posting Date.
3. Click **Get Items** (loads current qty/rate) or upload a CSV.
4. Set `qty` and `valuation_rate` to the actual physical count.
5. Submit. ERPNext creates the necessary Stock Ledger Entries to bridge from old → new.

### Impact on GL

If perpetual inventory is on, the reconciliation posts a GL Entry to:

- Dr/Cr Stock Asset for the valuation change.
- Dr/Cr the **Stock Adjustment Account** configured on the Company.

### Pitfalls

- **Reconciliation cancels existing entries for the day** — if any stock movement exists on the reconciliation date, the reconciliation overrides it. Choose a date with no movements or accept the override.
- **Reconciliation does NOT change Serial/Batch** — only quantity and rate. Update serials/batches separately.
- **Use for opening stock, not for ongoing movements** — for routine adjustments, use Material Issue/Receipt.

## Stock Ledger Entries

`Stock Ledger Entry` (SLE, table `tabStock Ledger Entry`) is the **audit trail** of every stock movement. Every voucher that touches inventory creates one or more SLEs on submit and reverses them on cancel. The SLE is **immutable** — it is the source of truth.

### Key Columns

| Column | Purpose |
|---|---|
| `posting_date`, `posting_time` | When the movement occurred (not when recorded). |
| `item_code` | Item affected. |
| `warehouse` | Warehouse affected. |
| `actual_qty` | + for receipts, - for issues. |
| `qty_after_transaction` | Running balance at the moment of posting. |
| `stock_value` | Running valuation. |
| `incoming_rate` / `outgoing_rate` | Valuation per unit. |
| `valuation_rate` | Item's valuation after this entry. |
| `voucher_type`, `voucher_no` | Source document (Stock Entry, Purchase Receipt, etc.). |
| `batch_no`, `serial_no` | If applicable. |
| `company` | Always present. |

### Querying

```python
sles = frappe.get_all("Stock Ledger Entry",
    filters={
        "item_code": "RAW-001",
        "warehouse": "Stores - ACME",
        "posting_date": ["between", ["2026-01-01", "2026-01-31"]],
    },
    fields=["posting_date", "actual_qty", "qty_after_transaction", "voucher_type", "voucher_no"],
    order_by="posting_date, posting_time, creation"
)
```

### Never Edit SLEs Directly

SLEs are protected — they should only be created by the framework's `update_entries_after` and `make_sl_entry` functions. Editing them via `frappe.db.sql` will desync the warehouse balance from reality. If SLEs are corrupt, use **Repost Item Valuation** or **Repost Stock Ledger Entry** tools (search Awesome Bar) to regenerate from voucher data.

## Landed Cost Voucher

When goods arrive with additional costs (freight, insurance, customs duty), use `Landed Cost Voucher` to allocate those costs to the items in a Purchase Receipt. The allocated cost updates the item's valuation rate (and GL if perpetual inventory is on).

### Workflow

1. Create a Purchase Receipt (or pick an existing one).
2. Create **Landed Cost Voucher** → reference the Purchase Receipt.
3. Add **Taxes & Charges** rows (account, description, amount).
4. ERPNext auto-distributes the cost across items proportional to their value (or quantity — configurable per row).
5. Submit. SLEs are re-posted with the new valuation rate.

### Pitfalls

- **Cannot edit after submission** — must cancel and re-create.
- **Cannot be created after Sales of the items** — the item has already left the warehouse; reversing earlier valuation is not supported. Apply landed cost before delivery.
- **Duty drawback / refund scenarios** — handle via a separate Credit Note to the freight/duty supplier; do not net against landed cost.

## Quality Inspection

`Quality Inspection` records the inspection result for a batch of items received (or manufactured). Enable per Item with `inspection_required_before_purchase` / `inspection_required_before_delivery`.

### Workflow

1. On the Item master, set `inspection_required_before_purchase = 1`.
2. When the Purchase Receipt is created, ERPNext prompts to create a Quality Inspection before submit.
3. Pick an **Quality Inspection Template** (criteria with min/max/numeric/text values).
4. Record readings per criterion.
5. Submit the Quality Inspection. The Purchase Receipt becomes submittable.
6. Rejected items — set `qty` lower than received; create a **Purchase Receipt → Return** or use the `rejected_warehouse` field on the parent row.

## Stock Reservation

Stock Reservation (`Stock Reservation Entry`) reserves a quantity of an item in a warehouse against a Sales Order (or a Work Order). Reserved stock is excluded from "available to sell" calculations but remains physically in the warehouse until delivered.

### Workflow

1. Open a Sales Order.
2. Click **Reserve Stock** (under Items section).
3. Pick the warehouse and quantity per item row.
4. Submit. A `Stock Reservation Entry` is created with `status = Reserved`.
5. When the Delivery Note is created from the Sales Order, ERPNext marks the reservation as `Delivered`.

### Pitfalls

- **Reservation does not move stock** — it only flags it. Use Material Transfer if you need physical segregation.
- **Reservation auto-expires** — if the Sales Order is cancelled, the reservation is cancelled too.

## Pricing (Item Price, Price List, Pricing Rule)

ERPNext separates **catalog pricing** (Item Price) from **dynamic pricing** (Pricing Rule). Both work in tandem.

### Item Price

`Item Price` is the simplest pricing mechanism: one record per (Item, Price List, UOM, valid-from date). Set:

- `item_code`, `item_name` (auto-filled).
- `price_list` — Selling or Buying type.
- `uom` — defaults to the item's stock UOM.
- `valid_from` / `valid_upto` — date range.
- `price_list_rate` — the rate.
- `currency` — auto from the Price List.
- `packing_unit` — for items sold in pack multiples.

### Price List

`Price List` DocType classifies prices. Each list has a `currency` and `selling` / `buying` flag. Common patterns:

- **Standard Selling** — base price list in company currency.
- **Wholesale** / **Retail** — different price levels.
- **USD Export** — foreign-currency list.
- **Purchase Standard** — for buying.

A customer's `default_price_list` pre-selects on Sales Orders.

### Pricing Rule

`Pricing Rule` is the dynamic pricing engine. It applies discounts, surcharges, or fixed prices based on conditions. Use it for:

- Volume discounts (buy 10+ → 5% off).
- Customer-segment discounts (VIP → 10% off).
- Time-limited promotions (Jan 1–31 → 15% off Item X).
- Free items with purchase (buy 3, get 1 free).

### Pricing Rule Anatomy

```python
pr = frappe.get_doc({
    "doctype": "Pricing Rule",
    "title": "Bulk Discount on Widgets",
    "apply_on": "Item Code",
    "items": [{"item_code": "WIDGET-001"}],
    "selling": 1,
    "min_qty": 10,
    "discount_percentage": 5,
    "valid_from": "2026-01-01",
    "valid_upto": "2026-12-31",
    "company": "Acme",
    "currency": "USD",
    "rate_or_discount": "Discount Percentage",
})
pr.insert()
```

### Key Pricing Rule Fields

| Field | Effect |
|---|---|
| `apply_on` | `Item Code`, `Item Group`, `Brand`, `Transaction`. |
| `applicable_for` | `Customer`, `Customer Group`, `Territory`, `Supplier`, `Supplier Group`, `Campaign`, `Sales Partner`, or blank for everyone. |
| `selling` / `buying` | Direction. |
| `min_qty` / `max_qty` | Quantity window. |
| `min_amount` / `max_amount` | Amount window. |
| `rate_or_discount` | `Rate`, `Discount Percentage`, `Discount Amount`. |
| `discount_percentage` / `discount_amount` / `price` / `rate` | The actual number. |
| `free_item` / `free_item_qty` | Free item giveaway (buy X get Y). |
| `valid_from` / `valid_upto` | Date range. |
| `priority` | When multiple rules match, higher priority wins. |
| `apply_multiple_pricing_rules` | If checked, several rules can stack (use carefully). |
| `threshold_percentage` | Round-threshold behavior. |
| `for_price_list` | Restrict to one Price List. |

### Rule Conflict Resolution

When multiple Pricing Rules match the same row, ERPNext picks by:

1. Higher `priority`.
2. More specific `applicable_for` (Customer > Customer Group > Territory > blank).
3. Higher `min_qty` (more restrictive condition wins).

If `apply_multiple_pricing_rules = 1` on each rule, all matching rules stack their discounts. Use this sparingly — stacking causes unpredictable effective rates.

### Common Pricing Pitfalls

- **Item Price vs Pricing Rule conflict** — if a Pricing Rule sets `Rate`, it overrides the Item Price. If it sets a discount, it applies to the Item Price. Mixing leads to "which one wins?" confusion. Pick one model per item.
- **Wrong currency** — Pricing Rules are currency-specific. A USD rule does not apply to an INR invoice.
- **Forgotten date range** — promotions left `valid_upto` blank run forever.

## Stock Reports

The most-used reports under **Stock → Reports**:

| Report | Purpose |
|---|---|
| **Stock Ledger** | Filterable list of every SLE. The audit trail. |
| **Stock Balance** | Current qty + valuation per Item/Warehouse. |
| **Stock Projected Qty** | Current + expected inflow/outflow per Item. |
| **Stock Projected Quantity** | Per-item projected availability. |
| **Item-wise Price List Rate** | All Item Prices across Price Lists. |
| **Item Prices** | Same with filters. |
| **Stock Ageing** | How long each Item/Warehouse has held stock. |
| **Batch Expiry** | Batches sorted by expiry. |
| **Serial No Status** | All serials with current warehouse/status. |
| **Item Variant Details** | Variant attribute comparison. |
| **Purchase Order Analysis** | PO items by status. |
| **Requested Items To Indent** | Open Material Requests not yet converted. |
| **Short Closed Item** | Items with `end_of_life` approaching. |
| **Stock Value** | Stock valuation summary. |
| **Warehouse-Wise Stock Balance** | Per-warehouse comparison. |

## Barcode & QR Code Setup

ERPNext supports barcode scanning on most stock transactions (Stock Entry, Purchase Receipt, Delivery Note, POS).

### Setup

1. **Stock Settings → show_barcode_field = 1**.
2. On the Item master, add **Barcodes** child rows. Each row has `barcode` and `barcode_type` (e.g. `EAN`, `UPC-A`, `Code128`, `QR`).
3. Optionally set the **Item Barcode Format** in **Stock Settings** to auto-generate on item creation.

### Print Barcodes

Use the **Item Barcode Print Format** (Print Format → New → Standard Format → "Barcode") or design your own with the Print Designer. Most customers use the open-source `Labels & Barcodes` integration or a custom Jinja print format.

### Scanning in the UI

Each stock transaction has a barcode scan field. Type or scan a barcode; ERPNext looks up the item by barcode, then by item_code, then by serial/batch (depending on field focus).

## Putaway Rules

`Putaway Rule` (Stock → Putaway Rule) auto-assigns items to warehouses based on rules. Use for warehouse slotting.

### Anatomy

| Field | Effect |
|---|---|
| `company`, `item_code` | Scope. |
| `warehouse` | Target warehouse for this item. |
| `capacity` | Maximum qty that can be put away here. |
| `disable` | Soft toggle. |

When a Purchase Receipt is submitted, ERPNext checks each item row against the putaway rules and auto-fills the `warehouse` if multiple candidate warehouses exist, splitting by capacity.

### Pitfalls

- Putaway rules are **advisory** — they auto-fill the warehouse but the user can override.
- Capacity is per rule, not per warehouse. If you have two rules pointing to the same warehouse, sum their capacities mentally.

## Common Errors & Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `Negative stock error for Item X in Warehouse Y` | Issuing more than available when `allow_negative_stock = 0`. | Verify count; do a Material Receipt first or temporarily enable negative stock. |
| `Item X is not a stock item` | Trying to transact an Item with `is_stock_item = 0`. | Enable `is_stock_item` (cannot reverse if already transacted) or use a different item. |
| `Cannot change stock_uom after transactions` | Self-explanatory. | Create a new item or use a UOM conversion instead. |
| `Warehouse W is a group warehouse` | Transacting against `is_group = 1` warehouse. | Pick a leaf warehouse. |
| `Serial No S0001 not found` | The serial was not received before issue. | Receive via Purchase Receipt / Stock Entry first. |
| `Batch B001 has expired` | Issuing from an expired batch. | Use FEFO picking; allow override only with `Stock Settings → allow_expired_batches`. |
| `Valuation rate is 0 for Item X` | Item received with `allow_zero_valuation_rate = 1` and no rate. | Use **Landed Cost Voucher** or **Stock Reconciliation** to set the rate. |
| `Cannot cancel Stock Entry; linked Work Order exists` | A WO has consumed the stock. | Cancel the WO first. |
| `Stock Ledger Entry is corrupt; qty mismatch` | Manual DB edits. | Run **Repost Stock Ledger Entry** for the affected Item/Warehouse. |
| `Bin exists but qty is wrong` | Same — Bin is a cached aggregate of SLEs. | Repost SLE; the Bin recalculates. |
| `Pricing Rule not applied` | Customer/territory/currency mismatch or `valid_upto` past. | Verify the rule's conditions; check the `Pricing Rule` debug log in the Sales Order. |
| `Duplicate item in same row` | Pricing rule generated a free item with same code as purchased. | Set the Pricing Rule's `free_item` to a different code (or check `same_item` toggle). |
| `Stock value does not match GL` | Perpetual inventory off when stock moved, then re-enabled. | Use **Repost Accounting Ledger** for the affected period. |
| `Cannot reserve stock; insufficient qty` | Trying to reserve more than available. | Free up existing reservations or wait for replenishment. |

### Debugging Tips

- **View Stock Ledger** — every Stock Entry / Purchase Receipt / Delivery Note has a **Stock Ledger** button. Click to see the SLEs it generated.
- **Bin** — each (Item, Warehouse) has a `Bin` record with cached aggregates (`actual_qty`, `ordered_qty`, `reserved_qty`, `projected_qty`). If Bin seems wrong, the source SLE is the truth — repost via the **Repost Stock Ledger Entry** tool.
- **Repost Item Valuation** — when valuation rate is wrong, this tool recomputes the SLE's `incoming_rate` and downstream valuations. Use cautiously — it cancels and recreates SLEs.
- **Stock Projection** report — best for debugging "why is my projected qty wrong" — it shows every contribution (current, ordered, requested, reserved).

## Where to Learn More

- Stock intro: `https://docs.frappe.io/erpnext/stock-introduction`
- Item: `https://docs.frappe.io/erpnext/item`
- Item attributes: `https://docs.frappe.io/erpnext/item-attributes`
- Item pricing: `https://docs.frappe.io/erpnext/item-pricing`
- Warehouse: `https://docs.frappe.io/erpnext/warehouse`
- Stock Entry: `https://docs.frappe.io/erpnext/stock-entry`
- Stock reconciliation: `https://docs.frappe.io/erpnext/stock-reconciliation`
- Stock settings: `https://docs.frappe.io/erpnext/stock-settings`
- Inventory settings: `https://docs.frappe.io/erpnext/inventory-settings`
- Stock reservation: `https://docs.frappe.io/erpnext/stock-reservation`
- Serial No: `https://docs.frappe.io/erpnext/serial-no`
- Batch: `https://docs.frappe.io/erpnext/batch`
- Batch splitting: `https://docs.frappe.io/erpnext/batch-splitting`
- Valuation method: `https://docs.frappe.io/erpnext/valuation-method`
- Stock balance report: `https://docs.frappe.io/erpnext/stock-balance-report`
- Stock ledger: `https://docs.frappe.io/erpnext/stock-ledger`
- Landed cost voucher: `https://docs.frappe.io/erpnext/landed-cost-voucher`
- Quality inspection: `https://docs.frappe.io/erpnext/quality-inspection`
- Purchase receipt: `https://docs.frappe.io/erpnext/purchase-receipt`
- Delivery note: `https://docs.frappe.io/erpnext/delivery-note`

For the framework concepts behind stock postings (controllers, `validate`/`on_submit` hooks, `frappe.get_doc`), read `../framework/python-api.md` and `../framework/doctype-guide.md`. For GL-side accounting of stock movements, read `accounts.md`. For the manufacturing consumption of stock (Work Orders, BOMs), read `manufacturing.md`. For purchasing/selling transactions, read `selling-buying.md`.
