# Assessment Rubrics — Generation Guide

This reference defines how the Frappe Course Generator skill produces **assessments**: per-module quizzes, per-lesson exercises, the progressive project rubric, the capstone brief, and the final quiz. An AI agent reading this file should be able to generate high-quality assessments that measure real understanding — not memorization.

Assessments are the single most important indicator of course value. A course with weak assessments is just documentation in disguise. Every quiz, exercise, and rubric here must test whether the learner can **do** something useful in Frappe, not whether they can recite facts.

---

## مقدمة (Introduction)

### Assessment Philosophy

The Frappe Course Generator follows five principles when designing assessments:

1. **التطبيق على الحفظ (Application over recall)** — every question must test whether the learner can apply a concept, not whether they memorized an API signature. If a learner can answer by looking something up in 10 seconds, the question is too trivial.
2. **التدرج في الصعوبة (Graduated difficulty)** — start easy to build confidence, then medium to verify understanding, then hard to stretch the learner. The canonical distribution is **40% easy / 40% medium / 20% hard**.
3. **الواقعية (Realism)** — every exercise and project task must mirror a real-world Frappe task. If a developer would never write this code in production, don't ask the learner to write it in an exercise.
4. **الشفافية في التصحيح (Transparent grading)** — every answer must come with an explanation. The learner must understand **why** an answer is correct, not just **that** it is correct. Wrong options in MCQs must have plausible-but-clearly-incorrect reasoning.
5. **الفصل بين السؤال والإجابة (Separation of question and answer)** — answers always live in a separate file. A learner should be able to attempt the question without seeing the answer, then check their work.

### What "Good" Looks Like

A good assessment:

- Maps directly to a learning objective stated in the lesson.
- Has exactly one unambiguous correct answer (for objective questions).
- Tests a single concept per question (don't combine two unrelated ideas).
- Uses realistic Frappe code, field names, and API calls.
- Provides an explanation that teaches something, even to a learner who got it right.

### What "Bad" Looks Like

A bad assessment:

- Asks for trivia (founding dates, version numbers, person names).
- Has multiple defensibly-correct answers.
- Requires the learner to have memorized an exact parameter order.
- Reuses the same DocType name across 5 different questions (boring, doesn't test generalization).
- Provides an answer key with no explanation.

---

## Assessment Types Overview

The course uses four assessment types, each with a different purpose:

| Type | Purpose | Count per course | Length | Graded by | When delivered |
|---|---|---|---|---|---|
| **Quiz** (اختبار قصير) | Verify recall and concept recognition | 1 per module + 1 final | 5-10 Q (module), 50 Q (final) | Auto-gradable | End of each module + end of course |
| **Exercise** (تمرين) | Verify ability to apply a concept in code | 3 per lesson + 5-7 per module | 5 min - 2 hours | Self-check with solution | End of each lesson |
| **Project** (مشروع) | Verify ability to build a complete feature over time | 1 progressive project | Spans whole course | Rubric (5 criteria) | End of each module (incremental) |
| **Capstone** (مشروع التخرج) | Verify mastery of the whole course in one open-ended brief | 1 per course | 8-20 hours | Stricter rubric | End of course |

**Cognitive load by type:**

- Quiz → recognition, recall, short reasoning
- Exercise → application, analysis
- Project → synthesis, design, debugging
- Capstone → end-to-end synthesis, judgment, autonomy

The four types together cover all levels of Bloom's taxonomy from "remember" up to "create".

---

## Quiz Generation

### Per-Module Quizzes

Each module ends with a short quiz. Spec:

- **Question count**: 5-10 questions (target 8 for a typical module).
- **Coverage**: must cover every lesson in the module. If the module has 8 lessons, no lesson should be entirely missing from the quiz.
- **Question types**: mix at least 3 different types from the list below.
- **Difficulty distribution**: 40% easy, 40% medium, 20% hard. For an 8-question quiz: 3 easy, 3 medium, 2 hard.
- **File location**: `exercises/quiz.md` inside the module folder.
- **Answer file**: `exercises/quiz-solutions.md` (always separate).

### Final Quiz

The course ends with a final quiz. Spec:

- **Question count**: exactly 50 questions.
- **Coverage**: spans every module. For a 12-module course, roughly 4 questions per module (weighted by module importance).
- **Question types**: must include all 6 types listed below.
- **Difficulty distribution**: 40% easy (20 Q), 40% medium (20 Q), 20% hard (10 Q).
- **File location**: `assessments/final-quiz.md`.
- **Answer file**: `assessments/final-quiz-solutions.md` (always separate).
- **Passing score**: 70% (35/50). Learner retakes if below.

### Question Types

Six question types are supported. Each must follow its template exactly so the auto-grader (if used) can parse the file.

#### Type 1 — Multiple Choice (MCQ)

**Template:**

```markdown
**Q[N]**. [Question text in Arabic — single sentence, no more than 2 lines]

- [ ] أ. [option A]
- [ ] ب. [option B]
- [ ] ج. [option C]
- [ ] د. [option D]
```

**Example (3 questions about Frappe Framework):**

```markdown
**Q1**. ما هو الـ DocType في Frappe Framework؟

- [ ] أ. ملف Python يحتوي على دوال الـ business logic
- [ ] ب. تعريف JSON/Python يصف هيكل المستند وحقوله وسلوكه
- [ ] ج. صف في قاعدة بيانات MySQL يخزن البيانات
- [ ] د. قالب HTML لعرض المستند في المتصفح

**Q2**. أي دالة من دوال Frappe تستخدم لجلب مستند من قاعدة البيانات باسمه ونوعه؟

- [ ] أ. `frappe.get_list()`
- [ ] ب. `frappe.get_doc()`
- [ ] ج. `frappe.db.get_value()`
- [ ] د. `frappe.get_all()`

**Q3**. عند تعريف حقل من نوع `Link` في DocType، ماذا يحدد الـ `options`؟

- [ ] أ. القيمة الافتراضية للحقل
- [ ] ب. اسم الـ DocType الذي يُربط به هذا الحقل
- [ ] ج. صلاحيات المستخدم على الحقل
- [ ] د. هل الحقل إلزامي أم اختياري
```

**Anti-patterns (do NOT ask):**

- "أي مما يلي صحيح؟" without context — too vague.
- Questions with two correct answers (e.g., both `frappe.get_doc()` and `frappe.db.get_value()` can return a document field — pick the one that returns the full document).
- Questions where the answer is "all of the above" or "none of the above" — these are uninformative.

#### Type 2 — True/False

**Template:**

```markdown
**Q[N]**. [Statement in Arabic — assert one specific claim]
- [ ] صحيح
- [ ] خطأ
```

**Example:**

```markdown
**Q4**. في Frappe، كل DocType يجب أن يحتوي على حقل `name` كـ primary key في جدول قاعدة البيانات.
- [ ] صحيح
- [ ] خطأ

**Q5**. دالة `frappe.get_all()` تُرجع قائمة dict عوضاً عن كائن Document.
- [ ] صحيح
- [ ] خطأ

**Q6**. يمكن استدعاء دالة Python موجودة في `api.py` من JavaScript العميل عبر `frappe.call()` شريطة أن تكون مزينة بـ `@frappe.whitelist()`.
- [ ] صحيح
- [ ] خطأ
```

**Anti-patterns:**

- Don't write statements with two clauses where one is true and the other false (e.g., "Frappe uses MariaDB AND MongoDB"). The learner can't tell which part you're testing.
- Don't write statements that are "mostly true" or "true except in edge cases" — true/false questions must be unambiguous.

#### Type 3 — Fill-in-the-Blank

**Template:**

```markdown
**Q[N]**. [Sentence with `_____` blank] 
> الإجابة: ____________
```

**Example:**

```markdown
**Q7**. لإنشاء سجل جديد من نوع `Customer` برمجياً، نستخدم الدالة `frappe.get_doc({​"doctype": "_____", "customer_name": "Acme"})`.
> الإجابة: ____________

**Q8**. الـ decorator الذي يُستخدم لتعريض دالة Python لـ REST API هو `@frappe._____()`.
> الإجابة: ____________

**Q9**. الأمر المستخدم لتشغيل الـ migrations بعد إضافة DocType جديد هو `bench _____`.
> الإجابة: ____________
```

**Answer key for fill-in-the-blank must include the exact expected string.** Accept minor variations (e.g., `migrate` vs `migrate --site all`) and note them in the answer file.

**Anti-patterns:**

- Don't have multiple valid words for the blank (e.g., "The Frappe CLI tool is called _____" — could be `bench` or `frappe` depending on version).
- Don't make the blank a number the learner would have to memorize.

#### Type 4 — Short Answer

**Template:**

```markdown
**Q[N]**. [Open question in Arabic — answer in 1-3 sentences]
> الإجابة:
```

**Example:**

```markdown
**Q10**. اشرح الفرق بين `frappe.get_doc()` و `frappe.get_all()` في جملتين.

> الإجابة:

**Q11**. اذكر ثلاثة أنواع من الـ field types المتاحة في Frappe DocType، مع مثال على استخدام كل واحد.

> الإجابة:

**Q12**. ماذا يحدث عند تنفيذ `bench migrate`؟ اذكر خطوتين على الأقل.

> الإجابة:
```

**Anti-patterns:**

- Don't ask "explain everything you know about X" — too broad, impossible to grade consistently.
- Don't ask questions that require a paragraph — short answer means 1-3 sentences.

#### Type 5 — Code-Output Prediction

**Template:**

```markdown
**Q[N]**. ما هو الناتج المتوقع من تنفيذ الكود التالي؟

```python
[code snippet — 3-10 lines]
```

> الإجابة:
```

**Example:**

```markdown
**Q13**. ما هو الناتج المتوقع من تنفيذ الكود التالي؟

```python
import frappe

doc = frappe.get_doc({
    "doctype": "Task",
    "subject": "Test Task",
    "status": "Open"
})
print(doc.doctype)
print(doc.subject)
print(type(doc))
```

> الإجابة:
```

**Expected answer:**

```text
Task
Test Task
<class 'frappe.model.document.Document'>
```

**Anti-patterns:**

- Don't use code that raises an exception unless the question explicitly asks "ماذا يحدث؟" — predictable output is the point.
- Don't use code that depends on database state (e.g., `frappe.get_doc("Customer", "CUST-001")`) unless you provide the seed data.

#### Type 6 — Code-Completion

**Template:**

```markdown
**Q[N]**. أكمل الكود التالي لـ [goal]:

```python
[code with `_____` blank]
```

> الإجابة:
```

**Example:**

```markdown
**Q14**. أكمل الكود التالي لإنشاء مهمة (Task) جديدة وحفظها في قاعدة البيانات:

```python
import frappe

doc = frappe.get_doc({
    "doctype": _____,
    "subject": "Complete Frappe course",
    "status": "Open"
})
doc._____
```

> الإجابة:
```

**Expected answer:** `"Task"` and `insert()` (or `.save()`).

**Anti-patterns:**

- Don't leave blanks that have multiple valid completions unless the answer key lists all acceptable variants.
- Don't leave the blank at a syntax-critical position where the answer would not parse without it (e.g., a missing comma).

### Difficulty Distribution

Every quiz must follow the **40/40/20 rule**:

| Difficulty | Definition | Share | Example question style |
|---|---|---|---|
| Easy (سهل) | Direct recall or one-step application | 40% | "ما هو الـ DocType؟" — definition, single API name, true/false on a clear fact |
| Medium (متوسط) | Two-step reasoning or application | 40% | "ما الفرق بين X و Y؟" — comparison, code-output prediction, short code completion |
| Hard (صعب) | Multi-step reasoning, edge cases, debugging | 20% | "لماذا يفشل هذا الكود؟" — debugging, prediction with twist, multi-blank code |

**For an 8-question module quiz:** 3 easy, 3 medium, 2 hard.
**For the 50-question final:** 20 easy, 20 medium, 10 hard.

### Answers ALWAYS in a Separate File

This is non-negotiable. The questions file (`quiz.md`) and the answers file (`quiz-solutions.md`) must be separate files. Reasons:

1. The learner can attempt the quiz without seeing answers.
2. Instructors can hand out only the questions file.
3. The questions file can be exported alone (e.g., to LMS).

The answer file uses this template:

```markdown
# Quiz Solutions — [Module Name]

## Q1
**الإجابة الصحيحة**: ب. `frappe.get_doc()`

**التوضيح**: `frappe.get_doc()` تُرجع كائن Document كامل يمكن التعامل معه
كخاصية. `frappe.get_list()` و `frappe.get_all()` تُرجعان قائمة من dict،
بينما `frappe.db.get_value()` تُرجع قيمة واحدة فقط.

**لماذا الخيارات الأخرى خاطئة**:
- أ: `frappe.get_list()` لا تُرجع Document.
- ج: `frappe.db.get_value()` تُرجع قيمة وليس مستند.
- د: `frappe.get_all()` تُرجع قائمة وليس مستند واحد.

## Q2
...
```

---

## Exercise Generation

### Per-Lesson Exercises

Every theory lesson ends with **3 exercises** at three difficulty levels:

| # | Difficulty | Time | What it tests |
|---|---|---|---|
| 1 | Easy (سهل) | 5-10 min | Direct application of one concept from the lesson |
| 2 | Medium (متوسط) | 15-30 min | Combine 2-3 concepts from the lesson |
| 3 | Challenge (تحدي) | 1-2 hours | Open-ended, requires research or external reading |

### Per-Module Exercises

At the end of each module, the module folder contains `exercises/cumulative.md` with **5-7 cumulative exercises** that span the whole module. These are larger than per-lesson exercises and test integration of multiple lessons.

Spec:

- 5-7 exercises total.
- Each exercise uses concepts from at least 2 lessons in the module.
- Difficulty: 2 easy, 2-3 medium, 1-2 challenge.
- Solutions in `exercises/cumulative-solutions.md`.

### Difficulty Definitions (with Templates and Examples)

#### Easy Exercise

**Definition:** Direct application of one concept. The learner has seen a worked example in the lesson and is now applying the same pattern to a slightly different input.

**Time:** 5-10 minutes.

**Template:**

```markdown
### تمرين [N] (سهل) — [Title]
**المدة**: 5-10 دقائق

**المطلوب**: [One-sentence task that maps to a single lesson concept]

**السياق**: [Brief context — what DocType, what data, what goal]

**المخرجات**: [What the learner should produce — a file, a code snippet, a command]

> الحل في `exercises/solutions.md`
```

**Example:**

```markdown
### تمرين 1 (سهل) — إنشاء DocType بسيط
**المدة**: 5-10 دقائق

**المطلوب**: أنشئ DocType باسم `Book` يحتوي على الحقول التالية:

| Field name | Label | Field type |
|---|---|---|
| `title` | العنوان | Data |
| `author` | المؤلف | Data |
| `isbn` | ISBN | Data |
| `price` | السعر | Currency |

**السياق**: أنت تبني تطبيقاً صغيراً لإدارة مكتبة. هذا أول DocType فيه.

**المخرجات**: لقطة شاشة لـ DocType بعد الحفظ، أو ملف JSON المُصدَّر من DocType.

> الحل في `exercises/solutions.md`
```

**Solution:**

```markdown
### تمرين 1 (سهل) — الحل

#### إعادة صياغة المسألة
نحتاج إلى DocType باسم `Book` مع 4 حقول: title, author, isbn, price.

#### المنهج
1. انتقل إلى DocType List → Add DocType.
2. أدخل الاسم `Book` و Module `Library`.
3. أضف الحقول الأربعة بالأنواع الموضحة.
4. احفظ ثم اضغط Go to Book List.

#### الحل الكامل

```json
{
  "doctype": "DocType",
  "name": "Book",
  "module": "Library",
  "naming_rule": "Expression",
  "autoname": "field:title",
  "fields": [
    {"fieldname": "title", "label": "العنوان", "fieldtype": "Data", "reqd": 1},
    {"fieldname": "author", "label": "المؤلف", "fieldtype": "Data"},
    {"fieldname": "isbn", "label": "ISBN", "fieldtype": "Data"},
    {"fieldname": "price", "label": "السعر", "fieldtype": "Currency", "options": "SAR"}
  ]
}
```

#### الشرح
- استخدمنا `autoname: "field:title"` ليكون عنوان الكتاب هو اسم السجل.
- جعلنا `title` حقلاً إلزامياً (`reqd: 1`) لأن العنوان أساسي.
- استخدمنا `Currency` للسعر مع تحديد العملة عبر `options`.

#### أخطاء شائعة
- نسيان `module` — يفشل الحفظ.
- استخدام `fieldtype: "String"` — هذا النوع غير موجود في Frappe، الصحيح `Data`.
- وضع `reqd: 1` على ISBN مع أن بعض الكتب قد لا يكون لها ISBN.
```

#### Medium Exercise

**Definition:** Combine 2-3 concepts from the lesson. The learner has seen each concept separately; now they must combine them.

**Time:** 15-30 minutes.

**Template:**

```markdown
### تمرين [N] (متوسط) — [Title]
**المدة**: 15-30 دقيقة

**المطلوب**: [Task that requires 2-3 concepts — e.g., create DocType + write server method + add Client Script]

**السياق**: [Realistic scenario]

**المدخلات**: [What inputs the learner works with — sample data, existing DocTypes, etc.]

**المخرجات**: [What the learner produces — code file, working feature]

> الحل في `exercises/solutions.md`
```

**Example:**

```markdown
### تمرين 2 (متوسط) — حساب الخصم عند تجاوز السعر حدّاً معيناً
**المدة**: 15-30 دقيقة

**المطلوب**: على DocType `Book` الذي أنشأته في التمرين السابق:

1. أضف حقلاً باسم `discounted_price` من نوع Currency.
2. اكتب دالة Python في `api.py` تأخذ `book_name` وتُرجع `discounted_price`:
   - إذا كان `price` > 100، اخصم 10%.
   - إذا كان `price` > 200، اخصم 20%.
   - غير ذلك، لا خصم.
3. اعرض الـ `discounted_price` في Form View محدثاً فوراً عند تغيير `price` باستخدام Client Script.

**السياق**: المكتبة تريد عرض السعر بعد الخصم تلقائياً للموظف أثناء إدخال الكتاب.

**المدخلات**: DocType `Book` من التمرين السابق.

**المخرجات**: 
- ملف `api.py` محدّث.
- ملف `book.js` في Client Script.
- لقطة شاشة تُظهر التحديث الفوري.

> الحل في `exercises/solutions.md`
```

**Solution:**

```markdown
### تمرين 2 (متوسط) — الحل

#### إعادة صياغة المسألة
نحتاج إلى:
- حقل جديد `discounted_price` على DocType `Book`.
- دالة Python تحسب الخصم.
- Client Script يحدّث الحقل فوراً.

#### المنهج
1. أضف الحقل عبر DocType builder.
2. اكتب الدالة في `library/api.py` وزيّنها بـ `@frappe.whitelist()`.
3. اكتب Client Script في `library/public/js/book.js` يستدعي الدالة عبر `frappe.call()`.

#### الحل الكامل

```python
# library/api.py
import frappe

@frappe.whitelist()
def calculate_discounted_price(book_name: str) -> float:
    """Calculate the discounted price of a book."""
    book = frappe.get_doc("Book", book_name)
    price = book.price or 0
    if price > 200:
        return price * 0.8
    elif price > 100:
        return price * 0.9
    return price
```

```javascript
// library/public/js/book.js
frappe.ui.form.on("Book", {
    price: function (frm) {
        if (!frm.doc.name) {
            // سجل غير محفوظ بعد — احسب محلياً
            const price = frm.doc.price || 0;
            frm.set_value("discounted_price", calculate_local(price));
            return;
        }
        frappe.call({
            method: "library.api.calculate_discounted_price",
            args: { book_name: frm.doc.name },
            callback: function (r) {
                if (r.message !== undefined) {
                    frm.set_value("discounted_price", r.message);
                }
            }
        });
    }
});

function calculate_local(price) {
    if (price > 200) return price * 0.8;
    if (price > 100) return price * 0.9;
    return price;
}
```

#### الشرح
- الدالة `@frappe.whitelist()` ضرورية لاستدعائها من JavaScript العميل.
- في Client Script تحققنا من `frm.doc.name` لأن السجل غير المحفوظ لا يمكن جلبه من السيرفر.
- استخدمنا `frm.set_value()` بدل التعديل المباشر ليُطلق الأحداث المرتبطة.

#### أخطاء شائعة
- نسيان `@frappe.whitelist()` — يؤدي إلى `frappe.exceptions.PermissionError`.
- استدعاء `frappe.call()` قبل حفظ السجل — السيرفر لا يجد السجل.
- نسيان `callback` — التحديث لا يحدث رغم نجاح الطلب.
```

#### Challenge Exercise

**Definition:** Open-ended, requires research (reading official docs, source code, or forum). Multiple valid approaches exist.

**Time:** 1-2 hours.

**Template:**

```markdown
### تمرين [N] (تحدي) — [Title]
**المدة**: 1-2 ساعة

**المطلوب**: [Open-ended brief — what the learner must build, not how]

**السياق**: [Real-world scenario]

**القيود**: [Hard constraints — e.g., "must not exceed 100 lines", "must include error handling"]

**المعايير**: [How the solution will be judged — what makes a "good" solution]

**روابط للبحث**: [1-2 official docs URLs the learner should read]

> الحل المقترح في `exercises/solutions.md` (قد تكون هناك حلول أخرى صحيحة)
```

**Example:**

```markdown
### تمرين 3 (تحدي) — تقرير "الكتب الأكثر استعارة"
**المدة**: 1-2 ساعة

**المطلوب**: ابنِ تقريراً (Report) من نوع Script Report يعرض أعلى 10 كتب استعارةً في آخر 30 يوماً، مع عدد مرات الاستعارة لكل كتاب.

**السياق**: مدير المكتبة يريد معرفة الكتب الأكثر شعبية لإعادة الطلب.

**القيود**:
- استخدم DocTypes `Book` و `Loan` (الافتراض أن `Loan` يحتوي على `book` كـ Link و `loan_date` كـ Date).
- يجب أن يستخدم SQL واحد efficient (لا N+1 queries).
- الكود يجب أن يتعامل مع حالة عدم وجود استعارات في آخر 30 يوماً.

**المعايير**:
- صحّة النتائج.
- جودة الكود (مقروء، موثّق، يتبع conventions).
- كفاءة الاستعلام (استخدم JOIN بدل حلقة).

**روابط للبحث**:
- https://frappeframework.com/docs/user/en/desk/reports/script-reports
- https://frappeframework.com/docs/user/en/api/database

> الحل المقترح في `exercises/solutions.md`
```

**Solution:**

```markdown
### تمرين 3 (تحدي) — الحل المقترح

#### إعادة صياغة المسألة
نحتاج Script Report يُرجع أعلى 10 كتب من حيث عدد الاستعارات في آخر 30 يوماً.

#### المنهج
1. إنشاء Script Report جديد باسم "Most Borrowed Books".
2. كتابة `execute` function تأخذ `filters` وتُرجع `[columns, data]`.
3. استخدام query واحد مع JOIN و GROUP BY و ORDER BY ... LIMIT 10.

#### الحل الكامل

```python
# library/report/most_borrowed_books/most_borrowed_books.py
import frappe
from frappe import _
from frappe.utils import add_days, today


def execute(filters=None):
    columns = get_columns()
    data = get_data()
    return columns, data


def get_columns():
    return [
        {"label": _("Book Title"), "fieldname": "title", "fieldtype": "Data", "width": 300},
        {"label": _("Author"), "fieldname": "author", "fieldtype": "Data", "width": 200},
        {"label": _("Times Borrowed"), "fieldname": "count", "fieldtype": "Int", "width": 120},
    ]


def get_data():
    since = add_days(today(), -30)
    # استعلام واحد efficient مع JOIN + GROUP BY + ORDER BY + LIMIT
    return frappe.db.sql(
        """
        SELECT
            b.title AS title,
            b.author AS author,
            COUNT(l.name) AS count
        FROM `tabLoan` l
        INNER JOIN `tabBook` b ON b.name = l.book
        WHERE l.loan_date >= %s
          AND l.docstatus = 1
        GROUP BY b.name
        ORDER BY count DESC
        LIMIT 10
        """,
        (since,),
        as_dict=True,
    )
```

#### الشرح
- استخدمنا `add_days(today(), -30)` بدل `NOW() - INTERVAL 30 DAY` لتجنّب الاختلاف بين MariaDB/Postgres.
- `docstatus = 1` يضمن أن نحسب القروض المُؤكدة فقط (ليست مسودات).
- `as_dict=True` يجعل البيانات متوافقة مع شكل الأعمدة.
- `LIMIT 10` في الـ SQL بدل Python لتقليل البيانات المنقولة.

#### أخطاء شائعة
- جلب كل القروض ثم التجميع في Python — بطيء عند وجود آلاف السجلات.
- نسيان `docstatus = 1` — يحسب المسودات الملغاة.
- استخدام `frappe.db.get_all()` مع `fields=["*"]` ثم فلترة — أيضاً بطيء.

#### حلول أخرى ممكنة
- استخدام Query Report بدل Script Report — أبسط لكن أقل مرونة.
- إضافة فلاتر للتاريخ بدل 30 يوماً ثابتة — أفضل للمستخدم النهائي.
```

### Solution Format (Required for Every Exercise)

Every solution must follow this 5-part structure:

1. **إعادة صياغة المسألة** (Problem restatement) — restate the problem in your own words. Forces the learner to confirm understanding before reading the answer.
2. **المنهج** (Approach) — high-level steps, no code yet. Like a plan.
3. **الحل الكامل** (Full solution code) — the actual code, runnable, with comments.
4. **الشرح** (Explanation) — why this code works, what each non-trivial line does.
5. **أخطاء شائعة** (Common mistakes) — 3-5 mistakes the learner might have made.

Skipping any of these parts makes the solution less useful. The 5-part structure is the **mandatory template** for every solution file.

---

## Project Rubric Generation

The course includes a **progressive project**: building a custom CRM app on the Frappe Framework. Each module adds one feature, so by the end of the course the learner has a complete, working CRM.

### Progressive Project Structure

| Module | Feature added | Cumulative state of CRM |
|---|---|---|
| Module 1 (Intro) | Project brief + app skeleton | Empty `crm_app` installed on site |
| Module 2 (DocTypes) | `Lead` DocType with basic fields | Can create Leads manually |
| Module 3 (Scripting) | Server method to convert Lead → Customer | Can convert Leads |
| Module 4 (Forms) | Client Script for auto-fill + validation | Form UX improved |
| Module 5 (Permissions) | Role-based access (Sales User vs Sales Manager) | Multi-user ready |
| Module 6 (Workflows) | Lead lifecycle workflow (Open → Qualified → Converted) | Lifecycle managed |
| Module 7 (Reports) | "Pipeline by Stage" Script Report | Analytics available |
| Module 8 (REST API) | REST endpoints for Lead CRUD | Mobile app can integrate |
| Module 9 (Print) | Custom Print Format for Lead summary | Printable artifacts |
| Module 10 (Scheduler) | Daily digest of new Leads to manager | Automated emails |
| Module 11 (Testing) | Unit tests for conversion logic | CI-ready |
| Module 12 (Deployment) | Production setup with backup | Live app |

### Final Project Rubric

The cumulative project is graded on **5 criteria**, weighted as follows:

| Criterion | Weight | What it measures |
|---|---|---|
| Functionality | 40% | Does the app work? Can a user complete every workflow without errors? |
| Code quality | 25% | Is the code clean, readable, follows Frappe conventions (PEP8, naming, structure)? |
| Best practices | 20% | Permissions, validation, error handling, no SQL injection, no hardcoded secrets |
| Documentation | 10% | README, docstrings on every public function, inline comments where non-obvious |
| Testing | 5% | Unit tests for critical paths (Lead conversion, validation, REST endpoints) |

### Detailed Rubric Table

The full grading rubric (used by instructor or self-assessment):

| Criterion | Excellent (90-100%) | Good (75-89%) | Fair (60-74%) | Poor (<60%) |
|---|---|---|---|---|
| **Functionality (40%)** | كل الميزات تعمل. لا أخطاء. التدفقات مكتملة من البداية للنهاية. REST endpoints تستجيب بشكل صحيح. | ميزة واحدة أو اثنتان بهما أخطاء بسيطة لكن التطبيق usable. | عدة ميزات مكسورة لكن التطبيق يعمل بشكل أساسي. | التطبيق لا يعمل أو يتعطل عند الاستخدام الأساسي. |
| **Code quality (25%)** | كود يتبع PEP8. أسماء واضحة. ملفات منظمة حسب Frappe conventions. لا تكرار. | يتبع PEP8 بشكل عام. بعض الأسماء غير واضحة. | أخطاء PEP8 متكررة. تكرار للكود. بنية ملفات غير منتظمة. | كود غير مقروء. أسماء عشوائية. لا تنظيم. |
| **Best practices (20%)** | صلاحيات صحيحة لكل Role. validation على كل الحقول الحرجة. معالجة أخطاء كاملة. SQL parameterized. لا hardcoded secrets. | صلاحيات صحيحة بشكل أساسي. بعض الحقول بدون validation. | صلاحيات ناقصة. validation مفقود. أخطاء تظهر للمستخدم بشكل غير مهذب. | صلاحيات مفتوحة (everyone can edit). لا validation. SQL injection محتمل. |
| **Documentation (10%)** | README شامل. docstring لكل دالة عامة. تعليقات في الأماكن غير الواضحة. | README موجود. بعض docstrings ناقصة. | README ضعيف. لا docstrings تقريباً. | لا توثيق إطلاقاً. |
| **Testing (5%)** | تغطية tests للـ critical paths (Lead conversion, validation, REST). tests تُمرر. | tests للمسارات الرئيسية لكن بعضها fails. | tests موجودة لكن لا تغطي المنطق الحرج. | لا tests. |

### Scoring Guide

To compute the final grade:

1. Assign each criterion a score from 0-100 based on the rubric above.
2. Multiply each criterion score by its weight.
3. Sum the weighted scores to get the final percentage.
4. Map the percentage to a letter grade:

| Score | Grade | Interpretation |
|---|---|---|
| 90-100 | A | ممتاز — يفوق التوقعات. جاهز للنشر. |
| 80-89 | B | جيد جداً — يلبي التوقعات. جاهز للنشر بعد تحسينات بسيطة. |
| 70-79 | C | مقبول — يعمل لكن يحتاج تحسينات قبل النشر. |
| <70 | Needs Revision | يحتاج مراجعة — لا ينشر. المتعلم يعيد العمل على المعايير الضعيفة. |

**Worked example**: a learner scores:
- Functionality: 85 × 0.40 = 34.0
- Code quality: 90 × 0.25 = 22.5
- Best practices: 70 × 0.20 = 14.0
- Documentation: 80 × 0.10 = 8.0
- Testing: 60 × 0.05 = 3.0
- **Total: 81.5 → Grade B**

### Rubric File Location

The rubric is written to `project/rubric.md` in the course folder. It includes:

1. The 5-criterion table above.
2. The scoring guide.
3. A self-assessment checklist the learner ticks before submitting.
4. A list of "common reasons submissions lose points" with specific examples.

---

## Capstone Project

The capstone is a separate, **open-ended** project brief that requires applying everything from the course. Unlike the progressive project (which is guided step-by-step), the capstone gives the learner only a brief and lets them design the solution.

### Capstone Brief Example

```markdown
# Capstone — Library Management System

## المطلوب
ابنِ تطبيقاً كاملاً على Frappe Framework لإدارة مكتبة. التطبيق يجب أن يدعم:

1. **الكتب** (Books): عنوان، مؤلف، ISBN، سعر، تصنيف، عدد النسخ.
2. **الأعضاء** (Members): اسم، بريد، هاتف، تاريخ الانضمام، حالة العضوية.
3. **الاستعارات** (Loans): كتاب، عضو، تاريخ الاستعارة، تاريخ الإرجاع المتوقع، تاريخ الإرجاع الفعلي، حالة.
4. **الغرامات** (Fines): استعارة، مبلغ، حالة الدفع.

## المتطلبات الإلزامية
يجب أن يتضمن التطبيق:

- [ ] **5 DocTypes على الأقل** (الكتب، الأعضاء، الاستعارات، الغرامات، + واحد من اختيارك).
- [ ] **Custom Print Format** لاستمارة الاستعارة (Loan Receipt).
- [ ] **Workflow** كامل لدورة الاستعارة: Draft → Borrowed → Returned → Overdue.
- [ ] **REST API endpoints** لإنشاء استعارة جديدة وعرض استعارات عضو معين.
- [ ] **Custom Report** اسمه "Overdue Loans" يعرض الاستعارات المتأخرة مع حساب عدد أيام التأخير.
- [ ] **Scheduler job** يومي يفحص الاستعارات المتأخرة ويحدّث حالتها إلى "Overdue".
- [ ] **Unit tests** لمنطق حساب الغرامة (يوم تأخير = X ريال).

## القيود
- اللغة: Arabic UI labels, English code.
- لا تستخدم مكتبات خارجية غير مثبتة افتراضياً مع Frappe.
- الكود يجب أن يتبع Frappe conventions.
- يجب أن يعمل التطبيق على Frappe Framework v14 أو أحدث.

## التسليم
- ملف ZIP يحتوي على التطبيق.
- README.md يشرح التثبيت والاستخدام.
- ملف `tests/` يحتوي على tests.
- لقطة شاشة قصيرة (gif أو فيديو 30 ثانية) تُظهر التطبيق يعمل.

## زمن التسليم المتوقع
8-20 ساعة عمل.

## معايير التقييم
انظر `capstone-rubric.md`.
```

### Capstone Rubric

The capstone rubric uses the same 5 criteria as the project rubric, but with **stricter thresholds**:

| Criterion | Weight | Capstone passing threshold (vs project) |
|---|---|---|
| Functionality | 40% | Must be ≥85% (project: ≥70%) |
| Code quality | 25% | Must be ≥80% |
| Best practices | 20% | Must be ≥85% (no SQL injection, full permissions matrix, full error handling) |
| Documentation | 10% | Must be ≥75% (README must include setup + architecture diagram) |
| Testing | 5% | Must be ≥70% (cover all critical paths, not just one) |

**Capstone grade interpretation:**

| Score | Grade | Interpretation |
|---|---|---|
| 90-100 | A | ممتاز — المتعلم جاهز للعمل كمطور Frappe مستقل. |
| 80-89 | B | جيد جداً — جاهز مع إشراف خفيف. |
| 70-79 | C | مقبول — جاهز كمطور مبتدئ تحت إشراف. |
| <70 | Fail | غير مجتاز — يجب إعادة العمل. |

The capstone rubric is saved to `assessments/capstone-rubric.md`.

---

## Code-Output Prediction Questions

This question type tests the learner's understanding of **API behavior** without requiring them to write code. It's excellent for testing understanding of `frappe.get_doc`, `frappe.db.sql`, validation hooks, and lifecycle methods.

### Template

```markdown
**Q[N]**. ما هو الناتج المتوقع من تنفيذ الكود التالي؟

```python
[code snippet]
```

> الإجابة:
```

### Example 1 — `frappe.get_doc` behavior

```markdown
**Q15**. ما هو الناتج المتوقع من تنفيذ الكود التالي؟

```python
import frappe

frappe.db.delete("Task", {"subject": ("like", "%Test%")})

doc = frappe.get_doc({
    "doctype": "Task",
    "subject": "Test Task 1",
    "status": "Open"
})
doc.insert()

fetched = frappe.get_doc("Task", doc.name)
print(fetched.subject)
print(fetched.status)
print(fetched.owner)
print(fetched.creation is None)
```

> الإجابة:
```

**Expected answer:**

```text
Test Task 1
Open
<logged-in-user-email>
False
```

**Explanation in answer key:** `insert()` automatically sets `owner` to the current user and `creation` to the current timestamp. `fetched.creation is None` is therefore `False`.

### Example 2 — `frappe.db.sql` result shape

```markdown
**Q16**. ما هو الناتج المتوقع من تنفيذ الكود التالي؟

```python
import frappe

result = frappe.db.sql(
    "SELECT name, status FROM `tabTask` WHERE status = %s LIMIT 2",
    ("Open",),
    as_dict=True,
)
print(type(result))
print(len(result))
print(result[0].keys() if result else "empty")
```

> الإجابة:
```

**Expected answer:**

```text
<class 'list'>
2
dict_keys(['name', 'status'])
```

### Anti-patterns for Code-Output Questions

- Don't show code that depends on the database state without seeding it first (the example above deletes test tasks before inserting).
- Don't show code that prints an object's full repr — it's noisy and version-dependent.
- Don't show code where the answer is "raises exception" without making it explicit that's a possibility.

---

## Code-Completion Questions

This question type tests **syntax recall** and **API name recall** without requiring the learner to write a full snippet from scratch.

### Template

```markdown
**Q[N]**. أكمل الكود التالي لـ [goal]:

```python
[code with `_____` blanks]
```

> الإجابة:
```

### Example 1 — Create and save a Task

```markdown
**Q17**. أكمل الكود التالي لإنشاء مهمة (Task) جديدة وحفظها:

```python
import frappe

doc = frappe._____({
    "doctype": _____,
    "subject": "Complete Frappe course",
    "status": "Open"
})
doc._____()
```

> الإجابة:
```

**Expected answer:**
- Blank 1: `get_doc`
- Blank 2: `"Task"`
- Blank 3: `insert` (or `save`)

### Example 2 — Whitelisted API method

```markdown
**Q18**. أكمل الكود التالي لتعريض دالة Python لـ REST API:

```python
import frappe

@frappe._____()
def get_customer_count():
    return frappe.db._____("Customer")
```

> الإجابة:
```

**Expected answer:**
- Blank 1: `whitelist`
- Blank 2: `count`

### Anti-patterns for Code-Completion Questions

- Don't have multiple valid answers that differ wildly (e.g., blank could be `get_all` or `get_list` — both work, but the question should specify which is preferred).
- Don't leave the blank in a position where the code won't parse without it (e.g., inside a string literal).
- Don't make the blank a parameter value that depends on business logic — that's a short-answer question, not code-completion.

---

## Practical Lab Assessments

Practical labs are **step-by-step tasks** the learner must perform in a real Frappe instance (not just on paper). They differ from exercises in that they require the learner to navigate the UI, run real commands, and verify the result themselves.

### Lab Template

```markdown
### معمل عملي (Lab) — [Title]
**المدة**: [time]

**الهدف**: [What the learner will achieve]

**المتطلبات**: [Site state required — e.g., "ERPNext installed, Library app installed"]

#### الخطوات
1. [Step 1 — concrete action]
2. [Step 2]
3. [Step 3]
...

#### التحقق (Verification)
بعد إكمال الخطوات، نفّذ الأمر التالي في الـ terminal:

```bash
bench execute library.api.list_books
```

المتوقع أن ترى الناتج التالي:

```json
[
  {"title": "...", "author": "..."},
  ...
]
```

#### ملاحظات
- [Common gotchas]
```

### Example Lab

```markdown
### معمل عملي (Lab) — إنشاء DocType Book وإضافة 3 سجلات
**المدة**: 15 دقيقة

**الهدف**: بنهاية هذا المعمل، سيكون لديك DocType `Book` يعمل مع 3 سجلات في قاعدة البيانات.

**المتطلبات**: Frappe site شغّال، تطبيق `library` مثبّت.

#### الخطوات
1. افتح المتصفح على `http://localhost:8000/app` وادخل بحساب Administrator.
2. اذهب إلى DocType List → Add DocType.
3. أدخل الاسم `Book` واختر Module `Library`.
4. أضف الحقول التالية في الـ Fields table:
   - Row 1: `title` / العنوان / Data / Required ✓
   - Row 2: `author` / المؤلف / Data
   - Row 3: `isbn` / ISBN / Data
   - Row 4: `price` / السعر / Currency / Options: `SAR`
5. في قسم Naming، اختر Autoname = `field:title`.
6. احفظ الـ DocType.
7. اذهب إلى Book List → Add Book.
8. أضف 3 كتب ببيانات من اختيارك.

#### التحقق (Verification)
في الـ terminal، نفّذ:

```bash
bench --site default execute library.api.list_books
```

يجب أن ترى قائمة بـ 3 كتب. مثال للناتج:

```json
[
  {"title": "Clean Code", "author": "Robert Martin", "price": 150.0},
  {"title": "The Pragmatic Programmer", "author": "Hunt & Thomas", "price": 180.0},
  {"title": "Refactoring", "author": "Martin Fowler", "price": 220.0}
]
```

#### ملاحظات
- إذا ظهر خطأ "Module Library not found"، شغّل `bench migrate` ثم أعد المحاولة.
- إذا لم يظهر DocType في الـ list بعد الحفظ، اعمل `bench clear-cache`.
```

### When to Use Labs

- After setup lessons (verify the install works).
- After DocType-creation lessons (verify the DocType works).
- After deployment lessons (verify the deployment works).
- At end of each module as a "capstone lite" — a hands-on check that ties the module together.

---

## Self-Assessment Checklists

Each module ends with a **self-assessment checklist** — a list of "can you do X?" statements the learner rates themselves on. This is formative, not graded, but helps the learner identify gaps before taking the quiz.

### Template

```markdown
## قائمة التقييم الذاتي — Module [N]: [Title]

قبل الانتقال للدرس التالي، قيّم نفسك:

| # | البيان | نعم | جزئياً | لا |
|---|---|---|---|---|
| 1 | أستطيع [skill 1]. | ☐ | ☐ | ☐ |
| 2 | أستطيع [skill 2]. | ☐ | ☐ | ☐ |
| 3 | أستطيع [skill 3]. | ☐ | ☐ | ☐ |
| ... |

**النتيجة**: 
- إذا أجبت "نعم" على الكل → انتقل للدرس التالي.
- إذا أجبت "لا" على أي بند → راجع الدرس ذي الصلة.
- إذا أجبت "جزئياً" على أكثر من بند واحد → كرر التمارين.
```

### Example Checklist (Module: DocTypes)

```markdown
## قائمة التقييم الذاتي — Module 2: DocTypes

| # | البيان | نعم | جزئياً | لا |
|---|---|---|---|---|
| 1 | أستطيع إنشاء DocType جديد من scratch في الـ DocType builder. | ☐ | ☐ | ☐ |
| 2 | أعرف الفرق بين `Data`, `Text`, `Small Text`, `Long Text`. | ☐ | ☐ | ☐ |
| 3 | أستطيع تعريف حقل `Link` يربط DocType بآخر. | ☐ | ☐ | ☐ |
| 4 | أعرف كيف أجعل حقل إلزامياً (`reqd`). | ☐ | ☐ | ☐ |
| 5 | أستطيع تعريف `autoname` باستخدام حقل أو pattern. | ☐ | ☐ | ☐ |
| 6 | أعرف الفرق بين Section Break و Column Break. | ☐ | ☐ | ☐ |
| 7 | أستطيع تصدير DocType إلى JSON وعكسه. | ☐ | ☐ | ☐ |
| 8 | أعرف ماذا يفعل `bench migrate` بعد إضافة DocType جديد. | ☐ | ☐ | ☐ |

**النتيجة**: 
- 8/8 "نعم" → ممتاز، انتقل للوحدة التالية.
- 6-7 "نعم" → جيد، راجع البنود الضعيفة.
- أقل من 6 → أعد قراءة دروس الوحدة.
```

---

## Answer Key Standards

The answer key is just as important as the questions. A bad answer key teaches nothing; a good one reinforces the concept.

### Mandatory Standards

1. **Always in a separate file** — never inline with questions.
2. **Include explanation for every answer** — even multiple choice.
3. **For code questions**: show the correct code AND explain why each non-trivial line is needed.
4. **For multiple choice**: explain why the wrong options are wrong (not just why the right one is right).
5. **For fill-in-the-blank**: list acceptable variations (e.g., `migrate` and `migrate --site all` both OK).
6. **For short answer**: provide a model answer plus 2-3 acceptable alternatives.

### Answer Key File Template

```markdown
# Solutions — [Assessment Name]

> هذا الملف يحتوي على إجابات جميع الأسئلة في `quiz.md`. 
> حاول حل الأسئلة قبل النظر هنا.

## Q1
**الإجابة الصحيحة**: [letter]. [text of correct option]

**التوضيح**: [1-2 paragraphs explaining why this is correct]

**لماذا الخيارات الأخرى خاطئة**:
- [option A]: [why wrong]
- [option B]: [why wrong]
- [option C]: [why wrong]
- [option D]: [why wrong]

## Q2
...
```

### Example Answer Entry (MCQ)

```markdown
## Q2
**الإجابة الصحيحة**: ب. `frappe.get_doc()`

**التوضيح**: `frappe.get_doc()` تُرجع كائن Document كامل يمكن الوصول إلى 
حقوله كخصائص (attributes) واستدعاء دواله (مثل `.save()` و `.submit()`). 
هذا هو الخيار الصحيح عندما تحتاج التعامل مع المستند ككائن.

**لماذا الخيارات الأخرى خاطئة**:
- أ. `frappe.get_list()`: تُرجع قائمة من dict باختيار حقول محددة فقط، 
  وليس كائن Document كامل.
- ج. `frappe.db.get_value()`: تُرجع قيمة واحدة أو tuple من القيم، 
  ليست كائن Document.
- د. `frappe.get_all()`: شبيهة بـ `get_list()` وتُرجع قائمة من dict.
```

### Example Answer Entry (Code-Completion)

```markdown
## Q17
**الإجابة الصحيحة**:
- Blank 1: `get_doc`
- Blank 2: `"Task"`
- Blank 3: `insert()` (أو `save()`)

**التوضيح**:

```python
import frappe

doc = frappe.get_doc({
    "doctype": "Task",
    "subject": "Complete Frappe course",
    "status": "Open"
})
doc.insert()
```

- `get_doc({...})` ينشئ كائن Document جديد في الذاكرة (لا يحفظه بعد).
- `"doctype": "Task"` يجب أن يكون الاسم الـ snake_case للـ DocType.
- `.insert()` يحفظ السجل في قاعدة البيانات. `.save()` يحفظ أيضاً 
  لكنه يستخدم للتحديث عادةً.

**ملاحظة**: لو استخدمت `.save()` بدل `.insert()` على سجل غير محفوظ، 
فإن Frappe ينشئه تلقائياً — كلاهما صحيح هنا.
```

---

## Anti-Patterns

When generating assessments, **avoid these anti-patterns**. Each one makes the assessment less valuable.

### 1. Don't ask trivia

❌ **Bad**: "في أي سنة تأسست Frappe؟" (In what year was Frappe founded?)
✅ **Good**: "ما المشكلة التي يحلها Frappe Framework مقارنة ببناء تطبيق Django من الصفر؟"

Trivia tests memory, not understanding. Anything Googleable in 5 seconds is not worth a quiz question.

### 2. Don't ask ambiguous questions

❌ **Bad**: "ما الطريقة الصحيحة لجلب مستند في Frappe؟" — has multiple correct answers (`get_doc`, `get_all`, `db.get_value` all fetch documents in some sense).
✅ **Good**: "ما الدالة التي تُرجع كائن Document كامل يمكن استدعاء `.save()` عليه؟" — has one correct answer.

### 3. Don't require memorizing exact API signatures

❌ **Bad**: "ما ترتيب parameters في `frappe.db.sql()`؟" — the learner should be allowed to look this up.
✅ **Good**: "أي من الكود التالي يستخدم `frappe.db.sql()` بطريقة آمنة من SQL injection؟" — tests the concept, not the signature.

### 4. Don't make exercises too easy (copy-paste from lesson)

❌ **Bad**: an exercise that asks the learner to type out the exact same code shown in the lesson, only changing a string.
✅ **Good**: an exercise that asks the learner to apply the **same pattern** to a **different DocType or scenario**.

### 5. Don't make exercises too hard (require external libraries not mentioned)

❌ **Bad**: an exercise that requires `pandas` when the course never mentioned installing it.
✅ **Good**: an exercise that uses only Frappe's built-in APIs and standard library.

### 6. Don't reuse the same example across multiple questions

❌ **Bad**: every question in the quiz uses `Customer` as the DocType.
✅ **Good**: spread examples across `Customer`, `Item`, `Sales Invoice`, `Task`, `Book`, `Lead`. This tests generalization, not pattern-matching on a single familiar name.

### 7. Don't make the answer depend on Frappe version quirks

❌ **Bad**: a question whose answer changes between Frappe v13 and v14.
✅ **Good**: a question whose answer is stable across v13/v14/v15 (or which explicitly notes "for Frappe v14+").

### 8. Don't put answers in the same file as questions

❌ **Bad**: questions followed immediately by answers in `quiz.md`.
✅ **Good**: questions in `quiz.md`, answers in `quiz-solutions.md`.

### 9. Don't grade on style in objective questions

❌ **Bad**: marking an MCQ wrong because the learner's reasoning was different (but arrived at the right answer).
✅ **Good**: in MCQs, only the chosen letter matters. Reasoning matters in short answer and code questions.

### 10. Don't write questions without writing the answer first

❌ **Bad**: writing 10 questions, then realizing Q7 has no clear answer.
✅ **Good**: write the answer key **first**, then write the question that leads to it. This guarantees the question is answerable.

---

## Quality Checklist

Before declaring an assessment complete, verify **all** of the following:

- [ ] Every quiz has answers in a **separate file** (not inline).
- [ ] Every exercise has a solution with the **5-part structure** (problem restatement, approach, full code, explanation, common mistakes).
- [ ] Difficulty distribution is **40% easy / 40% medium / 20% hard** (count the questions and verify).
- [ ] Questions cover **all key concepts** from the module (cross-check against the module README's learning objectives).
- [ ] **No trivia** — no founding dates, version numbers, or person names.
- [ ] **No ambiguous questions** — every question has exactly one defensible correct answer.
- [ ] **No API-signature memorization** — questions test concepts, not parameter order.
- [ ] Code in questions is **runnable** — no syntax errors, no missing imports.
- [ ] Code in answers is **runnable** — copy-paste into a `bench console` works.
- [ ] **No repeated examples** — each question uses a different DocType or scenario where possible.
- [ ] Answer key includes **explanations** (not just the letter).
- [ ] Answer key for MCQs explains **why wrong options are wrong**.
- [ ] Answer key for code questions shows the **full correct code**, not just the missing fragment.
- [ ] Project rubric covers all **5 criteria** (Functionality, Code quality, Best practices, Documentation, Testing).
- [ ] Capstone brief lists **all mandatory requirements** explicitly as checkboxes.
- [ ] Self-assessment checklist exists for **every module**.
- [ ] All Arabic prose uses correct grammar and consistent terminology with the glossary.

---

## Sample Final Quiz

Below is a **20-question sample final quiz** covering Frappe basics. In a real course, the final quiz has 50 questions; this sample shows the structure and difficulty mix.

### Quiz File (`final-quiz.md`)

```markdown
# Final Quiz — Frappe Basics

> عدد الأسئلة: 20 | زمن الإجابة: 30 دقيقة | درجة النجاح: 70%
> الإجابات في `final-quiz-solutions.md`

## Part A — Multiple Choice (Q1-Q6, easy/medium)

**Q1**. ما هو الـ DocType في Frappe Framework؟

- [ ] أ. ملف Python يحتوي على دوال الـ business logic
- [ ] ب. تعريف JSON/Python يصف هيكل المستند وحقوله وسلوكه
- [ ] ج. صف في قاعدة بيانات MySQL يخزن البيانات
- [ ] د. قالب HTML لعرض المستند في المتصفح

**Q2**. أي دالة تستخدم لجلب كائن Document كامل من قاعدة البيانات؟

- [ ] أ. `frappe.get_list()`
- [ ] ب. `frappe.get_doc()`
- [ ] ج. `frappe.db.get_value()`
- [ ] د. `frappe.get_all()`

**Q3**. ماذا يحدد الـ `options` في حقل من نوع `Link`؟

- [ ] أ. القيمة الافتراضية
- [ ] ب. اسم الـ DocType المرتبط
- [ ] ج. صلاحيات المستخدم
- [ ] د. هل الحقل إلزامي

**Q4**. أي أمر من الأوامر التالية يُشغل الـ migrations؟

- [ ] أ. `bench update`
- [ ] ب. `bench migrate`
- [ ] ج. `bench sync`
- [ ] د. `bench install`

**Q5**. ما الـ decorator اللازم لتعريض دالة Python لـ REST API؟

- [ ] أ. `@frappe.api()`
- [ ] ب. `@frappe.expose()`
- [ ] ج. `@frappe.whitelist()`
- [ ] د. `@frappe.rest()`

**Q6**. أي ملف في الـ app يتم وضع الـ server-side Python hooks فيه؟

- [ ] أ. `hooks.py`
- [ ] ب. `setup.py`
- [ ] ج. `__init__.py`
- [ ] د. `config.py`

## Part B — True/False (Q7-Q10, easy/medium)

**Q7**. كل DocType يجب أن يحتوي على حقل `name` كـ primary key في الجدول.
- [ ] صحيح
- [ ] خطأ

**Q8**. `frappe.get_all()` تُرجع قائمة dict عوضاً عن كائن Document.
- [ ] صحيح
- [ ] خطأ

**Q9**. يمكن استدعاء دالة Python من `api.py` عبر `frappe.call()` في JavaScript العميل فقط إذا كانت مزينة بـ `@frappe.whitelist()`.
- [ ] صحيح
- [ ] خطأ

**Q10**. حقل `Link` يخزن اسم السجل المرتبط كنص عادي.
- [ ] صحيح
- [ ] خطأ

## Part C — Fill-in-the-Blank (Q11-Q13, easy/medium)

**Q11**. لإنشاء سجل جديد برمجياً، نستخدم `frappe.get_doc({"doctype": "_____", ...})`.
> الإجابة: ____________

**Q12**. الـ decorator لتعريض دالة Python هو `@frappe._____()`.
> الإجابة: ____________

**Q13**. أمر تشغيل الـ migrations هو `bench _____`.
> الإجابة: ____________

## Part D — Short Answer (Q14-Q15, medium)

**Q14**. اشرح الفرق بين `frappe.get_doc()` و `frappe.get_all()` في جملتين.
> الإجابة:

**Q15**. اذكر ثلاثة أنواع من الـ field types في Frappe مع مثال على كل واحد.
> الإجابة:

## Part E — Code-Output Prediction (Q16-Q17, medium/hard)

**Q16**. ما الناتج المتوقع؟

```python
import frappe

doc = frappe.get_doc({"doctype": "Task", "subject": "T1", "status": "Open"})
doc.insert()
fetched = frappe.get_doc("Task", doc.name)
print(fetched.subject)
print(fetched.docstatus)
```

> الإجابة:

**Q17**. ما الناتج المتوقع؟

```python
import frappe

result = frappe.db.sql(
    "SELECT status, COUNT(*) as cnt FROM `tabTask` GROUP BY status",
    as_dict=True,
)
print(type(result))
print([r["status"] for r in result] if result else "empty")
```

> الإجابة:

## Part F — Code-Completion (Q18-Q19, medium/hard)

**Q18**. أكمل الكود لإنشاء Customer جديد:

```python
import frappe

doc = frappe.get_doc({
    "doctype": _____,
    "customer_name": "Acme Corp",
    "customer_group": "All Customer Groups"
})
doc._____()
```

> الإجابة:

**Q19**. أكمل الكود لتعريف دالة متاحة عبر REST API:

```python
import frappe

@frappe._____()
def get_active_customers():
    return frappe.db._____("Customer", {"disabled": 0})
```

> الإجابة:

## Part G — Hard Question (Q20, hard)

**Q20**. الكود التالي يُفترض أن يحدّث سعر كل Item سعره أقل من 100 إلى 100. 
لكنه يحتوي على خطأ. اشرح الخطأ وكيف تصلحه:

```python
import frappe

items = frappe.get_all("Item", filters={"standard_rate": ("<", 100)}, fields=["name"])

for item in items:
    doc = frappe.get_doc("Item", item.name)
    doc.standard_rate = 100
    doc.save()
```

> الإجابة:
```

### Answer Key (`final-quiz-solutions.md`)

```markdown
# Final Quiz Solutions — Frappe Basics

## Q1 — ب
**التوضيح**: الـ DocType هو تعريف (schema) يصف حقول المستند وعلاقاته وصلاحياته،
ويولّد جدولاً في قاعدة البيانات وواجهة Form/List/Report.
**لماذا غيرها خاطئ**: أ (الـ business logic في ملفات Python منفصلة)، 
ج (صف DB هو نتيجة لا تعريف)، د (HTML template اسمه Print Format).

## Q2 — ب. `frappe.get_doc()`
**التوضيح**: تُرجع كائن Document كامل يمكن استدعاء دواله (مثل `.save()`).
**لماذا غيرها خاطئ**: أ، د (`get_list`/`get_all` تُرجعان قائمة dict)، 
ج (`db.get_value` تُرجع قيمة واحدة).

## Q3 — ب. اسم الـ DocType المرتبط
**التوضيح**: حقل `Link` يربط السجل بسجل في DocType آخر. الـ `options` يحدد 
الـ DocType الهدف (مثال: `options: "Customer"`).

## Q4 — ب. `bench migrate`
**التوضيح**: يشغّل الـ migrations (جداول جديدة، أعمدة، patches). 
`bench update` يشغّل migrate ضمن خطوات أخرى لكنه ليس الأمر المخصص.

## Q5 — ج. `@frappe.whitelist()`
**التوضيح**: يسمح بدالة Python أن تُستدعى عبر REST API أو JS العميل. 
بدونه تُرفض الطلبات بـ `PermissionError`.

## Q6 — أ. `hooks.py`
**التوضيح**: ملف `hooks.py` في جذر التطبيق يحتوي على `doc_events`، 
`override_whitelisted_methods`، `scheduled_tasks`، إلخ.

## Q7 — خطأ
**التوضيح**: Frappe يضيف حقل `name` تلقائياً كـ primary key لكل DocType.

## Q8 — صحيح
**التوضيح**: `frappe.get_all()` تُرجع قائمة dict بالحقول المطلوبة فقط، 
أخف من `get_doc()` التي تُرجع كائنات كاملة.

## Q9 — صحيح
**التوضيح**: بدون `@frappe.whitelist()` تُرفض الطلبات من المستخدمين 
غير المصرّح لهم.

## Q10 — صحيح
**التوضيح**: حقل `Link` يخزن **اسم** السجل المرتبط كنص، ويُستخدم 
لاحقاً لجلب البيانات.

## Q11 — `"Task"` (أو أي اسم DocType صالح)
**التوضيح**: الـ `"doctype"` key يحدد نوع المستند. القيمة يجب أن تكون 
اسم DocType موجود.

## Q12 — `whitelist`
**التوضيح**: `@frappe.whitelist()` هو الـ decorator القياسي لتعريض 
دالة Python لـ REST API.

## Q13 — `migrate`
**التوضيح**: `bench migrate` يشغّل الـ migrations.

## Q14 — إجابة نموذجية
- `frappe.get_doc()` تُرجع كائن Document كامل يمكن استدعاء دواله.
- `frappe.get_all()` تُرجع قائمة dict بالحقول المطلوبة فقط (أخف).

**بدائل مقبولة**: أي إجابة تذكر أن `get_doc` يُرجع Document و 
`get_all` يُرجع قائمة dict.

## Q15 — إجابة نموذجية (أي 3 من القائمة)
- `Data`: نص قصير، مثل `customer_name`.
- `Text`: نص متعدد الأسطر، مثل `description`.
- `Link`: مرجع لـ DocType آخر، مثل `customer`.
- `Int`: عدد صحيح، مثل `quantity`.
- `Currency`: مبلغ مالي، مثل `rate`.
- `Date`: تاريخ، مثل `transaction_date`.

## Q16
```text
T1
0
```
**التوضيح**: `fetched.subject` = "T1" (القيمة التي أدخلناها). 
`docstatus` = 0 لأن `insert()` ينشئ السجل كمسودة (Draft). 
(1 = Submitted، 2 = Cancelled).

## Q17
- السطر الأول: `<class 'list'>`
- السطر الثاني: قائمة بحالات الـ Tasks الموجودة في القاعدة 
  (مثل `['Open', 'Closed']`) أو `[]` إذا لم تكن هناك مهام.

**التوضيح**: `frappe.db.sql(..., as_dict=True)` تُرجع list of dicts. 
النوع (list) ثابت لكن المحتوى يعتمد على البيانات.

## Q18
- Blank 1: `"Customer"`
- Blank 2: `insert()` (أو `save()`)

```python
doc = frappe.get_doc({
    "doctype": "Customer",
    "customer_name": "Acme Corp",
    "customer_group": "All Customer Groups"
})
doc.insert()
```

**التوضيح**: `"doctype"` يجب أن يكون اسم DocType موجود. 
`.insert()` يحفظ السجل الجديد في قاعدة البيانات.

## Q19
- Blank 1: `whitelist`
- Blank 2: `get_all` (أو `get_list`)

```python
@frappe.whitelist()
def get_active_customers():
    return frappe.db.get_all("Customer", {"disabled": 0})
```

**التوضيح**: `@frappe.whitelist()` يسمح بالاستدعاء من العميل. 
`frappe.db.get_all()` تجلب سجلات Customer التي `disabled = 0`.

## Q20 — Hard
**الخطأ الرئيسي**: **N+1 query problem** — لكل Item نجلب Document كامل 
ونحفظه. بطيء جداً عند وجود آلاف الـ Items.

**الخطأ الأهم**: `doc.save()` يطلق جميع الـ hooks (`validate`, `on_update`) 
مما قد يسبب آثاراً جانبية غير مرغوبة. الأفضل استخدام `frappe.db.set_value()`:

```python
import frappe

items = frappe.get_all("Item", filters={"standard_rate": ("<", 100)}, pluck="name")

for name in items:
    frappe.db.set_value("Item", name, "standard_rate", 100, update_modified=False)
```

- `pluck="name"` يجلب قائمة names فقط (أخف من list of dicts).
- `frappe.db.set_value()` يحدّث القيمة مباشرة في SQL بدون تحميل Document.
- `update_modified=False` يمنع تحديث `modified` و `modified_by` (اختياري).

**بدائل مقبولة**: ذكر أي من: N+1 problem، `save()` يطلق hooks، 
استخدام `db.set_value` بدل `save()`، استخدام `frappe.db.sql("UPDATE ...")` 
للتحديث الجماعي.
```

---

## Closing Notes for the Agent

When generating assessments, remember:

1. **Quality over quantity** — a 5-question quiz with great explanations is better than a 20-question quiz with weak ones.
2. **Test behavior, not memorization** — every question should test whether the learner can do something useful.
3. **Write the answer first** — if you can't write a clear answer, you can't write a clear question.
4. **Keep examples diverse** — rotate DocTypes and scenarios so the learner sees the breadth of Frappe.
5. **Respect the learner's time** — every minute spent on a poorly-designed question is a minute wasted.

Use the templates in this file as the **mandatory starting point** for every assessment. Deviate only when you have a strong pedagogical reason — and document that reason in the assessment file's header.
