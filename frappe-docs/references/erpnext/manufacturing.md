# ERPNext — Manufacturing Module

The Manufacturing module converts raw materials into finished goods. It covers the full discrete-process flow: BOM definition, production planning (MRP-like), work orders, job cards, routing, workstations, and capacity planning. It also handles subcontracting — sending raw materials to an external supplier who returns the finished item. Use this file for any question about BOMs, work orders, production plans, job cards, routing, workstations, manufacturing settings, capacity planning, or production reports. For the underlying stock movements (Material Transfer for Manufacture, Manufacture Stock Entry), see `stock.md`. For procurement of raw materials (Material Requests, Purchase Orders), see `selling-buying.md`.

## Table of Contents

1. [Bill of Materials (BOM)](#bill-of-materials-bom)
2. [Routing & Operations](#routing--operations)
3. [Workstation](#workstation)
4. [Work Order](#work-order)
5. [Job Card](#job-card)
6. [Production Plan](#production-plan)
7. [Manufacturing Settings](#manufacturing-settings)
8. [Subcontracting](#subcontracting)
9. [Capacity Planning](#capacity-planning)
10. [BOM Explorer & BOM Tree](#bom-explorer--bom-tree)
11. [Production Forecast](#production-forecast)
12. [Material Request for Raw Materials](#material-request-for-raw-materials)
13. [Manufacturing Reports](#manufacturing-reports)
14. [Common Errors & Troubleshooting](#common-errors--troubleshooting)
15. [Where to Learn More](#where-to-learn-more)

## Bill of Materials (BOM)

The `BOM` DocType defines **what** goes into a finished item and **how much**. A BOM is per item, per company, per quantity of finished output. ERPNext supports multi-level BOMs (a finished item can have a sub-assembly whose BOM references another sub-assembly).

### Key Fields

| Field | Purpose |
|---|---|
| `item` | The finished item (must be `is_stock_item = 1` or `is_fixed_asset = 1`). |
| `company` | Single BOM per item per company is typical. |
| `quantity` | Output quantity — items table is for this quantity. Default `1`. |
| `uom` | UOM of the output (defaults to item's stock UOM). |
| `is_default` | Marks as the default BOM for the item. Only one default per item per company. |
| `is_active` | Soft toggle; inactive BOMs don't appear in pickers. |
| `allow_same_item_multiple_times` | Permits the same raw material on multiple rows. |
| `rm_cost_as_per` | `Valuation Rate`, `Price List`, `Last Purchase Rate`, `Landed Cost`. Drives cost calculation. |
| `rate_of_materials_based_on` | Companion to `rm_cost_as_per`. |
| `with_operations` | If checked, the BOM has an **Operations** child table. |
| `items` | Raw materials child table. |
| `operations` | Operations child table (if `with_operations = 1`). |
| `scrap_items` | Scrap items child table (output of the process). |
| `project` | Optional project tag. |

### Items (Raw Materials) Child Table

| Field | Purpose |
|---|---|
| `item_code` | Raw material item. |
| `qty` | Quantity per BOM output. |
| `uom` / `conversion_factor` | UOM handling. |
| `rate` | Per-unit cost (auto-computed based on `rm_cost_as_per`). |
| `amount` | Computed. |
| `stock_uom_qty` | Quantity in stock UOM. |
| `source_warehouse` / `default_warehouse` | Where to pick from. |
| `include_item_in_manufacturing` | If checked, this row is a sub-assembly (has its own BOM). |
| `bom_no` | The sub-assembly's BOM reference. |
| `do_not_include_in_manufacturing` | Skip when exploding. |

### Scrap Items Child Table

Scrap items are byproducts (e.g. trimmings, off-cuts). They are produced and stocked in a scrap warehouse, and their value nets against the production cost.

### Operations Child Table

If `with_operations = 1`, each row defines an operation in the production sequence. See [Routing & Operations](#routing--operations).

### Creating a BOM Programmatically

```python
bom = frappe.get_doc({
    "doctype": "BOM",
    "item": "WIDGET-FINISHED",
    "company": "Acme",
    "quantity": 1,
    "uom": "Nos",
    "is_default": 1,
    "is_active": 1,
    "with_operations": 1,
    "items": [
        {"item_code": "RAW-CASING", "qty": 1, "uom": "Nos"},
        {"item_code": "RAW-SCREWS", "qty": 4, "uom": "Nos"},
        {"item_code": "RAW-LABEL", "qty": 1, "uom": "Nos"},
    ],
    "operations": [
        {"operation": "Assembly", "workstation": "Assembly Bench 1", "time_in_mins": 30},
        {"operation": "Testing", "workstation": "Test Station 1", "time_in_mins": 10},
    ],
})
bom.insert()
bom.submit()
```

### Multi-Level BOMs (Sub-Assemblies)

For a finished item that uses a sub-assembly, set `include_item_in_manufacturing = 1` and `bom_no` on the items row. When the Work Order is created, ERPNext explodes the BOM recursively and generates Job Cards and Material Transfer Stock Entries for each level.

### BOM Costing

ERPNext computes `total_cost` = sum of `items.amount` + sum of `operations.cost` (based on workstation hourly rate × time) − sum of `scrap_items.amount`. The `costing_based_on` field chooses the basis: `Valuation Rate` (current stock value), `Price List`, `Last Purchase Rate`, or `Landed Cost`.

### BOM Versions and Updates

BOMs are submittable — once submitted, edits require cancellation. The pattern for a "new version":

1. Cancel the old BOM.
2. Mark `is_default = 0`.
3. Create a new BOM with the same item, set `is_default = 1`, submit.

Old Work Orders keep their BOM reference even after the BOM is cancelled — they continue to use the snapshot.

### Pitfalls

- **No default BOM** — Work Order creation fails without `is_default = 1` somewhere.
- **Wrong UOM on a row** — ERPNext multiplies by `conversion_factor`; verify the stock UOM quantity matches reality.
- **Sub-assembly BOM not exploded** — check `include_item_in_manufacturing` is on.
- **Costing not refreshed** — BOM stores `total_cost` at last save. To recompute, edit & save again (ERPNext refreshes automatically on each save if `rm_cost_as_per` is set).

## Routing & Operations

`Routing` and `Operation` are separate DocTypes that together describe the **how** of production.

### Operation

`Operation` is the master record for a single manufacturing step (e.g. "Lathe Turning", "Assembly", "Painting"). One master record per step; reused across many BOMs.

| Field | Purpose |
|---|---|
| `name` | Operation name. |
| `workstation` | Default workstation. |
| `description` | Free text. |
| `batch_size` | Default units per batch. |
| `default_time` | Default cycle time in minutes. |

### Routing

`Routing` is a sequence of Operations. Reusable across BOMs. Stored as a child table of `Operation` rows on the Routing master.

```python
routing = frappe.get_doc({
    "doctype": "Routing",
    "routing_name": "Widget Assembly",
    "operations": [
        {"operation": "Assembly", "workstation": "Assembly Bench 1", "time_in_mins": 30, "sequence": 1},
        {"operation": "Testing", "workstation": "Test Station 1", "time_in_mins": 10, "sequence": 2},
        {"operation": "Packaging", "workstation": "Packaging Bench 1", "time_in_mins": 5, "sequence": 3},
    ],
})
routing.insert()
```

### Linking Routing to a BOM

On the BOM, set `routing` (link field). ERPNext auto-populates the BOM's `operations` child table from the routing. You can override per-BOM if needed.

### Pitfalls

- **Time per unit vs per batch** — verify whether `time_in_mins` is per single unit or per batch (defined by `batch_size` on the Operation).
- **Missing workstation** — operations without a workstation cannot be scheduled.
- **Routing changes do not auto-propagate to existing BOMs** — open each BOM and re-link the routing to refresh.

## Workstation

`Workstation` is the production resource (a machine, a bench, a cell). It has cost, capacity, and availability constraints.

### Key Fields

| Field | Purpose |
|---|---|
| `name` | Workstation name. |
| `production_capacity` | How many units can run in parallel. |
| `hour_rate` | Hourly cost (labor + machine depreciation + overhead). Drives `operations.cost` on BOMs. |
| `default_hour_rate` | Fallback. |
| `holiday_list` | Days the workstation is offline. |
| `working_hours` | Child table — `from_time`, `to_time`, `break_minutes`. |
| `overhead` | Annual or hourly overhead allocation. |
| `cost_center` | Where workstation costs are booked. |
| `description` | Free text. |

### Working Hours

Each workstation can have multiple shifts (working hours rows). Job cards scheduled outside working hours are pushed to the next available slot.

### Holiday List

Link a `Holiday List` (typically created per year). Job cards are not scheduled on holidays unless overridden.

## Work Order

`Work Order` (formerly `Production Order`) is the production job. It records:

- What to produce (`production_item`, `qty`).
- From what BOM (`bom_no`).
- By when (`expected_delivery_date`).
- To what warehouse (`fg_warehouse`, `scrap_warehouse`).
- Required materials (auto-filled from BOM).
- Required operations (auto-filled from BOM if `with_operations`).
- Per-operation Job Cards (auto-generated on submit).

### Key Fields

| Field | Purpose |
|---|---|
| `production_item` | The finished item. |
| `bom_no` | The BOM to use. |
| `qty` | Quantity to produce. |
| `company` | Production company. |
| `fg_warehouse` | Finished goods target warehouse. |
| `wip_warehouse` | Work-in-progress warehouse. |
| `scrap_warehouse` | Target for scrap. |
| `expected_delivery_date` | Customer-facing due date. |
| `planned_start_date` | Internal planned start. |
| `sales_order` | Optional link to a Sales Order (planned production). |
| `project` | Optional project tag. |
| `material_transferred_for_manufacturing` | Auto-updated as material is issued. |
| `produced_qty` | Auto-updated as finished goods are received. |
| `status` | `Draft`, `Not Started`, `In Process`, `Completed`, `Stopped`, `Cancelled`. |

### Work Order Lifecycle

```
1. Create Work Order (Draft)
2. Submit (status: Not Started, Job Cards auto-created)
3. Transfer raw materials (Stock Entry: Material Transfer for Manufacture)
4. Run Job Cards (or auto-complete if no operations)
5. Receive finished goods (Stock Entry: Manufacture, or Job Card → Job Card → Complete)
6. Work Order becomes Completed when produced_qty = qty
```

### Material Transfer for Manufacture

When you click **Transfer Material** on a Work Order, ERPNext creates a **Stock Entry** of type `Material Transfer for Manufacture`. This moves raw materials from their stock warehouse to the WIP warehouse (defined on the Work Order). With `Manufacturing Settings → backflush_raw_materials_based_on` set to `Material Transferred`, you transfer raw materials before production.

### Manufacture Entry (Production Output)

When production completes, click **Finish** on the Work Order. ERPNext creates a **Stock Entry** of type `Manufacture`:

- Credits raw materials from WIP warehouse at their valuation.
- Debits finished goods to FG warehouse at BOM cost.

With `backflush_raw_materials_based_on = BOM`, ERPNext back-calculates the raw materials consumed based on the BOM — no manual transfer needed.

### Job Card Scheduling

When a Work Order with operations is submitted, ERPNext auto-creates one **Job Card** per operation. The Job Card references the Work Order, the Operation, the Workstation, and the expected time. Scheduling (which start time?) is done by the **Job Card** planner, which respects workstation working hours and holidays.

### Stopping a Work Order

If production is halted mid-way, click **Stop**. ERPNext:

- Cancels pending Job Cards.
- Marks the Work Order `Stopped`.
- Allows restart via **Restart** button.

Stopped Work Orders still report their partial production in analytics.

### Pitfalls

- **BOM not default** — Work Order creation fails. Set `is_default = 1` on BOM.
- **Insufficient raw materials** — material transfer Stock Entry fails. Use a Material Request first, or temporarily allow negative stock.
- **Wrong WIP warehouse** — the WIP warehouse must exist and be a leaf; ERPNext does not auto-create.
- **Job Card time not logged** — without `time_logs`, the Job Card can be submitted but production analytics show zero hours.
- **Production cost mismatch** — if raw material valuation rate changes between transfer and manufacture, the FG rate will differ from BOM cost. Use **Landed Cost Voucher** style adjustments if material.

## Job Card

`Job Card` is the per-operation execution record. One Work Order with 3 operations generates 3 Job Cards. The Job Card is what the shop-floor operator interacts with.

### Key Fields

| Field | Purpose |
|---|---|
| `work_order` | Parent Work Order. |
| `operation` | The operation row from the BOM. |
| `workstation` | Where the operation runs. |
| `employee` | Who ran it (optional). |
| `for_quantity` | Quantity to produce through this operation. |
| `started_time` / `completed_time` | Auto-set when work begins/ends. |
| `time_logs` | Child table — `from_time`, `to_time`, `time_in_mins`, `completed_qty`, `employee`, `operation`. Multiple rows allow splitting across operators/shifts. |
| `total_time_in_mins` | Sum of time_logs. |
| `total_completed_qty` | Sum of completed_qty across time_logs. |
| `expected_start_date` / `expected_end_date` | Planned schedule. |
| `actual_start_date` / `actual_end_date` | Actual. |
| `status` | `Open`, `Work In Progress`, `Completed`, `Material Transferred`. |

### Time Logs

Each row in `time_logs` represents one work session. An operator can pause and resume — each pause creates a new row. The total completed quantity is the sum of all rows.

```python
jc = frappe.get_doc({
    "doctype": "Job Card",
    "work_order": "WO-00001",
    "operation": "Assembly",
    "workstation": "Assembly Bench 1",
    "for_quantity": 100,
    "time_logs": [
        {"from_time": "2026-01-15 09:00:00", "to_time": "2026-01-15 12:00:00",
         "time_in_mins": 180, "completed_qty": 60, "employee": "EMP-001"},
        {"from_time": "2026-01-15 13:00:00", "to_time": "2026-01-15 14:30:00",
         "time_in_mins": 90, "completed_qty": 40, "employee": "EMP-001"},
    ],
})
jc.insert()
jc.submit()
```

### Job Card Buttons

- **Start Job** — sets `actual_start_date`, status `Work In Progress`.
- **Complete Job** — submits the Job Card when `total_completed_qty >= for_quantity`.
- **Pause Job** — ends the current `time_logs` row.
- **Resume Job** — starts a new row.
- **Material Transfer** — for operations that consume materials, transfer them to the workstation's WIP warehouse.
- **Submit For Quality Inspection** — opens a Quality Inspection for the produced batch.

### Operation-Level Quality Inspection

Each operation can require a quality inspection (configured on the Operation master via `quality_inspection_template`). The Job Card cannot be submitted until the inspection is recorded.

## Production Plan

`Production Plan` is ERPNext's MRP (Material Requirements Planning) tool. It aggregates demand from multiple sources (Sales Orders, Material Requests, manual entries) and generates:

- Work Orders for manufactured items.
- Material Requests for purchased raw materials.

### Workflow

1. Create **Production Plan** (`Manufacturing → Production Plan → New`).
2. Add **Sales Orders** or **Material Requests** in the **Get Items From** section.
3. ERPNext aggregates demand and shows a **Production Plan Items** table.
4. For each item, set `planned_qty` (how much to make / buy).
5. Click **Get Items for Production Plan** — explodes BOMs and produces a list of raw materials.
6. Click **Create Work Order** — generates one Work Order per produced item.
7. Click **Create Material Request** — generates one Material Request per purchased raw material.

### Key Fields

| Field | Purpose |
|---|---|
| `from_date` / `to_date` | Demand window. |
| `company` | One company per plan. |
| `for_warehouse` | Stock to consider for net demand. |
| `po_items` | Items to produce (manufactured). |
| `mr_items` | Items to procure (raw materials). |
| `sub_assembly_items` | Sub-assemblies that need their own Work Orders. |
| `get_items_from` | Source: `Sales Order`, `Material Request`, `Purchase Request`. |
| `combine_items` | Combine demand for same item across Sales Orders into one Work Order. |
| `ignore_existing_ordered_qty` | Skip netting against open WOs/MRs. |

### Best Practices

- Run weekly as part of S&OP. Save each plan with a clear date in the name (e.g. `PP-2026-W03`).
- Use **Projected Quantity** report alongside to validate plan assumptions.
- Lock the plan once Work Orders are created — editing afterward requires cancellation and recreation.

## Manufacturing Settings

`Manufacturing Settings` (Single DocType) tunes module behavior. The most-tuned fields:

| Setting | Effect |
|---|---|
| `default_workstation` | Fallback when an operation has none. |
| `default_wip_warehouse` | Fallback WIP warehouse. |
| `default_scrap_warehouse` | Fallback scrap warehouse. |
| `overproduction_percentage_for_work_order` | Allow producing N% more than `qty` (e.g. for shrinkage compensation). |
| `backflush_raw_materials_based_on` | `Material Transferred` (default) or `BOM` (auto-backflush). |
| `material_consumption` | Auto-create a consumption Stock Entry when Job Card completes (v14+). |
| `do_not_update_projected_qty` | Skip projected qty recalculation on each SLE (performance optimization for large sites). |
| `job_card_excess_transfer` | Allow transferring more raw materials than BOM dictates. |
| `add_corrective_operation` | Add a corrective operation row on Job Card for rework. |
| `set_serial_batch_state` | Track serial/batch state through production. |
| `update_bom_costs_automatically` | Refresh BOM costs on item price changes. |
| `set_qty_in_jobs_based_on_operation_time` | Compute completed_qty from operator hours. |

## Subcontracting

Subcontracting is the practice of sending raw materials to an external supplier who performs the manufacturing step and returns the finished item. ERPNext v15+ has dedicated subcontracting DocTypes:

- **Subcontracting Order** — replaces the old "Subcontracting Purchase Order" pattern.
- **Subcontracting Receipt** — receives the finished item back.
- **Subcontracting Invoice** — supplier's invoice for the service.

### Setup

1. **Supplier** — `is_subcontractor = 1`.
2. **Item** — finished item with a BOM (raw materials defined as usual).
3. **Subcontracting Order** — references the BOM and the supplier.

### Workflow

1. Create **Subcontracting Order** (from a Sales Order or standalone).
2. ERPNext computes the raw materials needed (from the BOM).
3. Submit the Order.
4. Click **Material Transfer** — creates a Stock Entry moving raw materials from your Stores to a `Supplier Warehouse` (a warehouse of type `Supplier Warehouse`).
5. Supplier processes the materials.
6. Click **Create → Subcontracting Receipt** — receives the finished item into your FG warehouse.
7. ERPNext auto-returns unused raw materials to your Stores (or keeps them at the supplier per the order's `supply_raw_material` setting).
8. Click **Create → Purchase Invoice / Subcontracting Invoice** — books the supplier's service invoice.

### Service Item

A subcontracting order needs a service item representing the conversion cost. ERPNext auto-creates one (or you can pre-define) — typically `SUBCONTRACT-SERVICE-<item>`.

### Scrap and Loss

If the supplier produces scrap (raw material lost in processing), define a `scrap_warehouse` on the Subcontracting Order. ERPNext posts scrap to that warehouse on receipt.

### Pitfalls

- **Supplier warehouse configuration** — every subcontracting supplier needs a dedicated warehouse of type `Supplier Warehouse`. Mixing it with your Stores causes stock loss.
- **No returned materials** — if the supplier keeps materials (loss in processing), set `retain_sample = 0` and adjust the receipt's `consumed_qty` manually.
- **Valuation** — finished item's valuation = raw materials' valuation + service cost. The Subcontracting Receipt computes this automatically; verify the rate.
- **Service invoice mismatch** — supplier's invoice amount may differ from the order's service rate. Reconcile on the invoice before payment.

## Capacity Planning

ERPNext capacity planning happens at the **Workstation** and **Job Card** level. The planning engine respects:

- Workstation `production_capacity` (parallel slots).
- Workstation `working_hours` (shifts).
- Workstation `holiday_list` (off-days).
- Operation `time_in_mins` and `batch_size`.
- Existing Job Card schedule (no double-booking).

### Capacity Planning Report

Open **Manufacturing → Reports → Capacity Planning**. Shows per-workstation:

- Available hours per day (from working hours minus holidays).
- Planned hours (sum of expected job card times).
- Utilization %.

### Bottleneck Detection

Use the **Workstation Utilization** report to find over-utilized workstations. If a workstation is consistently > 90% utilized, consider:

- Adding a second workstation (increase `production_capacity`).
- Shifting jobs to off-hours (add a shift).
- Outsourcing (subcontracting).

### Holiday List

Each year, create a `Holiday List` for the company (and per workstation if they differ). Link to each Workstation. Job Cards scheduled on a holiday auto-move to the next working day.

## BOM Explorer & BOM Tree

The **BOM Explorer** (`Manufacturing → BOM Explorer`) is an interactive tree view of a BOM, showing:

- Raw materials at each level.
- Sub-assembly BOMs (expanded recursively).
- Per-level cost and total cost.
- Per-operation time and cost.

Use it for **what-if** analysis: change a raw material and see the cost ripple. Save the explorer view as a Print Format for sharing with engineering.

### BOM Tree Report

The **BOM Tree** report is a tabular version: every item, every BOM, every level. Filterable by item, company, or active status.

### BOM Compare

The **BOM Comparison Tool** diffs two BOMs (old vs new) — useful for engineering change management. Shows added/removed/changed items and operations, plus cost impact.

## Production Forecast

`Production Forecast` DocType records expected future demand that does not yet have a Sales Order. Use it for:

- Seasonal planning (holiday demand).
- New product launches.
- Sales-team sales forecasts.

Each forecast has:

- `item_code`
- `for_warehouse`
- `planned_qty` per month (in a child table).

When you run a **Production Plan** with `get_items_from = Production Plan Forecast`, ERPNext includes forecast demand alongside actual Sales Orders.

## Material Request for Raw Materials

A `Material Request` is the procurement trigger for raw materials. Created from:

- A **Production Plan** (auto).
- A **Work Order** (manually via the **Material Request** button).
- A **Sales Order** (for trade-only items with `default_supplier` set).

### Material Request Types

| `material_request_type` | Use |
|---|---|
| `Purchase` | Buy from supplier (becomes Purchase Order). |
| `Material Transfer` | Move between warehouses (becomes Stock Entry). |
| `Material Issue` | Issue to a department/project (becomes Stock Entry). |
| `Customer Provided` | Item returned by customer for repair (becomes Stock Entry). |
| `Manufacture` | Make in-house (becomes Work Order). |

The lifecycle is `Draft → Submitted → Stopped / Cancelled`, then converted to a downstream document via the **Create** button.

## Manufacturing Reports

The most-used reports under **Manufacturing → Reports**:

| Report | Purpose |
|---|---|
| **Production Plan Summary** | Plans vs actuals. |
| **Work Stock Summary** | WIP inventory by item/warehouse. |
| **BOM Explorer** | Interactive BOM tree. |
| **BOM Tree** | Flat BOM listing. |
| **Capacity Planning** | Workstation hours and utilization. |
| **Workstation Utilization** | Per-workstation percentage used. |
| **Production Analytics** | Production trends over time. |
| **Open Work Orders** | Active WOs with progress. |
| **Job Card Summary** | Per-operator hours and output. |
| **Subcontracting Order** | Subcontracting pipeline. |
| **Released Production Orders** | Submitted WOs. |
| **Item Manufacturer** | Items and their manufacturers. |

Each report is a Query Report or Script Report — both can be customized (see `customization.md`).

## Common Errors & Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `Default BOM not found for item X` | No BOM with `is_default = 1` and `is_active = 1` exists. | Create or activate a BOM. |
| `Cannot create Work Order; Item X has no BOM` | Self-explanatory. | Create a BOM first. |
| `Insufficient stock for raw material` | Material Transfer Stock Entry cannot complete. | Buy more (Material Request → PO → Receipt) or temporarily enable negative stock. |
| `Job Card cannot be completed; quantity mismatch` | `total_completed_qty < for_quantity`. | Add more `time_logs` rows until quantity matches, or reduce `for_quantity` (requires WO edit). |
| `Workstation is on holiday` | Job Card scheduled on a holiday. | Move the Job Card date or extend the holiday list. |
| `BOM explosion skipped sub-assembly` | `include_item_in_manufacturing = 0` on the sub-assembly row. | Check the flag and the `bom_no` reference. |
| `Work Order produced_qty > qty` | Overproduction beyond `overproduction_percentage_for_work_order`. | Increase the percentage in Manufacturing Settings, or split into a new WO. |
| `Manufacture Stock Entry valuation mismatch` | Raw material valuation rate changed between transfer and manufacture. | Use **Stock Reconciliation** or **Landed Cost Voucher** to align rates. |
| `Subcontracting Receipt shows zero valuation` | Service item rate missing or raw material rate is zero. | Set service item rate on the Subcontracting Order; verify raw material valuation. |
| `Capacity Planning shows incorrect hours` | Workstation `working_hours` or `holiday_list` misconfigured. | Audit the workstation record. |
| `Job Card auto-create fails` | BOM has `with_operations = 0` or routing is missing operations. | Edit the BOM, add operations, re-save. |
| `Production Plan creates WO for already-stocked item` | `ignore_existing_ordered_qty = 0` but `Projected Quantity` is wrong. | Repost SLE for affected items, then re-run plan. |

### Debugging Tips

- **View Job Cards** — every Work Order has a **Job Cards** button. Click to see all generated Job Cards and their statuses.
- **View Stock Entries** — every Work Order has a **Stock Entries** button. Click to see material transfer and manufacture entries.
- **BOM Cost** — open the BOM and click **Update Cost** to refresh `total_cost` with current material rates.
- **Production Plan dry run** — use the **Get Items for Production Plan** button without creating WOs to see what would be made/bought.
- **Capacity report** — verify per-workstation utilization before scheduling new WOs.

## Where to Learn More

- Manufacturing intro: `https://docs.frappe.io/erpnext/manufacturing-introduction`
- Bill of Materials: `https://docs.frappe.io/erpnext/bill-of-materials`
- Work Order: `https://docs.frappe.io/erpnext/work-order`
- Production Plan: `https://docs.frappe.io/erpnext/production-plan`
- Job Card: `https://docs.frappe.io/erpnext/job-card`
- Routing: `https://docs.frappe.io/erpnext/routing`
- Operation: `https://docs.frappe.io/erpnext/operation`
- Workstation: `https://docs.frappe.io/erpnext/workstation`
- Manufacturing settings: `https://docs.frappe.io/erpnext/manufacturing-settings`
- Subcontracting: `https://docs.frappe.io/erpnext/subcontracting`

For the underlying stock movements used by manufacturing (Material Transfer for Manufacture, Manufacture Stock Entry, valuation), read `stock.md`. For procurement of raw materials (Material Requests, Purchase Orders), read `selling-buying.md`. For GL impact of production (WIP accounting, finished goods capitalization, perpetual inventory), read `accounts.md`. For customizing manufacturing DocTypes (custom BOM fields, Job Card automation, custom production reports), read `customization.md` and `../framework/scripting.md`.
