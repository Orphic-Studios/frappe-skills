# Skill Anatomy

How the Frappe Skills Pack is structured and why.

## The Standard Skill Format

Every skill is a folder under `skills/` containing:

```
skills/skill-name/
├── SKILL.md          ← required, the entry point
└── (any other files) ← optional, loaded on demand
```

The `SKILL.md` file must start with YAML frontmatter:

```yaml
---
name: "skill-name"
description: "When to trigger this skill..."
---

# Skill Title

Body content...
```

- `name`: unique identifier (matches folder name)
- `description`: tells the AI agent WHEN to use this skill

The agent reads only the frontmatter initially. When the user asks a question that matches the description, the agent loads the full `SKILL.md` and any referenced files.

## Frappe Skills Pack Structure

```
frappe-skills/
├── README.md
├── CLAUDE.md
├── AGENTS.md
├── GEMINI.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── plugin.json                       ← root plugin manifest
├── skills.json                       ← skills.sh marketplace manifest
├── .claude-plugin/                   ← Claude Code & Cursor plugin manifests
├── .codex-plugin/                    ← OpenAI Codex CLI plugin manifest
├── .agents/plugins/                  ← Codex marketplace manifest
├── .claude/commands/                 ← Claude Code slash commands (.md)
├── .gemini/commands/                 ← Gemini CLI slash commands (.toml)
├── commands/                         ← Antigravity CLI slash commands (.toml)
├── agents/                           ← Specialist personas (architect, reviewer, instructor)
├── references/                       ← Quick-reference checklists
├── scripts/                          ← Validation scripts (Node.js)
├── docs/                             ← Setup guides per agent host
├── install.sh / install.ps1 / install.py
│
└── skills/
    ├── frappe-docs/                  ← SKILL 1
    │   ├── SKILL.md                  ← entry point + decision tree
    │   └── references/               ← loaded on demand
    │       ├── docs-index.md
    │       ├── troubleshooting.md
    │       ├── framework/
    │       │   ├── architecture.md
    │       │   ├── python-api.md
    │       │   ├── rest-api.md
    │       │   ├── doctype-guide.md
    │       │   ├── scripting.md
    │       │   ├── bench-cli.md
    │       │   └── webviews-deployment.md
    │       ├── erpnext/
    │       │   ├── overview.md
    │       │   ├── accounts.md
    │       │   ├── stock.md
    │       │   ├── selling-buying.md
    │       │   ├── manufacturing.md
    │       │   ├── hr-projects.md
    │       │   └── customization.md
    │       └── apps/
    │           └── ecosystem.md
    │
    └── frappe-course-generator/      ← SKILL 2
        ├── SKILL.md                  ← 9-step generation workflow
        ├── references/               ← loaded on demand
        │   ├── curriculum.md
        │   ├── lesson-blueprints.md
        │   ├── delivery-formats.md
        │   └── assessment-rubrics.md
        ├── assets/
        │   ├── templates/            ← blank templates
        │   │   ├── lesson.template.md
        │   │   ├── exercise.template.md
        │   │   ├── quiz.template.md
        │   │   ├── module-readme.template.md
        │   │   └── course-readme.template.md
        │   └── project-scaffold/
        │       └── README.md         ← progressive project brief
        └── scripts/                  ← executable helpers
            ├── scaffold_course.py
            ├── build_course.py
            └── verify_course.py
```

## How the Two Skills Work Together

```
User asks: "Create a Frappe course for developers"
                    │
                    ▼
        AI agent loads BOTH skills
                    │
        ┌───────────┴───────────┐
        ▼                       ▼
  frappe-docs           frappe-course-generator
  (knowledge source)    (pedagogy + workflow)
        │                       │
        │         ┌─────────────┘
        ▼         ▼
  Read reference    Read curriculum.md
  files for         to pick structure
  technical accuracy
        │                       │
        └───────────┬───────────┘
                    ▼
        Generate lessons using
        frappe-docs as source of truth
                    │
                    ▼
        Run scaffold_course.py
        to create folder structure
                    │
                    ▼
        Run build_course.py
        to produce PDF/ZIP
                    │
                    ▼
        Run verify_course.py
        to check quality
                    │
                    ▼
        Deliver to /download/courses/
```

## Why This Structure?

### Why two skills instead of one?

- **Separation of concerns**: `frappe-docs` is a reference (passive), `frappe-course-generator` is a generator (active)
- **Independent use**: you can use `frappe-docs` alone for Q&A without generating courses
- **Composable**: `frappe-course-generator` can be replaced with a different generator (e.g. for English courses) without touching `frappe-docs`

### Why reference files instead of one big SKILL.md?

- **Progressive disclosure**: the agent only loads what it needs, saving tokens
- **Maintainability**: easier to update one file than a 15,000-line monolith
- **Reusability**: other skills can reference the same files

### Why Python scripts?

- **Deterministic**: scaffold/verify operations should be reliable, not LLM-guesswork
- **Fast**: creating 100 folders is instant in Python, slow if the agent does it
- **Testable**: you can run scripts in CI/CD without an AI agent

## Dependency Declaration

In [`skills/frappe-course-generator/SKILL.md`](../skills/frappe-course-generator/SKILL.md):

```markdown
## Dependency on `frappe-docs` Skill

This skill is a sibling of `frappe-docs`. They are designed to work together.
```

In [`skills.json`](../skills.json):

```json
{
  "name": "frappe-course-generator",
  "dependencies": ["frappe-docs"]
}
```

This tells the marketplace and installer that `frappe-docs` must be installed first.
