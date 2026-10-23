# Using Frappe Skills with Cursor

Cursor supports native Agent Skills under `.cursor/skills/` (project) or `~/.cursor/skills/` (global), alongside short `.cursor/rules/*.mdc` rules.

## Setup

### Option 1: Skills CLI (Recommended)

```bash
npx skills add Orphic-Studios/frappe-skills --agent cursor
```

### Option 2: Manual Sync

```bash
git clone https://github.com/Orphic-Studios/frappe-skills.git
mkdir -p .cursor/skills
cp -R frappe-skills/skills/* .cursor/skills/
```

Once placed in `.cursor/skills/`, Cursor automatically discovers `frappe-docs` and `frappe-course-generator` via their `SKILL.md` frontmatter descriptions.
