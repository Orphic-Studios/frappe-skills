# Agent Personas

Pre-configured specialist personas in [`agents/`](../agents/) for targeted architectural design, code review, and curriculum instruction.

## Available Personas

| Persona | File | Role | When to Invoke |
|---|---|---|---|
| **frappe-architect** | [`agents/frappe-architect.md`](../agents/frappe-architect.md) | Senior Frappe & ERPNext Solution Architect | Designing custom apps, choosing between low-code fixtures vs. custom DocTypes, planning hooks and background workers |
| **frappe-reviewer** | [`agents/frappe-reviewer.md`](../agents/frappe-reviewer.md) | Frappe Core Code & Security Reviewer | Auditing PRs, controllers, SQL queries (`frappe.db.sql`), `@frappe.whitelist()` permissions, and lifecycle hooks |
| **frappe-course-instructor** | [`agents/frappe-course-instructor.md`](../agents/frappe-course-instructor.md) | Bilingual (Arabic/English) Technical Trainer | Structuring curricula, writing Arabic lessons, designing exercises/quizzes, and reviewing educational material |

## How Personas Compose with Skills

- **`frappe-architect`** consults `skills/frappe-docs` to ground architectural proposals in Frappe v14/v15+ conventions and `references/doctype-checklist.md`.
- **`frappe-reviewer`** enforces `references/security-checklist.md` and `references/doctype-checklist.md` against proposed changes.
- **`frappe-course-instructor`** orchestrates `skills/frappe-course-generator` and verifies technical accuracy against `skills/frappe-docs`.
