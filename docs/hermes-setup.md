# Using Frappe Skills with Hermes

Hermes natively discovers skills containing `SKILL.md` inside `~/.config/hermes/skills/` (or project `.hermes/skills/`).

## Setup

### Option 1: One-Command Installer

```bash
curl -fsSL https://raw.githubusercontent.com/Orphic-Studios/frappe-skills/main/install.sh | bash
```

### Option 2: Skills CLI

```bash
npx skills add Orphic-Studios/frappe-skills
```

### Option 3: Manual Copy

```bash
git clone https://github.com/Orphic-Studios/frappe-skills.git
mkdir -p ~/.config/hermes/skills/
cp -R frappe-skills/skills/* ~/.config/hermes/skills/
```
