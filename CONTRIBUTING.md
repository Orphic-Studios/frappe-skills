# Contributing to Frappe Skills Pack

First off, thank you for considering contributing! 🎉

This project aims to be the best AI skill pack and plugin for the Frappe/ERPNext ecosystem, and contributions from the community are what make that possible.

## Ways to Contribute

- 🐛 **Report bugs** — open an issue with reproduction steps
- 💡 **Suggest features** — open an issue with the `enhancement` label
- 📝 **Improve documentation** — fix typos, add examples, clarify explanations
- 🌍 **Translate** — help translate course templates to other languages
- 🧪 **Add test cases** — help expand validation scripts and checklists
- 🔧 **Fix bugs** — submit a pull request

## Before You Start

### Code of Conduct

By participating, you agree to abide by our [Code of Conduct](./CODE_OF_CONDUCT.md). Please read it.

### Prerequisites

- Git
- Node.js 20+ (for running repository validation scripts)
- Python 3.11+ (for running `frappe-course-generator` scripts)
- A Markdown editor (VS Code recommended)
- An AI agent to test with (Claude Code, Antigravity, Gemini CLI, Codex, Cursor, Hermes, etc.)

## Development Workflow

### 1. Fork and clone

```bash
# Fork the repo on GitHub, then:
git clone https://github.com/YOUR_USERNAME/frappe-skills.git
cd frappe-skills
git remote add upstream https://github.com/Orphic-Studios/frappe-skills.git
```

### 2. Create a branch

```bash
git checkout -b fix/my-bug-fix
# or
git checkout -b feature/my-new-feature
```

### 3. Make your changes

Follow the guidelines below for the type of change you're making. Also review [`.claude/rules/skills-contributing.md`](./.claude/rules/skills-contributing.md).

### 4. Test and validate your changes

```bash
# Run repository validation checks:
node scripts/validate-skills.js
node scripts/validate-versions.js
node scripts/validate-commands.js

# For frappe-course-generator script changes:
cd skills/frappe-course-generator/scripts
python3 scaffold_course.py --name test --track developer --audience developers --language ar --length quick --with-project --output /tmp/test-course
python3 verify_course.py /tmp/test-course
```

### 5. Commit and push

```bash
git add .
git commit -m "fix: correct lifecycle hook order in doctype-guide.md"
git push origin fix/my-bug-fix
```

Use [Conventional Commits](https://www.conventionalcommits.org/) format:
- `fix:` bug fixes
- `feat:` new features
- `docs:` documentation changes
- `refactor:` code refactoring
- `test:` adding tests
- `chore:` maintenance

### 6. Open a pull request

Go to GitHub and open a PR against `main`.

## Contribution Guidelines by Type

### Fixing a Bug in `frappe-docs`

1. Identify the file with the error (use the decision tree in `skills/frappe-docs/SKILL.md` to find it).
2. Verify the error against the official Frappe docs at https://docs.frappe.io.
3. Fix the error.
4. Test by asking your AI agent about the topic.
5. Submit a PR with `fix:` prefix.

### Adding a New Reference File to `frappe-docs`

1. Check that the topic isn't already covered (search existing files).
2. Create the new file under the appropriate subdirectory inside `skills/frappe-docs/`:
   - `references/framework/` for Framework topics
   - `references/erpnext/` for ERPNext topics
   - `references/apps/` for other Frappe apps
3. Follow the existing style:
   - Start with a `# Title` and a Table of Contents
   - Use H2 for major sections, H3 for subsections
   - Include code examples with language tags
   - Include "Where to Learn More" with live docs URLs
4. Update `skills/frappe-docs/SKILL.md` to mention the new file in the Reference Files table.
5. Update `skills/frappe-docs/references/docs-index.md` if applicable.
6. Submit a PR with `feat:` prefix.

### Improving `frappe-course-generator`

1. **Curriculum changes**: edit `skills/frappe-course-generator/references/curriculum.md`.
2. **Lesson template changes**: edit `skills/frappe-course-generator/references/lesson-blueprints.md`.
3. **Script changes**: edit the relevant script in `skills/frappe-course-generator/scripts/`.
4. **New template**: add to `skills/frappe-course-generator/assets/templates/` and update `skills/frappe-course-generator/SKILL.md`.
5. Test by generating a sample course.
6. Submit a PR.

## Style Guide

### Markdown & Encoding

- Save all files as **UTF-8 without BOM** with `LF` line endings.
- Use H1 (`#`) only once per file, at the top.
- Use H2 (`##`) for major sections and H3 (`###`) for subsections.
- Code blocks must have language tags: ` ```python `, ` ```bash `, ` ```json `.

### Language

- `frappe-docs`: English only.
- `frappe-course-generator`: Arabic prose, English code and technical terms.
- First occurrence of technical terms: bilingual (`DocType (نوع المستند)`).

## Release Process

Releases follow semantic versioning:

1. Bump the version across all 6 plugin manifests (`plugin.json`, `skills.json`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`) and verify with `node scripts/validate-versions.js`.
2. Update `CHANGELOG.md`.
3. Create and push a git tag (`v1.1.0`, etc.) to trigger the automated GitHub Release workflow.

Thank you for contributing! 🙏
