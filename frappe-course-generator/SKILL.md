---
name: "frappe-course-generator"
description: "Generates complete, production-ready training courses on the Frappe/ERPNext ecosystem in Arabic (with English code/technical terms). Use this skill whenever the user asks to 'create a course', 'build a curriculum', 'generate training material', 'make a tutorial', 'توليد دورة', 'إنشاء كورس تعليمي', 'دورة Frappe', 'دورة ERPNext', 'محتوى تعليمي', 'مواد تدريبية', or wants to teach Frappe/ERPNext to others (developers, end-users, or admins). Also use it when the user wants a 'training kit', 'workshop materials', 'bootcamp', 'onboarding guide', 'learning path', or any structured educational deliverable covering Frappe Framework, ERPNext modules, or any Frappe app. This skill depends on the 'frappe-docs' skill for technical accuracy — always load both together. The skill produces a full course package — structured curriculum, lesson files (Markdown), exercises with solutions, quizzes, progressive project, PDF export, and a delivery-ready folder layout."
---

# Frappe & ERPNext Course Generator

This skill turns the Frappe/ERPNext knowledge base into **structured educational courses**. It is a content-generation engine, not just a reference. When triggered, it produces a complete, ready-to-deliver course package in Arabic (with English code and technical terms).

## How This Skill Works

This skill is a **workflow orchestrator**. It:

1. **Loads the `frappe-docs` skill** for technical reference (the source of truth for content).
2. **Reads the curriculum blueprint** from `references/curriculum.md` to pick the right structure.
3. **Reads lesson blueprints** from `references/lesson-blueprints.md` to know how to format each lesson.
4. **Scaffolds a course folder** under `/home/z/my-project/download/courses/<course-name>/` using `scripts/scaffold_course.py`.
5. **Generates each lesson** following the templates in `assets/templates/`.
6. **Packages the final course** as PDF + Markdown + ZIP using `scripts/build_course.py`.

The skill is **opinionated about structure**: every course has the same anatomy (cover, intro, modules, lessons, exercises, project, assessment, glossary). This consistency is what makes courses learnable and deliverable.

## When to Trigger

Trigger this skill when the user:

- Asks to "create a course", "build a curriculum", "make training material"
- Says "دورة", "كورس", "تدريب", "مواد تعليمية", "محتوى تعليمي"
- Wants to teach Frappe/ERPNext to others
- Wants a "bootcamp", "workshop", "onboarding guide", "learning path"
- Asks for "شامل", "متكامل", "كامل" educational deliverables
- Wants PDF or downloadable training material on Frappe

**Do NOT trigger** when the user asks a one-off question (e.g. "how do I create a DocType?"). That's for `frappe-docs`. This skill is for **generating courses**, not answering questions.

## Course Anatomy

Every generated course follows this exact structure:

```
<course-name>/
├── README.md                          ← Course overview, learning objectives, how to use
├── 00-cover/
│   └── cover.md                       ← Title, subtitle, target audience, duration, prerequisites
├── 01-introduction/
│   ├── README.md                      ← Module overview
│   ├── 01-what-is-frappe.md           ← Lesson 1
│   ├── 02-why-erpnext.md              ← Lesson 2
│   └── exercises/
│       ├── 01-intro-quiz.md
│       └── solutions.md
├── 02-setup-and-installation/
│   ├── README.md
│   ├── 01-prerequisites.md
│   ├── 02-install-bench.md
│   ├── 03-create-site.md
│   ├── 04-install-erpnext.md
│   └── exercises/
│       ├── 01-verify-install.md
│       └── solutions.md
├── 03-... (more modules)
├── project/
│   ├── README.md                      ← Project brief
│   ├── starter/                       ← Starter code
│   ├── solution/                      ← Reference solution
│   └── rubric.md                      ← Grading rubric
├── assessments/
│   ├── final-quiz.md                  ← 50-question final quiz
│   ├── solutions.md
│   └── capstone.md                    ← Capstone project
├── glossary/
│   └── glossary.md                    ← Bilingual (AR/EN) glossary
├── resources/
│   ├── cheatsheet.md                  ← Quick reference
│   ├── common-errors.md               ← Top 30 errors and fixes
│   └── further-reading.md             ← Curated links
└── exports/
    ├── course.pdf                     ← Single-file PDF (generated)
    └── course.zip                     ← Zipped Markdown (generated)
```

## Course Generation Workflow

When triggered, follow these steps **in order**:

### Step 1 — Clarify the course spec

Ask the user (only if not already specified):

- **Audience**: developers / end-users / admins / mixed?
- **Track**: full course or one track?
- **Length**: quick (50 lessons) / medium (100) / pro (200+)?
- **Project**: yes (build a real project across lessons) or no (just exercises)?
- **Language**: Arabic / English / bilingual?

If the user already specified (e.g. "course for developers, 100 lessons, with project"), skip asking and proceed.

### Step 2 — Pick the curriculum

Read `references/curriculum.md`. It contains 3 tracks:

- **Developer Track** (Track D) — building apps on Frappe Framework
- **User Track** (Track U) — using ERPNext for business
- **Admin Track** (Track A) — installing, deploying, maintaining

For a full course, generate all 3 tracks with shared introduction module. For a single-track course, generate only that track.

### Step 3 — Scaffold the course folder

Run the scaffolding script:

```bash
python3 /home/z/my-project/skills/frappe-course-generator/scripts/scaffold_course.py \
    --name "frappe-developer-bootcamp" \
    --track developer \
    --audience developers \
    --language ar \
    --length medium \
    --with-project \
    --output /home/z/my-project/download/courses/frappe-developer-bootcamp
```

This creates the folder structure with placeholder files. Then you fill them in.

### Step 4 — Generate each module

For each module in the curriculum:

1. Read the corresponding reference file from `frappe-docs` skill (e.g. for "Accounting module" lesson, read `frappe-docs/references/erpnext/accounts.md`).
2. Read the lesson blueprint from `references/lesson-blueprints.md`.
3. Generate the lesson Markdown using the template in `assets/templates/lesson.template.md`.
4. Generate exercises using `assets/templates/exercise.template.md`.
5. Generate quiz (if module ends) using `assets/templates/quiz.template.md`.

**Critical**: each lesson must be **self-contained** — a learner should be able to read one lesson and understand it without reading others. Cross-link to other lessons for context, but don't require them.

### Step 5 — Generate the progressive project

If `--with-project` is set:

1. Read `assets/project-scaffold/README.md` for the project brief.
2. Generate `project/README.md` with the full brief.
3. Generate `project/starter/` with starter code (a basic Frappe app skeleton).
4. Generate `project/solution/` with the reference solution (complete working app).
5. Generate `project/rubric.md` with grading criteria.

The project should be **progressive** — each module adds a feature, so by the end the learner has a complete custom app.

### Step 6 — Generate assessments

- **Per-module quizzes**: 5-10 questions each, multiple choice + short answer.
- **Final quiz**: 50 questions covering the whole course.
- **Capstone**: an open-ended project brief that requires applying everything.

Use `assets/templates/quiz.template.md`.

### Step 7 — Generate glossary and resources

- **Glossary**: bilingual (AR/EN) terms with definitions. Pull from all lessons.
- **Cheatsheet**: one-page reference of most-used APIs, commands, field types.
- **Common errors**: top 30 errors with causes and fixes (pull from `frappe-docs/references/troubleshooting.md`).
- **Further reading**: curated links to official docs, GitHub repos, community resources.

### Step 8 — Build the deliverables

Run the build script:

```bash
python3 /home/z/my-project/skills/frappe-course-generator/scripts/build_course.py \
    --input /home/z/my-project/download/courses/frappe-developer-bootcamp \
    --format all
```

This produces:

- `exports/course.pdf` — single PDF (using `pdf` skill)
- `exports/course.zip` — zipped Markdown
- `exports/course.pptx` — slides for instructors (optional, `--format pptx`)

### Step 9 — Deliver

Tell the user the course is ready at:

```
/home/z/my-project/download/courses/<course-name>/
```

And point them to the `README.md` for the course overview. Mention the PDF is at `exports/course.pdf`.

## Content Standards

Every lesson must meet these standards:

### Length

- **Theory lessons**: 800-1500 words of body content (excluding code).
- **Exercise lessons**: 500-800 words + 3-5 exercises.
- **Quiz lessons**: 200-400 words intro + 5-10 questions.

### Structure (every lesson)

```markdown
# [Lesson N]: [Title]

> **المدة**: X دقيقة | **المستوى**: مبتدئ/متوسط/متقدم | **المتطلبات السابقة**: [Lesson X]

## أهداف الدرس
بنهاية هذا الدرس، ستكون قادراً على:
- [Objective 1]
- [Objective 2]
- [Objective 3]

## المقدمة
[2-3 paragraphs introducing the topic in Arabic]

## الشرح
[Main content — sections with H2/H3, code blocks, tables, examples]

## أمثلة عملية
[1-2 worked examples with full code]

## أخطاء شائعة
[Bullet list of 3-5 common mistakes and how to avoid them]

## ملخص الدرس
- [Key takeaway 1]
- [Key takeaway 2]

## تمارين
1. [Exercise 1 — easy]
2. [Exercise 2 — medium]
3. [Exercise 3 — challenge]

> الحلول في `exercises/solutions.md`

## الخطوة التالية
الدرس التالي: [Lesson N+1: Title] →
```

### Code blocks

- Always use language tags (` ```python `, ` ```bash `, ` ```javascript `, ` ```json `).
- Include comments in Arabic where helpful.
- Show expected output as a comment (`# Output: ...`).
- Never truncate — full runnable code only.

### Translation rules

- All prose in Arabic.
- All code in English (variable names, function names, etc.).
- Technical terms: first occurrence bilingual (`DocType (نوع المستند)`), then English only.
- UI elements: Arabic translation in parentheses (`System Settings (إعدادات النظام)`).

### Exercises

- 3 difficulty levels per lesson: easy / medium / challenge.
- Easy: direct application of the lesson.
- Medium: requires combining 2-3 concepts.
- Challenge: open-ended, requires research.
- Solutions provided in `exercises/solutions.md` with full explanations.

## Reference Files

| File | When to read |
|---|---|
| `references/curriculum.md` | To pick the right curriculum structure |
| `references/lesson-blueprints.md` | When generating each lesson (templates for theory/exercise/quiz/project lessons) |
| `references/delivery-formats.md` | When packaging the course (PDF/Markdown/PPTX/Web) |
| `references/assessment-rubrics.md` | When generating quizzes and grading rubrics |
| `assets/templates/lesson.template.md` | Empty lesson template |
| `assets/templates/exercise.template.md` | Empty exercise template |
| `assets/templates/quiz.template.md` | Empty quiz template |
| `assets/templates/module-readme.template.md` | Empty module README template |
| `assets/project-scaffold/README.md` | Progressive project brief |
| `scripts/scaffold_course.py` | Creates course folder structure |
| `scripts/build_course.py` | Builds PDF/ZIP/PPTX from Markdown |

## Dependency on `frappe-docs` Skill

**This skill is a sibling of `frappe-docs`.** They are designed to work together:

- `frappe-docs` provides the **knowledge** (technical reference).
- `frappe-course-generator` provides the **pedagogy** (how to teach that knowledge).

When generating course content, **always** read the corresponding `frappe-docs` reference file first. The course content must be technically accurate — never invent APIs or behaviors that aren't in `frappe-docs`.

If `frappe-docs` is not available (e.g. the user only installed this skill), fall back to fetching live docs from `https://docs.frappe.io/` via `web-reader`. But warn the user that accuracy may suffer.

## Generation Strategy for Long Courses

A full medium-length course has ~100 lessons. Generating all of them in one pass would take too long and risk token exhaustion. Use this **chunked strategy**:

1. **Generate the course skeleton first**: README, cover, all module READMEs, glossary, resources. (~10 files, fast.)
2. **Generate one module at a time**: each module is 8-10 lessons. After each module, save progress to `worklog.md` so the user can resume if interrupted.
3. **Generate the project last**: it depends on concepts from all modules.
4. **Generate assessments last**: they reference content from all lessons.
5. **Build PDF/ZIP at the end**: only after all Markdown is complete.

For each module, follow this sub-workflow:

1. Read the module brief from `references/curriculum.md`.
2. Read the corresponding `frappe-docs` reference file(s).
3. Generate the module README (overview + lesson list + learning objectives).
4. Generate each lesson in order (Lesson 1 → Lesson N).
5. Generate the exercises file + solutions.
6. Generate the module quiz + solutions.
7. Update the course README to mark this module as complete.
8. Append to `worklog.md`.

## Quality Checklist

Before declaring a course complete, verify:

- [ ] Every lesson has all required sections (objectives, intro, body, examples, errors, summary, exercises, next).
- [ ] Every code block has a language tag and is runnable.
- [ ] Every exercise has a solution in `solutions.md`.
- [ ] Every quiz has answers in a separate file (not inline).
- [ ] Every module README lists all lessons with links.
- [ ] Course README has a complete table of contents.
- [ ] Glossary covers all technical terms used.
- [ ] Project brief is complete and the starter code runs.
- [ ] Project solution passes all tests (if applicable).
- [ ] PDF builds successfully and renders Arabic correctly.
- [ ] All cross-links between lessons work.

## Customization Hooks

The user may ask for customizations:

- **"Add a section on Frappe Insights"** → add a new module, follow the standard structure.
- **"Make exercises harder"** → bump difficulty levels (easy → medium, medium → hard, challenge → expert).
- **"Add video scripts"** → for each lesson, also generate a `lesson.video.md` with a TTS-ready narration script.
- **"Add instructor notes"** → for each lesson, also generate a `lesson.instructor.md` with teaching tips, common student questions, demo ideas.
- **"Translate to English"** → re-generate with `--language en`.

## Anti-Patterns

Don't:

- Generate placeholder content ("TODO: write this lesson"). If you can't generate it, say so and ask the user.
- Skip exercises or solutions — they're mandatory.
- Use English prose in an Arabic course (except code and technical terms).
- Copy-paste from `frappe-docs` verbatim — rephrase for the learner audience.
- Generate a single giant file — the modular structure is what makes the course usable.
- Skip the project — it's the most valuable part of the course.

## Example Invocations

### Example 1: Full developer bootcamp

> User: "أريد دورة كاملة لتعليم المطورين على Frappe Framework، مع مشروع تطبيقي، حول 100 درس"

Action:
1. Trigger this skill.
2. Run `scaffold_course.py --name frappe-dev-bootcamp --track developer --audience developers --language ar --length medium --with-project`.
3. Generate modules 1-12 from the Developer Track in `references/curriculum.md`.
4. Generate progressive project (custom CRM app).
5. Generate final quiz + capstone.
6. Build PDF + ZIP.
7. Deliver at `/home/z/my-project/download/courses/frappe-dev-bootcamp/`.

### Example 2: Quick ERPNext user course

> User: "دورة سريعة لمستخدمي ERPNext، 50 درس، بدون مشروع"

Action:
1. Trigger this skill.
2. Run `scaffold_course.py --name erpnext-quick-start --track user --audience users --language ar --length quick --no-project`.
3. Generate modules 1-7 from the User Track.
4. Generate per-module quizzes only (no capstone).
5. Build PDF + ZIP.
6. Deliver.

### Example 3: Admin workshop

> User: "ورشة عمل لمسؤولي نظام ERPNext، يوم واحد، 8 دروس"

Action:
1. Trigger this skill.
2. Run `scaffold_course.py --name erpnext-admin-workshop --track admin --audience admins --language ar --length quick --no-project`.
3. Generate 8 lessons from the Admin Track (hand-picked for a 1-day workshop).
4. Add a hands-on lab per lesson.
5. Build PDF only (no ZIP needed for a workshop).
6. Deliver.

## Output Location

All generated courses go to:

```
/home/z/my-project/download/courses/<course-name>/
```

The `courses/` subdirectory keeps them organized. Each course is a self-contained folder.

## Final Notes

- This skill is **content-generative** — it doesn't just retrieve info, it produces new educational material.
- The quality bar is **production-ready training material**, not a rough draft.
- Always respect the learner's time: every lesson should teach something concrete and useful.
- Use the `frappe-docs` skill as the technical source of truth — never invent APIs.
- When in doubt about structure, follow the templates in `assets/templates/`.
