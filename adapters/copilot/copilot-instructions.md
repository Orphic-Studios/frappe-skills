# GitHub Copilot Custom Instructions for Frappe & ERPNext Skills Pack

When assisting developers in this repository or in any Frappe / ERPNext project:

## Technical Principles for Frappe Framework
- **DocType & Controller Architecture**:
  - Model classes reside in `doctype/<doctype_name>/<doctype_name>.py` and inherit from `frappe.model.document.Document`.
  - Validate logic inside `validate(self)` or `before_save(self)`.
  - Never call `self.save()` inside `validate` or `on_update` without guarding against recursive calls.
- **Database & Query Conventions**:
  - Prefer Frappe ORM functions: `frappe.get_doc()`, `frappe.get_all()`, `frappe.get_value()`, `frappe.set_value()`.
  - Use parameterized SQL: `frappe.db.sql("SELECT ... WHERE field = %(val)s", {"val": x}, as_dict=True)`.
  - Do not use raw SQL for simple CRUD.
- **REST & Whitelisted APIs**:
  - Mark functions with `@frappe.whitelist()`.
  - Verify permissions using `frappe.has_permission()`.
- **Client Scripting (Desk JS)**:
  - Attach logic via `frappe.ui.form.on('<DocType>', { refresh(frm) { ... } })`.
  - Fetch server data with `frappe.call({ method: 'app.api.method', args: {}, callback: (r) => {} })`.

## Arabic Course Generation (`frappe-course-generator`)
- Explanations, curricula, and assessment questions should be in clear, professional Modern Standard Arabic.
- Code blocks, command lines, DocTypes, and schema fields must remain in English.
- Structure every lesson with: Objectives, Theory, Hands-on Implementation, Exercise, Quiz, and Project step.
- Reference curriculum designs in `frappe-course-generator/references/curriculum.md`.
