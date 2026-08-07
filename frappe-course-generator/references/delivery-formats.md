# Delivery Formats — Packaging the Generated Course

> **الهدف**: هذا المرجع يشرح كيفية تحويل محتوى الدورة (الملفات بتنسيق Markdown) إلى صيغ تسليم قابلة للاستهلاك: ZIP و PDF و PPTX و Web. يُقرأ هذا الملف بواسطة الـ agent لتشغيل سكربتات البناء وإنتاج الملفات النهائية.

## Table of Contents

1. [مقدمة](#مقدمة)
2. [Formats Overview](#formats-overview)
3. [Markdown Course (ZIP Package)](#markdown-course-zip-package)
4. [PDF Export](#pdf-export)
5. [PowerPoint (PPTX) Export](#powerpoint-pptx-export)
6. [Web (HTML) Export](#web-html-export)
7. [Bilingual Export](#bilingual-export)
8. [Build Script Reference](#build-script-reference)
9. [Asset Handling](#asset-handling)
10. [PDF Arabic Rendering Details](#pdf-arabic-rendering-details)
11. [Quality Verification](#quality-verification)
12. [Distribution](#distribution)

---

## مقدمة

بعد إكمال توليد محتوى الدورة (ملفات `.md` لكل درس + التمارين + المشاريع + التقييمات)، يأتي دور **التغليف** (packaging). الهدف هو إنتاج ملف واحد أو مجموعة ملفات يمكن تسليمها للمتعلم أو المدرب مباشرة دون الحاجة إلى بيئة تطوير.

يدعم هذا الـ skill أربعة صيغ تسليم، كلٌ منها يخدم احتياجاً مختلفاً:

| الصيغة | الجمهور المستهدف | متى تُستخدم |
|---|---|---|
| **ZIP** | المتعلمون (learners) | الوضع الافتراضي — كل المتعلمين يحصلون عليه |
| **PDF** | المتعلمون بدون إنترنت، الطباعة | للقراءة على الجوال، الطباعة، الأرشفة |
| **PPTX** | المدربون (instructors) | للعرض في قاعة تدريب أو ورشة عمل |
| **Web** | المتعلمون عبر المتصفح | للتصفح السريع والبحث والوصول من أي جهاز |

> **قاعدة ذهبية**: صيغة ZIP هي الصيغة الأساسية (base format)، وكل الصيغ الأخرى تُشتق منها. لا تُولّد أي صيغة أخرى قبل التأكد من اكتمال ZIP.

### المبدأ الأهم — Single Source of Truth

كل الصيغ الأربعة تُبنى من **نفس مجموعة ملفات Markdown** الموجودة في مجلد الدورة. هذا يعني:

- لا حاجة لمزامنة محتوى بين صيغ مختلفة.
- أي تصحيح في ملف `.md` يظهر تلقائياً في كل الصيغ بعد إعادة البناء.
- الـ agent يكتب المحتوى مرة واحدة فقط.

---

## Formats Overview

### جدول مقارنة الصيغ

| الخاصية | ZIP | PDF | PPTX | Web |
|---|---|---|---|---|
| **الملف الناتج** | `exports/course.zip` | `exports/course.pdf` | `exports/course.pptx` | `exports/web/index.html` + assets |
| **حجم تقريبي** | 5-50 MB | 2-30 MB | 5-40 MB | 10-80 MB |
| **متطلبات العرض** | أي Markdown viewer | قارئ PDF (Adobe, Foxit, browser) | PowerPoint / LibreOffice Impress | متصفح ويب |
| **يدعم البحث** | نعم (في المحرر) | نعم (Ctrl+F) | محدود | نعم (بحث فوري) |
| **يدعم الوضع الليلي** | حسب المحرر | لا (إلا عبر التطبيق) | لا | نعم (toggle) |
| **يدعم التفاعل** | لا | روابط داخلية فقط | انتقالات وأنيميشن | نعم (نسخ الكود، بحث، ت_sidimenu) |
| **سرعة البناء** | سريع (< 5s) | متوسط (30s-2min) | متوسط (20s-1min) | سريع (< 10s) |
| **مناسب للطباعة** | لا | نعم (مثالي) | نعم (slides) | لا |
| **مناسب لـ LMS** | نعم (SCORM-ish) | نعم | نعم | نعم (iframe embed) |
| **الحفاظ على RTL عربي** | نعم (Markdown) | نعم (مع معالجة خاصة) | نعم | نعم (CSS) |

### متى تُستخدم كل صيغة؟

- **ZIP**: دائماً. هي الصيغة الافتراضية ويُبنى تلقائياً مع `--format all`.
- **PDF**: عندما يطلب المتعلم نسخة للقراءة دون اتصال، أو للطباعة، أو للأرشفة على المدى الطويل.
- **PPTX**: عندما يطلب مدرب نسخة للعرض. لا تُولّد تلقائياً إلا إذا مرّر `--format pptx` أو `--format all`.
- **Web**: للدورات التي ستُستضاف على GitHub Pages أو خادم ثابت. ليست افتراضية.

---

## Markdown Course (ZIP Package)

### الوصف

صيغة ZIP هي **الحزمة الأساسية**. تحتوي على كل ملفات Markdown الأصلية بالإضافة إلى مجلد `assets/` للصور والملفات الملحقة. كل صيغ التسليم الأخرى تُشتق من هذه الحزمة.

### البنية المتوقعة

قبل تشغيل سكربت البناء، يجب أن تكون بنية مجلد الدورة كالتالي:

```
frappe-developer-bootcamp/
├── README.md
├── 00-cover/
│   └── cover.md
├── 01-introduction/
│   ├── README.md
│   ├── 01-what-is-frappe.md
│   ├── 02-why-erpnext.md
│   └── exercises/
│       ├── 01-intro-quiz.md
│       └── solutions.md
├── 02-setup-and-installation/
│   └── ...
├── project/
│   ├── README.md
│   ├── starter/
│   ├── solution/
│   └── rubric.md
├── assessments/
│   ├── final-quiz.md
│   └── solutions.md
├── glossary/
│   └── glossary.md
├── resources/
│   ├── cheatsheet.md
│   └── common-errors.md
├── assets/
│   ├── images/
│   │   ├── architecture-diagram.png
│   │   └── screenshot-01.png
│   ├── code/
│   │   ├── example_app.py
│   │   └── hooks_sample.py
│   └── data/
│       ├── customers.csv
│       └── sample_items.json
└── exports/    ← يُنشأ تلقائياً عند البناء
    ├── course.zip
    ├── course.pdf
    ├── course.pptx
    └── web/
```

### التغليف

لتغليف الدورة في ZIP:

```bash
python3 /home/z/my-project/skills/frappe-course-generator/scripts/build_course.py \
    --input /home/z/my-project/download/courses/frappe-developer-bootcamp \
    --format zip \
    --output /home/z/my-project/download/courses/frappe-developer-bootcamp/exports/course.zip
```

### الناتج

```
exports/course.zip
   ├── README.md
   ├── 00-cover/...
   ├── 01-introduction/...
   ├── 02-setup-and-installation/...
   ├── ...
   ├── assets/
   │   ├── images/
   │   ├── code/
   │   └── data/
   └── MANIFEST.json     ← يُضاف تلقائياً (metadata)
```

`MANIFEST.json` يحتوي على:

```json
{
  "course_name": "frappe-developer-bootcamp",
  "generated_at": "2025-01-15T10:30:00Z",
  "generator": "frappe-course-generator v1.0",
  "language": "ar",
  "track": "developer",
  "audience": "developers",
  "lesson_count": 102,
  "module_count": 12,
  "total_words": 145820,
  "checksum": "sha256:abc123..."
}
```

### كيف يستهلكها المتعلم

1. تنزيل `course.zip`.
2. فك الضغط في أي مجلد محلي.
3. فتح `README.md` في أي عارض Markdown:
   - **VS Code** (مجاني، يدعم RTL والمعاينة).
   - **Typora** (مدفوع، أفضل دعم RTL).
   - **Obsidian** (مجاني، مع بحث وملاحظات).
   - **GitHub** (لرفع المجلد إلى repo وقراءته عبر المتصفح).
4. اتباع الروابط الداخلية بين الدروس (تعمل في كل العارضات).

### ملاحظات هامة

- **لا تضع مجلد `exports/` داخل الـ ZIP نفسه** — هذا يسبب recursive packaging.
- **استبعد** الملفات المؤقتة: `.DS_Store`, `Thumbs.db`, `__pycache__/`, `*.pyc`.
- **حافظ على ترتيب الدروس**: البادئات الرقمية (`01-`, `02-`) تضمن ترتيباً صحيحاً في كل العارضات.
- **الحجم الأقصى الموصى به**: 100MB. إذا تجاوزه، استخدم `--compress-images` لتقليل حجم الصور.

---

## PDF Export

### الوصف

ملف PDF واحد يجمع كل الدروس بالترتيب، مع غلاف وفهرس وأرقام صفحات وترقيم صحيح. هذا هو الخيار الأمثل للمتعلمين الذين يريدون قراءة الدورة على جوال أو طباعتها.

### المتطلبات

- **مكتبة ReportLab**: `pip install reportlab==4.2.5`
- **مكتبة arabic-reshaper**: `pip install arabic-reshaper==3.0.0`
- **مكتبة python-bidi**: `pip install python-bidi==0.4.2`
- **خط Noto Sans Arabic**: مثبّت على النظام (راجع [PDF Arabic Rendering Details](#pdf-arabic-rendering-details)).
- **skill الـ pdf**: يُستخدم كمرجع لـ ReportLab patterns.

### التوليد

```bash
python3 /home/z/my-project/skills/frappe-course-generator/scripts/build_course.py \
    --input /home/z/my-project/download/courses/frappe-developer-bootcamp \
    --format pdf \
    --output /home/z/my-project/download/courses/frappe-developer-bootcamp/exports/course.pdf
```

### الناتج

`exports/course.pdf` — ملف PDF واحد يحتوي على:

1. **صفحة الغلاف** (cover): اسم الدورة، الجمهور، المدة، التاريخ.
2. **فهرس المحتويات** (table of contents): مع أرقام صفحات قابلة للنقر.
3. **المحتوى**: كل وحدة (module) تبدأ بصفحة عنوان، ثم تُسرد دروسها.
4. **ترقيم الصفحات**: في أسفل كل صفحة (باستثناء الغلاف).
5. **التذييل**: اسم الدورة + رقم الصفحة.

### قاعدة فاصل الصفحات (Page Break Rule) — حرج جداً

> **CRITICAL**: أضف فاصل صفحات (page break) **فقط** في المواضع التالية:
>
> 1. بعد صفحة الغلاف.
> 2. بعد فهرس المحتويات.
> 3. بين الوحدات (modules) — صفحة جديدة لكل module.
>
> **لا تضيف** فاصل صفحات بين كل درس ودرس داخل نفس الوحدة. الدروس المتتالية يجب أن تتدفق بشكل طبيعي مع سطر فاصل فقط. السبب:
>
> - إذا أضفت فاصل صفحات بين كل درس، سيصبح ملف PDF ضخماً (مثلاً 300 صفحة بدلاً من 150).
> - صفحات كثيرة ستكون نصف فارغة (هدر مساحة).
> - المتعلم يضغط Next كثيراً بدلاً من التمرير السلس.

### نمط السكربت (Script Pattern)

الـ pattern العام الذي يستخدمه `scripts/build_course.py --format pdf` (انظر [PDF Arabic Rendering Details](#pdf-arabic-rendering-details) للكود الكامل):

```python
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak

def build_pdf(course_dir: str, output_path: str):
    doc = SimpleDocTemplate(output_path, pagesize=A4,
                            rightMargin=2*cm, leftMargin=2*cm,
                            topMargin=2*cm, bottomMargin=2*cm)
    story = []

    # --- Cover page ---
    story.append(Spacer(1, 6*cm))
    story.append(Paragraph(shape_arabic("دورة Frappe للمطورين"), STYLE_H1))
    story.append(PageBreak())           # ← page break #1: after cover

    # --- Table of contents ---
    story.append(Paragraph(shape_arabic("فهرس المحتويات"), STYLE_H1))
    # ... build TOC entries ...
    story.append(PageBreak())           # ← page break #2: after TOC

    # --- Content: iterate modules ---
    modules = sorted(Path(course_dir).glob("[0-9][0-9]-*"))
    for i, module_dir in enumerate(modules):
        if i > 0:
            story.append(PageBreak())   # ← page break #3: between modules ONLY

        story.append(Paragraph(shape_arabic(module_dir.name), STYLE_H1))

        # Iterate lessons in module — NO PageBreak between lessons
        for lesson_file in sorted(module_dir.glob("[0-9][0-9]-*.md")):
            md_text = lesson_file.read_text(encoding="utf-8")
            story.extend(md_to_flowables(md_text))   # helper from §10
            story.append(Spacer(1, 12))

    doc.build(story)
```

> **ملاحظة**: الدالة المساعدة `md_to_flowables()` تحوّل Markdown إلى ReportLab flowables (Paragraph, Preformatted, Table). الكود الكامل في قسم [PDF Arabic Rendering Details](#pdf-arabic-rendering-details).

### معالجة عناصر Markdown الخاصة

| العنصر | المعالجة |
|---|---|
| `# H1`, `## H2`, `### H3` | تحويل إلى ParagraphStyle مناسب |
| ```` ```python ```` code blocks | `Preformatted` بـ DejaVuMono font، LTR |
| `- bullet` lists | إضافة `•` يدوياً + TA_RIGHT |
| `1. ordered` lists | الحفاظ على الرقم + TA_RIGHT |
| `\| table \|` | تحويل إلى `Table` مع RTL column order |
| `> quote` | إضافة border يمين + لون خلفية |
| `![alt](path)` | تضمين Image (تحجيم تلقائي إلى عرض الصفحة) |
| `[text](url)` | تحويل إلى `<link href="url">text</link>` |
| `` `inline code` `` | تغيير font إلى DejaVuMono + خلفية رمادية |
| `**bold**` / `*italic*` | استخدام `<b>` / `<i>` tag داخل Paragraph |

> أخطاء PDF الشائعة (حروف منفصلة، اتجاه LTR، تداخل أسطر) موثقة بالتفصيل في [PDF Arabic Rendering Details](#pdf-arabic-rendering-details).

---

## PowerPoint (PPTX) Export

### الوصف

للمدربين الذين يريدون العرض في قاعة تدريب. كل درس يُقسّم إلى شرائح (slides) حسب الأقسام: الأهداف، المقدمة، المفاهيم، الأمثلة، الملخص. النص الكامل للدرس يوضع في speaker notes.

### المتطلبات

- **مكتبة python-pptx**: `pip install python-pptx==1.0.2`

### التوليد

```bash
python3 /home/z/my-project/skills/frappe-course-generator/scripts/build_course.py \
    --input /home/z/my-project/download/courses/frappe-developer-bootcamp \
    --format pptx \
    --output /home/z/my-project/download/courses/frappe-developer-bootcamp/exports/course.pptx
```

### الناتج

`exports/course.pptx` — ملف PowerPoint واحد يحتوي على:

- **شريحة غلاف**: اسم الدورة، الجمهور، المدة.
- **شريحة فهرس**: قائمة بالوحدات.
- **لكل وحدة**: شريحة عنوان + شرائح الدروس.
- **لكل درس**: 4-6 شرائح (الأهداف، المقدمة، المفاهيم الرئيسية، الأمثلة، الملخص).
- **Speaker notes**: النص الكامل للدرس في خانة الملاحظات لكل شريحة.

### بنية الشريحة لكل درس

شريحة واحدة لكل قسم من أقسام الدرس:

| # | عنوان الشريحة | المحتوى |
|---|---|---|
| 1 | عنوان الدرس + رقمه | عنوان كبير + رقم الدرس + اسم الوحدة |
| 2 | أهداف الدرس | bullet list بـ 3-5 أهداف |
| 3 | المقدمة | فقرة موجزة (200-300 كلمة) |
| 4 | المفاهيم الرئيسية | 3-5 bullets + شرح موجز |
| 5 | أمثلة عملية | screenshot أو code snippet |
| 6 | ملخص الدرس | 3-5 key takeaways |

### نمط السكربت

```python
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN
from pptx.dml.color import RGBColor

prs = Presentation()
prs.slide_width = Inches(13.333)   # 16:9
prs.slide_height = Inches(7.5)

# Use blank layout for full control
blank_layout = prs.slide_layouts[6]

def add_slide(title_text, body_lines, notes_text=""):
    slide = prs.slides.add_slide(blank_layout)

    # Title
    title_box = slide.shapes.add_textbox(Inches(0.5), Inches(0.3),
                                          Inches(12), Inches(1))
    tf = title_box.text_frame
    p = tf.paragraphs[0]
    p.text = title_text
    p.font.size = Pt(32)
    p.font.bold = True
    p.font.name = "Noto Sans Arabic"
    p.alignment = PP_ALIGN.RIGHT

    # Body
    body_box = slide.shapes.add_textbox(Inches(0.5), Inches(1.5),
                                         Inches(12), Inches(5.5))
    btf = body_box.text_frame
    btf.word_wrap = True
    for line in body_lines:
        para = btf.add_paragraph()
        para.text = line
        para.font.size = Pt(18)
        para.font.name = "Noto Sans Arabic"
        para.alignment = PP_ALIGN.RIGHT

    # Speaker notes
    if notes_text:
        notes_slide = slide.notes_slide
        notes_slide.notes_text_frame.text = notes_text

# Iterate lessons and add slides...
# (see scripts/build_course.py for full implementation)

prs.save("exports/course.pptx")
```

### ملاحظات

- **الخط**: استخدم "Noto Sans Arabic" أو "Arial" — كلاهما يدعم العربية في PowerPoint.
- **اتجاه الشريحة**: اضبط `PP_ALIGN.RIGHT` لكل النصوص العربية.
- **Code blocks**: ضعها في textbox منفصل بـ font "Consolas" أو "Courier New".
- **الصور**: اضبط حجمها إلى أقصى 80% من ارتفاع الشريحة.
- **عدد الشرائح**: لدورة 100 درس، توقع 400-600 شريحة. لا تتجاوز 1000 (PowerPoint يصبح بطيئاً).

---

## Web (HTML) Export

### الوصف

موقع HTML ثابت (static) مع شريط جانبي للتنقُّل، بحث فوري، دعم الجوال، ووضع ليلي. مناسب للاستضافة على GitHub Pages أو أي خادم ثابت.

### المتطلبات

- **MkDocs** (الخيار الموصى به): `pip install mkdocs==1.6.1 mkdocs-material==9.5.49`
- **بدائل**: Hugo، Jekyll، أو سكربت Python مخصص (لتعديلات دقيقة).

### التوليد

```bash
python3 /home/z/my-project/skills/frappe-course-generator/scripts/build_course.py \
    --input /home/z/my-project/download/courses/frappe-developer-bootcamp \
    --format web \
    --output /home/z/my-project/download/courses/frappe-developer-bootcamp/exports/web
```

### الناتج

```
exports/web/
├── index.html              ← الصفحة الرئيسية (README)
├── 00-cover/
│   └── index.html
├── 01-introduction/
│   ├── index.html          ← README
│   ├── 01-what-is-frappe/
│   │   └── index.html
│   └── 02-why-erpnext/
│       └── index.html
├── assets/
│   ├── images/
│   ├── code/
│   └── data/
├── search/                 ← Lunr.js index
│   └── search_index.json
└── static/
    ├── css/
    │   ├── theme.css
    │   └── theme-dark.css
    └── js/
        ├── search.js
        └── copy-code.js
```

### المزايا المطلوبة في الإصدار Web

| الميزة | الطريقة |
|---|---|
| **شريط جانبي للتنقُّل** | MkDocs Material sidebar تلقائياً من `mkdocs.yml` nav |
| **بحث فوري** | Lunr.js (مدمج في MkDocs Material) |
| **استجابة الجوال** | Material theme responsive تلقائياً |
| **الوضع الليلي** | `theme.feature.blocks.toggle` في `mkdocs.yml` |
| **زر نسخ الكود** | `markdown_extensions: - pymdownx.highlight` |
| **RTL عربي** | `direction: rtl` في `theme.language: ar` |
| **روابط داخلية صحيحة** | استخدام `{{ page.next_page.url }}` في القالب |

### نمط ملف `mkdocs.yml`

```yaml
site_name: دورة Frappe للمطورين
site_description: Bootcamp شامل لتعلم Frappe Framework
site_author: frappe-course-generator
site_url: https://user.github.io/frappe-dev-bootcamp/

theme:
  name: material
  language: ar
  direction: rtl
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - search.suggest
    - search.highlight
    - content.code.copy
    - content.code.annotate
  palette:
    - media: "(prefers-color-scheme: light)"
      scheme: default
      toggle:
        icon: material/weather-night
        name: الوضع الليلي
    - media: "(prefers-color-scheme: dark)"
      scheme: slate
      toggle:
        icon: material/weather-sunny
        name: الوضع النهاري
  font:
    text: Noto Sans Arabic
    code: JetBrains Mono

markdown_extensions:
  - admonition
  - pymdownx.highlight:
      anchor_linenums: true
      line_spans: __span
      pygments_lang_class: true
  - pymdownx.superfences
  - pymdownx.tabbed:
      alternate_style: true
  - tables
  - toc:
      permalink: true

nav:
  - الرئيسية: index.md
  - الغلاف: 00-cover/cover.md
  - المقدمة:
      - نظرة عامة: 01-introduction/README.md
      - ما هو Frappe: 01-introduction/01-what-is-frappe.md
      - لماذا ERPNext: 01-introduction/02-why-erpnext.md
  - التنصيب: 02-setup-and-installation/README.md
  # ... etc
```

### بناء الموقع

```bash
# Inside the course folder, after generating mkdocs.yml
cd /home/z/my-project/download/courses/frappe-developer-bootcamp
mkdocs build --strict --site-dir exports/web
```

`--strict` يسبب فشلاً إذا كان هناك رابط مكسور — مهم للجودة.

### استضافة GitHub Pages

```bash
# Inside the course folder
mkdocs gh-deploy --force
```

هذا يدفع المجلد `exports/web/` إلى branch `gh-pages` تلقائياً.

### سكربت Python بديل (بدون MkDocs)

إذا تعذّر تثبيت MkDocs، يمكن استخدام سكربت Python بسيط:

```python
import markdown
from pathlib import Path

def md_to_html(md_path: Path, template: str) -> str:
    md_text = md_path.read_text(encoding="utf-8")
    html_body = markdown.markdown(
        md_text,
        extensions=["fenced_code", "tables", "toc", "admonition"],
    )
    return template.replace("{{ content }}", html_body)

# Iterate all .md files and generate .html siblings
# (see scripts/build_course.py --format web for full implementation)
```

---

## Bilingual Export

### الوصف

للمتعلمين الذين يريدون النص العربي والإنجليزي جنباً إلى جنب، أو زر تبديل بين اللغتين. يُفعَّل عبر flag `--language bilingual`.

### التوليد

```bash
python3 /home/z/my-project/skills/frappe-course-generator/scripts/build_course.py \
    --input /home/z/my-project/download/courses/frappe-developer-bootcamp \
    --format web \
    --language bilingual \
    --output /home/z/my-project/download/courses/frappe-developer-bootcamp/exports/web
```

### أنماط Bilingual

| النمط | الوصف | متى يُستخدم |
|---|---|---|
| **Side-by-side** | النص العربي يميناً والإنجليزي يساراً في نفس الصفحة | للجمهور المختلط |
| **Toggle button** | زر في الأعلى يبدّل بين AR و EN | للجمهور الذي يفضّل لغة واحدة |
| **Stacked** | النص العربي أولاً ثم الإنجليزي تحته | للطباعة |

### متطلبات المحتوى Bilingual

لكي يعمل `--language bilingual`، يجب أن يحتوي كل ملف `.md` على نسختين:

```markdown
<!-- AR -->
## أهداف الدرس
بنهاية هذا الدرس، ستكون قادراً على:
- فهم بنية DocType

<!-- EN -->
## Lesson Objectives
By the end of this lesson, you will be able to:
- Understand DocType structure
```

السكربت يفصل بين القسمين بـ HTML comments `<!-- AR -->` و `<!-- EN -->` ويولّد HTML لكل لغة مع toggle.

> **ملاحظة**: توليد محتوى bilingual يضاعف زمن التوليد. استخدمه فقط عندما يطلبه المستخدم صراحةً.

---

## Build Script Reference

### الاستدعاء العام

```bash
python3 scripts/build_course.py --input <course_dir> --format <format> [options]
```

### CLI Flags

| Flag | النوع | الافتراضي | الوصف |
|---|---|---|---|
| `--input` | path | **(required)** | مسار مجلد الدورة (يحتوي على `README.md`) |
| `--format` | string | `zip` | الصيغة: `zip`, `pdf`, `pptx`, `web`, `all` |
| `--output` | path | `<input>/exports/course.<ext>` | مسار ملف/مجلد الإخراج |
| `--language` | string | `ar` | اللغة: `ar`, `en`, `bilingual` |
| `--template` | path | `assets/templates/default` | مسار قالب مخصص (لـ PDF/PPTX/Web) |
| `--include-solutions` | bool | `True` | تضمين ملفات الحلول (للتنسيقات غير المعروضة للطلاب) |
| `--compress-images` | bool | `False` | ضغط صور PNG/JPG إلى 80% جودة |
| `--no-exercises` | bool | `False` | استبعاد التمارين من الإخراج |
| `--only-modules` | list | (all) | قائمة بأرقام الوحدات (مثل `1,3,5`) لتقييد البناء |
| `--verbose` | bool | `False` | طباعة سجل تفصيلي |
| `--dry-run` | bool | `False` | محاكاة البناء دون كتابة الملفات |

### أمثلة استدعاء

#### مثال 1 — بناء الكل (الوضع الافتراضي)

```bash
python3 scripts/build_course.py \
    --input /home/z/my-project/download/courses/frappe-dev-bootcamp \
    --format all
```

#### مثال 2 — PDF فقط مع ضغط الصور

```bash
python3 scripts/build_course.py \
    --input /home/z/my-project/download/courses/frappe-dev-bootcamp \
    --format pdf \
    --compress-images \
    --verbose
```

#### مثال 3 — PPTX بدون الحلول (للطلاب)

```bash
python3 scripts/build_course.py \
    --input /home/z/my-project/download/courses/frappe-dev-bootcamp \
    --format pptx \
    --include-solutions=False
```

#### مثال 4 — Web bilingual مع وحدات مختارة

```bash
python3 scripts/build_course.py \
    --input /home/z/my-project/download/courses/frappe-dev-bootcamp \
    --format web \
    --language bilingual \
    --only-modules 1,2,3,4,5
```

#### مثال 5 — Dry run للتحقق من الجاهزية

```bash
python3 scripts/build_course.py \
    --input /home/z/my-project/download/courses/frappe-dev-bootcamp \
    --format all \
    --dry-run \
    --verbose
```

### ترتيب بناء `--format all`

عند طلب `all`، يُبنى بالترتيب التالي (لأن بعض الصيغ تعتمد على مخرجات أخرى):

1. **ZIP** أولاً (الصيغة الأساسية).
2. **PDF** ثانياً (يستخدم نفس ملفات Markdown).
3. **PPTX** ثالثاً (يستخدم نفس ملفات Markdown).
4. **Web** رابعاً (ينسخ المجلد كاملاً).

### كود الخروج (Exit Codes)

| Code | المعنى |
|---|---|
| `0` | نجاح كامل |
| `1` | خطأ في المدخلات (مجلد غير موجود، صيغة غير مدعومة) |
| `2` | خطأ في المحتوى (ملف Markdown ناقص، صيغة غير صالحة) |
| `3` | خطأ في الـ dependencies (مكتبة غير مثبتة، خط مفقود) |
| `4` | فشل التحقق من الجودة (راجع [Quality Verification](#quality-verification)) |

---

## Asset Handling

### الأصول (Assets) — ثلاثة أنواع

#### 1. الصور (Images)

**الموقع**: `assets/images/`

**التنسيقات المدعومة**: PNG، JPG، SVG، WebP.

**الإشارة في Markdown**:

```markdown
![وصف الصورة](../assets/images/architecture-diagram.png)
```

> استخدم مساراً نسبياً من ملف الدرس الحالي.

**التضمين في PDF**: السكربت يحوّل المسار النسبي إلى مطلق ويستخدم `reportlab.platypus.Image`. الصور الكبيرة (> 1MB) يجب تمرير `--compress-images`.

**التضمين في PPTX**: استخدام `slide.shapes.add_picture()`.

**التضمين في Web**: نسخ المجلد كما هو إلى `exports/web/assets/images/`.

#### 2. ملفات الكود (Code Files)

**الموقع**: `assets/code/`

**الاستخدام**: ملفات `.py` كاملة قابلة للتنزيل بجانب الدرس.

**الإشارة في Markdown**:

```markdown
راجع الملف الكامل: [`example_app.py`](../assets/code/example_app.py)
```

**في PDF**: لا تُضمّن كملفات، لكن يمكن إدراج محتواها كـ code block:

````markdown
```python
# assets/code/example_app.py
# (full file content here)
```
````

**في Web**: نسخ المجلد إلى `exports/web/assets/code/` مع إضافة روابط للتنزيل.

#### 3. البيانات التجريبية (Sample Data)

**الموقع**: `assets/data/`

**الأنواع**: CSV، JSON، XLSX.

**الإشارة في Markdown**:

```markdown
حمّل ملف البيانات: [`customers.csv`](../assets/data/customers.csv)
```

**في PDF**: إدراج أول 10 صفوف كـ table inline.

**في Web**: نسخ المجلد + إضافة "preview" widget (لـ CSV).

### قواعد التسمية

- استخدم `kebab-case` للأسماء: `architecture-diagram.png` وليس `ArchitectureDiagram.png`.
- أضف رقم الوحدة في البداية عند الحاجة: `01-install-flow.png`.
- تجنّب المسافات والرموز الخاصة في أسماء الملفات.

### حجم الأصول

| النوع | الحجم الأقصى لكل ملف | الإجراء إذا تجاوز |
|---|---|---|
| صورة PNG | 2 MB | `--compress-images` |
| صورة JPG | 1 MB | `--compress-images` |
| ملف كود | 100 KB | تقسيم إلى ملفات أصغر |
| ملف بيانات | 5 MB | تضمين عينة فقط (10 صفوف) + رابط للملف الكامل |

---

## PDF Arabic Rendering Details

> **CRITICAL SECTION** — هذه أصعب مرحلة في توليد PDF. اقرأها بعناية فائقة.

### المشكلة

اللغة العربية لها خصائص فريدة تجعل render في PDF صعباً:

1. **اتصال الحروف**: الحروف تتغير شكلها حسب موقعها (بداية، وسط، نهاية، منفرد).
2. **الاتجاه RTL**: النص يُكتب من اليمين إلى اليسار.
3. **التشكيل (Diacritics)**: الحركات (الفتحة، الضمة، الكسرة، التنوين).
4. **الأرقام**: قد تكون عربية (٠١٢٣) أو هندية (0123).
5. **خلط LTR/RTL**: عند وجود كلمات إنجليزية أو كود داخل نص عربي.

ReportLab وحده **لا يدعم** أي من هذه الخصائص. الحل: استخدام `arabic-reshaper` + `python-bidi` قبل تمرير النص إلى ReportLab.

### الحلول

#### 1. تثبيت الـ Dependencies

```bash
pip install reportlab==4.2.5 arabic-reshaper==3.0.0 python-bidi==0.4.2
```

#### 2. تثبيت خط عربي

الخط الموصى به: **Noto Sans Arabic** (مفتوح المصدر، يدعم كل الحروف).

**على Ubuntu/Debian**:

```bash
sudo apt install fonts-noto-core fonts-noto-extra
# Or specifically:
sudo apt install fonts-noto-naskh-arabic
```

**على macOS**:

```bash
brew install --cask font-noto-sans-arabic
```

**على Windows**: تنزيل من [Google Fonts](https://fonts.google.com/noto/specimen/Noto+Sans+Arabic) وتثبيت ملف `.ttf`.

**التحقق من المسار**:

```bash
# Linux
fc-list | grep -i "noto.*arabic"
# Expected output:
# /usr/share/fonts/truetype/noto/NotoSansArabic-Regular.ttf: Noto Sans Arabic:style=Regular
# /usr/share/fonts/truetype/noto/NotoSansArabic-Bold.ttf: Noto Sans Arabic:style=Bold
# /usr/share/fonts/truetype/noto/NotoNaskhArabic-Regular.ttf: Noto Naskh Arabic:style=Regular
```

#### 3. كود الـ Reshaping

```python
import arabic_reshaper
from bidi.algorithm import get_display

def shape_arabic(text: str) -> str:
    """
    تحويل النص العربي إلى صيغة قابلة للعرض في PDF.

    يقوم بـ:
    1. reshape: ربط الحروف حسب موقعها (بداية، وسط، نهاية).
    2. bidi: تطبيق خوارزمية BiDi لتحديد اتجاه كل حرف.
    """
    reshaped = arabic_reshaper.reshape(text)
    bidi_text = get_display(reshaped)
    return bidi_text

# Example:
arabic_text = "السلام عليكم ورحمة الله"
shaped = shape_arabic(arabic_text)
# Pass `shaped` to ReportLab Paragraph
```

#### 4. كود كامل لتسجيل الخط في ReportLab

```python
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase.pdfmetrics import registerFontFamily

# Register regular and bold
pdfmetrics.registerFont(TTFont("NotoArabic", "/usr/share/fonts/truetype/noto/NotoSansArabic-Regular.ttf"))
pdfmetrics.registerFont(TTFont("NotoArabic-Bold", "/usr/share/fonts/truetype/noto/NotoSansArabic-Bold.ttf"))

# Register as family (so <b> tags work)
registerFontFamily(
    "NotoArabic",
    normal="NotoArabic",
    bold="NotoArabic-Bold",
    italic="NotoArabic",       # Arabic rarely uses italic
    boldItalic="NotoArabic-Bold",
)

# For code blocks (mono font)
pdfmetrics.registerFont(TTFont("DejaVuMono", "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"))
```

#### 5. تعريف الأنماط (Paragraph Styles)

```python
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.enums import TA_RIGHT, TA_LEFT, TA_CENTER

STYLE_BODY = ParagraphStyle(
    name="Body",
    fontName="NotoArabic",
    fontSize=11,
    leading=18,                # = 1.6 * fontSize (good for Arabic)
    alignment=TA_RIGHT,        # RTL
    wordWrap="RTL",            # Critical for word wrapping
    rightIndent=0,
    leftIndent=0,
    spaceBefore=0,
    spaceAfter=6,
)

STYLE_CODE = ParagraphStyle(
    name="Code",
    fontName="DejaVuMono",     # Mono font for code
    fontSize=9,
    leading=12,
    alignment=TA_LEFT,         # Code is always LTR
    wordWrap="LTR",
    leftIndent=12,
    rightIndent=12,
    backColor="#f5f5f5",
    borderColor="#e0e0e0",
    borderWidth=0.5,
    borderPadding=6,
)
```

#### 6. خلط النص العربي مع الكود

عندما يحتوي نص عربي على كلمة إنجليزية أو code inline، يجب معالجته بحذر:

```python
import re

def shape_mixed_text(text: str) -> str:
    """
    معالجة نص يحتوي على عربي + إنجليزي/code.

    - النص العربي يمر بـ arabic_reshaper + bidi.
    - النص الإنجليزي/code يبقى كما هو.
    """
    # Split by inline code (backticks)
    parts = re.split(r"(`[^`]+`)", text)
    result = []
    for part in parts:
        if part.startswith("`") and part.endswith("`"):
            # Keep code as-is (strip backticks, wrap in <font> tag)
            code = part[1:-1]
            result.append(f'<font name="DejaVuMono" size="10">{code}</font>')
        else:
            # Shape Arabic
            if any("\u0600" <= c <= "\u06FF" for c in part):
                shaped = shape_arabic(part)
                result.append(shaped)
            else:
                result.append(part)
    return "".join(result)
```

### الأخطاء الشائعة (Pitfalls)

| المشكلة | السبب | الحل |
|---|---|---|
| الحروف منفصلة (لا تتصل) | لم يُستخدم `arabic_reshaper` | أضف `shape_arabic()` على كل نص |
| اتجاه النص LTR (يسار لليمين) | `alignment=TA_LEFT` أو لم يُضبط | استخدم `TA_RIGHT` + `wordWrap="RTL"` |
| الكلمات الإنجليزية معكوسة | `bidi` يطبق على كل النص | استخدم `shape_mixed_text()` (أعلاه) |
| التشكيل يختفي أو يظهر في مكان خطأ | خط لا يدعم التشكيل | استخدم Noto Sans Arabic (يدعمه) |
| الأرقام معكوسة (٣٢١ بدلاً من ١٢٣) | bidi يعكس الأرقام | أضف `\\u202B` في بداية الأرقام أو استخدم `arabic_reshaper.reshape()` فقط بدون bidi للأرقام |
| نص طويل يتجاوز الصفحة | `wordWrap="LTR"` بدلاً من `"RTL"` | اضبط `wordWrap="RTL"` |
| `\n` لا يظهر | ReportLab يتجاهل `\n` في Paragraph | استخدم `<br/>` tag أو `Paragraph(text.replace('\n', '<br/>'))` |
| Markdown غير مُحوَّل | تم تمرير النص الخام | استخدم `markdown.markdown()` أو محوّل مخصص قبل `Paragraph` |

### قائمة تحقق نهائية لـ PDF عربي

قبل تسليم ملف PDF، تحقق من:

- [ ] كل نص عربي مرّ بـ `shape_arabic()`.
- [ ] كل ParagraphStyle له `alignment=TA_RIGHT` و `wordWrap="RTL"` (ما عدا الكود).
- [ ] الكود يستخدم `DejaVuMono` أو `Courier` مع `alignment=TA_LEFT`.
- [ ] خط Noto Sans Arabic مسجّل (regular + bold).
- [ ] `leading >= fontSize * 1.5` لتفادي تداخل الأسطر.
- [ ] الأرقام داخل نص عربي تظهر بشكل صحيح.
- [ ] التشكيل (الحركات) يظهر في مكانه الصحيح.
- [ ] روابط `<a href>` تعمل داخل PDF.
- [ ] فاصل الصفحات فقط بين modules، وليس بين كل درس.

---

## Quality Verification

### لماذا التحقق إلزامي؟

بناء PDF أو PPTX قد "ينجح" technically لكن ينتج ملفاً معطوباً:
- PDF لا يفتح بسبب font غير مدعوم.
- حروف عربية تظهر كمربعات.
- روابط داخلية مكسورة.
- ملف بحجم 0 بايت (script فشل بصمت).
- ملف بحجم 200MB (صور غير مضغوطة).

لذا **دائماً** شغّل سكربت التحقق بعد البناء.

### سكربت التحقق

```bash
python3 /home/z/my-project/skills/frappe-course-generator/scripts/verify_course.py \
    --input /home/z/my-project/download/courses/frappe-developer-bootcamp \
    --check all
```

### قائمة الفحوصات

| الفحص | الوصف | الحد المقبول |
|---|---|---|
| `file_exists` | الملف موجود وليس فارغاً | > 1 KB |
| `pdf_opens` | PDF يفتح بلا أخطاء | pypdf تقرأ بنجاح |
| `pdf_arabic_ok` | لا توجد مربعات replacement character | 0 occurrences of `\ufffd` |
| `pdf_page_count` | عدد صفحات معقول | 10 ≤ pages ≤ 2000 |
| `pdf_file_size` | حجم الملف معقول | 10 KB ≤ size ≤ 100 MB |
| `pdf_code_highlight` | code blocks لها font mono | visual inspection |
| `pdf_links_work` | روابط داخلية تصل إلى صفحة موجودة | 0 broken |
| `zip_integrity` | ZIP يفتح ويحتوي على README.md | `unzip -t` نجاح |
| `zip_file_count` | عدد الملفات معقول | 50 ≤ files ≤ 5000 |
| `pptx_opens` | PPTX يفتح بلا أخطاء | python-pptx تقرأ بنجاح |
| `pptx_slide_count` | عدد الشرائح معقول | 50 ≤ slides ≤ 2000 |
| `web_index_exists` | `index.html` موجود | file exists |
| `web_search_index` | `search_index.json` موجود | file exists |
| `web_broken_links` | لا روابط مكسورة | 0 broken |

### نمط سكربت التحقق

```python
#!/usr/bin/env python3
"""Verify the integrity of generated course deliverables."""
import sys, json, zipfile
from pathlib import Path

def check_pdf(pdf_path: Path) -> dict:
    results = {}
    if not pdf_path.exists():
        return {"error": f"File not found: {pdf_path}"}
    results["file_size_mb"] = round(pdf_path.stat().st_size / 1024 / 1024, 2)
    try:
        from pypdf import PdfReader
        reader = PdfReader(str(pdf_path))
        results["page_count"] = len(reader.pages)
        full_text = "".join((p.extract_text() or "") for p in reader.pages)
        results["replacement_chars"] = full_text.count("\ufffd")
        results["arabic_chars"] = sum(1 for c in full_text if "\u0600" <= c <= "\u06FF")
    except Exception as e:
        return {"error": f"PDF read failed: {e}"}
    results["size_ok"] = 0.01 < results["file_size_mb"] < 100
    results["pages_ok"] = 10 <= results["page_count"] <= 2000
    results["arabic_ok"] = results["replacement_chars"] == 0
    return results

def check_zip(zip_path: Path) -> dict:
    results = {}
    if not zip_path.exists():
        return {"error": f"File not found: {zip_path}"}
    results["file_size_mb"] = round(zip_path.stat().st_size / 1024 / 1024, 2)
    try:
        with zipfile.ZipFile(zip_path, "r") as zf:
            names = zf.namelist()
            results["file_count"] = len(names)
            results["has_readme"] = any("README.md" in n for n in names)
            results["integrity"] = zf.testzip() is None
    except Exception as e:
        return {"error": f"ZIP read failed: {e}"}
    return results

if __name__ == "__main__":
    exports_dir = Path(sys.argv[1]) / "exports"
    report = {"course": sys.argv[1], "checks": {}}
    pdf = exports_dir / "course.pdf"
    if pdf.exists():
        report["checks"]["pdf"] = check_pdf(pdf)
    zipf = exports_dir / "course.zip"
    if zipf.exists():
        report["checks"]["zip"] = check_zip(zipf)
    print(json.dumps(report, indent=2, ensure_ascii=False))
    sys.exit(0 if not any("error" in c for c in report["checks"].values()) else 1)
```

### نمط تقرير التحقق

```
{
  "course": "/home/z/my-project/download/courses/frappe-dev-bootcamp",
  "checks": {
    "pdf": {
      "file_size_mb": 12.4,
      "page_count": 187,
      "replacement_chars": 0,
      "arabic_chars": 45820,
      "size_ok": true,
      "pages_ok": true,
      "arabic_ok": true
    },
    "zip": {
      "file_size_mb": 8.2,
      "file_count": 142,
      "has_readme": true,
      "integrity": true
    }
  }
}

✅ All checks passed.
```

---

## Distribution

### قنوات التوزيع

#### 1. Google Drive / Dropbox (للملفات الفردية)

```bash
# بعد بناء PDF
cp exports/course.pdf /mnt/gdrive/Courses/frappe-dev-bootcamp.pdf

# مشاركة الرابط مع المتعلمين
# Right-click → Share → "Anyone with the link"
```

**الإيجابيات**: سريع، يدعم تنزيل مباشر.
**السلبيات**: لا يوجد بحث، لا تتبع للتقدم.

#### 2. GitHub Pages (للصيغة Web)

```bash
cd /home/z/my-project/download/courses/frappe-dev-bootcamp

# Initialize git repo if not already
git init
git add .
git commit -m "Initial course content"

# Push to GitHub
git remote add origin git@github.com:user/frappe-dev-bootcamp.git
git push -u origin main

# Deploy web to GitHub Pages
mkdocs gh-deploy --force
```

الموقع سيكون متاحاً على: `https://user.github.io/frappe-dev-bootcamp/`

**الإيجابيات**: مجاني، يدعم HTTPS، يسمح بتحديثات سريعة.
**السلبيات**: محدودية حجم repo (1GB)، محدودية bandwidth (100GB/شهر).

#### 3. Print on Demand (للـ PDF)

- **Lulu.com**: ارفع PDF واطبع نسخاً ورقية عند الطلب.
- **Amazon KDP**: للنشر التجاري.
- **مطبعة محلية**: أوفِد PDF مباشرة.

**متطلبات PDF للطباعة**:
- مقاس A4 أو Letter (ليس مخصصاً للشاشة).
- الهوامش: 2.5cm على الأقل (للـ binding).
- الصور: 300 DPI.
- الفهرس: مع أرقام صفحات صحيحة.

#### 4. LMS Integration (SCORM) — إشارة موجزة

للدورات التي ستُستضاف على Moodle أو Canvas أو TalentLMS:

```bash
# Generate SCORM package
python3 scripts/build_course.py \
    --input /home/z/my-project/download/courses/frappe-dev-bootcamp \
    --format web \
    --template scorm \
    --output exports/scorm-package.zip
```

SCORM package يحتوي على:

```
scorm-package.zip
├── imsmanifest.xml         ← SCORM metadata
├── index.html              ← Launch page
├── shared/
│   └── scorm_api.js        ← LMS communication
└── content/                ← same as web export
```

> **ملاحظة**: SCORM غير مدعوم بشكل كامل في الإصدار الحالي. هذه ميزة مستقبلية (roadmap).

#### 5. بريد إلكتروني (للملفات الصغيرة)

للدورات < 25MB (حد Gmail):

```bash
# Build a lean PDF
python3 scripts/build_course.py \
    --input /home/z/my-project/download/courses/frappe-dev-bootcamp \
    --format pdf \
    --compress-images \
    --no-exercises

# Email via mutt or similar
echo "تجد مرفقاً دورة Frappe" | mutt -s "دورة Frappe" -a exports/course.pdf -- learner@example.com
```

### قائمة تحقق ما قبل التسليم

قبل تسليم الدورة للمتعلم:

- [ ] تشغيل `verify_course.py --check all` — يجب أن يمر كل شيء.
- [ ] فتح PDF على جهازين مختلفين (Linux + macOS) للتأكد من توافق الخط.
- [ ] فتح ZIP على Windows للتأكد من عدم وجود مشاكل encoding في أسماء الملفات.
- [ ] فتح Web على متصفحين (Chrome + Firefox) للتأكد من التوافق.
- [ ] اختبار روابط التنزيل.
- [ ] التأكد من تضمين `README.md` واضح في الجذر.
- [ ] إزالة ملفات `.DS_Store` و `Thumbs.db`:

```bash
find /home/z/my-project/download/courses/frappe-dev-bootcamp \
    -name ".DS_Store" -o -name "Thumbs.db" -o -name "__pycache__" \
    -exec rm -rf {} +
```

### توثيق التسليم

بعد التسليم، سجّل في `worklog.md`:

```
- Course delivered: frappe-dev-bootcamp
- Format: PDF + ZIP
- Delivery channel: Google Drive (link: https://...)
- Learner count: 12
- File sizes: PDF 12.4MB, ZIP 8.2MB
- Verification: all checks passed
```

---

## خلاصة

| المرحلة | الأمر |
|---|---|
| بناء الكل | `python3 scripts/build_course.py --input <dir> --format all` |
| بناء PDF فقط | `python3 scripts/build_course.py --input <dir> --format pdf` |
| تحقق | `python3 scripts/verify_course.py --input <dir> --check all` |
| توزيع Web | `mkdocs gh-deploy --force` |

**تذكر**:

1. صيغة ZIP هي الأساس — ابدأ بها دائماً.
2. PDF عربي يحتاج `arabic_reshaper` + `python-bidi` + Noto Sans Arabic.
3. لا تضف فاصل صفحات بين كل درس في PDF — فقط بين modules.
4. شغّل `verify_course.py` بعد كل بناء — دون استثناء.
5. للدورات الكبيرة (> 100 درس)، استخدم `--compress-images` لتقليل الحجم.

المراجع ذات الصلة:
- `references/curriculum.md` — لاختيار بنية الدورة.
- `references/lesson-blueprints.md` — لقالب كل درس.
- `references/assessment-rubrics.md` — للتقييمات.
- `frappe-docs/references/troubleshooting.md` — لمصدر الأخطاء الشائعة.
- `pdf` skill — لمرجع ReportLab الكامل.
