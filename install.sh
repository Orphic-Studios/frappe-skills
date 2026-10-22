#!/usr/bin/env bash
#
# Frappe Skills Pack — Universal AI Agent Installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Orphic-Studios/frappe-skills/main/install.sh | bash
#
# Or:
#   git clone https://github.com/Orphic-Studios/frappe-skills.git && cd frappe-skills && ./install.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}ℹ${NC}  $1"; }
success() { echo -e "${GREEN}✓${NC}  $1"; }
warning() { echo -e "${YELLOW}⚠${NC}  $1"; }
error() { echo -e "${RED}✗${NC}  $1"; }

REPO_URL="https://github.com/Orphic-Studios/frappe-skills.git"
TEMP_DIR="/tmp/frappe-skills-install-$$"

detect_agents() {
    local agents=()

    # Hermes
    if [ -d "$HOME/.config/hermes" ] || command -v hermes &>/dev/null; then
        agents+=("Hermes:$HOME/.config/hermes/skills")
    fi

    # Claude Code
    if [ -d "$HOME/.claude" ] || command -v claude &>/dev/null; then
        agents+=("Claude Code:$HOME/.claude/skills")
    fi

    # Google Antigravity / Gemini
    if [ -d "$HOME/.gemini" ] || [ -d "$HOME/.antigravity" ]; then
        agents+=("Antigravity & Gemini:$HOME/.gemini/antigravity/skills")
    fi

    # Cursor
    if [ -d "$HOME/.cursor" ]; then
        agents+=("Cursor:$HOME/.cursor/skills")
    fi

    # Windsurf
    if [ -d "$HOME/.windsurf" ]; then
        agents+=("Windsurf:$HOME/.windsurf/skills")
    fi

    # Cline
    if [ -d "$HOME/.cline" ]; then
        agents+=("Cline:$HOME/.cline/skills")
    fi

    # Generic
    if [ -d "$HOME/.skills" ]; then
        agents+=("Generic Skills:$HOME/.skills")
    fi

    for a in "${agents[@]}"; do
        echo "$a"
    done
}

install_to_dir() {
    local target_dir="$1"
    mkdir -p "$target_dir"

    # Install frappe-docs
    rm -rf "$target_dir/frappe-docs"
    cp -r "$SOURCE_DIR/frappe-docs" "$target_dir/"

    # Install frappe-course-generator
    rm -rf "$target_dir/frappe-course-generator"
    cp -r "$SOURCE_DIR/frappe-course-generator" "$target_dir/"

    success "Installed to $target_dir"
}

main() {
    echo ""
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${CYAN}       Frappe Skills Pack — Multi-Agent Installer   ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo ""

    if ! command -v git &>/dev/null; then
        error "git is not installed. Please install git first."
        exit 1
    fi

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "$SCRIPT_DIR/frappe-docs/SKILL.md" ]; then
        SOURCE_DIR="$SCRIPT_DIR"
    else
        info "Cloning repository..."
        rm -rf "$TEMP_DIR"
        git clone --depth 1 "$REPO_URL" "$TEMP_DIR"
        SOURCE_DIR="$TEMP_DIR"
    fi

    # Detect installed agent environments
    mapfile -t DETECTED < <(detect_agents)

    if [ ${#DETECTED[@]} -eq 0 ]; then
        warning "No known AI agent directories detected automatically."
        echo "Defaulting to ~/.skills/"
        TARGET_DIR="$HOME/.skills"
        install_to_dir "$TARGET_DIR"
    elif [ "$1" == "--all" ]; then
        info "Installing to all detected agents..."
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
        echo -e "  $(( ${#DETECTED[@]} + 1 )). ${YELLOW}Install to ALL detected agents${NC}"
        echo -e "  $(( ${#DETECTED[@]} + 2 )). Custom directory"
        echo ""

        read -p "Select option [1-$(( ${#DETECTED[@]} + 2 ))]: " choice
        
        if [ "$choice" -ge 1 ] && [ "$choice" -le "${#DETECTED[@]}" ]; then
            selected_path="${DETECTED[$((choice-1))]#*:}"
            install_to_dir "$selected_path"
        elif [ "$choice" -eq "$(( ${#DETECTED[@]} + 1 ))" ]; then
            for entry in "${DETECTED[@]}"; do
                target="${entry#*:}"
                install_to_dir "$target"
            done
        else
            read -p "Enter custom skills directory path: " custom_dir
            install_to_dir "$custom_dir"
        fi
    fi

    # Cleanup temp
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi

    echo ""
    echo -e "${GREEN}🎉 Installation successful!${NC}"
    echo "Restart your agent to activate frappe-docs and frappe-course-generator."
    echo ""
}

main "$@"

