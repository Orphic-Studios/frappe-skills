# Using Frappe Skills with Gemini CLI

Install `frappe-skills` as native skills in Gemini CLI for automatic discovery, or use the TOML slash commands in `.gemini/commands/`.

## Setup

### Install from GitHub

```bash
gemini skills install https://github.com/Orphic-Studios/frappe-skills.git --path skills
```

### Install from a Local Clone

```bash
git clone https://github.com/Orphic-Studios/frappe-skills.git
gemini skills install ./frappe-skills/skills/
```

### Via Skills CLI

```bash
npx skills add Orphic-Studios/frappe-skills --agent gemini-cli
```

## Slash Commands (`.gemini/commands/`)

When `.gemini/commands/` is present in your workspace or `~/.gemini/commands/`, Gemini CLI exposes:
- `/frappe-ask`
- `/frappe-doctype`
- `/frappe-debug`
- `/frappe-course`
