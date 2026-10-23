# Using Frappe Skills with Claude Code

`frappe-skills` ships native Claude Code plugin manifests (`.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`) along with slash commands in `.claude/commands/`.

## Option 1: Claude Code Plugin Marketplace (Recommended)

Inside Claude Code, add the marketplace and install the plugin:

```
/plugin marketplace add Orphic-Studios/frappe-skills
/plugin install frappe-skills@orphic-frappe-skills
```

> **SSH errors?** If you don't have SSH keys configured on GitHub, use the full HTTPS URL:
> ```
> /plugin marketplace add https://github.com/Orphic-Studios/frappe-skills.git
> /plugin install frappe-skills@orphic-frappe-skills
> ```

## Option 2: Skills CLI

```bash
npx skills add Orphic-Studios/frappe-skills --agent claude-code
```

## Option 3: Local Plugin Directory

```bash
git clone https://github.com/Orphic-Studios/frappe-skills.git
claude --plugin-dir ./frappe-skills
```

## Available Slash Commands

| Command | Description |
|---|---|
| `/frappe-ask` | Answer technical questions or implement features in Frappe & ERPNext |
| `/frappe-doctype` | Design and scaffold a DocType, controller, client script, hooks, and tests |
| `/frappe-debug` | Diagnose and fix Frappe, ERPNext, bench, MariaDB, or Redis errors |
| `/frappe-course` | Generate a complete Arabic training course or module |
