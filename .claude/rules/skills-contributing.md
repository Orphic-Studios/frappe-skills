---
description: Guardrails for adding or updating skills in frappe-skills
paths:
  - "skills/**"
---

# Adding or updating a skill

Before creating a new `skills/<name>/` directory or modifying an existing skill:

- Follow the conventions in [docs/ANATOMY.md](../../docs/ANATOMY.md) and [CONTRIBUTING.md](../../CONTRIBUTING.md).
- Every skill must have valid YAML frontmatter with `name` (matching the directory name) and `description` (<= 1024 characters).
- Keep `frappe-docs` as the single source of truth for technical accuracy; other skills like `frappe-course-generator` reference `frappe-docs` rather than duplicating technical reference material.
- Run `node scripts/validate-skills.js` and `node scripts/validate-versions.js` before committing.
