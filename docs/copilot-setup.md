# Using Frappe Skills with GitHub Copilot

GitHub Copilot in VS Code, JetBrains, and GitHub.com supports Agent Skills via `.github/skills/` and workspace instructions via `.github/copilot-instructions.md`.

## Setup

### Option 1: Skills CLI

```bash
npx skills add Orphic-Studios/frappe-skills --agent github-copilot
```

### Option 2: Workspace Instructions & Personas

Copy `.github/copilot-instructions.md` into your Frappe project's `.github/` directory, and use the specialist definitions in [`agents/`](../agents/) (`frappe-architect`, `frappe-reviewer`, `frappe-course-instructor`) as custom Copilot agent personas.
