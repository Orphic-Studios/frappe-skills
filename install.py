#!/usr/bin/env python3
"""
Frappe Skills Pack - Cross-Platform Installer for AI Agents
Supports: Hermes, Claude Code, Google Antigravity, Gemini CLI, OpenAI Codex,
Cursor, Windsurf, OpenCode, GitHub Copilot CLI, Command Code, Cline, Roo Code, Kiro, and generic skills.
"""

import argparse
import shutil
import sys
import tempfile
import urllib.request
import zipfile
from pathlib import Path

HOME = Path.home()
SCRIPT_DIR = Path(__file__).resolve().parent
ZIP_URL = "https://github.com/Orphic-Studios/frappe-skills/archive/refs/heads/main.zip"

AGENTS = [
    ("antigravity", "Google Antigravity", HOME / ".gemini" / "antigravity" / "skills", HOME / ".gemini" / "antigravity"),
    ("gemini", "Gemini CLI", HOME / ".gemini" / "skills", HOME / ".gemini"),
    ("claude", "Claude Code", HOME / ".claude" / "skills", HOME / ".claude"),
    ("codex", "OpenAI Codex", HOME / ".codex" / "skills", HOME / ".codex"),
    ("cursor", "Cursor", HOME / ".cursor" / "skills", HOME / ".cursor"),
    ("windsurf", "Windsurf", HOME / ".codeium" / "windsurf" / "skills", HOME / ".codeium" / "windsurf"),
    ("hermes", "Hermes", HOME / ".config" / "hermes" / "skills", HOME / ".config" / "hermes"),
    ("opencode", "OpenCode", HOME / ".config" / "opencode" / "skills", HOME / ".config" / "opencode"),
    ("copilot", "GitHub Copilot CLI", HOME / ".copilot" / "skills", HOME / ".copilot"),
    ("commandcode", "Command Code", HOME / ".commandcode" / "skills", HOME / ".commandcode"),
    ("cline", "Cline", HOME / ".cline" / "skills", HOME / ".cline"),
    ("roo", "Roo Code", HOME / ".roo" / "skills", HOME / ".roo"),
    ("kiro", "Kiro", HOME / ".kiro" / "skills", HOME / ".kiro"),
    ("generic", "Generic Skills", HOME / ".skills", HOME / ".skills"),
]


def get_source_dir(temp_root: Path) -> Path:
    local_skills = SCRIPT_DIR / "skills" / "frappe-docs" / "SKILL.md"
    if local_skills.exists():
        return SCRIPT_DIR

    print("[INFO] Downloading latest skills package from GitHub...")
    zip_path = temp_root / "frappe-skills.zip"
    urllib.request.urlretrieve(ZIP_URL, zip_path)
    with zipfile.ZipFile(zip_path, "r") as zf:
        zf.extractall(temp_root)
    return temp_root / "frappe-skills-main"


def install_skills(source_dir: Path, dest: Path) -> None:
    dest.mkdir(parents=True, exist_ok=True)
    for skill in ["frappe-docs", "frappe-course-generator"]:
        src = source_dir / "skills" / skill
        target = dest / skill
        if target.exists():
            shutil.rmtree(target)
        shutil.copytree(src, target)
    print(f"[OK] Installed skills to: {dest}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Frappe Skills Pack - Universal Python Installer")
    parser.add_argument("--all", action="store_true", help="Install to all detected agents")
    parser.add_argument(
        "--agent",
        type=str,
        default="",
        help="Target a specific agent (hermes, claude, gemini, antigravity, codex, cursor, windsurf, opencode, copilot, commandcode, cline, roo, kiro, generic, or all)",
    )
    parser.add_argument("--path", type=str, default="", help="Install to a custom directory path")
    args = parser.parse_args()

    print("\n====================================================")
    print("      Frappe Skills Pack - Python Multi-Agent Installer")
    print("====================================================\n")

    with tempfile.TemporaryDirectory() as tmp:
        source_dir = get_source_dir(Path(tmp))

        if args.path:
            install_skills(source_dir, Path(args.path).expanduser())
            return

        agent_Map = {key: path for key, _, path, _ in AGENTS}
        if args.agent and args.agent.lower() != "all":
            key = args.agent.lower()
            if key not in agent_Map:
                print(f"[ERROR] Unknown agent '{args.agent}'. Valid options: {', '.join(agent_Map.keys())}, all")
                sys.exit(1)
            install_skills(source_dir, agent_Map[key])
            print("\n[OK] Installation complete! Restart your AI agent to apply.")
            return

        detected = [(name, path) for _, name, path, check in AGENTS if check.exists()]

        if not detected:
            dest = HOME / ".skills"
            print(f"No specific agent detected. Installing to generic path: {dest}")
            install_skills(source_dir, dest)
            return

        if args.all or args.agent.lower() == "all" or not sys.stdin.isatty():
            print("Installing to all detected agents...")
            for _, path in detected:
                install_skills(source_dir, path)
            print("\n[OK] Installation complete! Restart your AI agent to apply.")
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
            choice = all_opt if not raw else int(raw)
        except (ValueError, EOFError):
            choice = all_opt

        if 1 <= choice <= len(detected):
            install_skills(source_dir, detected[choice - 1][1])
        elif choice == all_opt:
            for _, path in detected:
                install_skills(source_dir, path)
        else:
            try:
                custom_path = input("Enter custom path: ").strip()
                if custom_path:
                    install_skills(source_dir, Path(custom_path).expanduser())
            except (EOFError, KeyboardInterrupt):
                pass

        print("\n[OK] Installation complete! Restart your AI agent to apply.")


if __name__ == "__main__":
    main()
