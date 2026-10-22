# Skill Anatomy

How the Frappe Skills Pack is structured and why.

## The Standard Skill Format

Every skill is a folder containing:

```
skill-name/
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
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── skills.json                       ← marketplace manifest
├── install.sh                        ← installer script
├── .gitignore
├── docs/
│   ├── INSTALL.md
│   ├── USAGE.md
│   └── ANATOMY.md                    ← this file
│
├── frappe-docs/                      ← SKILL 1
│   ├── SKILL.md                      ← entry point + decision tree
│   └── references/                   ← loaded on demand
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
└── frappe-course-generator/          ← SKILL 2
    ├── SKILL.md                      ← 9-step generation workflow
    ├── references/                   ← loaded on demand
    │   ├── curriculum.md
    │   ├── lesson-blueprints.md
    │   ├── delivery-formats.md
    │   └── assessment-rubrics.md
    ├── assets/
    │   ├── templates/                ← blank templates
    │   │   ├── lesson.template.md
    │   │   ├── exercise.template.md
    │   │   ├── quiz.template.md
    │   │   ├── module-readme.template.md
    │   │   └── course-readme.template.md
    │   └── project-scaffold/
    │       └── README.md             ← progressive project brief
    └── scripts/                      ← executable helpers
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

### Why templates?

- **Consistency**: every generated lesson follows the same structure
- **Speed**: the agent fills in blanks instead of starting from scratch
- **Quality**: the templates encode best practices (objectives, exercises, etc.)

## File Naming Conventions

- **Skill folders**: `kebab-case` (e.g. `frappe-docs`, not `frappe_docs` or `FrappeDocs`)
- **SKILL.md**: always uppercase, always at the root of the skill folder
- **Reference files**: `kebab-case` (e.g. `python-api.md`)
- **Templates**: `<name>.template.md` (e.g. `lesson.template.md`)
- **Scripts**: `snake_case.py` (e.g. `scaffold_course.py`)

## Frontmatter Best Practices

```yaml
---
name: "skill-name"           # MUST match folder name
description: "..."           # 500-1000 chars, include trigger phrases
---
```

### Description tips

- Include both English and Arabic trigger phrases (if bilingual)
- Be specific about what triggers it (not just "Frappe")
- Mention key APIs/concepts the user might ask about
- Don't make it too long (>1024 chars may fail validation on some platforms)

### Bad description

```yaml
description: A skill for Frappe.
```

### Good description

```yaml
description: "Comprehensive knowledge of the Frappe/ERPNext ecosystem. Use this skill whenever the user mentions Frappe, ERPNext, bench commands, DocType, frappe.get_doc, frappe.whitelist, frappe.call, ERPNext modules (Accounts/Stock/Selling/Buying/Manufacturing/HR/Projects/Payroll), or any task involving installation, customization, troubleshooting, code generation, or configuration of Frappe-based systems."
```

## Cross-References

Inside SKILL.md, reference other files with relative paths:

```markdown
## Reference Files

| File | When to read |
|---|---|
| `references/framework/python-api.md` | When writing Python code |
| `references/erpnext/accounts.md` | When asked about accounting |
```

Inside reference files, cross-reference sibling files:

```markdown
For REST API details, see [rest-api.md](./rest-api.md).
For Python API, see [python-api.md](./python-api.md).
```

## Dependency Declaration

In `frappe-course-generator/SKILL.md`:

```markdown
## Dependency on `frappe-docs` Skill

This skill is a sibling of `frappe-docs`. They are designed to work together.
```

In `skills.json`:

```json
{
  "name": "frappe-course-generator",
  "dependencies": ["frappe-docs"]
}
```

This tells the marketplace and installer that `frappe-docs` must be installed first.
