# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-10-23

### Added
- **Multi-Agent Universal Compatibility**: Full support for all modern AI coding agents and platforms.
- **Root Configuration Files**:
  - `CLAUDE.md`: Claude Code and Anthropic ecosystem project instructions.
  - `GEMINI.md`: Google Gemini & Antigravity IDE configuration.
  - `AGENTS.md`: Universal standard for autonomous AI coding agents.
  - `.cursorrules` & `.cursor/rules/*.mdc`: Cursor AI legacy and modern rules.
  - `.windsurfrules`: Windsurf (Codeium Cascade) workspace rules.
  - `.github/copilot-instructions.md`: GitHub Copilot custom workspace instructions.
  - `.clinerules` & `.roomodes`: Specialized modes for Cline and Roo Code.
- **Dedicated Adapters Hub (`adapters/`)**:
  - `adapters/hermes/`: Automated setup script and Hermes skill configuration.
  - `adapters/claude/`: Claude Code, Projects system prompt, and Desktop MCP settings.
  - `adapters/gemini-antigravity/`: Antigravity skill guide & Gemini system instruction prompt.
  - `adapters/codex-openai/`: ChatGPT Custom GPT builder guide & OpenAI Assistants API instructions.
  - `adapters/cursor/`, `adapters/windsurf/`, `adapters/copilot/`, `adapters/cline/`.
- **Multi-Agent Cross-Platform Installers**:
  - Enhanced `install.sh` for Linux/macOS with agent autodetection.
  - Added `install.ps1` for Windows PowerShell one-command installation.
  - Added `install.py` cross-platform Python installer.

## [1.0.0] - 2026-08-08

### Added

- **Initial release** of the Frappe Skills Pack
- `frappe-docs` skill (v1.0.0): comprehensive technical reference
  - 18 reference files covering Framework, ERPNext, all Frappe apps, troubleshooting
  - 14,338 lines of curated documentation
  - Decision tree for routing questions to the right reference file
  - URL map for fetching live docs.frappe.io pages
  - Quick API cheatsheet (Python, JavaScript, REST, bench CLI)
- `frappe-course-generator` skill (v1.0.0): course generation engine
  - 3-track curriculum (Developer / User / Admin) with 30 modules and 280 lessons
  - 5 lesson type blueprints (theory, practical, exercise, quiz, project step)
  - Progressive project: custom CRM app built across 12 modules
  - 3 helper scripts: `scaffold_course.py`, `build_course.py`, `verify_course.py`
  - Support for PDF (with Arabic rendering), ZIP, PPTX, and Web output formats
  - Automated quality verification (7 check categories)
- Repository metadata:
  - README.md with installation and usage instructions
  - LICENSE (MIT + Commercial dual license)
  - CONTRIBUTING.md
  - CODE_OF_CONDUCT.md
  - skills.json manifest for skills.sh marketplace
  - install.sh one-command installer
  - .gitignore

### Skills

| Skill | Files | Lines | Size | Language |
|---|---|---|---|---|
| `frappe-docs` | 18 | 14,338 | 181 KB | English |
| `frappe-course-generator` | 15 | 8,366 | 112 KB | Arabic + English code |

### Compatibility

- Tested with Hermes agent, Claude Code, Cursor, Windsurf
- Compatible with any agent that supports the standard skill format (folder + SKILL.md + YAML frontmatter)

### Known Limitations

- Arabic PDF rendering requires `arabic-reshaper` and `python-bidi` libraries
- Course generation for very long courses (>200 lessons) may require chunked generation
- Live docs fetching requires internet access to `docs.frappe.io`

---

## Versioning

This project uses semantic versioning:

- **MAJOR**: breaking changes to skill structure or frontmatter
- **MINOR**: new features, new reference files, new lesson types
- **PATCH**: bug fixes, content corrections, documentation improvements

---

## Migration Guides

### From v0.x to v1.0.0

If you installed an earlier version (before the public release):

1. Remove the old skills:
   ```bash
   rm -rf ~/.config/hermes/skills/frappe-docs
   rm -rf ~/.config/hermes/skills/frappe-course-generator
   ```

2. Install the new version:
   ```bash
   npx skills add https://github.com/Orphic-Studios/frappe-skills --skill frappe-docs
   npx skills add https://github.com/Orphic-Studios/frappe-skills --skill frappe-course-generator
   ```

3. Restart your AI agent.

