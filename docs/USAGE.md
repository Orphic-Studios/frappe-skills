# Usage Examples

Real-world examples of using the Frappe Skills Pack with your AI agent.

## Example 1: Asking Technical Questions

Once `frappe-docs` is installed, your AI agent becomes an expert on Frappe/ERPNext.

### Example prompts

**English:**

> "How do I create a new DocType in Frappe Framework with a child table?"

> "What's the difference between frappe.get_doc and frappe.get_cached_doc?"

> "I'm getting 'ValidationError: Could not find Custom Field' when running bench migrate. How do I fix it?"

> "Write a Server Script that sends an email notification when a Sales Invoice is submitted."

> "How do I configure nginx for production ERPNext deployment?"

**Arabic:**

> "كيف أنشئ DocType جديد مع جدول فرعي (child table)؟"

> "ما الفرق بين frappe.get_doc و frappe.get_cached_doc؟"

> "أحصل على خطأ 'PermissionError' عند محاولة حفظ مستند. ما السبب؟"

> "اكتب لي Server Script يرسل إشعاراً بالبريد عند اعتماد فاتورة مبيعات."

### Expected behavior

The agent will:
1. Detect that your question is about Frappe/ERPNext (or run via `/frappe-ask`)
2. Load the `frappe-docs` skill
3. Read the relevant reference file (e.g. `python-api.md` for API questions)
4. Give you a detailed answer with code examples, common mistakes, and best practices

---

## Example 2: Generating a Full Course

Once both skills are installed, you can generate complete training courses (or invoke `/frappe-course`).

### Basic usage

> "أنشئ دورة تعليمية كاملة على Frappe Framework للمطورين، حوالي 100 درس، مع مشروع تطبيقي."

The agent will:
1. Ask you to confirm preferences (track, language, length)
2. Scaffold the course folder structure
3. Generate each module's lessons (theory + code + exercises)
4. Build PDF and ZIP exports
5. Deliver the course to your output folder

### Customizing the course

You can specify:

| Parameter | Example | Options |
|---|---|---|
| Track | "مسار المطور" | developer, user, admin, all |
| Audience | "للمطورين المبتدئين" | developers, users, admins, mixed |
| Length | "100 درس" | quick (50), medium (100), pro (200+) |
| Language | "بالعربية" | ar, en, bilingual |
| Project | "مع مشروع تطبيقي" | yes/no |

---

## Example 3: Using the Scripts Directly

The `frappe-course-generator` skill includes 3 Python scripts you can run manually.

### Scaffold a course

```bash
python3 skills/frappe-course-generator/scripts/scaffold_course.py \
    --name "my-frappe-course" \
    --track developer \
    --audience developers \
    --language ar \
    --length medium \
    --with-project \
    --output ~/my-frappe-course
```

This creates the course folder structure with placeholder files.

### Build PDF/ZIP from a course

```bash
python3 skills/frappe-course-generator/scripts/build_course.py \
    --input ~/my-frappe-course \
    --format all
```

Outputs:
- `~/my-frappe-course/exports/course.pdf`
- `~/my-frappe-course/exports/course.zip`
- `~/my-frappe-course/exports/course.pptx`
- `~/my-frappe-course/exports/web/`

### Verify course quality

```bash
python3 skills/frappe-course-generator/scripts/verify_course.py \
    ~/my-frappe-course
```

Checks for: structure, required sections, exercises with solutions, working cross-links, code blocks with language tags, etc.

---

## Integration with CI/CD

You can automate course scaffolding and packaging in GitHub Actions:

```yaml
# .github/workflows/generate-course.yml
name: Generate Course
on: workflow_dispatch
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: pip install reportlab markdown arabic-reshaper python-bidi python-pptx
      - name: Scaffold course
        run: python3 skills/frappe-course-generator/scripts/scaffold_course.py --name auto-course --track developer --audience developers --language ar --length quick --output ./course
      - name: Build PDF
        run: python3 skills/frappe-course-generator/scripts/build_course.py --input ./course --format pdf
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: course-pdf
          path: ./course/exports/course.pdf
```
