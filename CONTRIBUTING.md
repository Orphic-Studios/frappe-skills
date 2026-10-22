# Contributing to Frappe Skills Pack

First off, thank you for considering contributing! 🎉

This project aims to be the best AI skill pack for the Frappe/ERPNext ecosystem, and contributions from the community are what make that possible.

## Ways to Contribute

- 🐛 **Report bugs** — open an issue with reproduction steps
- 💡 **Suggest features** — open an issue with the `enhancement` label
- 📝 **Improve documentation** — fix typos, add examples, clarify explanations
- 🌍 **Translate** — help translate course templates to other languages
- 🧪 **Add test cases** — help expand the eval set
- 🔧 **Fix bugs** — submit a pull request

## Before You Start

### Code of Conduct

By participating, you agree to abide by our [Code of Conduct](./CODE_OF_CONDUCT.md). Please read it.

### Prerequisites

- Git
- Python 3.11+ (for running scripts)
- A Markdown editor (VS Code recommended)
- An AI agent to test with (Hermes, Claude Code, etc.)

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

Follow the guidelines below for the type of change you're making.

### 4. Test your changes

```bash
# For frappe-docs changes:
# Test by asking your AI agent questions about the topic you edited

# For frappe-course-generator changes:
cd frappe-course-generator/scripts
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

Go to GitHub and open a PR against `main`. Fill in the PR template.

## Contribution Guidelines by Type

### Fixing a Bug in `frappe-docs`

1. Identify the file with the error (use the decision tree in `frappe-docs/SKILL.md` to find it).
2. Verify the error against the official Frappe docs at https://docs.frappe.io.
3. Fix the error.
4. Test by asking your AI agent about the topic.
5. Submit a PR with `fix:` prefix.

### Adding a New Reference File to `frappe-docs`

1. Check that the topic isn't already covered (search existing files).
2. Create the new file under the appropriate subdirectory:
   - `references/framework/` for Framework topics
   - `references/erpnext/` for ERPNext topics
   - `references/apps/` for other Frappe apps
3. Follow the existing style:
   - Start with a `# Title` and a Table of Contents
   - Use H2 for major sections, H3 for subsections
   - Include code examples with language tags
   - Include "Where to Learn More" with live docs URLs
4. Update `frappe-docs/SKILL.md` to mention the new file in the Reference Files table.
5. Update `references/docs-index.md` if applicable.
6. Submit a PR with `feat:` prefix.

### Improving `frappe-course-generator`

1. **Curriculum changes**: edit `references/curriculum.md`.
2. **Lesson template changes**: edit `references/lesson-blueprints.md`.
3. **Script changes**: edit the relevant script in `scripts/`.
4. **New template**: add to `assets/templates/` and update SKILL.md.
5. Test by generating a sample course.
6. Submit a PR.

### Translating Course Output

The course generator currently outputs in Arabic. To add a new language:

1. Create `references/lesson-blueprints.<lang>.md` (translate the templates).
2. Update `scripts/scaffold_course.py` to accept the new `--language` value.
3. Update `SKILL.md` to mention the new language.
4. Test by generating a course in the new language.
5. Submit a PR.

## Style Guide

### Markdown

- Use H1 (`#`) only once per file, at the top.
- Use H2 (`##`) for major sections.
- Use H3 (`###`) for subsections.
- Code blocks must have language tags: ` ```python `, ` ```bash `, ` ```json `.
- Tables for structured data.
- No emojis in reference files (use in README/CHANGELOG is OK).

### Code

- Python: PEP 8, max line length 100.
- JavaScript: 2-space indentation, semicolons required.
- Bash: 4-space indentation, `set -e` at the top of scripts.

### Language

- `frappe-docs`: English only.
- `frappe-course-generator`: Arabic prose, English code and technical terms.
- First occurrence of technical terms: bilingual (`DocType (نوع المستند)`).
- Subsequent occurrences: English only.

## Review Process

Pull requests are reviewed by the maintainer. The review checks for:

1. **Technical accuracy** — does the change match the official Frappe docs?
2. **Style consistency** — does it follow the style guide above?
3. **Completeness** — does it include tests, docs, and changelog updates?
4. **Compatibility** — does it break existing functionality?

Reviews aim to be completed within 7 days. If you haven't heard back, please ping the PR.

## Release Process

Releases follow semantic versioning:

1. The maintainer bumps the version in `CHANGELOG.md`.
2. A new git tag is created (`v1.0.1`, `v1.1.0`, etc.).
3. The release is published on GitHub Releases.
4. The skills.sh marketplace manifest (`skills.json`) is updated.

## Questions?

- Open an issue with the `question` label.
- Or contact the maintainer via GitHub.

Thank you for contributing! 🙏

