---
description: Answer technical questions or implement features in Frappe Framework and ERPNext using authoritative references.
---

Invoke the `frappe-skills:frappe-docs` skill to ground your response in the authoritative Frappe & ERPNext reference files.

## Process

1. Identify the target domain from `$ARGUMENTS` (Framework Architecture, Python API, DocType, Client Scripting, REST API, Bench CLI, ERPNext module, or Ecosystem app).
2. Read the corresponding reference file in `skills/frappe-docs/references/` before writing code or answering deep architectural questions.
3. Follow Frappe conventions strictly:
   - Singular TitleCase DocType names (`Sales Invoice`), `tab`-prefixed database tables (`tabSales Invoice`), and `snake_case` fieldnames.
   - Prefer `frappe.get_doc`, `frappe.get_all`, and `frappe.db.get_value` over raw SQL; when raw SQL is required, always use parameterized queries (`%(param)s`).
   - Decorate client-callable endpoints with `@frappe.whitelist()` and verify permissions via `frappe.has_permission()`.
4. Provide complete, runnable code examples and cite the relevant Frappe documentation or reference file.
