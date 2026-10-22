# Hermes Agent Adapter

[Hermes](https://github.com/NousResearch/Hermes-Function-Calling) and Hermes-compatible agent frameworks support standard agent skill directories containing `SKILL.md` with YAML frontmatter.

---

## 📁 Installation into Hermes

### Option A: Automatic Setup
Run the setup script:
```bash
bash adapters/hermes/hermes-setup.sh
```

### Option B: Manual Setup
```bash
# 1. Create Hermes skills directory
mkdir -p ~/.config/hermes/skills/

# 2. Copy the skills
cp -r ../../frappe-docs ~/.config/hermes/skills/
cp -r ../../frappe-course-generator ~/.config/hermes/skills/

# 3. Verify Hermes sees the skills
hermes skills list
```

---

## 💡 How Hermes Uses These Skills

1. When asked about **Frappe / ERPNext questions**, Hermes automatically loads the `frappe-docs` skill description, navigates `references/`, and provides authoritative answers.
2. When prompted to **build a course or curriculum in Arabic**, Hermes invokes `frappe-course-generator`, reads `references/curriculum.md` and `references/lesson-blueprints.md`, and runs the scaffolding scripts.
