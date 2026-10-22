# Installing Frappe Skills in Google Antigravity

Google Antigravity allows developers to extend the coding agent with persistent skills.

---

## 🛠️ Step-by-Step Installation

### Step 1: Locate Antigravity Configuration
In Antigravity, user skills are discovered automatically under:
- **Windows**: `C:\Users\<username>\.gemini\antigravity\skills\`
- **Linux/macOS**: `~/.gemini/antigravity/skills/`

### Step 2: Copy the Skills
Run the following in PowerShell (Windows):
```powershell
$target = "$HOME\.gemini\antigravity\skills"
New-Item -ItemType Directory -Force -Path $target
Copy-Item -Recurse -Force "frappe-docs" "$target\"
Copy-Item -Recurse -Force "frappe-course-generator" "$target\"
```

Or on Linux / macOS:
```bash
mkdir -p ~/.gemini/antigravity/skills/
cp -r frappe-docs frappe-course-generator ~/.gemini/antigravity/skills/
```

### Step 3: Verification
Open Antigravity and ask:
> "ما هي بنية DocType في Frappe Framework وكيف أكتب وحدة تحكم Controller؟"

Antigravity will automatically activate `frappe-docs` and provide the comprehensive answer.
