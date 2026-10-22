# Claude Integration (Claude Code, Claude Projects, Claude Desktop)

This adapter enables deep Frappe & ERPNext support across all Anthropic Claude surfaces.

---

## 🚀 1. Claude Code CLI

Claude Code reads `CLAUDE.md` from the root of your project or from `~/.claude/skills/`.

```bash
# Option 1: Install as global skills in Claude Code
mkdir -p ~/.claude/skills/
cp -r ../../frappe-docs ~/.claude/skills/
cp -r ../../frappe-course-generator ~/.claude/skills/

# Option 2: Copy CLAUDE.md to your frappe-bench root
cp CLAUDE.md /path/to/your/frappe-bench/
```

---

## 🌐 2. Claude.ai Projects (Web)

1. Open **Claude.ai** and create a new Project named `Frappe & ERPNext Architect`.
2. Open [`CLAUDE_PROJECT_PROMPT.md`](file:///adapters/claude/CLAUDE_PROJECT_PROMPT.md) and paste its entire content into the **Project Instructions**.
3. (Optional) In the Project Knowledge section, upload the files from `frappe-docs/references/`.

---

## 🖥️ 3. Claude Desktop (MCP)

To connect Claude Desktop with local skills and execution tools, add the configuration in [`claude_desktop_mcp.json`](file:///adapters/claude/claude_desktop_mcp.json) to your Claude Desktop config file (`%APPDATA%\Claude\claude_desktop_config.json` on Windows or `~/Library/Application Support/Claude/claude_desktop_config.json` on macOS).
