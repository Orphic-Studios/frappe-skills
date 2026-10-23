# Frappe Course Quality Checklist (Arabic)

Use this checklist before packaging or delivering any training course generated with `frappe-course-generator`.

## 1. Structure & Completeness
- [ ] Root `README.md`, `00-cover/cover.md`, and `99-glossary/glossary.md` exist and contain no unreplaced `{{PLACEHOLDER}}` tokens.
- [ ] Every module folder (`01-...`, `02-...`) has a `README.md`, numbered lesson files, and an `exercises/` subfolder with both exercises and `solutions.md`.
- [ ] `python3 skills/frappe-course-generator/scripts/verify_course.py <course-dir>` passes without critical errors.

## 2. Language & Formatting
- [ ] Explanatory prose, learning objectives, and quiz questions are written in clear Modern Standard Arabic.
- [ ] Code blocks, `bench` commands, DocType names, fieldnames, and file paths are in English.
- [ ] Every code block has a language tag (`python`, `javascript`, `bash`, `json`, `sql`).

## 3. Technical Accuracy
- [ ] Every Frappe API call (`frappe.get_doc`, `frappe.db.get_value`, `frappe.call`) matches `skills/frappe-docs/references/`.
- [ ] Exercises include both a clear problem statement and a complete, working solution in `solutions.md`.
- [ ] Quizzes include an answer key with explanations for why each answer is correct.
