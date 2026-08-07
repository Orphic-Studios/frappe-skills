#!/usr/bin/env python3
"""
build_course.py — Build a Frappe course into deliverable formats (PDF/ZIP/PPTX/Web).

Usage:
    python3 build_course.py --input /path/to/course --format all
    python3 build_course.py --input /path/to/course --format pdf
    python3 build_course.py --input /path/to/course --format zip
    python3 build_course.py --input /path/to/course --format pptx
    python3 build_course.py --input /path/to/course --format web

The course must be scaffolded first by scaffold_course.py and filled in
by the AI agent.
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path
from datetime import datetime


def parse_args():
    parser = argparse.ArgumentParser(description="Build a Frappe course into deliverables")
    parser.add_argument("--input", required=True, help="Course directory (contains MANIFEST.json)")
    parser.add_argument("--format", required=True,
                        choices=["all", "pdf", "zip", "pptx", "web"],
                        help="Output format")
    parser.add_argument("--output", default=None,
                        help="Output directory (default: <input>/exports/)")
    parser.add_argument("--include-solutions", action="store_true",
                        help="Include solution files in deliverables (default: yes for PDF/ZIP, no for PPTX/Web)")
    parser.add_argument("--no-solutions", dest="include_solutions", action="store_false",
                        help="Exclude solution files")
    parser.set_defaults(include_solutions=True)
    return parser.parse_args()


def load_manifest(course_dir: Path) -> dict:
    """Load MANIFEST.json from the course directory."""
    manifest_path = course_dir / "MANIFEST.json"
    if not manifest_path.exists():
        print(f"❌ MANIFEST.json not found at: {manifest_path}", file=sys.stderr)
        sys.exit(1)
    with open(manifest_path, encoding="utf-8") as f:
        return json.load(f)


def collect_markdown_files(course_dir: Path, include_solutions: bool) -> list:
    """Collect all Markdown files in the correct reading order."""
    files = []

    # Cover first
    cover = course_dir / "00-cover" / "cover.md"
    if cover.exists():
        files.append(cover)

    # README (course overview)
    readme = course_dir / "README.md"
    if readme.exists():
        files.append(readme)

    # Modules in order
    module_dirs = sorted([d for d in course_dir.iterdir()
                         if d.is_dir() and d.name[0:2].isdigit() and d.name != "00-cover"])

    for module_dir in module_dirs:
        # Module README first
        module_readme = module_dir / "README.md"
        if module_readme.exists():
            files.append(module_readme)

        # Lessons in order
        lesson_files = sorted([f for f in module_dir.iterdir()
                              if f.suffix == ".md" and f.name[0:2].isdigit()])
        files.extend(lesson_files)

        # Exercises
        exercises_dir = module_dir / "exercises"
        if exercises_dir.exists():
            for f in sorted(exercises_dir.iterdir()):
                if f.suffix == ".md":
                    if "solutions" in f.name.lower() and not include_solutions:
                        continue
                    files.append(f)

    # Project
    project_dir = course_dir / "project"
    if project_dir.exists():
        readme = project_dir / "README.md"
        if readme.exists():
            files.append(readme)
        rubric = project_dir / "rubric.md"
        if rubric.exists():
            files.append(rubric)

    # Assessments
    assess_dir = course_dir / "assessments"
    if assess_dir.exists():
        for f in sorted(assess_dir.iterdir()):
            if f.suffix == ".md":
                if "solutions" in f.name.lower() and not include_solutions:
                    continue
                files.append(f)

    # Glossary
    glossary_dir = course_dir / "glossary"
    if glossary_dir.exists():
        for f in sorted(glossary_dir.iterdir()):
            if f.suffix == ".md":
                files.append(f)

    # Resources
    res_dir = course_dir / "resources"
    if res_dir.exists():
        for f in sorted(res_dir.iterdir()):
            if f.suffix == ".md":
                files.append(f)

    return files


def build_zip(course_dir: Path, output_dir: Path, include_solutions: bool) -> Path:
    """Package the course as a ZIP file."""
    output_dir.mkdir(parents=True, exist_ok=True)
    zip_path = output_dir / "course.zip"

    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(course_dir):
            # Skip exports/ to avoid recursion
            if "exports" in Path(root).parts:
                continue
            for file in files:
                file_path = Path(root) / file
                if "solutions" in file.lower() and not include_solutions:
                    continue
                arcname = file_path.relative_to(course_dir)
                zf.write(file_path, arcname)

    print(f"✅ ZIP created: {zip_path}")
    return zip_path


def build_pdf(course_dir: Path, output_dir: Path, include_solutions: bool) -> Path:
    """Build a single PDF from all Markdown files.

    This uses a Python script that:
    1. Concatenates all .md files in reading order
    2. Converts Markdown to HTML (with markdown library)
    3. Renders HTML to PDF using ReportLab with Arabic font support

    Note: For proper Arabic rendering, requires:
    - Noto Sans Arabic font (usually at /usr/share/fonts/truetype/)
    - arabic_reshaper and python-bidi libraries
    """
    output_dir.mkdir(parents=True, exist_ok=True)
    pdf_path = output_dir / "course.pdf"

    files = collect_markdown_files(course_dir, include_solutions)

    if not files:
        print("❌ No Markdown files found to build PDF", file=sys.stderr)
        sys.exit(1)

    # Build a Python script that generates the PDF using ReportLab
    # We write this script to /tmp and execute it
    pdf_gen_script = course_dir / "exports" / "_generate_pdf.py"
    pdf_gen_script.parent.mkdir(parents=True, exist_ok=True)

    files_list_str = repr([str(f) for f in files])

    script_content = f'''#!/usr/bin/env python3
"""Auto-generated PDF builder for course: {course_dir.name}"""
import sys
import os

try:
    from reportlab.lib.pagesizes import A4
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib.units import cm
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle
    from reportlab.lib import colors
    from reportlab.pdfbase import pdfmetrics
    from reportlab.pdfbase.ttfonts import TTFont
    from reportlab.lib.enums import TA_RIGHT, TA_LEFT, TA_CENTER
    import markdown
    import html as html_module
except ImportError as e:
    print(f"Missing dependency: {{e}}", file=sys.stderr)
    print("Install with: pip install reportlab markdown arabic-reshaper python-bidi", file=sys.stderr)
    sys.exit(1)

# Try to register Arabic font
ARABIC_FONT_NAME = "NotoSansArabic"
ARABIC_FONT_PATHS = [
    "/usr/share/fonts/truetype/noto/NotoSansArabic-Regular.ttf",
    "/usr/share/fonts/truetype/noto-serif-sc/NotoSerifSC-Regular.otf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",  # fallback
]

font_registered = False
for path in ARABIC_FONT_PATHS:
    if os.path.exists(path):
        try:
            pdfmetrics.registerFont(TTFont(ARABIC_FONT_NAME, path))
            font_registered = True
            print(f"Registered font: {{path}}", file=sys.stderr)
            break
        except Exception as e:
            print(f"Failed to register {{path}}: {{e}}", file=sys.stderr)

if not font_registered:
    ARABIC_FONT_NAME = "Helvetica"  # fallback (won't render Arabic correctly)

# Try to import Arabic reshaper
try:
    import arabic_reshaper
    from bidi.algorithm import get_display
    HAS_ARABIC_SUPPORT = True
except ImportError:
    HAS_ARABIC_SUPPORT = False
    print("Warning: arabic-reshaper or python-bidi not installed. Arabic may not render correctly.",
          file=sys.stderr)

def shape_arabic(text):
    """Shape Arabic text for proper rendering."""
    if not HAS_ARABIC_SUPPORT:
        return text
    try:
        reshaped = arabic_reshaper.reshape(text)
        return get_display(reshaped)
    except Exception:
        return text

# Collect all markdown
files = {files_list_str}

# Concatenate
all_markdown = ""
for f in files:
    with open(f, encoding="utf-8") as fh:
        all_markdown += fh.read() + "\\n\\n---\\n\\n"

# Convert to HTML
html_content = markdown.markdown(all_markdown, extensions=["tables", "fenced_code", "codehilite"])

# Build PDF
doc = SimpleDocTemplate(
    "{pdf_path}",
    pagesize=A4,
    leftMargin=2*cm, rightMargin=2*cm,
    topMargin=2*cm, bottomMargin=2*cm,
)

styles = getSampleStyleSheet()
arabic_style = ParagraphStyle(
    "ArabicBody",
    parent=styles["Normal"],
    fontName=ARABIC_FONT_NAME,
    fontSize=11,
    leading=16,
    alignment=TA_RIGHT,
    wordWrap="RTL",
)

story = []
# Simple approach: render each line as a paragraph
lines = html_content.split("\\n")
for line in lines:
    line = line.strip()
    if not line:
        story.append(Spacer(1, 6))
        continue
    if line.startswith("<h1>"):
        text = line.replace("<h1>", "").replace("</h1>", "")
        story.append(Paragraph(shape_arabic(text), ParagraphStyle(
            "H1", parent=styles["Heading1"], fontName=ARABIC_FONT_NAME,
            fontSize=20, leading=28, alignment=TA_RIGHT)))
        story.append(Spacer(1, 12))
    elif line.startswith("<h2>"):
        text = line.replace("<h2>", "").replace("</h2>", "")
        story.append(Paragraph(shape_arabic(text), ParagraphStyle(
            "H2", parent=styles["Heading2"], fontName=ARABIC_FONT_NAME,
            fontSize=16, leading=22, alignment=TA_RIGHT)))
        story.append(Spacer(1, 8))
    elif line.startswith("<h3>"):
        text = line.replace("<h3>", "").replace("</h3>", "")
        story.append(Paragraph(shape_arabic(text), ParagraphStyle(
            "H3", parent=styles["Heading3"], fontName=ARABIC_FONT_NAME,
            fontSize=14, leading=20, alignment=TA_RIGHT)))
    elif line.startswith("<table>"):
        # Skip tables for simplicity (TODO: render properly)
        story.append(Paragraph("[جدول]", arabic_style))
    elif line.startswith("<pre>"):
        # Code block — render as-is (English)
        text = line.replace("<pre><code>", "").replace("<code>", "").replace("</code></pre>", "").replace("</code>", "")
        text = html_module.unescape(text)
        story.append(Paragraph(text.replace("\\n", "<br/>"), ParagraphStyle(
            "Code", parent=styles["Code"], fontName="Courier",
            fontSize=9, leading=12, alignment=TA_LEFT,
            backColor=colors.lightgrey, borderPadding=4)))
    elif line.startswith("<ul>") or line.startswith("<ol>"):
        continue  # handle in <li>
    elif line.startswith("<li>"):
        text = line.replace("<li>", "• ").replace("</li>", "")
        story.append(Paragraph(shape_arabic(text), arabic_style))
    elif line.startswith("<p>"):
        text = line.replace("<p>", "").replace("</p>", "")
        story.append(Paragraph(shape_arabic(text), arabic_style))
    else:
        # Skip HTML we don't handle
        pass

doc.build(story)
print(f"✅ PDF created: {pdf_path}", file=sys.stderr)
'''

    pdf_gen_script.write_text(script_content, encoding="utf-8")

    # Execute the PDF generation script
    try:
        result = subprocess.run(
            ["python3", str(pdf_gen_script)],
            capture_output=True, text=True, timeout=600
        )
        if result.returncode != 0:
            print(f"❌ PDF generation failed:", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            sys.exit(1)
        print(result.stderr, file=sys.stderr)  # progress messages
    except subprocess.TimeoutExpired:
        print("❌ PDF generation timed out (600s)", file=sys.stderr)
        sys.exit(1)

    # Cleanup
    pdf_gen_script.unlink(missing_ok=True)

    return pdf_path


def build_pptx(course_dir: Path, output_dir: Path, include_solutions: bool) -> Path:
    """Build a PPTX from the course (one slide per lesson section)."""
    output_dir.mkdir(parents=True, exist_ok=True)
    pptx_path = output_dir / "course.pptx"

    try:
        from pptx import Presentation
        from pptx.util import Inches, Pt
    except ImportError:
        print("❌ python-pptx not installed. Install with: pip install python-pptx", file=sys.stderr)
        sys.exit(1)

    files = collect_markdown_files(course_dir, include_solutions)
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)

    title_layout = prs.slide_layouts[0]
    content_layout = prs.slide_layouts[1]

    for md_file in files:
        with open(md_file, encoding="utf-8") as f:
            content = f.read()

        # Parse: title (first H1), then sections (H2/H3)
        lines = content.split("\n")
        title = md_file.stem
        for line in lines:
            if line.startswith("# "):
                title = line[2:].strip()
                break

        # Title slide
        slide = prs.slides.add_slide(title_layout)
        slide.shapes.title.text = title
        if len(slide.placeholders) > 1:
            slide.placeholders[1].text = f"From: {md_file.relative_to(course_dir)}"

        # Content slides (one per H2 section)
        current_section = None
        current_content = []
        for line in lines:
            if line.startswith("## "):
                if current_section:
                    slide = prs.slides.add_slide(content_layout)
                    slide.shapes.title.text = current_section
                    if len(slide.placeholders) > 1:
                        body = slide.placeholders[1]
                        body.text = "\n".join(current_content[:10])  # cap at 10 lines
                current_section = line[3:].strip()
                current_content = []
            elif current_section:
                current_content.append(line)

        # Last section
        if current_section:
            slide = prs.slides.add_slide(content_layout)
            slide.shapes.title.text = current_section
            if len(slide.placeholders) > 1:
                body = slide.placeholders[1]
                body.text = "\n".join(current_content[:10])

    prs.save(str(pptx_path))
    print(f"✅ PPTX created: {pptx_path}")
    return pptx_path


def build_web(course_dir: Path, output_dir: Path, include_solutions: bool) -> Path:
    """Build a static HTML site (MkDocs-style)."""
    web_dir = output_dir / "web"
    if web_dir.exists():
        shutil.rmtree(web_dir)
    web_dir.mkdir(parents=True)

    # Copy all .md files
    docs_dir = web_dir / "docs"
    docs_dir.mkdir()

    for root, dirs, files in os.walk(course_dir):
        if "exports" in Path(root).parts:
            continue
        for file in files:
            src = Path(root) / file
            if "solutions" in file.lower() and not include_solutions:
                continue
            rel = src.relative_to(course_dir)
            dst = docs_dir / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)

    # Create index.html (simple)
    index_html = """<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<title>Course</title>
<style>
body { font-family: 'Noto Sans Arabic', sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
h1 { color: #333; }
</style>
</head>
<body>
<h1>الدورة التعليمية</h1>
<p>افتح README.md للبدء.</p>
<p><a href="docs/README.md">الذهاب إلى المحتوى</a></p>
</body>
</html>"""
    (web_dir / "index.html").write_text(index_html, encoding="utf-8")

    print(f"✅ Web site created: {web_dir}")
    return web_dir


def main():
    args = parse_args()
    course_dir = Path(args.input).resolve()

    if not course_dir.exists():
        print(f"❌ Course directory not found: {course_dir}", file=sys.stderr)
        sys.exit(1)

    manifest = load_manifest(course_dir)
    print(f"📚 Building course: {manifest.get('course_name', course_dir.name)}", file=sys.stderr)

    output_dir = Path(args.output) if args.output else course_dir / "exports"

    fmt = args.format
    if fmt == "all":
        fmts = ["zip", "pdf", "pptx", "web"]
    else:
        fmts = [fmt]

    for f in fmts:
        print(f"\n--- Building {f.upper()} ---", file=sys.stderr)
        if f == "zip":
            build_zip(course_dir, output_dir, args.include_solutions)
        elif f == "pdf":
            build_pdf(course_dir, output_dir, args.include_solutions)
        elif f == "pptx":
            build_pptx(course_dir, output_dir, args.include_solutions)
        elif f == "web":
            build_web(course_dir, output_dir, args.include_solutions)

    print(f"\n✅ Build complete. Outputs in: {output_dir}", file=sys.stderr)


if __name__ == "__main__":
    main()
