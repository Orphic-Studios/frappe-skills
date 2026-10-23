# Using Frappe Skills with OpenAI Codex CLI

`frappe-skills` includes a native `.codex-plugin/plugin.json` manifest and `.agents/plugins/marketplace.json` for OpenAI Codex CLI (v0.122+).

## Setup

### Option 1: Codex Plugin Marketplace (Recommended)

```bash
codex plugin marketplace add Orphic-Studios/frappe-skills
codex plugin add frappe-skills@frappe-skills
```

Codex reads the `skills/` directory directly through `.codex-plugin/plugin.json`. Once installed, invoke skills in chat using `@frappe-docs` or `@frappe-course-generator`.

### Option 2: Skills CLI

```bash
npx skills add Orphic-Studios/frappe-skills --agent codex
```

### Option 3: Project-Level `AGENTS.md`

Codex automatically reads `AGENTS.md` in your workspace root. Copy skills into `.codex/skills/` or `~/.codex/skills/` for local discovery.
