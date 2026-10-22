# CLAUDE.md — Frappe & ERPNext Skills Pack Configuration

This document instructs Claude Code on how to build, maintain, and troubleshoot Frappe Framework and ERPNext applications, and how to author comprehensive courses in Arabic.

---

## ⚡ Core Principles for Frappe Development

1. **Schema-as-Data**:
   - DocTypes define database tables. Database tables are prefixed with `tab` (`tabCustomer`).
   - Fields use `snake_case` (`first_name`, `customer_group`).
   - Controllers extend `frappe.model.document.Document`.

2. **Database Access & ORM**:
   - Single doc: `frappe.get_doc(doctype, name)`
   - Fast lookup: `frappe.db.get_value(doctype, filters, fieldname)`
   - Filtered list: `frappe.get_all(doctype, filters={...}, fields=[...])`
   - Parameterized SQL only: `frappe.db.sql("SELECT ... WHERE status=%(status)s", {"status": "Open"}, as_dict=True)`

3. **Security & API**:
   - Whitelist external/client endpoints: `@frappe.whitelist()`
   - Always verify permissions: `frappe.has_permission(doctype, ptype="read")`

4. **Client Scripting (Desk JS)**:
   - Form hooks: `frappe.ui.form.on('<DocType>', { refresh(frm) { ... } })`
   - Async calls: `frappe.call({ method: 'app.api.method', args: {}, callback: (r) => {} })`

---

## 🎓 Arabic Course Authoring (`frappe-course-generator`)

- Narrative and explanations in Modern Standard Arabic (فصحى مبسطة).
- Technical terms, code, DocType names, and bench commands in English.
- Every lesson includes: Objectives, Mental Model, Hands-on Implementation, Exercise, Quiz with answer key, and Capstone Project step.
