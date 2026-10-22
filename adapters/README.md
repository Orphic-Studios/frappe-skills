# AI Agent Adapters & Integration Hub

This directory contains tailored adapters, configuration files, and system prompts to make the **Frappe Skills Pack** run seamlessly with any AI coding agent and LLM platform.

---

## 🧭 Compatibility Overview

| Agent / Ecosystem | Target Environment | Key Files | Integration Type |
|---|---|---|---|
| **Hermes** | Nous Hermes / Local Agent | [`adapters/hermes/`](file:///adapters/hermes/) | Standard Skill (`SKILL.md`) + Config |
| **Claude** | Claude Code, Projects, Desktop | [`adapters/claude/`](file:///adapters/claude/) | `CLAUDE.md`, Project System Prompt, MCP Config |
| **Gemini & Antigravity** | Google Antigravity, Gemini Code Assist | [`adapters/gemini-antigravity/`](file:///adapters/gemini-antigravity/) | `GEMINI.md`, Antigravity Plugin, System Instruction |
| **OpenAI Codex & ChatGPT** | ChatGPT Custom GPTs, Assistants API | [`adapters/codex-openai/`](file:///adapters/codex-openai/) | Custom GPT Instructions, Assistant Prompt |
| **Cursor** | Cursor AI IDE | [`adapters/cursor/`](file:///adapters/cursor/) | `.cursorrules`, `.cursor/rules/*.mdc` |
| **Windsurf** | Codeium Windsurf Cascade | [`adapters/windsurf/`](file:///adapters/windsurf/) | `.windsurfrules` |
| **GitHub Copilot** | VS Code, JetBrains, GitHub.com | [`adapters/copilot/`](file:///adapters/copilot/) | `copilot-instructions.md` |
| **Cline & Roo Code** | VS Code Extensions | [`adapters/cline/`](file:///adapters/cline/) | `.clinerules`, `.roomodes` |

---

## 🚀 Quick Setup per Agent

### 1. Hermes
```bash
# Symlink or copy to Hermes skills folder
mkdir -p ~/.config/hermes/skills/
cp -r frappe-docs frappe-course-generator ~/.config/hermes/skills/
```

### 2. Claude Code
```bash
# Add to Claude Code skills
mkdir -p ~/.claude/skills/
cp -r frappe-docs frappe-course-generator ~/.claude/skills/

# Or copy root CLAUDE.md to your project
cp CLAUDE.md /path/to/your/frappe-bench/CLAUDE.md
```

### 3. Google Antigravity / Gemini
```bash
# Place inside Antigravity skills
mkdir -p ~/.gemini/antigravity/skills/
cp -r frappe-docs frappe-course-generator ~/.gemini/antigravity/skills/
```

### 4. OpenAI / ChatGPT Custom GPT
- Open [ChatGPT GPT Builder](https://chatgpt.com/gpts/editor).
- Copy the contents of [`adapters/codex-openai/CUSTOM_GPT_INSTRUCTIONS.md`](file:///adapters/codex-openai/CUSTOM_GPT_INSTRUCTIONS.md) into the **Instructions** box.
- Upload `frappe-docs/references/` as Knowledge files.

### 5. Cursor
- Place `.cursorrules` in your project root, or copy rules to `.cursor/rules/`:
```bash
mkdir -p .cursor/rules
cp adapters/cursor/*.mdc .cursor/rules/
```

### 6. Windsurf
```bash
cp adapters/windsurf/.windsurfrules /path/to/your/project/.windsurfrules
```
