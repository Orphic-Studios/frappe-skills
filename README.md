# Frappe Skills Pack — Multi-Agent AI Knowledge & Course Generator

[![License: MIT + Commercial](https://img.shields.io/badge/License-MIT%20%2B%20Commercial-blue.svg)](LICENSE)
[![Frappe v15+](https://img.shields.io/badge/Frappe-v15%2B-green.svg)](https://frappe.io)
[![Skills Count](https://img.shields.io/badge/Skills-2-orange.svg)](#skills)
[![Language: Arabic + English](https://img.shields.io/badge/Language-Arabic%20%2B%20English-red.svg)](#languages)
[![Multi-Agent Ready](https://img.shields.io/badge/Agents-Hermes%20%7C%20Claude%20%7C%20Gemini%20%7C%20Codex%20%7C%20Cursor-purple.svg)](#agent-compatibility-matrix)

A production-ready dual AI skill pack and multi-agent knowledge suite for the [Frappe](https://frappe.io) and [ERPNext](https://erpnext.com) ecosystems. Natively compatible with all major AI coding agents: **Hermes**, **Anthropic Claude**, **Google Gemini & Antigravity**, **OpenAI Codex & ChatGPT**, **Cursor**, **Windsurf**, **GitHub Copilot**, and **Cline / Roo Code**.

> **Two Skills, Universal Compatibility**:
> 1. `frappe-docs`: Deep technical reference covering the entire Frappe Framework and ERPNext ecosystem.
> 2. `frappe-course-generator`: An automated instructional engine that produces structured, production-grade training courses in Arabic with bilingual code.

---

## 🤖 Agent Compatibility Matrix

| AI Agent / Environment | Format & Rules | Setup Directory | Status |
|---|---|---|---|
| **Hermes** | `SKILL.md` Standard | `~/.config/hermes/skills/` | ✅ Native |
| **Claude Code** | `CLAUDE.md` + Skills | `~/.claude/skills/` or root `CLAUDE.md` | ✅ Native |
| **Claude Projects & Desktop** | System Prompt + MCP | [`adapters/claude/`](./adapters/claude/) | ✅ Supported |
| **Google Gemini & Antigravity** | `GEMINI.md` + Skills | `~/.gemini/antigravity/skills/` | ✅ Native |
| **OpenAI Codex & ChatGPT** | Custom GPT & Assistants | [`adapters/codex-openai/`](./adapters/codex-openai/) | ✅ Supported |
| **Cursor AI** | `.cursorrules` + `.mdc` | Root `.cursorrules` or `.cursor/rules/` | ✅ Native |
| **Windsurf (Cascade)** | `.windsurfrules` | Root `.windsurfrules` | ✅ Native |
| **GitHub Copilot** | Copilot Instructions | `.github/copilot-instructions.md` | ✅ Native |
| **Cline & Roo Code** | `.clinerules` + `.roomodes` | Root `.clinerules` / `.roomodes` | ✅ Native |
| **Universal Agents** | `AGENTS.md` standard | Root `AGENTS.md` | ✅ Native |

---

## 📦 What's Included

### 1. `frappe-docs` (Technical Knowledge Base)
- **Frappe Framework**: Architecture, Python ORM, DocType metadata system, hooks, bench CLI, REST APIs, client scripting, web views, security, and deployment.
- **ERPNext Modules**: Accounts, Stock, Selling, Buying, Manufacturing, HR, Projects, Payroll, and Customization.
- **Ecosystem Apps**: Frappe HR, CRM, Cloud, Builder, Insights, Print Designer, Wiki, Drive, Learning, Helpdesk, Lending.
- **Troubleshooting**: 40+ common production errors with root causes and verified fixes.
- **Specs**: 18 files · 14,338 lines · 181 KB · English

### 2. `frappe-course-generator` (Instructional Engine)
- **3 Tracks**: Developer (12 modules), User (10 modules), Admin (8 modules).
- **5 Lesson Types**: Theory, Practical, Hands-on Exercise, Quiz with answer key, and Progressive Capstone Project step.
- **Delivery Formats**: Markdown, PDF (with Arabic reshaping & RTL support), PPTX, ZIP.
- **Quality Verification**: Automated verification scripts for structure, completeness, and link integrity.
- **Specs**: 15 files · 8,366 lines · 112 KB · Arabic explanations with English code

---

## 🚀 Quick Installation

### Method 1: Skills CLI (Recommended for Hermes, Claude Code, Cursor, Antigravity)
`ash
# Add both skills to your active agent:
npx skills add Orphic-Studios/frappe-skills

# Or install globally across all agents without prompts:
npx skills add Orphic-Studios/frappe-skills -g --all
`

### Method 2: Linux / macOS / WSL (One-Command Auto-Installer)
`ash
curl -fsSL https://raw.githubusercontent.com/Orphic-Studios/frappe-skills/main/install.sh | bash
`
*Auto-detects all installed agents (Hermes, Claude, Antigravity, Cursor, Windsurf, Cline) and installs both skills.*

### Method 3: Windows (PowerShell One-Command)
`powershell
irm https://raw.githubusercontent.com/Orphic-Studios/frappe-skills/main/install.ps1 | iex
`

### Method 4: Cross-Platform (Python / Manual)
`ash
git clone https://github.com/Orphic-Studios/frappe-skills.git
cd frappe-skills
python install.py
`

---

## 🎯 Usage by Agent

### 1. Claude Code
Open your Frappe project or bench directory and run:
```bash
claude
```
Claude Code automatically picks up `CLAUDE.md`. Ask:
> *"Explain how doc events in hooks.py interact with DocType controllers."*

### 2. Google Antigravity & Gemini
Install to `~/.gemini/antigravity/skills/` and ask in Antigravity:
> *"كيف أنشئ DocType جديد في Frappe Framework مع إضافة حقول برمجية؟"*

### 3. Hermes
```bash
hermes "أنشئ دورة تدريبية على Frappe للمطورين تتكون من 10 دروس مع مشروع CRM"
```

### 4. Cursor / Windsurf
Open this repository in Cursor or Windsurf. The embedded `.cursorrules` or `.windsurfrules` will automatically guide code suggestions, DocType generation, and course creation.

### 5. ChatGPT Custom GPT & OpenAI Codex
See [`adapters/codex-openai/CUSTOM_GPT_INSTRUCTIONS.md`](./adapters/codex-openai/CUSTOM_GPT_INSTRUCTIONS.md) to launch your own custom Frappe GPT in seconds.

---

## 📁 Repository Structure

```
frappe-skills/
├── README.md                         ← Project documentation & matrix
├── AGENTS.md                         ← Universal AI agent standard
├── CLAUDE.md                         ← Claude Code configuration
├── GEMINI.md                         ← Gemini & Antigravity configuration
├── .cursorrules                      ← Cursor AI root rules
├── .windsurfrules                    ← Windsurf Cascade rules
├── .clinerules                       ← Cline instructions
├── .roomodes                         ← Roo Code custom modes
├── install.sh                        ← Linux/macOS multi-agent installer
├── install.ps1                       ← Windows PowerShell installer
├── install.py                        ← Cross-platform Python installer
├── skills.json                       ← Registry & marketplace metadata
├── LICENSE                           ← MIT + Commercial dual license
│
├── adapters/                         ← Dedicated agent adapter packages
│   ├── hermes/                       ← Hermes setup & configs
│   ├── claude/                       ← Claude Code, Projects & MCP
│   ├── gemini-antigravity/           ← Antigravity & AI Studio configs
│   ├── codex-openai/                 ← Custom GPT & Assistant instructions
│   ├── cursor/                       ← .cursorrules & .mdc rules
│   ├── windsurf/                     ← Windsurf rules
│   ├── copilot/                      ← Copilot custom instructions
│   └── cline/                        ← Cline & Roo Code modes
│
├── frappe-docs/                      ← Skill 1: Technical Knowledge Base
│   ├── SKILL.md
│   └── references/                   ← Deep-dive references & troubleshooting
│
└── frappe-course-generator/          ← Skill 2: Arabic Course Generator
    ├── SKILL.md
    ├── references/                   ← Curricula & lesson blueprints
    ├── assets/                       ← Templates & scaffolds
    └── scripts/                      ← scaffold_course, build_course, verify_course
```

---

## ⚖️ License

Dual-licensed:
- **MIT License** for open-source, personal, and small-team use.
- **Commercial License** for enterprise deployments, resale, or proprietary integrations.

See [LICENSE](./LICENSE) for details. Maintainer: [Orphic-Studios](https://github.com/Orphic-Studios).

