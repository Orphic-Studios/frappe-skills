# Frappe DocType & Custom App Checklist

Use this checklist before finalizing any new DocType, controller, or custom app feature.

## 1. Schema & Naming
- [ ] DocType name is **singular TitleCase** (e.g., `Service Request`, not `Service Requests`).
- [ ] Fieldnames use **snake_case** (`customer_name`, `posting_date`).
- [ ] Naming rule (`autoname`) is explicitly chosen (`naming_series:`, `field:<fieldname>`, `prompt`, or `hash`).
- [ ] `Title Field` and `Search Fields` are configured for clean link dropdowns and list views.
- [ ] Frequently filtered fields (`status`, `company`, `customer`, `posting_date`) have `search_index = 1`.

## 2. Document Type Selection
- [ ] **Submittable (`is_submittable = 1`)** is enabled if the document represents an auditable ledger/transaction (`docstatus` 0 → 1 → 2) and includes an `amended_from` Link field.
- [ ] **Child Table (`istable = 1`)** is used for line items owned by a parent document.
- [ ] **Single (`issingle = 1`)** is used for global configuration settings (no `tab<DocType>` table created).
- [ ] **Tree (`is_tree = 1`)** is used for hierarchical master data.

## 3. Controller & Hooks
- [ ] Controller inherits from `frappe.model.document.Document`.
- [ ] Validation logic lives in `validate(self)` or `before_save(self)`.
- [ ] `self.save()` is **never** called inside `validate` or `on_update` without a recursion guard.
- [ ] `frappe.db.commit()` is **not** called manually inside standard controller lifecycle hooks.
- [ ] Core ERPNext DocTypes are extended via `doc_events` or `override_doctype_class` in `hooks.py` — never by editing `apps/erpnext` or `apps/frappe` directly.

## 4. Verification
- [ ] `bench --site <site> migrate` completes cleanly without schema errors.
- [ ] Role permissions are defined for at least `System Manager` and the target business roles.
- [ ] Unit tests exist in `test_<doctype_snake>.py` and pass via `bench --site <site> run-tests --doctype "<DocType>"`.
