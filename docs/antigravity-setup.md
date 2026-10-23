# Using Frappe Skills with Antigravity (`agy`)

The `frappe-skills` repository includes a root `plugin.json`, `skills/`, `agents/`, and `commands/` so it can be installed directly as a native plugin in Google Antigravity (`agy`).

## Setup

### Option 1: Native Plugin Installation (Recommended)

Install directly from GitHub:

```bash
agy plugin install https://github.com/Orphic-Studios/frappe-skills.git
```

Or install from a local clone:

```bash
git clone https://github.com/Orphic-Studios/frappe-skills.git
agy plugin install ./frappe-skills
```

Verify active plugins:

```bash
agy plugin list
```

### Option 2: Skills CLI

```bash
npx skills add Orphic-Studios/frappe-skills --agent antigravity
```

## Skills & Personas Included

- **Skills** (`skills/`):
  - `frappe-docs` — Full Frappe Framework, ERPNext, and Ecosystem technical reference
  - `frappe-course-generator` — Arabic course generation engine
- **Personas** (`agents/`):
  - `frappe-architect`
  - `frappe-reviewer`
  - `frappe-course-instructor`
