#!/usr/bin/env python3
"""
Frappe Skills Pack - Cross-Platform Installer for AI Agents
Supports: Hermes, Claude Code, Gemini/Antigravity, Cursor, Windsurf, Cline, and generic skills.
"""

import os
import sys
import shutil
from pathlib import Path

HOME = Path.home()
SCRIPT_DIR = Path(__file__).resolve().parent

AGENTS = [
    ("Google Antigravity & Gemini", HOME / ".gemini" / "antigravity" / "skills", HOME / ".gemini"),
    ("Claude Code", HOME / ".claude" / "skills", HOME / ".claude"),
    ("Cursor", HOME / ".cursor" / "skills", HOME / ".cursor"),
    ("Windsurf", HOME / ".windsurf" / "skills", HOME / ".windsurf"),
    ("Hermes", HOME / ".config" / "hermes" / "skills", HOME / ".config" / "hermes"),
    ("Cline", HOME / ".cline" / "skills", HOME / ".cline"),
    ("Generic Skills", HOME / ".skills", HOME / ".skills"),
]

def install_skills(dest: Path):
    dest.mkdir(parents=True, exist_ok=True)
    for skill in ["frappe-docs", "frappe-course-generator"]:
        src = SCRIPT_DIR / skill
        target = dest / skill
        if target.exists():
            shutil.rmtree(target)
        shutil.copytree(src, target)
    print(f"[OK] Installed skills to: {dest}")

def main():
    print("\n====================================================")
    print("      Frappe Skills Pack - Python Multi-Agent Installer")
    print("====================================================\n")

    detected = [(name, path) for name, path, check in AGENTS if check.exists()]

    if not detected:
        dest = HOME / ".skills"
        print(f"No specific agent detected. Installing to generic path: {dest}")
        install_skills(dest)
        return

    if "--all" in sys.argv:
        print("Installing to all detected agents...")
        for name, path in detected:
            install_skills(path)
        return

    print("Detected AI Agent environments:")
    for idx, (name, path) in enumerate(detected, 1):
        print(f"  {idx}. {name} ({path})")
    all_opt = len(detected) + 1
    custom_opt = len(detected) + 2
    print(f"  {all_opt}. Install to ALL detected agents (default)")
    print(f"  {custom_opt}. Custom directory\n")

    try:
        raw = input(f"Select option [1-{custom_opt}]: ").strip()
        if not raw:
            choice = all_opt
        else:
            choice = int(raw)
    except (ValueError, EOFError):
        choice = all_opt

    if 1 <= choice <= len(detected):
        install_skills(detected[choice - 1][1])
    elif choice == all_opt:
        for name, path in detected:
            install_skills(path)
    else:
        try:
            custom_path = input("Enter custom path: ").strip()
            if custom_path:
                install_skills(Path(custom_path).expanduser())
        except (EOFError, KeyboardInterrupt):
            pass

    print("\n[OK] Installation complete! Restart your AI agent to apply.")

if __name__ == "__main__":
    main()
