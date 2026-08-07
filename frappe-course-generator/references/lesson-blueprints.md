# Lesson Blueprints — دليل توليد الدروس

This file is the **style guide for every lesson** the `frappe-course-generator` skill produces. An AI agent reads this file before generating any lesson, exercise, quiz, or project step. It defines the five lesson types, complete worked examples, code-block standards, translation rules, cross-reference conventions, anti-patterns, and a pre-flight quality checklist.

> **القاعدة الذهبية**: كل درس يجب أن يكون **قائماً بذاته** — يستطيع المتعلم قراءته وفهمه دون الرجوع إلى دروس أخرى. الروابط بين الدروس للسياق وليس للتبعية.

---

## Table of Contents

1. [مقدمة](#مقدمة)
2. [Lesson Types Overview](#lesson-types-overview)
3. [Lesson Type 1: Theory Lesson (درس نظري)](#lesson-type-1-theory-lesson)
4. [Lesson Type 2: Practical Lesson (درس تطبيقي)](#lesson-type-2-practical-lesson)
5. [Lesson Type 3: Exercise Lesson (درس تمارين)](#lesson-type-3-exercise-lesson)
6. [Lesson Type 4: Quiz Lesson (درس اختبار قصير)](#lesson-type-4-quiz-lesson)
7. [Lesson Type 5: Project Step (خطوة مشروع)](#lesson-type-5-project-step)
8. [Module README Blueprint](#module-readme-blueprint)
9. [Course README Blueprint](#course-readme-blueprint)
10. [Code Block Standards](#code-block-standards)
11. [Exercise Standards](#exercise-standards)
12. [Quiz Standards](#quiz-standards)
13. [Translation & Terminology Rules](#translation--terminology-rules)
14. [Cross-Reference Rules](#cross-reference-rules)
15. [Anti-Patterns](#anti-patterns)
16. [Quality Checklist](#quality-checklist)

---

## مقدمة

يولّد هذا المهارة خمسة أنواع من الدروس. كل نوع له هدف تعليمي مختلف، بنية مختلفة، ومعايير طول مختلفة. اختيار النوع الصحيح لكل درس هو أول قرار يتخذه الوكيل عند توليد المنهج.

### الأنواع الخمسة

1. **درس نظري (Theory Lesson)** — يقدّم مفاهيم جديدة، يشرح المعمارية، يعرّف المصطلحات. لا يكتب فيه المتعلم كوداً.
2. **درس تطبيقي (Practical Lesson)** — يد ليد المستخدم خطوة بخطوة خلال مهمة محددة (إنشاء DocType، تثبيت bench، تكوين role).
3. **درس تمارين (Exercise Lesson)** — نهاية الوحدة، جلسة تطبيق على مفاهيم الوحدة كلها.
4. **درس اختبار قصير (Quiz Lesson)** — نهاية الوحدة، فحص سريع للمعرفة بأسئلة موضوعية.
5. **خطوة مشروع (Project Step)** — كل خطوة تبني ميزة في التطبيق التقدمي الذي يصاحب الدورة (مثلاً تطبيق CRM مخصص).

### متى تستخدم أي نوع

- **بداية الوحدة**: درس نظري يقدّم المفهوم، ثم دروس تطبيقية متتالية تبني المهارة.
- **منتصف الوحدة**: دروس تطبيقية، أو خطوة مشروع (إن كانت الوحدة تساهم في التطبيق التقدمي).
- **نهاية الوحدة**: درس تمارين **ثم** درس اختبار قصير (بترتيب صارم — التمارين قبل الاختبار).

> **تنبيه**: لا تضع اختباراً قبل التمارين. المتعلم يحتاج إلى التطبيق أولاً ثم التقييم.

---

## Lesson Types Overview

| # | Type (EN) | Type (AR) | Length (words) | When to use | Has code? | Has exercises? | Has solutions? |
|---|-----------|-----------|----------------|-------------|-----------|----------------|----------------|
| 1 | Theory | درس نظري | 800–1500 | تقديم المفاهيم، المعمارية، التعريفات | نعم (أمثلة توضيحية) | 3 (easy/medium/challenge) | في ملف منفصل |
| 2 | Practical | درس تطبيقي | 600–1200 | خطوة بخطوة، تكوين، تثبيت | نعم (كود كامل قابل للتشغيل) | 3 (اختياري) | في ملف منفصل |
| 3 | Exercise | درس تمارين | 400–800 + 5–7 تمارين | نهاية الوحدة | قليل (في التمارين) | 5–7 تمارين متدرجة | في ملف منفصل |
| 4 | Quiz | درس اختبار قصير | 200–400 + 5–10 أسئلة | نهاية الوحدة | في أسئلة code-output | 5–10 أسئلة | في ملف منفصل |
| 5 | Project Step | خطوة مشروع | 700–1400 | كل ميزة جديدة في التطبيق التقدمي | نعم (كود كامل) | 1 تمرين تحقق | في ملف منفصل |

### صيغة اسم الملف

```
<NN>-<kebab-case-title>.md      ← في الفهرس الأبجدي للأرقام فقط
```

أمثلة:

```
01-what-is-frappe.md
02-install-bench.md
03-create-doctype.md
99-exercises-doc-types.md      ← درس التمارين
99-quiz-doc-types.md           ← درس الاختبار (بعد التمارين)
```

استخدم `99-` للدروس الختامية للوحدة (تمارين، اختبار) حتى تظهر في نهاية القائمة.

---

## Lesson Type 1: Theory Lesson

### متى تستخدمه

- تقديم مفهوم جديد للمرة الأولى (مثل "ما هو DocType؟").
- شرح المعمارية أو نمط تصميم على مستوى عالٍ.
- تعريف المصطلحات والمفاهيم المجردة.
- مقارنة بين خيارين أو أكثر (مثل `bench` vs `docker`).

لا تستخدمه للأمور التي تتطلب تطبيقاً يدوياً — استخدم Practical Lesson بدلاً من ذلك.

### البنية

```markdown
# [الدرس N]: [العنوان]

> **المدة**: X دقيقة | **المستوى**: مبتدئ/متوسط/متقدم | **المتطلبات السابقة**: [Lesson X]

## أهداف الدرس
بنهاية هذا الدرس، ستكون قادراً على:
- [Objective 1]
- [Objective 2]
- [Objective 3]

## المقدمة
[2–3 فقرات تقدّم الموضوع بالعربية]

## الشرح
### [قسم فرعي 1]
### [قسم فرعي 2]
### [قسم فرعي 3]

## أمثلة عملية
[1–2 أمثلة محلّلة مع كود كامل]

## أخطاء شائعة
- [Mistake 1 — كيف تتجنبه]
- [Mistake 2 — كيف تتجنبه]
- [Mistake 3 — كيف تتجنبه]

## ملخص الدرس
- [Takeaway 1]
- [Takeaway 2]
- [Takeaway 3]

## تمارين
1. [Exercise 1 — easy]
2. [Exercise 2 — medium]
3. [Exercise 3 — challenge]

> الحلول في `exercises/solutions.md`

## الخطوة التالية
الدرس التالي: [Lesson N+1: Title] →
```

### الطول

- **الحد الأدنى**: 800 كلمة من المتن (باستثناء الكود).
- **الحد الأعلى**: 1500 كلمة.
- **الكود**: لا يُحسب ضمن الـ800–1500.
- إن تجاوز 1500 كلمة، قسّم الدرس إلى درسين.

### مثال كامل: "ما هو DocType في Frappe Framework؟"

```markdown
# الدرس 5: ما هو DocType في Frappe Framework؟

> **المدة**: 35 دقيقة | **المستوى**: مبتدئ | **المتطلبات السابقة**: الدرس 4 (Bench CLI Basics)

## أهداف الدرس
بنهاية هذا الدرس، ستكون قادراً على:
- تعريف DocType (نوع المستند) بكلتا صفتيه: مخطط وصف Python.
- شرح ما يحدث عند حفظ DocType (إنشاء جدول، توليد Controller، تحديث الـ cache).
- التمييز بين DocType و Custom Field.
- قراءة JSON schema لـ DocType وتحديد الحقول والأذونات.

## المقدمة

عندما تفتح ERPNext لأول مرة وترى نماذج مثل "Customer" و"Sales Invoice"، فأنت ترى نتاج نظام يُسمى DocType. هذا النظام هو قلب Frappe Framework، وكل ما تبنيه عليه — من تطبيقات صغيرة إلى ERPNext نفسه — يبدأ بتعريف DocType.

الـ DocType ليس مجرد جدول في قاعدة البيانات. إنه **مخطط + سلوك**: يصف الحقول وأنواعها (المخطط)، ويصف ما يحدث قبل الحفظ وبعده (السلوك عبر Controller). هذا الاقتران بين البيانات والمنطق هو ما يميز Frappe عن أطر العمل التي تفصل المخطط عن الكود.

## الشرح

### DocType هو مخطط

الـ DocType يُخزَّن كسجل في جدول اسمه `tabDocType`. كل حقل من حقول DocType يُخزَّن في جدول اسمه `tabDocField`. هذا يعني أن **المخطط نفسه بيانات** — يمكنك الاستعلام عنه، تعديله برمجياً، أو تصديره.

عندما تنشئ DocType باسم `Task` وتضيف إليه حقلاً `title` من نوع `Data`، يحدث الآتي:

1. يُضاف سجل إلى `tabDocType` باسم `Task`.
2. يُضاف سجل إلى `tabDocField` يصف الحقل `title`.
3. ينشئ Frappe جدولاً جديداً في قاعدة البيانات باسم `tabTask` بعمود `title varchar(140)`.
4. يُولِّد Frappe كلاس Python باسم `Task` يرث من `frappe.model.document.Document`.
5. تُحدَّث ذاكرة الـ metadata cache لكل العمليات.

### DocType هو صف Python

إلى جانب المخطط، كل DocType له Controller — ملف Python يعرّف سلوك المستند عبر دوال تُسمى lifecycle hooks (خطافات دورة الحياة):

```python
import frappe
from frappe.model.document import Document

class Task(Document):
    # يُستدعى قبل الحفظ دائماً — للتحقق من صحة البيانات
    def validate(self):
        if self.due_date and self.due_date < frappe.utils.today():
            frappe.throw("Due date cannot be in the past", frappe.ValidationError)

    # يُستدعى بعد الحفظ في قاعدة البيانات
    def on_update(self):
        if self.assigned_to and self.has_value_changed("assigned_to"):
            frappe.sendmail(
                recipients=[self.assigned_to],
                subject=f"Task assigned: {self.title}",
                message=f"You have been assigned to task {self.name}",
            )
```

أهم دورة حياة:

| Hook | متى يُستدعى | الاستخدام الشائع |
|------|-------------|------------------|
| `before_insert` | قبل الإدراج في DB | تعيين قيم افتراضية |
| `validate` | قبل الحفظ دائماً | التحقق من صحة البيانات |
| `on_update` | بعد الحفظ | إرسال إشعارات، تحديث جداول مرتبطة |
| `on_submit` | بعد الإرسال (للـ Submittable) | تشغيل منطق موافق عليه |
| `on_trash` | قبل الحذف | منع الحذف أو تنظيف روابط |

### DocType vs Custom Field

هذا تمييز حاسم:

- **DocType** — نوع جديد تماماً تنشئه في تطبيقك (مثل `Task`، `Library Member`).
- **Custom Field** — حقل تضيفه إلى DocType موجود (مثل إضافة `custom_tax_number` إلى `Customer` القياسي في ERPNext) دون تعديل الكود الأصلي.

استخدم DocType عندما تبني نموذجاً جديداً. استخدم Custom Field عندما تريد توسيع نموذج موجود دون للمس الكود الأصلي (حتى لا تخسر التعديلات عند الترقية).

## أمثلة عملية

### مثال 1: DocType بسيط باسم Library Member

الـ JSON المختصر للـ DocType:

```json
{
  "doctype": "DocType",
  "name": "Library Member",
  "module": "Library",
  "naming_rule": "Expression",
  "autoname": "LIB-MEMBER-.#####",
  "fields": [
    { "fieldname": "full_name", "fieldtype": "Data", "label": "Full Name", "reqd": 1 },
    { "fieldname": "email", "fieldtype": "Data", "label": "Email", "options": "Email", "unique": 1 }
  ],
  "permissions": [
    { "role": "Library Manager", "read": 1, "write": 1, "create": 1, "delete": 1 },
    { "role": "Librarian", "read": 1, "write": 1, "create": 1 }
  ]
}
```

الـ Controller المقابل:

```python
import frappe
from frappe.model.document import Document

class LibraryMember(Document):
    def validate(self):
        # التأكد من أن البريد الإلكتروني فريد على مستوى قاعدة البيانات
        if frappe.db.exists("Library Member", {"email": self.email, "name": ("!=", self.name)}):
            frappe.throw(f"Email {self.email} already exists", frappe.DuplicateEntryError)
```

عند تشغيل `bench migrate`، ينشئ Frappe جدول `tabLibrary Member` بأعمدة `full_name`, `email`, إضافة إلى أعمدة نظام (`name`, `creation`, `modified`, `owner`, ...).

## أخطاء شائعة

- **استخدام جمع في اسم الـ DocType** (مثل `Tasks` بدلاً من `Task`). القاعدة: الاسم مفرد دائماً. الجمع يكسر اصطلاحات Frappe ويُربك تلقائية الجداول الفرعية.
- **الخلط بين `validate` و `on_update`**: لا تضع منطق تعديل البيانات في `on_update` — سيُنفَّذ بعد الحفظ، وتعديلك لن يُحفظ. ضع التحقق في `validate` والآثار الجانبية (إرسال بريد، تحديث جداول أخرى) في `on_update`.
- **عدم تعيين `module`**: بدون module صحيح، لا يمكن تصدير DocType كـ fixture ولا نقله بين البيئات.
- **استخدام `frappe.throw("msg")` بدون Exception class**: دائماً مرّر صنف الخطأ (`frappe.ValidationError`، `frappe.DuplicateEntryError`) حتى يستطيع المتعلم catch أنواعاً محددة.

## ملخص الدرس

- DocType = مخطط (JSON في `tabDocType`/`tabDocField`) + سلوك (Python Controller).
- حفظ DocType ينشئ جدولاً ويولّد Controller ويحدّث الـ cache.
- Lifecycle hooks تتيح لك التدخل: `validate` للتحقق، `on_update` للآثار الجانبية، `on_submit` للمنطق النهائي.
- لا تخلط بين DocType (نوع جديد) و Custom Field (حقل على نوع موجود).

## تمارين

1. **(سهل)** اكتب JSON片段 لـ DocType باسم `Book` يحتوي على حقول `title` (Data, مطلوب) و `isbn` (Data, فريد) و `status` (Select بقيم Available/Borrowed).
2. **(متوسط)** أضف Controller لـ `Book` يمنع الحفظ إذا كان `isbn` يحتوي على أحرف غير أرقام أو شرطات. اطبع رسالة خطأ واضحة.
3. **(تحدي)** صمم DocType باسم `Library Transaction` يربط `Library Member` بـ `Book` مع تواريخ إعارة وإرجاع. اكتب منطقاً في `validate` يمنع الإعارة إذا كان لدى العضو أكثر من 3 كتب معارة. ابحث في توثيق Frappe عن `frappe.db.count`.

> الحلول في `exercises/solutions.md`

## الخطوة التالية

الدرس التالي: [الدرس 6: إنشاء DocType جديد باسم Task مع الحقول الأساسية] →
```

---

## Lesson Type 2: Practical Lesson

### متى تستخدمه

- خطوة بخطوة لتثبيت أداة أو تكوين إعداد.
- إنشاء DocType جديد ومشاهدته في Desk.
- تكوين Role و Permissions.
- أي مهمة "اعمل هذا ثم هذا ثم هذا".

الفرق عن Theory Lesson: المتعلم يفتح Terminal أو Desk وينفّذ معك. الكود هنا **تعليمات ينفذها المتعلم**، لا مجرد توضيح.

### البنية

```markdown
# [الدرس N]: [العنوان]

> **المدة**: X دقيقة | **المستوى**: ... | **المتطلبات السابقة**: [Lesson X]

## أهداف الدرس
بنهاية هذا الدرس، ستكون قادراً على:
- [Skill 1]
- [Skill 2]

## السيناريو
[فقرة تصف الموقف الواقعي الذي يحلّه الدرس]

## التنفيذ خطوة بخطوة

### الخطوة 1: [العنوان]
[شرح قصير]
```bash
<command>
# Output: ...
```

### الخطوة 2: [العنوان]
...

### الخطوة 3: [العنوان]
...

## التحقق
[كيف يتأكد المتعلم أن العمل نجح — أمر، صفحة Desk، اختبار]

## استكشاف الأخطاء وإصلاحها
| الخطأ | السبب | الإصلاح |
|------|-------|---------|
| ... | ... | ... |

## تمارين (اختياري)
1. ...
2. ...

## الخطوة التالية
الدرس التالي: [Lesson N+1: Title] →
```

### الطول

- 600–1200 كلمة من الشرح + الأوامر.

### مثال كامل: "إنشاء DocType جديد باسم Task مع الحقول الأساسية"

```markdown
# الدرس 6: إنشاء DocType جديد باسم Task مع الحقول الأساسية

> **المدة**: 45 دقيقة | **المستوى**: مبتدئ | **المتطلبات السابقة**: الدرس 5 (ما هو DocType)

## أهداف الدرس
بنهاية هذا الدرس، ستكون قادراً على:
- إنشاء DocType عبر واجهة Desk.
- إضافة حقول بأنواع مختلفة (Data, Select, Date, Link, Table).
- ضبط الأذونات (Permissions) لأكثر من Role.
- تشغيل `bench migrate` ومشاهدة الجدول الجديد في قاعدة البيانات.

## السيناريو

تطبيق ERPNext الذي تستخدمه لا يحتوي على نظام مهام بسيط. مديرك يطلب منك إنشاء DocType باسم `Task` لتسجيل المهام الداخلية للموظفين: عنوان، حالة، أولوية، تاريخ استحقاق، الموظف المسؤول، وقائمة عناصر فرعية.

## التنفيذ خطوة بخطوة

### الخطوة 1: فتح قائمة DocType

1. في الـ Awesome Bar (شريط البحث العلوي)، اكتب `DocType List` واضغط Enter.
2. اضغط زر **Add New** (إضافة جديد) أعلى اليسار.

### الخطوة 2: ملء الحقول الأساسية

أدخل القيم التالية في رأس الـ DocType:

| الحقل | القيمة |
|------|-------|
| Name | `Task` |
| Module | `Tasks` |
| Naming Rule | `Expression` |
| Auto Name | `TASK-.#####` |
| Title Field | `title` |
| Track Changes | ✓ |

> **تنبيه**: تأكد أن الـ Module موجود في `tasks/tasks/modules.txt`. إن لم يكن، أضف `Tasks` في سطر جديد.

### الخطوة 3: إضافة الحقول

في قسم **Fields**، أضف الصفوف التالية بالترتيب:

| fieldname | fieldtype | label | options | reqd | in_list_view |
|-----------|-----------|-------|---------|------|--------------|
| `title` | Data | Title | — | ✓ | ✓ |
| `status` | Select | Status | `Open\nIn Progress\nCompleted\nCancelled` | ✓ | ✓ |
| `priority` | Select | Priority | `Low\nMedium\nHigh\nUrgent` | — | ✓ |
| `column_break_1` | Column Break | — | — | — | — |
| `due_date` | Date | Due Date | — | — | — |
| `assigned_to` | Link | Assigned To | `User` | — | — |
| `section_break_items` | Section Break | Items | — | — | — |
| `items` | Table | Items | `Task Item` | — | — |

> ملاحظة: حقل `Task Item` هو DocType فرعي (Child Table) يجب أنشأه أولاً. أنشئه بنفس الطريقة: Name=`Task Item`، Module=`Tasks`، حقلان `description` (Text) و `qty` (Int).

### الخطوة 4: ضبط الأذونات

في قسم **Permissions**، أضف صفين:

| Role | read | write | create | delete | submit | cancel | report | export |
|------|------|-------|--------|--------|--------|--------|--------|--------|
| System Manager | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Tasks User | ✓ | ✓ | ✓ | — | — | — | ✓ | ✓ |

### الخطوة 5: حفظ DocType وتشغيل migrate

1. اضغط **Save** ثم **Go to DocType List**.
2. في الـ Terminal:

```bash
cd ~/frappe-bench
bench --site mysite.localhost migrate
# Output: Migrating mysite.localhost
# Updating DocTypes       [========================================] 100%
# Success: Migrate completed in 4.21s
```

### الخطوة 6: التأكد من إنشاء الجدول

```bash
bench --site mysite.localhost console
# Output: >>> frappe console <<<
```

داخل الـ console:

```python
frappe.db.sql("DESCRIBE tabTask")
# Output: list of column tuples
# [('name', 'varchar(140)'), ..., ('title', 'varchar(140)'), ('status', 'varchar(140)'), ...]
```

## التحقق

للتأكد أن كل شيء يعمل:

1. اكتب `Task List` في الـ Awesome Bar.
2. اضغط **Add New Task**.
3. املأ العنوان `اختبار المهمة`، الحالة `Open`، الأولوية `High`.
4. اضغط **Save**.
5. يجب أن يظهر الاسم تلقائياً بالشكل `TASK-00001`.

```bash
bench --site mysite.localhost console <<'EOF'
frappe.get_last_doc("Task")
# Output: <Task: TASK-00001 title=اختبار المهمة>
EOF
```

## استكشاف الأخطاء وإصلاحها

| الخطأ | السبب | الإصلاح |
|------|-------|---------|
| `Module Does Not Exist: Tasks` | الـ Module غير مُعلَن في `modules.txt` | أضف سطر `Tasks` إلى `tasks/tasks/modules.txt` وأعد `bench migrate` |
| `Unknown column 'title'` بعد الحفظ | نسيت `bench migrate` | شغّل `bench --site X migrate` |
| لا تظهر قائمة Task في الـ Awesome Bar | الـ Role الحالي ليس له صلاحية `read` | أضف Role المستخدم الحالي إلى قسم Permissions |
| `ValueError: invalid option for Select` | خيارات الـ Select مفصولة بفاصلة بدلاً من `\n` | استخدم `\n` بين القيم (سطر جديد) |

## تمارين (اختياري)

1. **(سهل)** أضف حقل `description` من نوع `Text Editor` أسفل `title`.
2. **(متوسط)** أنشئ Role جديد باسم `Tasks Manager` يملك كل الصلاحيات، وأضفه إلى Permissions.
3. **(تحدي)** اكتب Client Script (JavaScript) يخفي حقل `due_date` تلقائياً إذا كانت `status` تساوي `Cancelled`. ابحث في توثيق Frappe عن `frm.toggle_display`.

## الخطوة التالية

الدرس التالي: [الدرس 7: Controllers و Lifecycle Hooks] →
```

---

## Lesson Type 3: Exercise Lesson

### متى تستخدمه

- نهاية كل وحدة.
- جلسة تطبيق تجمع كل مفاهيم الوحدة.
- لا تقدّم مفاهيم جديدة — تستخدم ما تعلّمه المتعلم.

### البنية

```markdown
# تمارين الوحدة N: [اسم الوحدة]

> **المدة**: 60–90 دقيقة | **المتطلبات السابقة**: دروس الوحدة كاملة

## أهداف الجلسة
- تطبيق مفاهيم الوحدة في تمارين متدرجة.
- كشف الثغرات في الفهم قبل الاختبار النهائي.

## استرجاع سريع
[1–2 جمل تذكّر المتعلم بأهم 3 مفاهيم في الوحدة]

## التمارين

### تمرين 1 (سهل) — [العنوان]
[وصف دقيق للمطلوب]

<details>
<summary>تلميح</summary>
[تلميح غير كاشف للجواب]
</details>

### تمرين 2 (سهل) — [العنوان]
...

### تمرين 3 (متوسط) — [العنوان]
...

### تمرين 4 (متوسط) — [العنوان]
...

### تمرين 5 (تحدي) — [العنوان]
[تمرين مفتوح يتطلب بحثاً في التوثيق]

## كيف تُقدَّر الحلول
- صحة الكود (هل يعمل؟).
- وضوح الأسلوب (هل تتبع اصطلاحات Frappe؟).
- تغطية الحالات الحدية (هل تعاملت مع null/empty؟).

> الحلول الكاملة مع الشرح في `exercises/solutions.md`
```

### الطول

- 400–800 كلمة مقدمة + 5–7 تمارين.
- كل تمرين 50–150 كلمة وصف.

### مستويات الصعوبة

| المستوى | الوصف | مثال |
|--------|-------|------|
| **سهل** | تطبيق مباشر لمفهوم واحد | "أنشئ DocType بحقل واحد" |
| **متوسط** | يجمع 2–3 مفاهيم | "أنشئ DocType + Controller + Custom Field مرتبط" |
| **تحدي** | مفتوح، يتطلب بحثاً | "صمم نظام إعارة كامل مع منطق منع الإفراط" |

### مثال كامل: تمارين وحدة DocType (5 تمارين)

```markdown
# تمارين الوحدة 3: DocType System

> **المدة**: 90 دقيقة | **المتطلبات السابقة**: الدروس 5، 6، 7، 8

## أهداف الجلسة
- تطبيق مفاهيم DocType والـ Controllers والـ Permissions في تمارين متدرجة.
- كشف الثغرات في الفهم قبل الاختبار النهائي.

## استرجاع سريع

تعلّمت في هذه الوحدة: (1) DocType = مخطط + Controller، (2) Lifecycle hooks تتيح التدخل قبل/بعد الحفظ، (3) Permissions تُضبط لكل Role على حدة، (4) Child Tables تربط DocTypes بعلاقة أصل–ابن.

## التمارين

### تمرين 1 (سهل) — DocType بسيط باسم Project

أنشئ DocType باسم `Project` (Module = `Tasks`) بالحقول التالية:

- `project_name` (Data, مطلوب, فريد)
- `start_date` (Date)
- `end_date` (Date)
- `status` (Select: Planning/Active/On Hold/Closed, افتراضي=Planning)

ضبط الأذونات: System Manager كامل، Tasks User قراءة فقط. شغّل `bench migrate` وتأكد أن الجدول `tabProject` أُنشئ.

<details>
<summary>تلميح</summary>
راجع الدرس 6 — نفس الخطوات، فقط غيّر الاسم والحقول.
</details>

### تمرين 2 (سهل) — Controller يتحقق من التواريخ

أضف Controller لـ `Project` يمنع الحفظ إذا كان `end_date` قبل `start_date`. الرسالة بالعربية: "تاريخ النهاية لا يمكن أن يسبق تاريخ البداية".

### تمرين 3 (متوسط) — Child Table باسم Project Task

أنشئ DocType فرعي باسم `Project Task` بحقول: `task_name` (Data), `assignee` (Link → User), `hours` (Float, افتراضي=1). ثم أضف إلى `Project` حقلاً `tasks` من نوع `Table` يشير إلى `Project Task`.

### تمرين 4 (متوسط) — حساب إجمالي الساعات تلقائياً

أضف إلى `Project` حقلاً `total_hours` (Float, read_only). اكتب Controller في `validate` يحسب مجموع `hours` من جدول `tasks` ويضعه في `total_hours`.

```python
# بداية الفكرة — أكملها
self.total_hours = sum(item.hours for item in self.tasks)
```

عالج الحالة الفارغة (لا توجد مهام).

### تمرين 5 (تحدي) — منع الإفراط في الإسناد

اكتب منطقاً يمنع حفظ `Project` إذا كان أحد الموظفين مسنداً لأكثر من 40 ساعة إجمالاً عبر جميع المشاريع النشطة. ابحث في التوثيق عن `frappe.db.get_all` مع `filters` و `group_by`. اعرض رسالة خطأ بأسماء الموظفين المتجاوزين.

> **ملاحظة**: هذا التمرين مفتوح — لا يوجد حل وحيد. الحل المرجعي في `solutions.md` يستخدم `frappe.db.sql` لاستعلام أسرع.

## كيف تُقدَّر الحلول

- **صحة الكود**: هل يعمل عند `bench migrate` ومن دون أخطاء؟
- **اتباع الاصطلاحات**: snake_case للـ fieldnames، مفرد لاسم DocType، module صحيح.
- **تغطية الحالات الحدية**: هل عالجت القوائم الفارغة؟ التواريخ null؟
- **جودة الرسائل**: رسائل خطأ واضحة بالعربية للمستخدم النهائي.

> الحلول الكاملة مع الشرح في `exercises/solutions.md`
```

---

## Lesson Type 4: Quiz Lesson

### متى تستخدمه

- نهاية كل وحدة، **بعد** درس التمارين.
- فحص سريع للمعرفة (10 دقائق كحد أقصى).
- لا يحل محل التمارين — يكمّلها.

### البنية

```markdown
# اختبار الوحدة N: [اسم الوحدة]

> **عدد الأسئلة**: N | **المدة**: 10–15 دقيقة | **نسبة النجاح**: 70%

## تعليمات

- اختر الإجابة الصحيحة لكل سؤال.
- لا تستخدم التوثيق في المحاولة الأولى.
- الإجابات في `exercises/quiz-solutions.md`.

## الأسئلة

### السؤال 1 (اختيار من متعدد)
[السؤال]
- A) ...
- B) ...
- C) ...
- D) ...

### السؤال 2 (صح/خطأ)
[عبارة]
- صح
- خطأ

### السؤال 3 (إكمال الفراغ)
الـ ______ في Frappe هو الجدول الذي يخزّن تعريف الـ DocTypes نفسها.

### السؤال 4 (إجابة قصيرة)
[سؤال يحتاج جواباً من 1–3 كلمات]

### السؤال 5 (توقّع المخرجات)
ما مخرجات الكود التالي؟
```python
...
```

## التصحيح
- 9–10 إجابات صحيحة: ممتاز، أنت جاهز للوحدة التالية.
- 7–8: جيد، راجع الدروس التي أخطأت فيها.
- أقل من 7: أعد قراءة الوحدة وحاول مرة أخرى.

> الإجابات النموذجية مع الشرح في `exercises/quiz-solutions.md`
```

### الطول

- 200–400 كلمة مقدمة + 5–10 أسئلة.

### أنواع الأسئلة

| النوع | مثال | نسبة مقترحة |
|------|------|--------------|
| اختيار من متعدد | 4 خيارات، إجابة واحدة | 40% |
| صح/خطأ | عبارة واحدة | 20% |
| إكمال الفراغ | نص بفراغ | 15% |
| إجابة قصيرة | 1–3 كلمات | 15% |
| توقّع المخرجات | كود + "ما المخرجات؟" | 10% |

> **تنوع**: لا تجعل كل الأسئلة اختيار من متعدد. التنوع يكشف أنواعاً مختلفة من الفهم.

### مثال كامل: اختبار وحدة Frappe Framework Basics (10 أسئلة)

```markdown
# اختبار الوحدة 2: Frappe Framework Basics

> **عدد الأسئلة**: 10 | **المدة**: 15 دقيقة | **نسبة النجاح**: 70%

## تعليمات

- اختر الإجابة الصحيحة لكل سؤال.
- لا تستخدم التوثيق في المحاولة الأولى.
- الإجابات في `exercises/quiz-solutions.md`.

## الأسئلة

### السؤال 1 (اختيار من متعدد)
ما هو الـ "Bench" في Frappe Framework؟
- A) أداة لتثبيت Python packages.
- B) وحدة وقت التشغيل التي تحوي apps و sites و virtualenv.
- C) واجهة ويب للإدارة.
- D) اسم لحزمة npm تُستخدم في build.

### السؤال 2 (اختيار من متعدد)
أي أمر ينشئ site جديد؟
- A) `bench new-app`
- B) `bench create-site`
- C) `bench new-site`
- D) `bench install-site`

### السؤال 3 (صح/خطأ)
جدول قاعدة البيانات الذي يخزّن بيانات DocType باسم `Task` يكون اسمه `Task`.
- صح
- خطأ

### السؤال 4 (صح/خطأ)
يمكن لـ bench واحد أن يستضيف عدة sites، ولكل site قاعدة بيانات مستقلة.
- صح
- خطأ

### السؤال 5 (إكمال الفراغ)
الـ DocType يُخزَّن كسجل في جدول اسمه `tab______`.

### السؤال 6 (إكمال الفراغ)
عندما يريد المتعلم تشغيل console Python داخل بيئة Frappe، يستخدم الأمر `bench --site X ______`.

### السؤال 7 (إجابة قصيرة)
ما اسم الـ hook الذي يُستدعى قبل حفظ المستند دائماً للتحقق من صحة البيانات؟ (كلمة واحدة)

### السؤال 8 (إجابة قصيرة)
أي decorator يجعل دالة Python قابلة للاستدعاء من الـ REST API بدون مصادقة جلسة؟ (اكتب الاسم الكامل)

### السؤال 9 (توقّع المخرجات)
ما مخرجات الكود التالي؟

```python
import frappe
doc = frappe.get_doc("Task", "TASK-00001")
print(doc.doctype, doc.name)
```

- A) `Task TASK-00001`
- B) `tabTask TASK-00001`
- C) `Error: doctype is not accessible`
- D) `None None`

### السؤال 10 (توقّع المخرجات)
ماذا يحدث عند تشغيل هذا الكود؟

```python
import frappe
@frappe.whitelist()
def get_open_tasks():
    return frappe.get_all("Task", filters={"status": "Open"}, fields=["name", "title"])
```

- A) يُرجع قائمة بكل المهام بكل حقولها.
- B) يُرجع قائمة بالمهام المفتوحة فقط، بحقلَي `name` و `title` فقط.
- C) يُرجع خطأ لأن `whitelist` يتطلب معطيات.
- D) يُرجع عدد المهام المفتوحة كرقم.

## التصحيح

- 9–10 إجابات صحيحة: ممتاز، أنت جاهز للوحدة التالية.
- 7–8: جيد، راجع الدروس التي أخطأت فيها.
- أقل من 7: أعد قراءة الوحدة وحاول مرة أخرى.

> الإجابات النموذجية مع الشرح في `exercises/quiz-solutions.md`
```

### نموذج ملف الإجابات (مستقل)

```markdown
# Quiz Solutions — الوحدة 2: Frappe Framework Basics

## السؤال 1
**الإجابة**: B

**الشرح**: Bench هو وحدة وقت التشغيل التي تحوي apps و sites و virtualenv. أداة تثبيت Python packages هي `pip` (A خطأ). واجهة ويب للإدارة هي Desk (C خطأ).

## السؤال 2
**الإجابة**: C

**الشرح**: الأمر الصحيح هو `bench new-site`. `bench new-app` ينشئ تطبيقاً جديداً (A). `create-site` و `install-site` ليست أوامر صحيحة.

## السؤال 3
**الإجابة**: خطأ

**الشرح**: اسم الجدول يكون `tabTask` — Frappe يضيف البادئة `tab` تلقائياً.

## السؤال 4
**الإجابة**: صح

**الشرح**: Bench واحد يحوي عدة sites، ولكل site قاعدة بيانات مستقلة. هذا النموذج متعدد المستأجرين (multi-tenant).

## السؤال 5
**الإجابة**: DocType

**الشرح**: تعريفات الـ DocTypes نفسها تُخزَّن في `tabDocType`، وحقولها في `tabDocField`. هذه هي فكرة "schema-as-data".

## السؤال 6
**الإجابة**: console

**الشرح**: `bench --site X console` يفتح Python REPL مع تحميل `frappe` تلقائياً.

## السؤال 7
**الإجابة**: validate

**الشرح**: `validate` هو الـ hook الأكثر استخداماً — يُستدعى قبل كل حفظ للتحقق من صحة البيانات.

## السؤال 8
**الإجابة**: `@frappe.whitelist()`

**الشرح**: هذا الـ decorator يسمح للدالة بالاستدعاء من REST API. بدونها، تُرفض الطلبات غير المتصلة بجلسة.

## السؤال 9
**الإجابة**: A — `Task TASK-00001`

**الشرح**: `doc.doctype` يُرجع اسم الـ DocType (بدون `tab`)، و `doc.name` يُرجع اسم المستند.

## السؤال 10
**الإجابة**: B

**الشرح**: `frappe.get_all` مع `filters` يُرجع المستندات المطابقة فقط، و `fields` يحدد الأعمدة المُرجَعة. لولا `fields` لرجع كل الحقول (A). الـ decorator لا يطلب معطيات (C خطأ). لإرجاع العدد فقط استخدم `frappe.db.count` (D خطأ).
```

---

## Lesson Type 5: Project Step

### متى تستخدمه

- كل خطوة في التطبيق التقدمي الذي يصاحب الدورة (مثلاً CRM مخصص).
- يبني ميزة واحدة ملموسة، ترتبط ببقية التطبيق.
- يجب أن تشير صراحة إلى مكان الخطوة في مسار المشروع العام.

الفرق عن Practical Lesson: خطوة المشروع **تضيف ميزة إلى تطبيق قائم**، وتُذكِّر المتعلم بالخطوات السابقة واللاحقة في نفس المشروع.

### البنية

```markdown
# خطوة المشروع N: [العنوان]

> **مرحلة المشروع**: X من Y | **المدة**: ... | **المتطلبات**: خطوة N-1

## أهداف الخطوة
- [Objective 1]
- [Objective 2]

## سياق المشروع
[أين نحن من التطبيق الكامل؟ ما الذي بُني حتى الآن؟ ما الذي سنبنيه لاحقاً؟]

## خطوات التنفيذ
### الخطوة 1: ...
### الخطوة 2: ...

## الاختبار
[كيف نتحقق أن الميزة تعمل]

## ما الذي تبقّى
[قائمة قصيرة بالخطوات القادمة في المشروع]

## الخطوة التالية
الخطوة التالية في المشروع: [Step N+1: Title] →
```

### الطول

- 700–1400 كلمة، تشمل الكود الكامل للميزة.

### مثال كامل: "إضافة نموذج Customer إلى تطبيق CRM المخصص"

```markdown
# خطوة المشروع 3: إضافة نموذج Customer إلى تطبيق CRM المخصص

> **مرحلة المشروع**: 3 من 8 | **المدة**: 60 دقيقة | **المتطلبات**: خطوة المشروع 2 (إعداد تطبيق CRM)

## أهداف الخطوة
- إنشاء DocType باسم `Customer` في تطبيق `crm_app`.
- إضافة حقول للهوية، الاتصال، التصنيف.
- ضبط أذونات Sales Manager و Sales User.
- ربط `Customer` بـ `Lead` (الذي أنشأناه في الخطوة 2) عبر حقل Link.
- اختبار دورة lead → customer كاملة.

## سياق المشروع

نحن نبني تطبيق CRM مخصصاً باسم `crm_app`. حتى الآن أنجزنا:

- **الخطوة 1**: إنشاء التطبيق والـ bench (`crm_app/crm_app/`).
- **الخطوة 2**: DocType `Lead` بحقول `lead_name`, `phone`, `email`, `status`.

في هذه الخطوة نضيف `Customer` — الكيان الذي يتحول إليه الـ Lead عند نجاح التواصل. لاحقاً (الخطوة 4) سنضيف `Opportunity`، ثم `Quotation`، ثم `Sales Order`. البنية النهائية ستكون:

```
Lead → Customer → Opportunity → Quotation → Sales Order
```

## خطوات التنفيذ

### الخطوة 1: إنشاء مجلد الـ DocType

```bash
cd ~/frappe-bench/apps/crm_app/crm_app/crm_app/doctype
mkdir -p customer/customer
# المجلد يحوي: customer.json و customer.py
```

> **اصطلاح Frappe**: اسم المجلد صغير (lowercase) ويطابق fieldname. اسم الـ DocType في JSON مفرد PascalCase.

### الخطوة 2: كتابة ملف JSON

أنشئ `customer/customer/customer.json`:

```json
{
  "doctype": "DocType",
  "name": "Customer",
  "module": "CRM",
  "naming_rule": "Expression",
  "autoname": "CUST-.#####",
  "title_field": "customer_name",
  "track_changes": 1,
  "field_order": [
    "customer_name",
    "customer_group",
    "column_break_contact",
    "phone",
    "email",
    "section_break_address",
    "address_line1",
    "city",
    "country",
    "section_break_lead",
    "lead_source"
  ],
  "fields": [
    { "fieldname": "customer_name", "fieldtype": "Data", "label": "Customer Name", "reqd": 1, "in_list_view": 1 },
    { "fieldname": "customer_group", "fieldtype": "Link", "label": "Customer Group", "options": "Customer Group" },
    { "fieldname": "column_break_contact", "fieldtype": "Column Break" },
    { "fieldname": "phone", "fieldtype": "Data", "label": "Phone", "options": "Phone" },
    { "fieldname": "email", "fieldtype": "Data", "label": "Email", "options": "Email", "unique": 1 },
    { "fieldname": "section_break_address", "fieldtype": "Section Break", "label": "Address" },
    { "fieldname": "address_line1", "fieldtype": "Data", "label": "Address Line 1" },
    { "fieldname": "city", "fieldtype": "Data", "label": "City" },
    { "fieldname": "country", "fieldtype": "Link", "label": "Country", "options": "Country" },
    { "fieldname": "section_break_lead", "fieldtype": "Section Break", "label": "Lead Tracking" },
    { "fieldname": "lead_source", "fieldtype": "Link", "label": "Lead Source", "options": "Lead" }
  ],
  "permissions": [
    { "role": "Sales Manager", "read": 1, "write": 1, "create": 1, "delete": 1, "export": 1, "report": 1 },
    { "role": "Sales User", "read": 1, "write": 1, "create": 1, "export": 1 }
  ]
}
```

### الخطوة 3: كتابة الـ Controller

أنشئ `customer/customer/customer.py`:

```python
import frappe
from frappe.model.document import Document


class Customer(Document):
    def validate(self):
        # التحقق من أن البريد الإلكتروني فريد على مستوى tabCustomer
        if self.email and frappe.db.exists("Customer", {"email": self.email, "name": ("!=", self.name)}):
            frappe.throw(
                f"البريد الإلكتروني {self.email} مسجّل مسبقاً لعميل آخر",
                frappe.DuplicateEntryError,
            )

    def on_update(self):
        # عند تحويل Lead إلى Customer، حدّث حالة الـ Lead الأصلي
        if self.lead_source and self.has_value_changed("name"):
            frappe.db.set_value("Lead", self.lead_source, "status", "Converted", update_modified=False)
            frappe.msgprint(f"تم تحديث حالة Lead #{self.lead_source} إلى 'Converted'", alert=True)
```

### الخطوة 4: تشغيل migrate وتثبيت التطبيق

```bash
cd ~/frappe-bench
bench --site mysite.localhost install-app crm_app
# Output: Installing crm_app...
# Updating DocTypes       [========================================] 100%
# Installed crm_app

bench --site mysite.localhost migrate
# Output: Migrating mysite.localhost
# Success
```

### الخطوة 5: التأكد من إنشاء الجدول

```bash
bench --site mysite.localhost console <<'EOF'
frappe.db.table_exists("tabCustomer")
# Output: True

frappe.get_meta("Customer").get_field("customer_name").options
# Output: None  (حقل Data بدون options)
EOF
```

## الاختبار

### اختبار 1: إنشاء Customer جديد

1. في Desk، اكتب `Customer List` في الـ Awesome Bar.
2. اضغط **Add New Customer**.
3. املأ: `customer_name` = "شركة الأفق للتجارة"، `email` = "info@horizon.com"، `phone` = "+966500000000".
4. اضغط **Save**.
5. يجب أن يظهر الاسم تلقائياً بالشكل `CUST-00001`.

### اختبار 2: التحقق من فريدة البريد

أنشئ Customer آخر بنفس البريد. يجب أن يُرفض الحفظ برسالة:

```
frappe.exceptions.DuplicateEntryError: البريد الإلكتروني info@horizon.com مسجّل مسبقاً لعميل آخر
```

### اختبار 3: دورة Lead → Customer الكاملة

```python
# داخل bench console
lead = frappe.get_doc({
    "doctype": "Lead",
    "lead_name": "أحمد",
    "phone": "+966511111111",
    "email": "ahmed@example.com",
    "status": "Open",
})
lead.insert()
# Output: <Lead: L-00001>

customer = frappe.get_doc({
    "doctype": "Customer",
    "customer_name": "أحمد",
    "email": "ahmed@example.com",
    "lead_source": lead.name,
})
customer.insert()
# Output: <Customer: CUST-00002>

frappe.db.get_value("Lead", lead.name, "status")
# Output: 'Converted'
```

## ما الذي تبقّى

الخطوات القادمة في المشروع:

- **الخطوة 4**: إنشاء DocType `Opportunity` وربطه بـ `Customer`.
- **الخطوة 5**: إنشاء `Quotation` وحساب الإجمالي.
- **الخطوة 6**: إنشاء `Sales Order` وتفعيل دورة التقديم.
- **الخطوة 7**: تقارير مخصصة (تقرير المبيعات الشهري).
- **الخطوة 8**: نشر التطبيق على خادم إنتاج.

## الخطوة التالية

الخطوة التالية في المشروع: [خطوة المشروع 4: إنشاء Opportunity وربطها بـ Customer] →
```

---

## Module README Blueprint

كل وحدة (module) في الدورة لها مجلد وملف `README.md`. هذا الملف هو نقطة الدخول للوحدة.

### البنية

```markdown
# Module N: [Module Title]

> **عدد الدروس**: X | **المدة التقديرية**: Y ساعة | **المستوى**: ...

## أهداف التعلم
بنهاية هذه الوحدة، ستكون قادراً على:
- [Objective 1]
- [Objective 2]
- [Objective 3]

## المتطلبات السابقة
- [Module X — link]
- [Skill Y — link]

## الدروس

| # | الدرس | النوع | المدة |
|---|------|------|------|
| 1 | [Title] | Theory | 30 دقيقة |
| 2 | [Title] | Practical | 45 دقيقة |
| ... | ... | ... | ... |
| N-1 | تمارين الوحدة | Exercise | 90 دقيقة |
| N | اختبار الوحدة | Quiz | 15 دقيقة |

## التقييم
- تمارين (40%)
- اختبار قصير (30%)
- خطوة مشروع (30%) — إن وجدت

## كيف تدرس هذه الوحدة
1. اقرأ README هذا أولاً.
2. ادرس الدروس بالترتيب.
3. نفّذ التمارين قبل الاختبار.
4. لا تنتقل للوحدة التالية قبل اجتياز الاختبار بنسبة 70%.

## الموارد الإضافية
- [رابط frappe-docs المرتبط]
- [رابط رسمي]
```

### مثال كامل: README للوحدة 3 — DocType System

```markdown
# Module 3: DocType System

> **عدد الدروس**: 6 | **المدة التقديرية**: 5 ساعات | **المستوى**: مبتدئ–متوسط

## أهداف التعلم
بنهاية هذه الوحدة، ستكون قادراً على:
- تعريف DocType بكلتا صفتيه (مخطط + Controller).
- إنشاء DocType جديد عبر Desk وبالكود.
- كتابة Controllers مع lifecycle hooks صحيحة.
- ضبط الأذونات لكل Role.
- تصميم Child Tables والربط بين DocTypes.
- تشخيص أخطاء migrate الشائعة.

## المتطلبات السابقة
- [Module 2: Setup & Installation](../02-setup-and-installation/README.md)
- معرفة أساسية بـ Python و SQL.

## الدروس

| # | الدرس | النوع | المدة |
|---|------|------|------|
| 1 | [ما هو DocType في Frappe Framework؟](01-what-is-doctype.md) | Theory | 35 دقيقة |
| 2 | [إنشاء DocType جديد باسم Task](02-create-task-doctype.md) | Practical | 45 دقيقة |
| 3 | [Controllers و Lifecycle Hooks](03-controllers-and-hooks.md) | Theory | 40 دقيقة |
| 4 | [Permissions و Role-Based Access](04-permissions.md) | Practical | 35 دقيقة |
| 5 | [Child Tables وربط DocTypes](05-child-tables.md) | Practical | 50 دقيقة |
| 6 | [تمارين وحدة DocType](06-exercises-doctype.md) | Exercise | 90 دقيقة |
| 7 | [اختبار وحدة DocType](07-quiz-doctype.md) | Quiz | 15 دقيقة |

## التقييم
- تمارين الوحدة (40%): 5 تمارين متدرجة، الحل في `exercises/solutions.md`.
- اختبار قصير (30%): 10 أسئلة، الإجابات في `exercises/quiz-solutions.md`.
- خطوة مشروع (30%): [خطوة المشروع 3: إضافة Customer إلى CRM](../project/03-customer-model.md).

## كيف تدرس هذه الوحدة
1. اقرأ README هذا أولاً.
2. ادرس الدروس بالترتيب — كل درس يبني على السابق.
3. نفّذ كل تمرين داخل الدرس قبل الانتقال.
4. في النهاية، افتح ملف التمارين وحلها دون النظر للحلول.
5. قارن مع `solutions.md` وأعد ما أخطأت فيه.
6. أجرِ الاختبار في 15 دقيقة دون توثيق.
7. إن نجحت بـ 70% فأعلى، انتقل للوحدة 4.

## الموارد الإضافية
- [Frappe Framework — DocType Guide](../references/framework/doctype-guide.md) (داخل مهارة frappe-docs)
- [Frappe Framework — Architecture](../references/framework/architecture.md)
- [التوثيق الرسمي: docs.frappe.io/framework](https://docs.frappe.io/framework)
```

---

## Course README Blueprint

ملف `README.md` في جذر الدورة هو البطاقة التعريفية. يجب أن يفتحه أي مدرب أو متعلم ويفهم خلال دقيقتين ما هي الدورة ولمن.

### البنية

```markdown
# [Course Title]

> [Subtitle — جملة واحدة تصف القيمة]

## الجمهور المستهدف
[من يفترض أن يأخذ هذه الدورة]

## المدة
[X ساعة / Y أسبوع]

## المتطلبات السابقة
- [Prereq 1]
- [Prereq 2]

## المنهج الكامل

### Module 1: [Title]
| # | الدرس | النوع |
|---|------|------|
| 1 | ... | ... |

### Module 2: [Title]
...

### Project: [Title]
[وصف موجز]

### Assessments
- Final Quiz (50 سؤال)
- Capstone Project

## كيف تستخدم هذه الدورة
1. ابدأ بـ README كل وحدة.
2. ادرس الدروس بالترتيب.
3. حل التمارين قبل الاختبارات.
4. اتبع خطوات المشروع التقدمي.

## المشروع التقدمي
[فقرة تصف التطبيق الذي سيبنيه المتعلم]

## سياسة التقييم
- تمارين الوحدات: 30%
- اختبارات الوحدات: 20%
- المشروع التقدمي: 30%
- الاختبار النهائي: 20%
- اجتياز: 70% إجمالاً
```

### مثال موجز

```markdown
# Frappe Developer Bootcamp

> دورة متكاملة لتأهيل مطور Frappe Framework من الصفر إلى الإنتاج.

## الجمهور المستهدف
مطورو Python/JavaScript الذين يريدون بناء تطبيقات أعمال على Frappe.

## المدة
80 ساعة (8 أسابيع، 10 ساعات أسبوعياً).

## المتطلبات السابقة
- معرفة بـ Python (مستوى متوسط).
- معرفة بـ SQL الأساسية.
- familiarity with the terminal.

## المنهج الكامل

### Module 1: Introduction to Frappe
[6 دروس — 4 ساعات]

### Module 2: Setup & Installation
[5 دروس — 4 ساعات]

### Module 3: DocType System
[7 دروس — 5 ساعات]

...

### Project: Custom CRM App
[8 خطوات — 16 ساعة]

### Assessments
- Final Quiz: 50 سؤال.
- Capstone: إضافة ميزة جديدة إلى CRM.

## المشروع التقدمي
طوال الدورة، يبني المتعلم تطبيق CRM مخصصاً باسم `crm_app`. كل وحدة تضيف ميزة:
- الوحدة 3: `Customer`, `Lead`.
- الوحدة 4: `Opportunity`, `Quotation`.
- الوحدة 5: `Sales Order`, `Invoice`.
- الوحدة 6: تقارير مخصصة.
- الوحدة 7: نشر على إنتاج.

## سياسة التقييم
- تمارين الوحدات: 30%
- اختبارات الوحدات: 20%
- المشروع التقدمي: 30%
- الاختبار النهائي: 20%
- اجتياز: 70% إجمالاً.
```

---

## Code Block Standards

الكود في الدروس يجب أن يكون **قابل للتشغيل** و**كامل** و**معلَّقاً بالعربية حيث يساعد**.

### القواعد الخمس

1. **استخدم language tag دائماً**: ` ```python `، ` ```bash `، ` ```javascript `، ` ```json `، ` ```sql `، ` ```text `.
2. **أظهِر المخرجات المتوقعة كتعليق**: `# Output: ...` للـ Python، `# Output:` للـ bash.
3. **لا تقطّع الكود أبداً**: لا `// ... rest of code`، لا `# (skipped)`. الكود كامل أو لا يُذكر.
4. **أدرِج الاستيرادات**: `import frappe` و `from frappe.model.document import Document` في كل كتلة Python.
5. **أضِف تعليقات عربية حيث تساعد** الفهم — لا تترجم كل سطر، فقط النقاط الحرجة.

### مثال جيد

```python
import frappe
from frappe.model.document import Document


class Task(Document):
    def validate(self):
        # التحقق من أن تاريخ الاستحقاق ليس في الماضي
        if self.due_date and self.due_date < frappe.utils.today():
            frappe.throw(
                "تاريخ الاستحقاق لا يمكن أن يكون في الماضي",
                frappe.ValidationError,
            )

    @frappe.whitelist()
    def mark_complete(self):
        """تعليم المهمة كمكتملة وحفظها."""
        self.status = "Completed"
        self.save()
        return {"status": "success", "name": self.name}
        # Output عند الاستدعاء: {'status': 'success', 'name': 'TASK-00001'}
```

### مثال سيّئ

```python
# سيئ: لا language tag، مُختصر، لا استيرادات، لا مخرجات
class Task(Document):
    def validate(self):
        if self.due_date < today():  # today لم تُستورد
            throw("error")  # throw لم تُستورد

    # ... باقي الكود محذوف
```

**ما الخطأ؟**

- لا language tag.
- `today` و `throw` غير مستوردتين.
- `# ... باقي الكود محذوف` — لا تقطع.
- التعليق "error" لا يفيد أحداً.

### جدول language tags

| اللغة | الـ tag | متى تستخدمه |
|------|---------|--------------|
| Python | ` ```python ` | Controllers، scripts، bench console |
| Bash | ` ```bash ` | أوامر bench، shell |
| JavaScript | ` ```javascript ` | Client Scripts، Form Scripts |
| JSON | ` ```json ` | DocType schema، fixtures، config |
| SQL | ` ```sql ` | استعلامات مباشرة على DB |
| Text | ` ```text ` | مخرجات، رسائل خطأ |
| YAML | ` ```yaml ` | (نادر) hooks إعداد |
| HTML | ` ```html ` | Print formats، templates |

---

## Exercise Standards

### القواعد

1. **3 مستويات صعوبة لكل درس** (نظري أو تطبيقي): easy / medium / challenge.
2. **الحلول في ملف منفصل**: `exercises/solutions.md` (نفس مجلد الوحدة).
3. **الحل يشمل شرحاً لا كوداً فقط**: اشرح *لماذا* هذه الإجابة صحيحة.
4. **التمرين التحدي مفتوح**: لا توجد إجابة وحيدة، لكن الحل المرجعي يعرض مقاربة معقولة.

### بنية الحل في `solutions.md`

```markdown
## تمرين 1 (سهل) — DocType باسم Project

**الحل**:

```json
{
  "doctype": "DocType",
  "name": "Project",
  "module": "Tasks",
  "naming_rule": "Expression",
  "autoname": "PROJ-.#####",
  "fields": [
    { "fieldname": "project_name", "fieldtype": "Data", "label": "Project Name", "reqd": 1, "unique": 1 },
    { "fieldname": "start_date", "fieldtype": "Date", "label": "Start Date" },
    { "fieldname": "end_date", "fieldtype": "Date", "label": "End Date" },
    { "fieldname": "status", "fieldtype": "Select", "label": "Status", "options": "Planning\nActive\nOn Hold\nClosed", "default": "Planning" }
  ],
  "permissions": [
    { "role": "System Manager", "read": 1, "write": 1, "create": 1, "delete": 1 },
    { "role": "Tasks User", "read": 1 }
  ]
}
```

**الشرح**:
- `module: Tasks` حتى يُربط DocType بالتطبيق الصحيح.
- `autoname: PROJ-.#####` يعطي أسماء تسلسلية `PROJ-00001`, `PROJ-00002`...
- `reqd: 1` على `project_name` يجعله إلزامياً.
- `unique: 1` يمنع تكرار اسم المشروع.
- `options` على الـ Select مفصولة بـ `\n` (سطر جديد) — ليس بفاصلة.
- `Tasks User` له `read: 1` فقط — لا يملك `write` لأن صلاحية الكتابة للمدير.
```

### مثال جيد vs سيّئ

#### جيد

```markdown
### تمرين 2 (متوسط) — منع الإفراط في الإسناد

اكتب منطقاً يمنع حفظ `Project` إذا كان أحد الموظفين مسنداً لأكثر من 40 ساعة إجمالاً عبر جميع المشاريع النشطة.
```

- واضح، محدد، يعطي رقماً دقيقاً (40 ساعة).
- يحدد النطاق (جميع المشاريع النشطة).
- يتطلب دمج مفاهيم (`frappe.db.get_all` + `validate`).

#### سيّئ

```markdown
### تمرين 2
اكتب كود يتحقق من ساعات الموظف.
```

- غير محدد: كم ساعة؟ أي موظف؟ أي مشاريع؟
- "اكتب كود" ضعيف — قل ما المطلوب تماماً.
- لا يحدد المستوى.

---

## Quiz Standards

### القواعد

1. **اخلط أنواع الأسئلة**: اختيار من متعدد، صح/خطأ، إكمال فراغ، إجابة قصيرة، توقّع مخرجات.
2. **الإجابات في ملف منفصل**: `exercises/quiz-solutions.md`.
3. **كل إجابة معها شرح**: لماذا هذه صحيحة، ولماذا الباقي خطأ.
4. **لا أسئلة خداع**: الإجابة الصحيحة يجب أن تكون صحيحة بلا لبس.

### مثال جيد

```markdown
### السؤال 3 (صح/خطأ)
جدول قاعدة البيانات الذي يخزّن بيانات DocType باسم `Task` يكون اسمه `Task`.
- صح
- خطأ
```

**الحل**:

```markdown
## السؤال 3
**الإجابة**: خطأ

**الشرح**: اسم الجدول يكون `tabTask` — Frappe يضيف البادئة `tab` تلقائياً إلى اسم الـ DocType.
```

- السؤال واضح، يختبر معرفة دقيقة (البادئة `tab`).
- الشرح يذكر القاعدة العامة.

### مثال سيّئ

```markdown
### السؤال 3
ماذا يحدث في Frappe؟
A) نعم
B) لا
C) ربما
D) كل ما سبق
```

**الخطأ**:
- السؤال بلا معنى.
- الخيارات غامضة.
- "كل ما سبق" يصعب التحقق منه.
- لا يختبر معرفة محددة.

### قواعد إضافية

- **الأسئلة الـ4-خيارات**: تأكد أن الخيارات الخاطئة **معقولة** (ليست سخيفة) — هذا ما يجعل السؤال صعباً بشكل عادل.
- **صح/خطأ**: تجنب العبارات المركبة بـ "و" لأن المتعلم قد يصيب بالصدفة.
- **إكمال الفراغ**: الفراغ يجب أن يكون لمصطلح أو اسم دالة، ليس لكلمة عادية.
- **توقّع المخرجات**: الكود يجب أن يكون قصيراً (5–10 أسطر) ومركّزاً.

---

## Translation & Terminology Rules

### القواعد

1. **كل النثر بالعربية** — المقدمة، الشرح، التعليقات التوضيحية، رسائل الخطأ في الكود (حيث تُعرض للمستخدم النهائي).
2. **كل الكود بالإنجليزية** — أسماء المتغيرات، الدوال، الـ fieldnames، الـ DocType names.
3. **المصطلحات التقنية**: أول ورود ثنائي اللغة `DocType (نوع المستند)`، ثم بالإنجليزية فقط.
4. **عناصر الواجهة**: الترجمة العربية بين قوسين بعد الاسم الإنجليزي: `System Settings (إعدادات النظام)`.
5. **رسائل الخطأ في الكود**: إذا كانت تُعرض للمستخدم النهائي، تُكتب بالعربية. إذا كانت في logs أو للـ developer، بالإنجليزية.

### مثال

```python
# جيد
frappe.throw("البريد الإلكتروني مسجّل مسبقاً", frappe.DuplicateEntryError)
# logger (للمطور):
frappe.log_error(f"Duplicate email for customer {self.name}")
```

```python
# سيئ
frappe.throw("Email already exists", frappe.DuplicateEntryError)
# (في دورة عربية، رسالة المستخدم النهائي يجب أن تكون عربية)
```

### مسرد المصطلحات المعتمدة (Glossary)

استخدم هذه الترجمات في كل الدورة. لا تخترع ترجمات جديدة لنفس المصطلح.

| English | العربية (المعتمدة) | ملاحظات |
|---------|---------------------|---------|
| DocType | نوع المستند | أول ورود: `DocType (نوع المستند)` |
| Document | مستند | |
| Field | حقل | |
| Fieldname | اسم الحقل | لا تُترجم |
| Fieldtype | نوع الحقل | لا تُترجم |
| Module | وحدة | |
| Bench | Bench | لا تُترجم (اسم علم) |
| Site | موقع | |
| App | تطبيق | |
| Controller | Controller | لا تُترجم (اصطلاح برمجي) |
| Lifecycle hook | خطّاف دورة الحياة | |
| Validate | تحقّق | كاسم: "دالة التحقق" |
| Permission | صلاحية | |
| Role | دور | |
| User | مستخدم | |
| Workspace | مساحة العمل | |
| Desk | Desk | لا تُترجم (اسم علم) |
| Awesome Bar | شريط البحث العلوي | |
| List View | عرض القائمة | |
| Form View | عرض النموذج | |
| Report | تقرير | |
| Custom Field | حقل مخصّص | |
| Property Setter | ضابط الخاصية | نادر الاستخدام |
| Print Format | تنسيق الطباعة | |
| Workflow | سير عمل | |
| Notification | إشعار | |
| Migration | ترحيل / هجرة | استخدم "ترحيل" |
| Patch | رقعة / ترقيع | استخدم "patch" في الكود |
| Fixture | Fixture | لا تُترجم (اصطلاح برمجي) |
| Hook (in hooks.py) | Hook | لا تُترجم |
| Whitelist | قائمة بيضاء | كفعل: "whitelist-able" |
| Background job | مهمة خلفية | |
| Worker | Worker | لا تُترجم |
| Queue | طابور | |
| Cache | Cache | لا تُترجم |
| Scheduler | المجدول | |
| REST API | REST API | لا تُترجم |
| Endpoint | نقطة نهاية | |
| Submittable | قابل للإرسال | |
| Cancel | إلغاء | |
| Submit | إرسال | (في سياق DocType) |
| Trash | حذف | |
| Rename | إعادة تسمية | |
| Child Table | جدول فرعي | |
| Parent | أصل | |
| Link (fieldtype) | رابط | |
| Select (fieldtype) | قائمة منسدلة | |
| Table (fieldtype) | جدول | |
| Section Break | فاصل قسم | |
| Column Break | فاصل عمود | |
| Tab Break | فاصل تبويب | |
| Single DocType | DocType مفرد | |
| Virtual DocType | DocType افتراضي | |
| Tree DocType | DocType شجري | |

> **تنبيه**: القاعدة الأولى هي الاتساق. إن اخترت ترجمة معينة في الدرس الأول، التزم بها في كل الدورة.

---

## Cross-Reference Rules

الروابط بين الدروس تجعل الدورة قابلة للتنقل. اتبع هذه القواعد بصرامة.

### 1. روابط نسبية دائماً

```markdown
<!-- جيد -->
[الدرس 5: ما هو DocType](../03-doctype-system/01-what-is-doctype.md)

<!-- سيئ: رابط مطلق -->
[الدرس 5](/home/z/my-project/download/courses/x/03-doctype-system/01-what-is-doctype.md)

<!-- سيئ: رابط URL خارجي للدروس الداخلية -->
[الدرس 5](https://example.com/lessons/01-what-is-doctype.md)
```

### 2. رابط "الدرس التالي" في نهاية كل درس

```markdown
## الخطوة التالية

الدرس التالي: [الدرس 7: Controllers و Lifecycle Hooks](07-controllers-and-hooks.md) →
```

استخدم السهم `→` للإشارة إلى التقدم للأمام.

### 3. رابط المتطلبات السابقة في بداية كل درس

في الـ header block:

```markdown
> **المدة**: 35 دقيقة | **المستوى**: مبتدئ | **المتطلبات السابقة**: [الدرس 4: Bench CLI Basics](../02-setup/04-bench-cli.md)
```

### 4. روابط داخل النص عند الإشارة لمفهوم في درس آخر

```markdown
تعلّمت في [الدرس 4](../02-setup/04-bench-cli.md) كيف تنشئ site جديد. الآن سنستخدمه.
```

### 5. رابط المسرد (glossary) للمصطلحات التقنية في أول ورود

```markdown
الـ DocType (نوع المستند، راجع [المسرد](../../glossary/glossary.md#doctype)) هو...
```

### 6. بنية المسارات

الدورة في:

```
courses/<course-name>/
├── README.md
├── 01-introduction/
│   ├── README.md
│   ├── 01-what-is-frappe.md
│   └── ...
├── 02-setup/
│   ├── README.md
│   └── ...
└── glossary/glossary.md
```

من درس داخل `01-introduction/`:

| الهدف | المسار النسبي |
|------|----------------|
| درس آخر في نفس الوحدة | `02-why-erpnext.md` |
| درس في وحدة أخرى | `../02-setup/01-prerequisites.md` |
| README الوحدة الحالية | `README.md` |
| README الوحدة الأخرى | `../02-setup/README.md` |
| README الدورة | `../README.md` |
| المسرد | `../glossary/glossary.md` |
| ملف في resources | `../resources/cheatsheet.md` |
| ملف في project | `../project/03-customer-model.md` |

### 7. تحقّق من الروابط

قبل التسليم، شغّل:

```bash
# ابحث عن روابط مكسورة
find courses/<name> -name "*.md" -exec grep -l '](\.\.' {} \;
```

أو استخدم أداة مثل `markdown-link-check`. كل رابط يجب أن يفتح ملفاً موجوداً.

---

## Anti-Patterns

### 1. لا تستخدم محتوى نائباً (placeholder)

**سيئ**:

```markdown
## الشرح
TODO: اكتب شرح DocType هنا.
```

إن لم تستطع توليد المحتوى، اطلب التوضيح من المستخدم أو ولّد مختصراً صادقاً: "هذا القسم يتطلب بحثاً إضافياً في توثيق Frappe."

### 2. لا تنسخ من التوثيق الرسمي حرفياً

`frappe-docs` مرجع تقني للـ developers. الدورة للمتعلمين. أعد الصياغة:

**frappe-docs** (تقني):

> A DocType is both a schema definition and a Python class that defines behavior.

**في الدورة** (تعليمي):

> DocType ليس مجرد جدول — إنه مخطط يصف الحقول **وصف Python يصف السلوك**. هذا الاقتران بين البيانات والمنطق هو ما يميز Frappe.

### 3. لا تتخطى التمارين أو الحلول

كل درس له 3 تمارين. كل تمرين له حل في `solutions.md`. إن لم تستطع توليد حل، أخبر المستخدم صراحة ولا تترك التمرين بلا حل.

### 4. لا تستخدم النثر الإنجليزي في دورة عربية

استثناؤه الوحيد: الكود (أسماء المتغيرات، الدوال، التعليقات التقنية القصيرة) والمصطلحات التقنية المعتمدة في المسرد.

**سيئ**:

```markdown
In this lesson, we will learn about DocType.
```

**جيد**:

```markdown
في هذا الدرس، سنتعلّم عن DocType (نوع المستند).
```

### 5. لا تولّد درساً عملاقاً في ملف واحد

إن تجاوز الدرس 1500 كلمة من المتن، قسّمه. مثلاً درس "Controllers" يصبح:

- `07-controllers-basics.md`
- `08-controllers-advanced.md`

الملف العملاق يصعب قراءته على المتعلم ويصعب صيانته.

### 6. لا تخلط بين أنواع الدروس

الدرس النظري يشرح، لا يطلب التنفيذ. الدرس التطبيقي يطلب التنفيذ، لا يشرح بعمق. إن احتجت الاثنين، قسّم إلى درسين.

### 7. لا تترك أقسام الـ JSON أو الكود ناقصة

```json
{
  "doctype": "DocType",
  "name": "Task"
  // ... باقي الحقول
}
```

هذا يربك المتعلم. إما أن تعرض الـ JSON كاملاً أو تشير إلى ملف كامل: "راجع `assets/templates/task-doctype.json` للنسخة الكاملة".

### 8. لا تتجاهل المتطلبات السابقة

إن كان الدرس يتطلب معرفة SQL، اذكر ذلك في `المتطلبات السابقة`. لا تفترض أن المتعلم يعرف.

### 9. لا تكرر المحتوى بين الدروس

إن شرحت `validate` في الدرس 7، لا تعد شرحه في الدرس 8 — اذكر ورابط: "تعلّمنا في [الدرس 7](07-controllers.md#validate) أن `validate` يُستدعى قبل الحفظ."

### 10. لا تضع الإجابات داخل الأسئلة

في ملف الاختبار، لا تضع الإجابات. ضعها في `quiz-solutions.md`. المتعلم يجب أن يحاول أولاً.

---

## Quality Checklist

قبل الإعلان أن درساً جاهزاً، تحقّق من كل بند:

### البنية

- [ ] عنوان H1 بصيغة `الدرس N: العنوان`.
- [ ] header block بالمدة والمستوى والمتطلبات.
- [ ] قسم `أهداف الدرس` بـ 3–5 أهداف.
- [ ] قسم `المقدمة` بفقرتين على الأقل.
- [ ] قسم `الشرح` بأقسام فرعية H3.
- [ ] قسم `أمثلة عملية` (للنظري) أو `خطوات التنفيذ` (للتطبيقي).
- [ ] قسم `أخطاء شائعة` بـ 3–5 نقاط.
- [ ] قسم `ملخص الدرس` بـ 3 نقاط على الأقل.
- [ ] قسم `تمارين` بـ 3 تمارين (سهل/متوسط/تحدي).
- [ ] إشارة إلى ملف الحلول: `> الحلول في exercises/solutions.md`.
- [ ] قسم `الخطوة التالية` برابط للدرس التالي.

### المحتوى

- [ ] النثر كله بالعربية (باستثناء المصطلحات التقنية).
- [ ] المصطلحات التقنية: أول ورود ثنائي اللغة، ثم إنجليزي فقط.
- [ ] عناصر الواجهة بين قوسين: `Awesome Bar (شريط البحث العلوي)`.
- [ ] الترجمة متوافقة مع المسرد المعتمد.
- [ ] الطول ضمن النطاق: نظري 800–1500، تطبيقي 600–1200، تمارين 400–800 + 5–7 تمارين، اختبار 200–400 + 5–10 أسئلة، مشروع 700–1400.

### الكود

- [ ] كل كتلة كود لها language tag (`python`، `bash`، `json`، ...).
- [ ] كل كتلة Python تبدأ بـ `import frappe` (إن كانت تستخدم Frappe APIs).
- [ ] كل كتلة كود كاملة (لا `// ...`، لا `# (skipped)`).
- [ ] المخرجات المتوقعة موجودة كتعليقات: `# Output: ...`.
- [ ] تعليقات عربية حيث تساعد الفهم.
- [ ] رسائل الخطأ للمستخدم النهائي بالعربية.
- [ ] أوامر `bench` تستخدم `--site <name>` صريحاً.

### التمارين

- [ ] 3 مستويات صعوبة (سهل/متوسط/تحدي) لكل درس (ما عدا التمارين والاختبار).
- [ ] كل تمرين محدد وواضح (لا "اكتب كود").
- [ ] التمرين التحدي مفتوح ويتطلب بحثاً.
- [ ] الحلول موجودة في `exercises/solutions.md`.
- [ ] كل حل معه شرح (لماذا هذه الإجابة).

### الاختبارات (لدرس الاختبار)

- [ ] 5–10 أسئلة.
- [ ] مزيج من أنواع: اختيار من متعدد، صح/خطأ، إكمال فراغ، إجابة قصيرة، توقّع مخرجات.
- [ ] الإجابات في ملف منفصل `exercises/quiz-solutions.md`.
- [ ] كل إجابة معها شرح.
- [ ] لا أسئلة خداع.

### الروابط

- [ ] روابط نسبية فقط (لا مطلقة، لا URLs خارجية للدروس الداخلية).
- [ ] رابط "الدرس التالي" في النهاية.
- [ ] رابط المتطلبات السابقة في الـ header.
- [ ] روابط داخل النص للمصطلحات والمفاهيم ذات الصلة.
- [ ] كل الروابط تفتح ملفات موجودة.

### الملفات المرتبطة

- [ ] `exercises/solutions.md` موجود ومحدّث.
- [ ] `exercises/quiz-solutions.md` موجود (إن كان هناك اختبار).
- [ ] `README.md` للوحدة محدّث بقائمة الدروس.
- [ ] `README.md` للدورة محدّث برابط الوحدة.

### التحقق التقني

- [ ] أسماء DocTypes مفردة PascalCase (`Task`، لا `Tasks`).
- [ ] fieldnames بـ snake_case (`due_date`، لا `DueDate`).
- [ ] أسماء الـ modules صحيحة وموجودة في `modules.txt`.
- [ ] الأوامر `bench` صحيحة (تحقّق من `frappe-docs/references/framework/bench-cli.md`).
- [ ] APIs المستخدمة موجودة فعلاً (تحقّق من `frappe-docs/references/framework/python-api.md`).
- [ ] لا APIs مخترعة — إن لم تكن متأكداً، تحقّق أو احذف.

### العرض

- [ ] الجداول بصيغة Markdown صحيحة.
- [ ] لا أزرار emoji إلا إن طلب المستخدم.
- [ ] لا نصوص تسويقية ("احجز الآن!"، "خصم 50%").
- [ ] النبرة محايدة تعليمية، لا ترويجية.

---

## ملخص الأخير

هذا الملف هو **المرجع النهائي** لبنية كل درس. عند الشك، ارجع إلى:

1. **مثال الدرس الكامل** من القسم المناسب (Theory / Practical / Exercise / Quiz / Project Step).
2. **القواعد التفصيلية** في الأقسام التالية (Code / Exercise / Quiz / Translation / Cross-Reference).
3. **Anti-Patterns** لتجنب الأخطاء الشائعة.
4. **Quality Checklist** كفحص أخير قبل التسليم.

كل درس تولّده يجب أن يمرّ عبر هذا الـ checklist. لا تستثني أي بند. الجودة تُبنى بالاتساق، لا بالاستثناءات.
