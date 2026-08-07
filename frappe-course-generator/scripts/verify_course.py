#!/usr/bin/env python3
"""
verify_course.py — Verify that a generated course meets quality standards.

Usage:
    python3 verify_course.py /path/to/course

Checks:
1. Folder structure is correct
2. All required files exist
3. Every lesson has required sections (objectives, intro, body, exercises)
4. Every exercise has a solution
5. Every quiz has answers
6. No placeholder content ("TBD", "TODO", "placeholder")
7. Cross-links between lessons work
8. PDF builds successfully (if exports/course.pdf exists)
9. Code blocks have language tags
"""

import re
import sys
from pathlib import Path
import json


REQUIRED_TOP_DIRS = ["00-cover", "assessments", "glossary", "resources", "exports"]
REQUIRED_LESSON_SECTIONS = ["أهداف الدرس", "المقدمة", "ملخص الدرس", "تمارين", "الخطوة التالية"]
PLACEHOLDER_PATTERNS = [
    r"\bTBD\b",
    r"\bTODO\b",
    r"\bplaceholder\b",
    r"\[.*?\]",
    r"Lesson \d+: Title",  # unfilled title placeholder
]


def verify_structure(course_dir: Path) -> list:
    """Check folder structure."""
    issues = []
    for d in REQUIRED_TOP_DIRS:
        if not (course_dir / d).exists():
            issues.append(f"Missing directory: {d}/")

    # Check for at least one module
    module_dirs = [d for d in course_dir.iterdir()
                  if d.is_dir() and d.name[0:2].isdigit() and d.name != "00-cover"]
    if not module_dirs:
        issues.append("No module directories found (expected: 01-..., 02-...)")

    return issues


def verify_lessons(course_dir: Path) -> list:
    """Check every lesson has required sections."""
    issues = []
    lesson_files = []
    for module_dir in sorted(course_dir.iterdir()):
        if not module_dir.is_dir() or not module_dir.name[0:2].isdigit():
            continue
        if module_dir.name == "00-cover":
            continue

        for f in module_dir.glob("*.md"):
            if f.name == "README.md":
                continue
            lesson_files.append(f)

    for lesson_file in lesson_files:
        content = lesson_file.read_text(encoding="utf-8")
        for section in REQUIRED_LESSON_SECTIONS:
            if section not in content:
                issues.append(f"{lesson_file.relative_to(course_dir)}: missing section '{section}'")

        # Check for placeholder content
        for pattern in PLACEHOLDER_PATTERNS:
            if re.search(pattern, content):
                # Allow some placeholders (like [Lesson X: Title] in template itself)
                if "template" in str(lesson_file):
                    continue
                issues.append(f"{lesson_file.relative_to(course_dir)}: contains placeholder pattern '{pattern}'")

    return issues


def verify_exercises(course_dir: Path) -> list:
    """Check every exercise has a solution."""
    issues = []

    for module_dir in sorted(course_dir.iterdir()):
        if not module_dir.is_dir() or not module_dir.name[0:2].isdigit():
            continue
        if module_dir.name == "00-cover":
            continue

        ex_dir = module_dir / "exercises"
        if not ex_dir.exists():
            issues.append(f"{module_dir.name}/exercises/: missing exercises directory")
            continue

        exercises_file = ex_dir / "exercises.md"
        solutions_file = ex_dir / "solutions.md"

        if not exercises_file.exists():
            issues.append(f"{module_dir.name}/exercises/exercises.md: missing")
        if not solutions_file.exists():
            issues.append(f"{module_dir.name}/exercises/solutions.md: missing")

        # Check quiz has answers
        quiz_file = ex_dir / "quiz.md"
        quiz_solutions = ex_dir / "quiz-solutions.md"
        if quiz_file.exists() and not quiz_solutions.exists():
            issues.append(f"{module_dir.name}/exercises/quiz-solutions.md: missing (quiz exists but no answers)")

    return issues


def verify_cross_links(course_dir: Path) -> list:
    """Check that relative links in lessons work."""
    issues = []
    link_pattern = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")

    for md_file in course_dir.rglob("*.md"):
        if "exports" in md_file.parts:
            continue
        content = md_file.read_text(encoding="utf-8")
        for match in link_pattern.finditer(content):
            text, link = match.groups()
            if link.startswith("http") or link.startswith("#"):
                continue
            # Resolve relative to the file
            target = (md_file.parent / link).resolve()
            if not target.exists():
                issues.append(f"{md_file.relative_to(course_dir)}: broken link '{link}' (target not found)")

    return issues


def verify_code_blocks(course_dir: Path) -> list:
    """Check that code blocks have language tags."""
    issues = []
    code_block_pattern = re.compile(r"^```(\w*)$", re.MULTILINE)

    for md_file in course_dir.rglob("*.md"):
        if "exports" in md_file.parts:
            continue
        content = md_file.read_text(encoding="utf-8")
        for match in code_block_pattern.finditer(content):
            lang = match.group(1).strip()
            if not lang:
                issues.append(f"{md_file.relative_to(course_dir)}: code block without language tag")

    return issues


def verify_pdf(course_dir: Path) -> list:
    """Check if PDF exists and is valid."""
    issues = []
    pdf_path = course_dir / "exports" / "course.pdf"
    if not pdf_path.exists():
        issues.append("exports/course.pdf: not built (run build_course.py --format pdf)")
        return issues

    if pdf_path.stat().st_size < 10000:  # < 10KB is suspicious
        issues.append(f"exports/course.pdf: suspiciously small ({pdf_path.stat().st_size} bytes)")

    if pdf_path.stat().st_size > 100 * 1024 * 1024:  # > 100MB
        issues.append(f"exports/course.pdf: too large ({pdf_path.stat().st_size // 1024 // 1024}MB)")

    return issues


def verify_manifest(course_dir: Path) -> list:
    """Check MANIFEST.json."""
    issues = []
    manifest_path = course_dir / "MANIFEST.json"
    if not manifest_path.exists():
        issues.append("MANIFEST.json: missing")
        return issues

    with open(manifest_path, encoding="utf-8") as f:
        manifest = json.load(f)

    if manifest.get("status") != "complete":
        issues.append(f"MANIFEST.json: status is '{manifest.get('status')}' (should be 'complete')")

    return issues


def main():
    if len(sys.argv) != 2:
        print("Usage: verify_course.py <course_dir>", file=sys.stderr)
        sys.exit(2)

    course_dir = Path(sys.argv[1]).resolve()
    if not course_dir.exists():
        print(f"❌ Course directory not found: {course_dir}", file=sys.stderr)
        sys.exit(2)

    print(f"🔍 Verifying course: {course_dir}\n")

    all_issues = []
    all_issues.extend(verify_structure(course_dir))
    all_issues.extend(verify_manifest(course_dir))
    all_issues.extend(verify_lessons(course_dir))
    all_issues.extend(verify_exercises(course_dir))
    all_issues.extend(verify_cross_links(course_dir))
    all_issues.extend(verify_code_blocks(course_dir))
    all_issues.extend(verify_pdf(course_dir))

    if not all_issues:
        print("✅ All checks passed! Course is ready for delivery.")
        return 0

    print(f"❌ Found {len(all_issues)} issue(s):\n")
    for issue in all_issues:
        print(f"  - {issue}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
