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
1. Detect that your question is about Frappe/ERPNext
2. Load the `frappe-docs` skill
3. Read the relevant reference file (e.g. `python-api.md` for API questions)
4. Give you a detailed answer with code examples, common mistakes, and best practices

---

## Example 2: Generating a Full Course

Once both skills are installed, you can generate complete training courses.

### Basic usage

> "أنشئ دورة تعليمية كاملة على Frappe Framework للمطورين، حوالي 100 درس، مع مشروع تطبيقي."

The agent will:
1. Ask you to confirm preferences (track, language, length)
2. Scaffold the course folder structure
3. Generate each module's lessons (theory + code + exercises)
4. Build PDF and ZIP exports
5. Deliver the course to your download folder

### Customizing the course

You can specify:

| Parameter | Example | Options |
|---|---|---|
| Track | "مسار المطور" | developer, user, admin, all |
| Audience | "للمطورين المبتدئين" | developers, users, admins, mixed |
| Length | "100 درس" | quick (50), medium (100), pro (200+) |
| Language | "بالعربية" | ar, en, bilingual |
| Project | "مع مشروع تطبيقي" | yes/no |

### Example: Quick 5-lesson tutorial

> "Create a short 5-lesson tutorial on ERPNext accounting for beginners, no project needed."

This generates a focused mini-course with 5 lessons + exercises + a final quiz.

### Example: Admin workshop

> "أنشئ ورشة عمل لمسؤولي نظام ERPNext، يوم واحد، 8 دروس عملية."

This generates a 1-day workshop curriculum with hands-on labs.

---

## Example 3: Generating Specific Lesson Types

You can ask for specific lesson types instead of a full course:

### Theory lesson

> "اكتب درس نظري عن 'ما هو DocType في Frappe Framework؟' بالعربية، 1000 كلمة."

### Practical lesson

> "اكتب درس تطبيقي عن 'إنشاء DocType جديد باسم Task' مع خطوات تفصيلية."

### Quiz

> "أنشئ اختبار قصير من 10 أسئلة عن Python API في Frappe، مع الإجابات."

### Exercise set

> "أعطني 5 تمارين متدرجة الصعوبة على إنشاء DocTypes، مع الحلول."

---

## Example 4: Using the Scripts Directly

The `frappe-course-generator` skill includes 3 Python scripts you can run manually.

### Scaffold a course

```bash
python3 ~/.config/hermes/skills/frappe-course-generator/scripts/scaffold_course.py \
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
python3 ~/.config/hermes/skills/frappe-course-generator/scripts/build_course.py \
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
python3 ~/.config/hermes/skills/frappe-course-generator/scripts/verify_course.py \
    ~/my-frappe-course
```

Checks for: structure, required sections, exercises with solutions, working cross-links, code blocks with language tags, etc.

---

## Example 5: Customizing Course Content

### Adding a custom module

> "أضف وحدة جديدة لدورتي بعنوان 'التكامل مع Shopify' تحتوي على 8 دروس."

The agent will:
1. Read the curriculum blueprint
2. Create a new module folder with the standard structure
3. Generate 8 lessons specific to Shopify integration
4. Update the course README

### Changing exercise difficulty

> "اجعل تمارين الوحدة 3 أصعب — استبدل التمارين السهلة بتمارين متوسطة."

### Translating to English

> "ترجم الدورة كاملة إلى الإنجليزية مع الاحتفاظ بالأكواد."

---

## Tips for Best Results

1. **Be specific**: instead of "make a course", say "make a 100-lesson developer course in Arabic with a CRM project".

2. **Mention prerequisites**: tell the agent if your learners are beginners or experienced.

3. **Ask for examples**: "include 2-3 real-world examples per lesson".

4. **Iterate**: generate one module first, review it, then ask for adjustments before generating the rest.

5. **Use the scripts directly**: for fine-grained control, use the Python scripts instead of letting the agent generate everything.

6. **Check the output**: use `verify_course.py` to ensure quality before delivering.

---

## Common Workflows

### Workflow 1: Onboarding new developers

1. Generate a 50-lesson developer course (quick length)
2. Customize the project to match your company's domain
3. Export as PDF and share with new hires
4. Have them complete the project as part of onboarding

### Workflow 2: Training end-users on ERPNext

1. Generate a 30-lesson user course (quick length, no project)
2. Customize modules to match the modules your company uses
3. Export as PPTX for instructor-led training
4. Use the quizzes as knowledge checks

### Workflow 3: Building a Frappe training business

1. Use the commercial license (contact maintainer)
2. Generate courses for different audiences (developers, users, admins)
3. Customize each course for the client's industry
4. Deliver as PDF + ZIP
5. Charge for the customization and delivery

---

## Integration with Other Tools

### LMS integration

The generated courses are in standard Markdown, which can be imported into:
- Moodle (via Markdown import plugin)
- Canvas (via Common Cartridge format)
- Notion (via copy-paste or API)
- GitBook (via Markdown source)

### CI/CD integration

You can automate course generation in CI/CD:

```yaml
# .github/workflows/generate-course.yml
name: Generate Course
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: pip install reportlab markdown arabic-reshaper python-bidi
      - name: Scaffold course
        run: python3 scripts/scaffold_course.py --name auto-course --track developer --audience developers --language ar --length quick --output ./course
      - name: Build PDF
        run: python3 scripts/build_course.py --input ./course --format pdf
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: course-pdf
          path: ./course/exports/course.pdf
```
