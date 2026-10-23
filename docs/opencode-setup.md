# Using Frappe Skills with OpenCode

OpenCode discovers skills under `.opencode/skills/` (project) or `~/.config/opencode/skills/` (global) alongside `AGENTS.md`.

## Setup

### Option 1: Skills CLI

```bash
npx skills add Orphic-Studios/frappe-skills --agent opencode
```

### Option 2: Manual Setup

```bash
git clone https://github.com/Orphic-Studios/frappe-skills.git
mkdir -p ~/.config/opencode/skills
cp -R frappe-skills/skills/* ~/.config/opencode/skills/
```
