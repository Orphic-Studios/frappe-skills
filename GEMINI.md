# GEMINI.md — Frappe & ERPNext Skills Pack Configuration for Gemini & Antigravity

This file provides system-level instructions and conventions for **Gemini models**, **Google Antigravity**, and **Gemini Code Assist** when working with this repository.

---

## 🎯 Role & Capabilities

You have access to the complete **Frappe Skills Pack**:
- **`frappe-docs`**: The authoritative technical knowledge base for Frappe Framework v14/v15+, ERPNext modules, ecosystem apps, REST APIs, bench CLI, and troubleshooting.
- **`frappe-course-generator`**: The curriculum engine designed to scaffold, author, and export complete, publication-grade Frappe and ERPNext courses in Arabic.

---

## ⚡ Core Rules & Best Practices for Frappe Development

1. **Strict ORM Usage**:
   - Always prioritize `frappe.get_doc`, `frappe.get_all`, `frappe.db.get_value` over raw SQL.
   - For queries with filters: `frappe.get_all('Customer', filters={'disabled': 0}, fields=['name', 'customer_name'])`.
   - Never write raw SQL without parameterized placeholders: `frappe.db.sql("""SELECT name FROM `tabItem` WHERE item_group=%(group)s""", {"group": item_group})`.

2. **Security & Permissions**:
   - All client-callable methods must have the `@frappe.whitelist()` decorator.
   - For write operations, always verify authorization: `frappe.has_permission('DocType', 'write', throw=True)`.
   - Respect user permissions using `frappe.get_list` (which enforces permissions) rather than `frappe.get_all` (which bypasses them unless specified).

3. **DocType Definition & Lifecycle**:
   - Follow standard naming: TitleCase singular (`Sales Invoice`, `Custom Field`).
   - Hooks: Hook into document lifecycle events (`validate`, `before_save`, `on_submit`, `on_cancel`) in `hooks.py` or the document controller class.
   - Avoid recursive saves in hooks: do not call `self.save()` inside `validate` or `on_update` without flags.

4. **Client-Side Scripting**:
   - Write client scripts using `frappe.ui.form.on('<DocType>', { refresh(frm) { ... } })`.
   - Keep business logic on the server; client scripts should focus on UI state, dynamic filtering, and user experience.

---

## 📖 Knowledge Base Router

When the user queries any Frappe/ERPNext topic, consult the corresponding reference:

- **Framework Architecture**: `frappe-docs/references/framework/architecture.md`
- **Bench CLI**: `frappe-docs/references/framework/bench-cli.md`
- **DocType Design**: `frappe-docs/references/framework/doctype-guide.md`
- **Python API**: `frappe-docs/references/framework/python-api.md`
- **REST API**: `frappe-docs/references/framework/rest-api.md`
- **Client Scripting**: `frappe-docs/references/framework/scripting.md`
- **Deployment & Web Views**: `frappe-docs/references/framework/webviews-deployment.md`
- **Troubleshooting (40+ Error Solutions)**: `frappe-docs/references/troubleshooting.md`
- **ERPNext Modules**: `frappe-docs/references/erpnext/`
- **Ecosystem Apps**: `frappe-docs/references/apps/ecosystem.md`

---

## 🎓 Arabic Course Generation Engine

When the user asks to build or generate a training course ("أنشئ دورة", "كورس Frappe", "محتوى تعليمي"):
- Read curriculum guidelines from `frappe-course-generator/references/curriculum.md`.
- Read lesson blueprints from `frappe-course-generator/references/lesson-blueprints.md`.
- Use Arabic for explanation and pedagogy; keep code, bench commands, and DocType identifiers in English.
- Provide practical exercises, quizzes with full answer keys, and a capstone project.
- Leverage the automation scripts in `frappe-course-generator/scripts/` (`scaffold_course.py`, `build_course.py`, `verify_course.py`).
