# Other Hosts

Skills are plain `SKILL.md` directories inside [`skills/`](../skills/), so any agent that supports the Agent Skills specification can load them directly.

- **Cline**: `npx skills add Orphic-Studios/frappe-skills --agent cline` (or copy `skills/*` to `~/.cline/skills/`)
- **Roo Code**: `npx skills add Orphic-Studios/frappe-skills --agent roo`
- **Kiro IDE & CLI**: Copy `skills/*` into `.kiro/skills/` (project or global)
- **Aider**: Pass `--read skills/frappe-docs/SKILL.md` or `AGENTS.md`
- **Dojo Workspace**: `dojo skills add Orphic-Studios/frappe-skills`
- **Oh My Pi**: `omp plugin marketplace add Orphic-Studios/frappe-skills`, then `omp plugin install frappe-skills@orphic-frappe-skills`
- **Pi**: `pi install git:github.com/Orphic-Studios/frappe-skills`
- **ChatGPT Custom GPTs / Claude.ai Projects**: Upload `skills/frappe-docs/SKILL.md` and `skills/frappe-docs/references/*.md` as Knowledge files, and use `CLAUDE.md` / `AGENTS.md` as project instructions.
