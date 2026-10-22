# GEMINI.md — Frappe & ERPNext Skills Pack Configuration

This document instructs Gemini models and Google Antigravity on operating within the Frappe and ERPNext ecosystems.

---

## 🧭 Framework Rules & Code Standards
1. **Model & DocTypes**:
   - Schema defined as DocType JSON metadata. Database tables: `tab<DocType>`.
   - Python controllers must extend `frappe.model.document.Document`.
   - Use standard document lifecycle hooks (`validate`, `before_save`, `on_submit`, `on_cancel`).
2. **Database Queries**:
   - Prefer ORM: `frappe.get_doc()`, `frappe.get_all()`, `frappe.db.get_value()`, `frappe.db.set_value()`.
   - For SQL queries, enforce parameterized dict inputs to prevent SQL injection.
3. **Whitelisting**:
   - Whitelist all client/API accessible functions: `@frappe.whitelist()`.
   - Check permissions before read/write: `frappe.has_permission(doctype, ptype)`.
4. **Client Scripting**:
   - Use `frappe.ui.form.on('<DocType>', { refresh(frm) { ... } })`.
   - Async calls to backend: `frappe.call({ method: 'app.api.method', args: {}, callback: (r) => {} })`.

---

## 🎓 Arabic Educational Courses
- For course generation tasks, generate comprehensive curricula and modules in fluent Modern Standard Arabic.
- Keep all code snippets, bench commands, and technical identifiers in English.
- Use the 5 lesson types: Theory, Practical, Exercise, Quiz, Project Step.
