# Getting Started with Frappe Skills Pack

The **Frappe Skills Pack** ships two complementary skills inside [`skills/`](../skills/):

1. **[`frappe-docs`](../skills/frappe-docs/SKILL.md)** — Deep technical knowledge base covering Frappe Framework (v14/v15+), ERPNext modules, Frappe ecosystem apps, REST/Python/JS APIs, bench CLI, and troubleshooting.
2. **[`frappe-course-generator`](../skills/frappe-course-generator/SKILL.md)** — Automated instructional engine that produces complete Arabic training courses with English code, exercises, quizzes, and PDF/PPTX/ZIP exports.

---

## Fastest Install (Any Agent)

Use the open [skills CLI](https://github.com/vercel-labs/skills) to install into 70+ supported agents (Claude Code, Cursor, Codex, Antigravity, Gemini CLI, Copilot, Cline, Hermes, Windsurf, OpenCode):

```bash
npx skills add Orphic-Studios/frappe-skills            # install both skills
npx skills add Orphic-Studios/frappe-skills --list     # preview skills before installing
npx skills add Orphic-Studios/frappe-skills -g --all   # install globally for all detected agents
```

---

## Native Agent Integrations

Pick your primary tool for native plugin/skill setup:

- **[Claude Code](claude-setup.md)** — Plugin marketplace install (`/plugin marketplace add Orphic-Studios/frappe-skills`) + slash commands
- **[Cursor](cursor-setup.md)** — `.cursor/skills/` + `.cursor/rules/*.mdc`
- **[Antigravity CLI (`agy`)](antigravity-setup.md)** — `agy plugin install https://github.com/Orphic-Studios/frappe-skills.git`
- **[Gemini CLI](gemini-cli-setup.md)** — `gemini skills install https://github.com/Orphic-Studios/frappe-skills.git --path skills`
- **[OpenAI Codex CLI](codex-setup.md)** — `codex plugin marketplace add Orphic-Studios/frappe-skills`
- **[Hermes](hermes-setup.md)** — `~/.config/hermes/skills/`
- **[Windsurf](windsurf-setup.md)** — `.windsurf/rules/` & `.windsurfrules`
- **[OpenCode](opencode-setup.md)** — `.opencode/skills/` & `AGENTS.md`
- **[GitHub Copilot](copilot-setup.md)** & **[Copilot CLI](copilot-cli-setup.md)** — `.github/copilot-instructions.md` & personas
- **[Command Code](commandcode-setup.md)** — `cmd skills add Orphic-Studios/frappe-skills`
- **[Other Hosts](other-hosts.md)** — Cline, Roo Code, Kiro, Dojo, Pi, and generic Markdown agents
