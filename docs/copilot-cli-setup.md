# Using Frappe Skills with GitHub Copilot CLI

The standalone `copilot` CLI supports installing plugins directly from GitHub repositories containing `plugin.json` and `skills/`.

## Setup

```bash
npx skills add Orphic-Studios/frappe-skills --agent github-copilot
```

Or clone the repository and load `skills/` into your Copilot CLI configuration directory.
