# CLAUDE.md — Frappe & ERPNext Skills Pack Configuration

Welcome to the **Frappe Skills Pack** for Claude Code and Anthropic AI models. This repository contains two core production-ready skills:
1. `frappe-docs`: Comprehensive technical documentation, APIs, hooks, DocType architecture, bench commands, and troubleshooting for Frappe Framework & ERPNext.
2. `frappe-course-generator`: An automated curriculum and course production engine generating complete Arabic training materials with bilingual code snippets.

---

## 🧭 Core Architectural Guidelines

### Frappe Framework Mental Model
- **Schema-as-Data**: DocTypes describe DB tables (`tabDocType`). Adding fields is metadata-driven; avoid raw DDL unless writing migrations.
- **ORM & DB Access**:
  - Always prefer `frappe.get_doc()`, `frappe.new_doc()`, `frappe.get_all()`, or `frappe.db.get_value()` over raw SQL.
  - When raw SQL is required: ALWAYS use parameterized queries `frappe.db.sql("""SELECT ... FROM `tab...` WHERE status = %(status)s""", {"status": "Open"}, as_dict=True)`.
  - Never concatenate user input into SQL queries.
  - Whitelisted endpoints: Must be decorated with `@frappe.whitelist()`. Validate user permissions with `frappe.has_permission()`.
- **Client-Side Conventions**:
  - Use `frappe.ui.form.on('DocType', { ... })` for form scripting.
  - Asynchronous calls: `frappe.call({ method: 'app.api.method', args: {}, callback: (r) => { ... } })`.
- **Hooks & Events**:
  - Register doc events, overrides, fixtures, scheduled jobs, and web views inside `hooks.py`.
  - Avoid infinite recursion in doc hooks (e.g. calling `doc.save()` inside `on_update` without flags).

---

## 📚 Skill Reference Mapping

When answering questions or generating code, consult the following local references:

| Domain | Reference Path |
|---|---|
| **Architecture & Lifecycle** | [frappe-docs/references/framework/architecture.md](file:///frappe-docs/references/framework/architecture.md) |
| **Python API & ORM** | [frappe-docs/references/framework/python-api.md](file:///frappe-docs/references/framework/python-api.md) |
| **DocType Definition & Schemas** | [frappe-docs/references/framework/doctype-guide.md](file:///frappe-docs/references/framework/doctype-guide.md) |
| **Bench CLI Commands** | [frappe-docs/references/framework/bench-cli.md](file:///frappe-docs/references/framework/bench-cli.md) |
| **REST API** | [frappe-docs/references/framework/rest-api.md](file:///frappe-docs/references/framework/rest-api.md) |
| **Client Scripting & JS API** | [frappe-docs/references/framework/scripting.md](file:///frappe-docs/references/framework/scripting.md) |
| **Webviews & Deployment** | [frappe-docs/references/framework/webviews-deployment.md](file:///frappe-docs/references/framework/webviews-deployment.md) |
| **Troubleshooting & Fixes** | [frappe-docs/references/troubleshooting.md](file:///frappe-docs/references/troubleshooting.md) |
| **ERPNext Modules (Accounts, Stock, etc.)** | [frappe-docs/references/erpnext/](file:///frappe-docs/references/erpnext/) |
| **Ecosystem Apps (HR, CRM, Helpdesk, etc.)** | [frappe-docs/references/apps/ecosystem.md](file:///frappe-docs/references/apps/ecosystem.md) |

---

## 🎓 Course Generator Workflow (`frappe-course-generator`)

When asked to create a training course, curriculum, workshop, or educational tutorial on Frappe / ERPNext:
1. **Target Language**: Arabic for explanatory text and pedagogical narrative; English for code, DocType names, bench commands, and field identifiers.
2. **Pedagogical Structure**: Follow the 5 lesson archetypes defined in `frappe-course-generator/references/lesson-blueprints.md`:
   - `theory`: Conceptual foundations with ASCII diagrams and architecture breakdowns.
   - `practical`: Step-by-step hands-on implementation guide.
   - `exercise`: Problem statement, hints, starter code, and test scenarios.
   - `quiz`: Multiple-choice and short-answer questions with detailed answer keys.
   - `project-step`: Progressive integration into the Capstone project.
3. **Execution Scripts**:
   - `frappe-course-generator/scripts/scaffold_course.py`: Scaffolds the standard directory hierarchy.
   - `frappe-course-generator/scripts/build_course.py`: Compiles Markdown, generates TOC, and builds PDF/ZIP bundles.
   - `frappe-course-generator/scripts/verify_course.py`: Runs structural and quality assertions.

---

## 🛠️ Preferred Commands & Development Checks

```bash
# Validate skill frontmatter and JSON manifest
python -m py_compile frappe-course-generator/scripts/*.py

# Run quality checks
bash install.sh --verify
```
