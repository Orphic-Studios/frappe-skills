#!/usr/bin/env bash
#
# Frappe Skills Pack - Universal AI Agent Installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Orphic-Studios/frappe-skills/main/install.sh | bash
#   ./install.sh --all
#   ./install.sh --agent hermes
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

resolve_agent_path() {
    case "$1" in
        hermes) echo "$HOME/.config/hermes/skills" ;;
        claude|claude-code) echo "$HOME/.claude/skills" ;;
        antigravity|agy) echo "$HOME/.gemini/antigravity/skills" ;;
        gemini|gemini-cli) echo "$HOME/.gemini/skills" ;;
        codex) echo "$HOME/.codex/skills" ;;
        cursor) echo "$HOME/.cursor/skills" ;;
        windsurf) echo "$HOME/.codeium/windsurf/skills" ;;
        opencode) echo "$HOME/.config/opencode/skills" ;;
        copilot|copilot-cli) echo "$HOME/.copilot/skills" ;;
        commandcode) echo "$HOME/.commandcode/skills" ;;
        cline) echo "$HOME/.cline/skills" ;;
        roo|roo-code) echo "$HOME/.roo/skills" ;;
        kiro) echo "$HOME/.kiro/skills" ;;
        generic|skills) echo "$HOME/.skills" ;;
        *) echo "" ;;
    esac
}

detect_agents() {
    # Hermes
    if [ -d "$HOME/.config/hermes" ] || command -v hermes >/dev/null 2>&1; then
        echo "Hermes:$HOME/.config/hermes/skills"
    fi

    # Claude Code
    if [ -d "$HOME/.claude" ] || command -v claude >/dev/null 2>&1; then
        echo "Claude Code:$HOME/.claude/skills"
    fi

    # Google Antigravity
    if [ -d "$HOME/.gemini/antigravity" ] || [ -d "$HOME/.antigravity" ] || command -v agy >/dev/null 2>&1; then
        echo "Google Antigravity:$HOME/.gemini/antigravity/skills"
    fi

    # Gemini CLI
    if [ -d "$HOME/.gemini" ] || command -v gemini >/dev/null 2>&1; then
        echo "Gemini CLI:$HOME/.gemini/skills"
    fi

    # OpenAI Codex CLI
    if [ -d "$HOME/.codex" ] || command -v codex >/dev/null 2>&1; then
        echo "OpenAI Codex:$HOME/.codex/skills"
    fi

    # Cursor
    if [ -d "$HOME/.cursor" ]; then
        echo "Cursor:$HOME/.cursor/skills"
    fi

    # Windsurf
    if [ -d "$HOME/.codeium/windsurf" ]; then
        echo "Windsurf:$HOME/.codeium/windsurf/skills"
    elif [ -d "$HOME/.windsurf" ]; then
        echo "Windsurf:$HOME/.windsurf/skills"
    fi

    # OpenCode
    if [ -d "$HOME/.config/opencode" ]; then
        echo "OpenCode:$HOME/.config/opencode/skills"
    fi

    # GitHub Copilot CLI
    if [ -d "$HOME/.copilot" ]; then
        echo "GitHub Copilot CLI:$HOME/.copilot/skills"
    fi

    # Command Code
    if [ -d "$HOME/.commandcode" ]; then
        echo "Command Code:$HOME/.commandcode/skills"
    fi

    # Cline
    if [ -d "$HOME/.cline" ]; then
        echo "Cline:$HOME/.cline/skills"
    fi

    # Roo Code
    if [ -d "$HOME/.roo" ]; then
        echo "Roo Code:$HOME/.roo/skills"
    fi

    # Kiro
    if [ -d "$HOME/.kiro" ]; then
        echo "Kiro:$HOME/.kiro/skills"
    fi

    # Generic ~/.skills/
    if [ -d "$HOME/.skills" ]; then
        echo "Generic Skills:$HOME/.skills"
    fi
}

install_to_dir() {
    local target_dir="$1"
    mkdir -p "$target_dir"

    rm -rf "$target_dir/frappe-docs"
    cp -r "$SOURCE_DIR/skills/frappe-docs" "$target_dir/"

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
    local install_all=0
    local requested_agent=""

    while [ $# -gt 0 ]; do
        case "$1" in
            --all|-a)
                install_all=1
                shift
                ;;
            --agent)
                requested_agent="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    if [ "$requested_agent" = "all" ]; then
        install_all=1
        requested_agent=""
    fi

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

    if [ -n "$requested_agent" ]; then
        target_path="$(resolve_agent_path "$requested_agent")"
        if [ -z "$target_path" ]; then
            error "Unknown agent: $requested_agent"
            exit 1
        fi
        install_to_dir "$target_path"
        echo ""
        echo -e "${GREEN}[OK] Installation complete!${NC}"
        exit 0
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
    elif [ "$install_all" -eq 1 ] || [ ! -t 0 ]; then
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
