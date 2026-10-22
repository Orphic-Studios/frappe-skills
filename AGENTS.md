# AGENTS.md — Universal AI Agent Guidelines for Frappe Skills Pack

This document specifies instructions, context, and operational guidelines for autonomous and semi-autonomous AI coding agents (OpenAI Codex, Hermes, Claude, Gemini, Cursor, Windsurf, Cline, Roo Code, Aider, Open Interpreter).

---

## 🎯 Repository Overview

This repository is a production-grade dual skill pack for the **Frappe Framework** and **ERPNext** ecosystem:
- **`frappe-docs`**: Complete technical knowledge base (architecture, DocTypes, Python API, REST API, Client Scripts, bench commands, ecosystem apps, ERPNext business domains, and troubleshooting).
- **`frappe-course-generator`**: An engine that authors comprehensive, pedagogical Frappe & ERPNext training courses in Arabic with bilingual code.

---

## 🧭 Behavioral Directives

1. **Precision & Conventions**:
   - Frappe is strictly convention-over-configuration. Use singular DocType names (`Customer`, `Stock Entry`).
   - Tables in the database are prefixed with `tab` (e.g. `tabCustomer`).
   - Standard field names use snake_case (`customer_name`, `posting_date`).
   - Controllers extend `frappe.model.document.Document`.

2. **Database Queries**:
   - Never use unsanitized string formatting in database queries.
   - Standard: `frappe.db.get_value(doctype, filters, fieldname)`
   - Multi-record: `frappe.get_all(doctype, filters=..., fields=..., order_by=...)`
   - Complex SQL: `frappe.db.sql("""... WHERE field = %(param)s""", {"param": value}, as_dict=True)`

3. **API & Endpoints**:
   - Whitelist functions meant to be accessed via REST or client calls using `@frappe.whitelist()`.
   - Explicitly verify read/write permissions via `frappe.has_permission()`.

4. **Arabic Course Generation**:
   - When generating courses, maintain high linguistic quality in Arabic (Modern Standard Arabic / فصحى مبسطة).
   - Code blocks, command line prompts, DocType names, and JSON fields must remain in English.
   - Always include interactive hands-on exercises, real-world scenarios, and evaluation quizzes.

---

## 📂 Navigation & References Map

- `frappe-docs/SKILL.md`: Main entrypoint and router for documentation.
- `frappe-docs/references/framework/`: Core Frappe Framework documentation (architecture, bench CLI, DocTypes, Python API, REST API, scripting, web views).
- `frappe-docs/references/erpnext/`: ERPNext module documentation (accounts, stock, selling, buying, manufacturing, HR, customization).
- `frappe-docs/references/apps/`: Ecosystem apps (Frappe HR, CRM, Helpdesk, Builder, Insights, etc.).
- `frappe-docs/references/troubleshooting.md`: 40+ common Frappe errors and concrete resolutions.
- `frappe-course-generator/SKILL.md`: Course creation orchestrator.
- `frappe-course-generator/references/curriculum.md`: Track curricula (Developer, User, Admin).
- `frappe-course-generator/references/lesson-blueprints.md`: Structural templates for lessons.
- `frappe-course-generator/scripts/`: Automation scripts (`scaffold_course.py`, `build_course.py`, `verify_course.py`).
