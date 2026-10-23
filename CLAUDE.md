# frappe-skills

This is the **Frappe Skills Pack** repository — production-grade Frappe Framework & ERPNext skills, commands, and specialist personas for AI coding agents.

> **Scope:** This file configures agents working on the [`Orphic-Studios/frappe-skills`](https://github.com/Orphic-Studios/frappe-skills) repository itself or using it as a plugin. The reusable skill assets live in `skills/`.

## Project Structure

```
skills/            → Core skills (SKILL.md per directory)
agents/            → Reusable agent personas (frappe-architect, frappe-reviewer, frappe-course-instructor)
.claude/commands/  → Claude Code slash commands (/frappe-ask, /frappe-doctype, /frappe-debug, /frappe-course)
.gemini/commands/  → Gemini CLI slash commands (.toml)
commands/          → Antigravity CLI slash commands (.toml)
references/        → Supplementary checklists (doctype, security, course-quality)
scripts/           → Repository validation scripts (validate-skills.js, validate-versions.js, validate-commands.js)
docs/              → Setup guides for every supported agent host
```

## Skills

- **[`frappe-docs`](skills/frappe-docs/SKILL.md)** — Authoritative technical reference covering Frappe Framework (architecture, ORM, DocTypes, hooks, REST/JS APIs, bench CLI), ERPNext modules, ecosystem apps, and 40+ troubleshooting guides.
- **[`frappe-course-generator`](skills/frappe-course-generator/SKILL.md)** — Automated curriculum and lesson authoring engine that generates complete Arabic training courses with English code, exercises, quizzes, and PDF/PPTX/ZIP packaging.

## Conventions

- Every skill lives in `skills/<name>/SKILL.md` with valid YAML frontmatter (`name` and `description` <= 1024 chars).
- All plugin manifests (`plugin.json`, `skills.json`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`) must share the exact same version and be saved as UTF-8 without BOM.
- Slash commands across `.claude/commands/`, `.gemini/commands/`, and `commands/` must stay in sync.

## Validation Commands

- `node scripts/validate-skills.js` — Validate all skills in `skills/` and personas in `agents/`
- `node scripts/validate-versions.js` — Verify version sync and UTF-8 (no BOM) across all 6 plugin manifests
- `node scripts/validate-commands.js` — Verify slash command parity across Claude, Gemini, and Antigravity
