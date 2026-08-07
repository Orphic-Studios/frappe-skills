# [Lesson N]: [Title in Arabic]

> **المدة**: [X] دقيقة | **المستوى**: [مبتدئ/متوسط/متقدم] | **المتطلبات السابقة**: [Lesson X: Title]

## أهداف الدرس

بنهاية هذا الدرس، ستكون قادراً على:

- [Objective 1 — concrete, measurable]
- [Objective 2]
- [Objective 3]

## المقدمة

[2-3 paragraphs in Arabic introducing the topic. Start with a hook — why does this matter? What problem does it solve? Connect to previous lessons.]

[Second paragraph: introduce the key concept at a high level.]

[Third paragraph: outline what we'll cover in this lesson.]

## الشرح

### [Subsection 1: Key Concept]

[Explanation in Arabic. Use code blocks for examples.]

```python
# Example code with Arabic comments
import frappe

# جلب مستند موجود
doc = frappe.get_doc("Task", "TASK00001")
print(doc.subject)
```

### [Subsection 2: How It Works]

[Detailed explanation with diagrams (use ASCII or text-based), tables, and examples.]

| Column 1 | Column 2 | Column 3 |
|---|---|---|
| Value 1 | Value 2 | Value 3 |
| Value 4 | Value 5 | Value 6 |

### [Subsection 3: Common Patterns]

[Show 2-3 common usage patterns with full code examples.]

```python
# Pattern 1: [Description]
def pattern_one():
    # ... full code
    pass

# Pattern 2: [Description]
def pattern_two():
    # ... full code
    pass
```

## أمثلة عملية

### مثال 1: [Title]

[Full worked example with explanation.]

```python
# Complete, runnable code
import frappe

@frappe.whitelist()
def create_task(subject, assigned_to=None):
    """إنشاء مهمة جديدة"""
    doc = frappe.new_doc("Task")
    doc.subject = subject
    doc.assigned_to = assigned_to
    doc.insert()
    return doc.name
```

**شرح الكود:**
- `[line 1 explanation]`
- `[line 2 explanation]`

### مثال 2: [Title]

[Another worked example.]

## أخطاء شائعة

- ❌ **[Mistake 1]**: [Description] → ✅ **الحل**: [Fix]
- ❌ **[Mistake 2]**: [Description] → ✅ **الحل**: [Fix]
- ❌ **[Mistake 3]**: [Description] → ✅ **الحل**: [Fix]

## ملخص الدرس

- [Key takeaway 1 — one sentence]
- [Key takeaway 2]
- [Key takeaway 3]

## تمارين

> الحلول في `exercises/solutions.md`

1. **[Easy]** [Exercise description — direct application of the lesson]

2. **[Medium]** [Exercise description — combines 2-3 concepts]

3. **[Challenge]** [Exercise description — open-ended, requires research]

## الخطوة التالية

الدرس التالي: **[Lesson N+1: Title]** →
