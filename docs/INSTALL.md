# Installation Guide

Complete installation instructions for the Frappe Skills Pack (`Orphic-Studios/frappe-skills`).

## Prerequisites

Before installing, ensure you have:

- **Git** — for cloning the repository
- **Python 3.11+** — for running `frappe-course-generator` scripts
- **An AI agent** that supports the standard skill format (`skills/<name>/SKILL.md`) or plugin marketplaces

Optional (for course PDF/PPTX export):

```bash
pip install reportlab markdown arabic-reshaper python-bidi python-pptx
```

## Installation Methods

### Method 1: Native Plugin Marketplaces & `npx skills` (Recommended)

**Skills CLI (`npx skills`) — Works across Claude Code, Cursor, Codex, Antigravity, Gemini CLI, Windsurf, Cline, etc.:**
```bash
# Interactive add (select which skills and agents to install for):
npx skills add Orphic-Studios/frappe-skills

# Or install globally across all detected agents without prompts:
npx skills add Orphic-Studios/frappe-skills -g --all
```

**Claude Code Plugin Marketplace:**
```text
/plugin marketplace add Orphic-Studios/frappe-skills
/plugin install frappe-skills@orphic-frappe-skills
```

**OpenAI Codex CLI Plugin Marketplace:**
```bash
codex plugin marketplace add Orphic-Studios/frappe-skills
codex plugin add frappe-skills@frappe-skills
```

**Google Antigravity (`agy`):**
```bash
agy plugin install Orphic-Studios/frappe-skills
```

**Gemini CLI:**
```bash
gemini skills install https://github.com/Orphic-Studios/frappe-skills.git --path skills
```

### Method 2: One-Command Universal Installer

**On Linux / macOS / WSL:**
```bash
curl -fsSL https://raw.githubusercontent.com/Orphic-Studios/frappe-skills/main/install.sh | bash
```

**On Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/Orphic-Studios/frappe-skills/main/install.ps1 | iex
```

**With Python (Cross-Platform):**
```bash
python3 install.py --agent all
```

### Method 3: Manual Installation

```bash
# Clone the repo
git clone https://github.com/Orphic-Studios/frappe-skills.git
cd frappe-skills

# Copy both skill folders to your agent's skills directory
# Example for Hermes:
cp -r skills/frappe-docs ~/.config/hermes/skills/
cp -r skills/frappe-course-generator ~/.config/hermes/skills/
```

## Per-Agent Setup Guides

| Agent | Skills / Config Directory | Setup Guide |
|---|---|---|
| Claude Code | Plugin or `~/.claude/skills/` | [`docs/claude-setup.md`](claude-setup.md) |
| Google Antigravity (`agy`) | `~/.gemini/antigravity/skills/` | [`docs/antigravity-setup.md`](antigravity-setup.md) |
| Gemini CLI | `~/.gemini/skills/` | [`docs/gemini-cli-setup.md`](gemini-cli-setup.md) |
| OpenAI Codex CLI | Plugin or `~/.codex/skills/` | [`docs/codex-setup.md`](codex-setup.md) |
| Cursor | Plugin or `~/.cursor/skills/` | [`docs/cursor-setup.md`](cursor-setup.md) |
| Hermes | `~/.config/hermes/skills/` | [`docs/hermes-setup.md`](hermes-setup.md) |
| Windsurf | `~/.codeium/windsurf/skills/` | [`docs/windsurf-setup.md`](windsurf-setup.md) |
| OpenCode | `.opencode/skills/` or `~/.config/opencode/skills/` | [`docs/opencode-setup.md`](opencode-setup.md) |
| GitHub Copilot (VS Code) | `AGENTS.md` / `.github/copilot-instructions.md` | [`docs/copilot-setup.md`](copilot-setup.md) |
| GitHub Copilot CLI | `~/.copilot/skills/` | [`docs/copilot-cli-setup.md`](copilot-cli-setup.md) |
| Command Code | `~/.commandcode/skills/` | [`docs/commandcode-setup.md`](commandcode-setup.md) |
| Cline / Roo Code / Kiro | `~/.cline/skills/` or `~/.roo/skills/` | [`docs/other-hosts.md`](other-hosts.md) |

## Verifying Installation

After installing, verify:

```bash
# Check both skills are present
ls ~/.config/hermes/skills/
# Should show: frappe-docs/  frappe-course-generator/

# Check SKILL.md exists in each
ls ~/.config/hermes/skills/frappe-docs/SKILL.md
ls ~/.config/hermes/skills/frappe-course-generator/SKILL.md
```

Then restart your AI agent and test:

> "كيف أنشئ DocType جديد في Frappe Framework؟"

The agent should now give detailed, accurate answers using the `frappe-docs` skill.
