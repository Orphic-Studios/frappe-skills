# Frappe Skills

**Production-grade Frappe Framework & ERPNext skills for AI coding agents.**

[![License: MIT + Commercial](https://img.shields.io/badge/License-MIT%20%2B%20Commercial-blue.svg)](LICENSE)
[![Frappe v15+](https://img.shields.io/badge/Frappe-v15%2B-green.svg)](https://frappe.io)
[![Skills Count](https://img.shields.io/badge/Skills-2-orange.svg)](#skills)
[![Language: Arabic + English](https://img.shields.io/badge/Language-Arabic%20%2B%20English-red.svg)](#skills)

Skills encode the architecture, conventions, APIs, and instructional workflows required to build, customize, debug, and teach the [Frappe](https://frappe.io) and [ERPNext](https://erpnext.com) ecosystem. Packaged so AI agents follow them consistently across every host.

```
  ASK / DESIGN         SCAFFOLD            DEBUG & FIX           TEACH & EXPORT
 ┌────────────┐      ┌────────────┐      ┌────────────┐      ┌────────────────────┐
 │ Architecture│ ───▶ │  DocType   │ ───▶ │ Bench / DB │ ───▶ │ Arabic Curriculum  │
 │ & ERPNext  │      │ Controller │      │   Triage   │      │ PDF / PPTX / ZIP   │
 └────────────┘      └────────────┘      └────────────┘      └────────────────────┘
  /frappe-ask        /frappe-doctype     /frappe-debug          /frappe-course
```

---

## Commands

4 slash commands that map to the Frappe & ERPNext engineering and training lifecycle. Each one activates the right skills automatically.

| What you're doing | Command | Key principle |
|-------------------|---------|---------------|
| Answer questions or implement Frappe/ERPNext features | `/frappe-ask` | Ground every answer in `frappe-docs` references |
| Design and scaffold a new DocType + controller + tests | `/frappe-doctype` | Schema-as-data conventions & upgrade safety |
| Diagnose and resolve Frappe, bench, DB, or worker errors | `/frappe-debug` | Root-cause triage before fixes |
| Generate a structured Arabic training course or tutorial | `/frappe-course` | 5-part lesson blueprint with verified code |

In Claude Code these install as plugin commands (`/frappe-ask`, `/frappe-doctype`, `/frappe-debug`, `/frappe-course`). Skills also activate automatically based on what you are doing — mentioning `DocType`, `frappe.get_doc`, `bench`, or ERPNext modules triggers `frappe-docs`, and asking to generate a course or training material triggers `frappe-course-generator`.

---

## Quick Start

**Fastest path — any agent, one command.** The open [skills CLI](https://github.com/vercel-labs/skills) installs into 70+ agents (Claude Code, Cursor, Codex, Antigravity, Gemini CLI, Copilot, Cline, Hermes, Windsurf, OpenCode, and more):

```bash
npx skills add Orphic-Studios/frappe-skills            # install all skills
npx skills add Orphic-Studios/frappe-skills --list     # browse before installing
```

Or grab individual skills:

```bash
npx skills add Orphic-Studios/frappe-skills --skill frappe-docs              # Frappe & ERPNext knowledge base
npx skills add Orphic-Studios/frappe-skills --skill frappe-course-generator  # Arabic course generator
```

Prefer a native integration? Pick your tool below.

<details>
<summary><b>Claude Code (recommended)</b></summary>

**Marketplace install:**

```
/plugin marketplace add Orphic-Studios/frappe-skills
/plugin install frappe-skills@orphic-frappe-skills
```

> **SSH errors?** The marketplace clones repos via SSH by default. If you don't have SSH keys set up on GitHub, use the full HTTPS URL:
> ```bash
> /plugin marketplace add https://github.com/Orphic-Studios/frappe-skills.git
> /plugin install frappe-skills@orphic-frappe-skills
> ```

**Local / development:**

```bash
git clone https://github.com/Orphic-Studios/frappe-skills.git
claude --plugin-dir /path/to/frappe-skills
```

See [docs/claude-setup.md](docs/claude-setup.md).

</details>

<details>
<summary><b>Cursor</b></summary>

Install directly into `.cursor/skills/`:

```bash
npx skills add Orphic-Studios/frappe-skills --agent cursor
```

Or sync `skills/*` into `.cursor/skills/` in your project. See [docs/cursor-setup.md](docs/cursor-setup.md).

</details>

<details>
<summary><b>Antigravity CLI</b></summary>

Install as a native plugin for skills, commands, and subagent personas. See [docs/antigravity-setup.md](docs/antigravity-setup.md).

**Install from the repo:**

```bash
agy plugin install https://github.com/Orphic-Studios/frappe-skills.git
```

**Install from a local clone:**

```bash
git clone https://github.com/Orphic-Studios/frappe-skills.git
agy plugin install ./frappe-skills
```

</details>

<details>
<summary><b>Gemini CLI</b></summary>

Install as native skills for auto-discovery, or add `GEMINI.md` for persistent context. See [docs/gemini-cli-setup.md](docs/gemini-cli-setup.md).

**Install from the repo:**

```bash
gemini skills install https://github.com/Orphic-Studios/frappe-skills.git --path skills
```

**Install from a local clone:**

```bash
gemini skills install ./frappe-skills/skills/
```

</details>

<details>
<summary><b>Codex</b></summary>

Install as a native Codex plugin (Codex CLI v0.122+):

```bash
codex plugin marketplace add Orphic-Studios/frappe-skills
codex plugin add frappe-skills@frappe-skills
```

Codex reads the `skills/` directory directly through `.codex-plugin/plugin.json`. Once installed, invoke skills in chat using `@` (e.g., `@frappe-docs` or `@frappe-course-generator`). See [docs/codex-setup.md](docs/codex-setup.md).

</details>

<details>
<summary><b>Hermes</b></summary>

Install into `~/.config/hermes/skills/` with the one-command installer or `npx skills`:

```bash
curl -fsSL https://raw.githubusercontent.com/Orphic-Studios/frappe-skills/main/install.sh | bash
```

See [docs/hermes-setup.md](docs/hermes-setup.md).

</details>

<details>
<summary><b>Windsurf</b></summary>

Install skills into `.windsurf/skills/` or `~/.windsurf/skills/`:

```bash
npx skills add Orphic-Studios/frappe-skills --agent windsurf
```

See [docs/windsurf-setup.md](docs/windsurf-setup.md).

</details>

<details>
<summary><b>OpenCode</b></summary>

Copy skills to `.opencode/skills/` (or `~/.config/opencode/skills/`), add a project-local `AGENTS.md`, and use the built-in `skill` tool. See [docs/opencode-setup.md](docs/opencode-setup.md).

</details>

<details>
<summary><b>GitHub Copilot</b></summary>

Use agent definitions from `agents/` as Copilot personas and `.github/copilot-instructions.md` for repository instructions. See [docs/copilot-setup.md](docs/copilot-setup.md) and [docs/copilot-cli-setup.md](docs/copilot-cli-setup.md).

</details>

<details>
<summary><b>Kiro IDE & CLI</b></summary>

Skills for Kiro reside under `.kiro/skills/` (project or global level). Kiro also supports `AGENTS.md`. See `https://kiro.dev/docs/skills/`.

</details>

<details>
<summary><b>Command Code</b></summary>

Install natively with `cmd skills`:

```bash
cmd skills add Orphic-Studios/frappe-skills            # pick skills to install (project)
cmd skills add Orphic-Studios/frappe-skills --global   # install globally (~/.commandcode/skills/)
```

See [docs/commandcode-setup.md](docs/commandcode-setup.md).

</details>

<details>
<summary><b>Other Agents & One-Line Installers</b></summary>

Skills are plain Markdown — they work with any agent that accepts `SKILL.md` or instruction files. See [docs/getting-started.md](docs/getting-started.md) and [docs/other-hosts.md](docs/other-hosts.md).

- **Linux / macOS / WSL**: `curl -fsSL https://raw.githubusercontent.com/Orphic-Studios/frappe-skills/main/install.sh | bash`
- **Windows (PowerShell)**: `irm https://raw.githubusercontent.com/Orphic-Studios/frappe-skills/main/install.ps1 | iex`

</details>

---

## Skills

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [frappe-docs](skills/frappe-docs/SKILL.md) | Comprehensive technical reference covering Frappe Framework (architecture, ORM, DocTypes, hooks, REST/JS APIs, bench CLI), ERPNext modules (Accounts, Stock, Selling, Buying, Manufacturing, HR, Projects), 11+ Frappe apps, and 40+ troubleshooting solutions (18 files · 14,338 lines) | Building, customizing, querying, deploying, or debugging anything in Frappe Framework, ERPNext, or Frappe apps |
| [frappe-course-generator](skills/frappe-course-generator/SKILL.md) | Automated curriculum and course authoring engine producing structured Arabic training courses (with English code) across Developer, User, and Admin tracks with exercises, quizzes, capstone projects, and PDF/PPTX/ZIP export scripts (15 files · 8,366 lines) | Creating a Frappe/ERPNext course, curriculum, workshop, tutorial, bootcamp, or training kit in Arabic |

---

## Agent Personas

Pre-configured specialist personas in [`agents/`](agents/) for targeted reviews and architecture:

| Agent | Role | Perspective |
|-------|------|-------------|
| [frappe-architect](agents/frappe-architect.md) | Senior Solution Architect | Custom app vs. low-code customization, DocType modeling, hooks, and upgrade safety |
| [frappe-reviewer](agents/frappe-reviewer.md) | Frappe Core Code Reviewer | Five-axis audit of ORM usage, parameterized SQL, `@frappe.whitelist()` permissions, and lifecycle hooks |
| [frappe-course-instructor](agents/frappe-course-instructor.md) | Arabic Technical Trainer | Bilingual pedagogical structure, 5-part lesson blueprint, exercises, and technical accuracy |

See [docs/agents.md](docs/agents.md) for how personas compose with skills and slash commands.

---

## Reference Checklists

Quick-reference material in [`references/`](references/) that skills and personas pull in when needed:

| Reference | Covers |
|-----------|--------|
| [doctype-checklist.md](references/doctype-checklist.md) | DocType naming, fieldtypes, indexing, controller lifecycle rules, and migration checks |
| [security-checklist.md](references/security-checklist.md) | Parameterized SQL, `@frappe.whitelist()` permission checks, secret storage, and XSS prevention |
| [course-quality-checklist.md](references/course-quality-checklist.md) | Bilingual formatting, placeholder verification, solution completeness, and `verify_course.py` gates |

---

## License

Dual-licensed:
- **MIT License** for personal, educational, open-source, and small-team use (≤5 users).
- **Commercial License** for enterprise deployment (>5 users), resale, or SaaS integration.

See [LICENSE](LICENSE) for details. Maintainer: [Orphic-Studios](https://github.com/Orphic-Studios).
