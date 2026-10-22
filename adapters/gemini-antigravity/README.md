# Google Gemini & Antigravity Adapter

This adapter provides seamless integration with **Google Antigravity**, **Gemini Code Assist**, and the **Gemini API** / Google AI Studio.

---

## 🚀 1. Google Antigravity Integration

Google Antigravity supports native skills and plugins. You can install the Frappe Skills Pack into Antigravity in two ways:

### Option A: Global Skills Directory
Copy the skills directly to your Antigravity user skills directory:
- **Windows**: `%USERPROFILE%\.gemini\antigravity\skills\`
- **Linux/macOS**: `~/.gemini/antigravity/skills/`

```bash
mkdir -p ~/.gemini/antigravity/skills/
cp -r ../../frappe-docs ~/.gemini/antigravity/skills/
cp -r ../../frappe-course-generator ~/.gemini/antigravity/skills/
```

### Option B: Workspace Skill / Rules
Copy `GEMINI.md` to your active workspace root. Antigravity automatically detects workspace rules and context files.

---

## ⚡ 2. Google AI Studio & Gemini API

For developers integrating Gemini via API or Vertex AI:
- Copy the system prompt from [`gemini_system_instruction.md`](file:///adapters/gemini-antigravity/gemini_system_instruction.md) into your model's `system_instruction` parameter.
