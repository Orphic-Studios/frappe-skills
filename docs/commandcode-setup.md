# Using Frappe Skills with Command Code

Command Code natively discovers `SKILL.md` files inside `skills/` using `cmd skills`:

```bash
cmd skills add Orphic-Studios/frappe-skills            # pick skills to install (project)
cmd skills add Orphic-Studios/frappe-skills --global   # install globally (~/.commandcode/skills/)
cmd skills add Orphic-Studios/frappe-skills -s frappe-docs
```

Installed skills appear in the TUI slash menu (`/frappe-docs`, `/frappe-course-generator`).
