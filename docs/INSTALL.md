# Installation Guide

Complete installation instructions for the Frappe Skills Pack.

## Prerequisites

Before installing, ensure you have:

- **Git** — for cloning the repository
- **Python 3.11+** — for running `frappe-course-generator` scripts
- **An AI agent** that supports the standard skill format (folder + SKILL.md)

Optional (for course PDF/PPTX export):

```bash
pip install reportlab markdown arabic-reshaper python-bidi python-pptx
```

## Installation Methods

### Method 1: One-command installer (recommended)

**On Linux / macOS / WSL:**
```bash
curl -fsSL https://raw.githubusercontent.com/yazan250/frappe-skills/main/install.sh | bash
```

**On Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/yazan250/frappe-skills/main/install.ps1 | iex
```

The installer will:
1. Auto-detect your AI agent (Hermes, Claude Code, Google Antigravity/Gemini, Cursor, Windsurf, Cline)
2. Clone or locate the repository
3. Copy both skills to the correct location
4. Verify the installation

### Method 2: Manual installation

```bash
# Clone the repo
git clone https://github.com/yazan250/frappe-skills.git
cd frappe-skills

# Copy both skill folders to your agent's skills directory
# Replace ~/.config/hermes/skills/ with your agent's path
cp -r frappe-docs ~/.config/hermes/skills/
cp -r frappe-course-generator ~/.config/hermes/skills/
```

### Method 3: Using `npx skills add` (skills.sh)

```bash
# Install frappe-docs first (it's a dependency)
npx skills add https://github.com/yazan250/frappe-skills --skill frappe-docs

# Then install frappe-course-generator
npx skills add https://github.com/yazan250/frappe-skills --skill frappe-course-generator
```

## Finding Your Agent's Skills Directory

Different agents use different paths:

| Agent | Skills / Config Directory | Adapter Guide |
|---|---|---|
| Hermes | `~/.config/hermes/skills/` | [`adapters/hermes/`](../adapters/hermes/) |
| Claude Code | `~/.claude/skills/` or `./CLAUDE.md` | [`adapters/claude/`](../adapters/claude/) |
| Gemini & Antigravity | `~/.gemini/antigravity/skills/` | [`adapters/gemini-antigravity/`](../adapters/gemini-antigravity/) |
| OpenAI Codex / ChatGPT | Custom GPT & Assistants Instructions | [`adapters/codex-openai/`](../adapters/codex-openai/) |
| Cursor | `~/.cursor/skills/` or `./.cursor/rules/` | [`adapters/cursor/`](../adapters/cursor/) |
| Windsurf | `~/.windsurf/skills/` or `./.windsurfrules` | [`adapters/windsurf/`](../adapters/windsurf/) |
| Cline & Roo Code | `~/.cline/skills/` or `./.clinerules` | [`adapters/cline/`](../adapters/cline/) |
| Generic | `~/.skills/` | [`AGENTS.md`](../AGENTS.md) |

To find your agent's skills directory:

```bash
# Method 1: search for existing skills
find ~ -name "SKILL.md" 2>/dev/null | head -5

# Method 2: search for skills directories
find ~ -type d -name "skills" 2>/dev/null | grep -v node_modules
```

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

## Updating

To update to a newer version:

```bash
# Remove old version
rm -rf ~/.config/hermes/skills/frappe-docs
rm -rf ~/.config/hermes/skills/frappe-course-generator

# Re-run installer
curl -fsSL https://raw.githubusercontent.com/yazan250/frappe-skills/main/install.sh | bash
```

Or with `npx skills`:

```bash
npx skills update frappe-docs
npx skills update frappe-course-generator
```

## Uninstalling

```bash
rm -rf ~/.config/hermes/skills/frappe-docs
rm -rf ~/.config/hermes/skills/frappe-course-generator
```

Restart your AI agent.

## Troubleshooting

### Skill not detected

1. Verify `SKILL.md` exists at the expected path
2. Check the YAML frontmatter is valid:
   ```bash
   head -5 ~/.config/hermes/skills/frappe-docs/SKILL.md
   ```
3. Restart your AI agent

### Scripts not working

```bash
# Install Python dependencies
pip install reportlab markdown arabic-reshaper python-bidi python-pptx

# Test the scripts
python3 ~/.config/hermes/skills/frappe-course-generator/scripts/scaffold_course.py --help
```

### Permission denied on install.sh

```bash
chmod +x install.sh
./install.sh
```
