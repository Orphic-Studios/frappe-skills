# AGENTS.md — Frappe Skills Pack

This repository provides production-grade skills, slash commands, and specialist personas for AI coding agents working with **Frappe Framework** and **ERPNext**.

## Repository Map

- `skills/frappe-docs/SKILL.md` — Deep technical reference for Frappe Framework, ERPNext modules, ecosystem apps, APIs, bench CLI, and troubleshooting.
- `skills/frappe-course-generator/SKILL.md` — Automated curriculum and lesson engine producing structured Arabic training courses with English code.
- `agents/` — Specialist personas (`frappe-architect`, `frappe-reviewer`, `frappe-course-instructor`).
- `references/` — Quick-reference checklists (`doctype-checklist.md`, `security-checklist.md`, `course-quality-checklist.md`).
- `commands/`, `.claude/commands/`, `.gemini/commands/` — Slash commands (`/frappe-ask`, `/frappe-doctype`, `/frappe-debug`, `/frappe-course`).

## Core Operating Rules

1. **Ground Frappe Decisions in `skills/frappe-docs`**:
   - DocTypes are singular TitleCase (`Sales Invoice`), database tables are prefixed with `tab` (`tabSales Invoice`), and fieldnames use `snake_case`.
   - Prefer `frappe.get_doc`, `frappe.get_all`, and `frappe.db.get_value` over raw SQL; always use parameterized queries (`%(param)s`) when calling `frappe.db.sql`.
   - Decorate client-callable methods with `@frappe.whitelist()` and validate permissions via `frappe.has_permission()`.
   - Never modify `apps/frappe` or `apps/erpnext` directly; use custom app hooks (`doc_events`, `override_doctype_class`, `fixtures`).

2. **Arabic Course Generation (`skills/frappe-course-generator`)**:
   - Load `frappe-docs` alongside `frappe-course-generator`.
   - Write explanatory text, exercises, and quizzes in clear Modern Standard Arabic; keep code blocks, `bench` commands, and DocType identifiers in English.

3. **Repository Maintenance**:
   - Run `node scripts/validate-skills.js`, `node scripts/validate-versions.js`, and `node scripts/validate-commands.js` before committing changes to this repository.
