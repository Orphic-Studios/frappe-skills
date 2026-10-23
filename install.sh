#!/usr/bin/env bash
#
# Frappe Skills Pack - Universal AI Agent Installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Orphic-Studios/frappe-skills/main/install.sh | bash
#
# Or:
#   git clone https://github.com/Orphic-Studios/frappe-skills.git && cd frappe-skills && ./install.sh
#

set -e

# ANSI Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warning() { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

REPO_URL="https://github.com/Orphic-Studios/frappe-skills.git"
ZIP_URL="https://github.com/Orphic-Studios/frappe-skills/archive/refs/heads/main.zip"
TEMP_DIR="/tmp/frappe-skills-install-$$"

detect_agents() {
    # Hermes
    if [ -d "$HOME/.config/hermes" ] || command -v hermes >/dev/null 2>&1; then
        echo "Hermes:$HOME/.config/hermes/skills"
    fi

    # Claude Code
    if [ -d "$HOME/.claude" ] || command -v claude >/dev/null 2>&1; then
        echo "Claude Code:$HOME/.claude/skills"
    fi

    # Google Antigravity & Gemini
    if [ -d "$HOME/.gemini" ] || [ -d "$HOME/.antigravity" ]; then
        echo "Antigravity & Gemini:$HOME/.gemini/antigravity/skills"
    fi

    # Cursor
    if [ -d "$HOME/.cursor" ]; then
        echo "Cursor:$HOME/.cursor/skills"
    fi

    # Windsurf
    if [ -d "$HOME/.windsurf" ]; then
        echo "Windsurf:$HOME/.windsurf/skills"
    fi

    # OpenCode
    if [ -d "$HOME/.config/opencode" ]; then
        echo "OpenCode:$HOME/.config/opencode/skills"
    fi

    # Cline
    if [ -d "$HOME/.cline" ]; then
        echo "Cline:$HOME/.cline/skills"
    fi

    # Generic ~/.skills/
    if [ -d "$HOME/.skills" ]; then
        echo "Generic Skills:$HOME/.skills"
    fi
}

install_to_dir() {
    local target_dir="$1"
    mkdir -p "$target_dir"

    # Install frappe-docs
    rm -rf "$target_dir/frappe-docs"
    cp -r "$SOURCE_DIR/skills/frappe-docs" "$target_dir/"

    # Install frappe-course-generator
    rm -rf "$target_dir/frappe-course-generator"
    cp -r "$SOURCE_DIR/skills/frappe-course-generator" "$target_dir/"

    success "Installed to $target_dir"
}

cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

main() {
    echo ""
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${CYAN}       Frappe Skills Pack - Multi-Agent Installer   ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo ""

    # Locate source files
    SCRIPT_DIR=""
    if [ -n "${BASH_SOURCE[0]}" ]; then
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
    fi

    if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/skills/frappe-docs/SKILL.md" ]; then
        SOURCE_DIR="$SCRIPT_DIR"
        info "Using local files from: $SOURCE_DIR"
    else
        mkdir -p "$TEMP_DIR"
        if command -v git >/dev/null 2>&1; then
            info "Cloning latest repository from GitHub..."
            git clone --depth 1 "$REPO_URL" "$TEMP_DIR/repo" 2>&1 | sed 's/^/    /'
            SOURCE_DIR="$TEMP_DIR/repo"
        else
            info "Downloading archive from GitHub..."
            curl -fsSL "$ZIP_URL" -o "$TEMP_DIR/frappe-skills.zip"
            unzip -q "$TEMP_DIR/frappe-skills.zip" -d "$TEMP_DIR"
            SOURCE_DIR="$TEMP_DIR/frappe-skills-main"
        fi
        success "Skills package downloaded."
    fi

    # Read detected agents portably (compatible with Bash 3.2 on macOS and Bash 4/5)
    DETECTED=()
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            DETECTED+=("$line")
        fi
    done <<EOF
$(detect_agents)
EOF

    if [ ${#DETECTED[@]} -eq 0 ]; then
        warning "No known AI agent directories detected. Using ~/.skills/"
        install_to_dir "$HOME/.skills"
    elif [ "$1" = "--all" ] || [ ! -t 0 ]; then
        info "Installing to all detected agent environments..."
        for entry in "${DETECTED[@]}"; do
            target="${entry#*:}"
            install_to_dir "$target"
        done
    else
        echo "Detected AI agent environments:"
        for i in "${!DETECTED[@]}"; do
            name="${DETECTED[$i]%%:*}"
            path="${DETECTED[$i]#*:}"
            echo -e "  $((i+1)). ${CYAN}$name${NC} ($path)"
        done
        echo -e "  $(( ${#DETECTED[@]} + 1 )). ${YELLOW}Install to ALL detected agents (default)${NC}"
        echo -e "  $(( ${#DETECTED[@]} + 2 )). Custom directory"
        echo ""

        # Try reading from /dev/tty if available
        choice=""
        if [ -e /dev/tty ]; then
            read -r -p "Select option [1-$(( ${#DETECTED[@]} + 2 ))] (Press Enter for ALL): " choice < /dev/tty
        fi

        if [ -z "$choice" ] || [ "$choice" -eq "$(( ${#DETECTED[@]} + 1 ))" ]; then
            for entry in "${DETECTED[@]}"; do
                target="${entry#*:}"
                install_to_dir "$target"
            done
        elif [ "$choice" -ge 1 ] && [ "$choice" -le "${#DETECTED[@]}" ]; then
            selected_path="${DETECTED[$((choice-1))]#*:}"
            install_to_dir "$selected_path"
        else
            custom_dir=""
            if [ -e /dev/tty ]; then
                read -r -p "Enter custom skills directory path: " custom_dir < /dev/tty
            fi
            if [ -n "$custom_dir" ]; then
                install_to_dir "$custom_dir"
            fi
        fi
    fi

    echo ""
    echo -e "${GREEN}[OK] Installation complete!${NC}"
    echo "Restart your AI agent to activate frappe-docs and frappe-course-generator."
    echo ""
}

main "$@"
