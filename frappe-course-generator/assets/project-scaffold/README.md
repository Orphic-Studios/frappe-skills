# المشروع التطبيقي: تطبيق CRM مخصص على Frappe Framework

## نظرة عامة

طوال الدورة، سنبني تدريجياً تطبيق CRM مخصص باسم `property_crm` لإدارة العقارات والعملاء والمعاملات. كل وحدة تضيف ميزة جديدة، حتى نحصل في النهاية على تطبيق كامل وجاهز للإنتاج.

## لماذا هذا المشروع؟

تطبيق CRM يجمع بين:
- **نماذج بيانات معقدة** (عقارات، عملاء، معاملات، وكلاء)
- **علاقات متشعبة** (عميل ← معاملة ← عقار ← وكيل)
- **منطق أعمال** (عمولات، حالات، تواريخ استحقاق)
- **تكامل مع ERPNext** (فواتير، مدفوعات)
- **واجهات مخصصة** (Portal للعملاء، Print Formats للعقود)
- **أتمتة** (تذكيرات، إشعارات، تقارير مجدولة)

هذا يغطي كل ما يحتاجه مطور Frappe لإتقانه.

## المتطلبات النهائية للمشروع

بنهاية الدورة، يجب أن يحتوي التطبيق على:

### 1. DocTypes الأساسية (5 على الأقل)

- `Property` — العقار (فيلا، شقة، أرض...)
- `Customer` — عميل (مشتري/بائع)
- `Agent` — وكيل عقاري
- `Transaction` — معاملة (بيع/إيجار)
- `Commission` — عمولة

### 2. DocTypes مساعدة

- `Property Visit` — زيارة عقار
- `Offer` — عرض سعر
- `Contract` — عقد
- `Payment Schedule` — جدول مدفوعات

### 3. الميزات المطلوبة

- ✅ Workflow كامل للمعاملة (مسودة → معروضة → مقبولة → مكتملة → ملغاة)
- ✅ Print Format مخصص لعقد البيع/الإيجار
- ✅ REST API للوصول الخارجي
- ✅ Portal page للعملاء (عرض العقارات المتاحة)
- ✅ Web Form لتسجيل العملاء الجدد
- ✅ Reports (مبيعات الشهر، عمولات الوكلاء، العقارات المتاحة)
- ✅ Notifications (إشعار الوكيل عند معاملة جديدة)
- ✅ Scheduled jobs (تذكير بالمدفوعات المستحقة)
- ✅ Custom Dashboard (KPIs للوكلاء)
- ✅ تكامل مع ERPNext (Sales Invoice للعمولات)

### 4. الأنظمة المساعدة

- ✅ أدوار مخصصة (Property Agent, Property Manager, Customer)
- ✅ صلاحيات على مستوى المستند (الوكيل يرى معاملاته فقط)
- ✅ Print Formats متعددة (عقد بيع، عقد إيجار، إيصال عمولة)
- ✅ Workflows للمعاملة والعرض
- ✅ Email Templates للإشعارات

## خطة التنفيذ عبر الوحدات

| الوحدة | ما يُضاف للمشروع |
|---|---|
| **D1: Architecture** | فهم بنية Frappe، لا كود بعد |
| **D2: DocType System** | إنشاء DocType `Property` مع الحقول الأساسية |
| **D3: Python API** | إضافة controller methods لـ `Property` (auto-calc price per sqm) |
| **D4: JavaScript API** | Client Script لـ `Property` (auto-fetch default agent) |
| **D5: REST API** |Expose endpoint لعرض العقارات المتاحة |
| **D6: Permissions** | أدوار مخصصة + User Permissions |
| **D7: Customization** | Workflow للمعاملة + Print Format للعقد |
| **D8: Web Views** | Portal page لعرض العقارات + Web Form للتسجيل |
| **D9: Background Jobs** | Scheduled job للتذكير بالمدفوعات المستحقة |
| **D10: Testing** | Unit tests للـ controllers والـ API |
| **D11: Deployment** | نشر التطبيق على خادم إنتاج |
| **D12: Custom App Lifecycle** | تجهيز التطبيق للنشر كـ Frappe app مستقل |

## بنية المشروع

```
property_crm/
├── property_crm/
│   ├── __init__.py
│   ├── hooks.py
│   ├── modules.txt
│   ├── patches.txt
│   ├── property/                    ← module
│   │   ├── __init__.py
│   │   ├── doctype/
│   │   │   ├── property/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── property.py
│   │   │   │   ├── property.json
│   │   │   │   └── property.js
│   │   │   ├── customer/
│   │   │   │   └── ...
│   │   │   ├── agent/
│   │   │   │   └── ...
│   │   │   ├── transaction/
│   │   │   │   └── ...
│   │   │   └── commission/
│   │   │       └── ...
│   │   ├── report/
│   │   │   ├── available_properties/
│   │   │   │   ├── available_properties.js
│   │   │   │   ├── available_properties.json
│   │   │   │   └── available_properties.py
│   │   │   └── agent_commissions/
│   │   │       └── ...
│   │   ├── print_format/
│   │   │   ├── sales_contract/
│   │   │   │   └── sales_contract.json
│   │   │   └── rental_contract/
│   │   │       └── rental_contract.json
│   │   ├── page/
│   │   │   └── properties_portal/
│   │   │       ├── __init__.py
│   │   │       ├── properties_portal.js
│   │   │       ├── properties_portal.json
│   │   │       └── properties_portal.py
│   │   └── workspace/
│   │       └── property_crm/
│   │           └── property_crm.json
│   ├── templates/
│   │   ├── pages/
│   │   │   └── properties.html
│   │   ├── emails/
│   │   │   ├── new_transaction.html
│   │   │   └── payment_reminder.html
│   │   └── includes/
│   │       └── property_card.html
│   ├── api.py                       ← REST API endpoints
│   ├── tasks.py                     ← Background jobs
│   ├── utils.py                     ← Helpers
│   └── tests/
│       ├── __init__.py
│       ├── test_property.py
│       ├── test_transaction.py
│       └── test_api.py
├── setup.py
├── pyproject.toml
├── package.json
└── README.md
```

## كيفية العمل على المشروع

### لكل درس مشروع:

1. اقرأ درس المشروع في `project/step-N.md`
2. افتح مجلد `project/starter/` للكود الابتدائي
3. نفّذ المتطلبات المذكورة في الدرس
4. اختبر عملك باستخدام `bench --site X run-tests`
5. قارن مع `project/solution/step-N/` للتحقق

### للبدء من الصفر:

```bash
# 1. انسخ الـ starter
cp -r project/starter/ apps/property_crm/

# 2. ثبّت التطبيق
bench --site mysite.localhost install-app property_crm

# 3. ابدأ بالدرس الأول
cd apps/property_crm/
# افتح property_crm/doctype/property/property.py وابدأ التعديل
```

## معايير التقييم (Rubric)

| المعيار | الوزن | الوصف |
|---|---|---|
| **الوظائف** | 40% | هل تعمل كل الميزات المطلوبة؟ |
| **جودة الكود** | 25% | كود نظيف، يتبع conventions، قابل للقراءة |
| **أفضل الممارسات** | 20% | صلاحيات، validation، error handling |
| **التوثيق** | 10% | README، docstrings، تعليقات |
| **الاختبارات** | 5% | unit tests للمسارات الحرجة |

### درجات التقييم

| النسبة | التقدير |
|---|---|
| 90-100% | ممتاز (A) |
| 80-89% | جيد جداً (B) |
| 70-79% | جيد (C) |
| < 70% | يحتاج مراجعة |

## الخطوة الأولى

ابدأ بقراءة: [`project/step-01.md`](step-01.md) — إنشاء بنية التطبيق و DocType `Property`

---

> 💡 **ملاحظة**: هذا المشروع تراكمي. إذا واجهت صعوبة في خطوة، ارجع للدرس المقابل في الوحدة المعنية. الحلول الكاملة موجودة في `project/solution/` كمرجع أخير.
