# اختبار [Module N]: [Module Title]

> **عدد الأسئلة**: [X] | **المدة المقدرة**: [Y] دقيقة | **النجاح**: [Z]% أو أكثر

## التعليمات

- اختر الإجابة الصحيحة لكل سؤال
- بعض الأسئلة قد لها أكثر من إجابة صحيحة (سيُذكر ذلك صراحة)
- للأسئلة البرمجية، اكتب الكود الكامل
- يمكنك استخدام التوثيق الرسمي: https://docs.frappe.io/

---

## القسم الأول: اختيار من متعدد

### السؤال 1

ما هو الـ DocType في Frappe Framework؟

- A) نوع من أنواع قواعد البيانات
- B) تعريف لمخطط (schema) لمستند ما
- C) واجهة مستخدم للنماذج
- D) أمر من أوامر bench

<details>
<summary>إظهار الإجابة</summary>

**الإجابة الصحيحة: B**

**الشرح**: الـ DocType هو التعريف (schema) لكيفية تخزين وسلوك مستند معين. يحتوي على الحقول، الأذونات، وخطافات دورة الحياة. الخيار A خاطئ لأن DocType ليس نوع قاعدة بيانات. الخيار C غير مكتمل لأن DocType يولّد واجهة ولكن ليس هو نفسه الواجهة. الخيار D خاطئ تماماً.

</details>

### السؤال 2

[Above format repeated for each question]

---

## القسم الثاني: صح أم خطأ

### السؤال 6

[Statement]

- A) صح
- B) خطأ

<details>
<summary>إظهار الإجابة</summary>

**الإجابة الصحيحة: [A/B]**

**الشرح**: [explanation]

</details>

---

## القسم الثالث: أكمل الفراغ

### السؤال 11

لجلب مستند موجود من قاعدة البيانات، نستخدم الدالة `frappe._____("Task", "TASK00001")`

<details>
<summary>إظهار الإجابة</summary>

**الإجابة الصحيحة: `get_doc`**

**الشرح**: `frappe.get_doc(doctype, name)` تُرجع كائن Document للمستند المحدد. مثال: `doc = frappe.get_doc("Task", "TASK00001")`.

</details>

---

## القسم الرابع: أسئلة قصيرة

### السؤال 14

[Question in Arabic — answer in 1-3 sentences]

<details>
<summary>إظهار الإجابة</summary>

**الإجابة المرجعية**:

[Model answer in Arabic]

</details>

---

## القسم الخامس: تنبؤ بالمخرجات

### السؤال 17

ما هو الناتج المتوقع للكود التالي؟

```python
import frappe

doc = frappe.new_doc("Task")
doc.subject = "Test"
doc.insert()
print(doc.name)
print(doc.docstatus)
```

<details>
<summary>إظهار الإجابة</summary>

**الإجابة الصحيحة**:

```
TASK-00001  (أو اسم مشابه حسب قاعدة التسمية)
0
```

**الشرح**: `frappe.new_doc()` ينشئ مستنداً جديداً في الذاكرة. `insert()` يحفظه في قاعدة البيانات ويولّد اسماً تلقائياً. `docstatus` للمستندات الجديدة (المسودة) يكون 0.

</details>

---

## القسم السادس: أكمل الكود

### السؤال 19

أكمل الكود التالي لإنشاء دالة whitelist-able تقبل اسم مستخدم وتُرجع عدد مهامه المفتوحة:

```python
import frappe

@frappe._____
def get_open_task_count(username):
    """إرجاع عدد المهام المفتوحة للمستخدم"""
    count = frappe.db._____(
        "Task",
        filters={
            "_____": username,
            "_____": "Open"
        }
    )
    return count
```

<details>
<summary>إظهار الإجابة</summary>

**الإجابة الصحيحة**:

```python
import frappe

@frappe.whitelist()
def get_open_task_count(username):
    """إرجاع عدد المهام المفتوحة للمستخدم"""
    count = frappe.db.count(
        "Task",
        filters={
            "owner": username,
            "status": "Open"
        }
    )
    return count
```

**الشرح**:
- `@frappe.whitelist()` ضروري لجعل الدالة قابلة للاستدعاء من العميل أو عبر REST API.
- `frappe.db.count(doctype, filters=...)` تُرجع عدد السجلات المطابقة.
- `owner` هو الحقل الذي يخزّن منشئ المستند.
- `status` هو الحقل الذي يخزّن حالة المهمة.

</details>

---

## مفتاح الإجابات

| السؤال | الإجابة |
|---|---|
| 1 | B |
| 2 | [A/B/C/D] |
| ... | ... |

---

## تقييم الأداء

| النسبة | التقدير |
|---|---|
| 90-100% | ممتاز (A) |
| 80-89% | جيد جداً (B) |
| 70-79% | جيد (C) |
| < 70% | يحتاج مراجعة |

> إذا حصلت على أقل من 70%، ننصح بإعادة مراجعة الدروس في هذه الوحدة قبل الانتقال للوحدة التالية.
