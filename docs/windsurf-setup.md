# Using Frappe Skills with Windsurf

Windsurf supports both Agent Skills (`.windsurf/skills/`) and Cascade rules (`.windsurf/rules/` or `.windsurfrules`).

## Setup

### Option 1: Skills CLI (Recommended)

```bash
npx skills add Orphic-Studios/frappe-skills --agent windsurf
```

### Option 2: Manual Copy

```bash
git clone https://github.com/Orphic-Studios/frappe-skills.git
mkdir -p .windsurf/skills
cp -R frappe-skills/skills/* .windsurf/skills/
```
