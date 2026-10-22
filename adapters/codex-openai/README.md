# OpenAI Codex & ChatGPT Integration

This adapter provides ready-to-use configurations for:
1. **ChatGPT Custom GPTs** (GPT-4o / GPT-4.5)
2. **OpenAI Assistants API**
3. **OpenAI Codex / Playground Prompting**

---

## 🤖 1. Creating a Custom GPT in ChatGPT

1. Go to [ChatGPT GPT Editor](https://chatgpt.com/gpts/editor).
2. Set Name: `Frappe & ERPNext Master Architect`
3. Set Description: `Expert technical guide for Frappe Framework & ERPNext development and Arabic course authoring.`
4. Copy the entire contents of [`CUSTOM_GPT_INSTRUCTIONS.md`](file:///adapters/codex-openai/CUSTOM_GPT_INSTRUCTIONS.md) and paste it into the **Instructions** area.
5. In **Knowledge**, upload the markdown files from `frappe-docs/references/` (or a bundled zip).
6. Save and publish!

---

## ⚡ 2. OpenAI Assistants API

If you are using the OpenAI Assistants API:
- Set `instructions` to the contents of [`OPENAI_ASSISTANT_INSTRUCTIONS.md`](file:///adapters/codex-openai/OPENAI_ASSISTANT_INSTRUCTIONS.md).
- Enable `file_search` and upload the reference documents.
- Set model to `gpt-4o` or latest reasoning/coding models.
