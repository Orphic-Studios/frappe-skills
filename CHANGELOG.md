# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-10-23

### Added
- **Multi-Agent Plugin & Marketplace Architecture** (modeled after `addyosmani/agent-skills`):
  - Placed skills in `skills/frappe-docs/` and `skills/frappe-course-generator/` (preserving 100% original skill files byte-for-byte).
  - Added 6 synchronized plugin and marketplace manifests (`plugin.json`, `skills.json`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`).
  - Added 4 lifecycle slash commands (`/frappe-ask`, `/frappe-doctype`, `/frappe-debug`, `/frappe-course`) synchronized across `.claude/commands/`, `.gemini/commands/`, and `commands/`.
  - Added 3 specialist agent personas in `agents/`: `frappe-architect.md`, `frappe-reviewer.md`, and `frappe-course-instructor.md`.
  - Added 3 quick-reference engineering & pedagogical checklists in `references/`: `doctype-checklist.md`, `security-checklist.md`, and `course-quality-checklist.md`.
  - Added per-agent setup documentation in `docs/` for Claude Code, Google Antigravity, Gemini CLI, OpenAI Codex CLI, Cursor, Hermes, Windsurf, OpenCode, GitHub Copilot, Command Code, and Cline/Roo Code/Kiro.
  - Added automated CI validation scripts in `scripts/`: `validate-skills.js`, `validate-versions.js`, and `validate-commands.js`.
- **Cross-Platform One-Command Installers**:
  - Updated `install.sh` (Linux/macOS/WSL), `install.ps1` (Windows PowerShell), and `install.py` (Python) with multi-agent auto-detection.

### Fixed
- Resolved `json.decoder.JSONDecodeError: Unexpected UTF-8 BOM` in GitHub Actions CI by enforcing UTF-8 (no BOM) across all repository files and adding `.gitattributes` and automated BOM validation.

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
