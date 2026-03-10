#!/bin/bash

# Copy skills to Claude/Cursor global skill folders
# TUI version with checkbox selection

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

SKILLS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║   Copy Skills to Global Folders       ║${NC}"
echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════╝${NC}"
echo ""

# Step 1: List available skills
cd "$SKILLS_DIR"
SKILLS=()
for dir in */; do
    if [ -f "${dir}SKILL.md" ]; then
        SKILL_NAME="${dir%/}"
        SKILLS+=("$SKILL_NAME")
    fi
done

if [ ${#SKILLS[@]} -eq 0 ]; then
    echo -e "${RED}✗ No skills found in this project!${NC}"
    exit 1
fi

# Check if fzf is available
if command -v fzf &> /dev/null; then
    USE_FZF=true
else
    USE_FZF=false
fi

if [ "$USE_FZF" = true ]; then
    # Use fzf for TUI selection
    echo -e "${CYAN}Select skills to copy:${NC}"
    echo -e "${DIM}(Use TAB to toggle selection, ENTER to confirm)${NC}"
    echo ""

    # Build fzf options for multi-select with checkboxes
    SELECTED=$(printf '%s\n' "${SKILLS[@]}" | fzf \
        --prompt="Select skills > " \
        --header="Select skills to copy (TAB to toggle)" \
        --height=~50% \
        --border \
        --layout=reverse \
        --color=header:italic:underline,marker:green \
        -m \
        --preview="cat $SKILLS_DIR/{}" \
        --preview-window=up:3:wrap)

    # Convert selected lines to array
    SELECTED_SKILLS=()
    while IFS= read -r line; do
        SELECTED_SKILLS+=("$line")
    done <<< "$SELECTED"
else
    # Fallback: Simple numbered list with checkboxes
    echo -e "${CYAN}Available skills:${NC}"
    echo ""

    for i in "${!SKILLS[@]}"; do
        idx=$((i + 1))
        echo -e "  ${YELLOW}[ ]${NC} ${BOLD}$idx)${NC} ${SKILLS[$i]}"
    done

    echo ""
    echo -e "${CYAN}Enter skill numbers to copy (comma-separated, 'a' for all):${NC}"
    read -r SELECTION

    SELECTED_SKILLS=()

    if [ "$SELECTION" = "a" ] || [ "$SELECTION" = "all" ]; then
        SELECTED_SKILLS=("${SKILLS[@]}")
    else
        IFS=',' read -ra NUMBERS <<< "$SELECTION"
        for num in "${NUMBERS[@]}"; do
            idx=$((num - 1))
            if [ $idx -ge 0 ] && [ $idx -lt ${#SKILLS[@]} ]; then
                SELECTED_SKILLS+=("${SKILLS[$idx]}")
            fi
        done
    fi
fi

if [ ${#SELECTED_SKILLS[@]} -eq 0 ]; then
    echo -e "${RED}✗ No skills selected!${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Selected skills:${NC}"
for skill in "${SELECTED_SKILLS[@]}"; do
    echo -e "  ${GREEN}☑${NC} $skill"
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"

# Step 2: Select target tools with checkbox TUI
echo -e "${CYAN}Select target tools:${NC}"
echo -e "${DIM}(Use TAB to toggle, ENTER to confirm)${NC}"
echo ""

if [ "$USE_FZF" = true ]; then
    TARGETS=()
    TOOL_OPTIONS=("Claude" "Cursor" "Kiro-CLI" "All")

    SELECTED_TARGETS=$(printf '%s\n' "${TOOL_OPTIONS[@]}" | fzf \
        --prompt="Select targets > " \
        --header="Select target tools (TAB to toggle)" \
        --height=~40% \
        --border \
        --layout=reverse \
        --color=header:italic,marker:green \
        -m)

    # Check if "All" is selected
    if echo "$SELECTED_TARGETS" | grep -q "^All$"; then
        TARGETS=("claude" "cursor" "kiro")
    else
        while IFS= read -r tool; do
            case "$tool" in
                "Claude") TARGETS+=("claude") ;;
                "Cursor") TARGETS+=("cursor") ;;
                "Kiro-CLI") TARGETS+=("kiro") ;;
            esac
        done <<< "$SELECTED_TARGETS"
    fi
else
    # Fallback: numbered selection with "All" option
    echo -e "  ${YELLOW}[ ]${NC} ${BOLD}1)${NC} Claude"
    echo -e "  ${YELLOW}[ ]${NC} ${BOLD}2)${NC} Cursor"
    echo -e "  ${YELLOW}[ ]${NC} ${BOLD}3)${NC} Kiro-CLI"
    echo -e "  ${YELLOW}[ ]${NC} ${BOLD}4)${NC} All"
    echo ""
    echo -e "${CYAN}Enter numbers to select (comma-separated, e.g., 1,3 or 4 for all):${NC}"
    read -r SELECTION

    TARGETS=()
    IFS=',' read -ra NUMBERS <<< "$SELECTION"
    for num in "${NUMBERS[@]}"; do
        case $num in
            1) TARGETS+=("claude") ;;
            2) TARGETS+=("cursor") ;;
            3) TARGETS+=("kiro") ;;
            4) TARGETS=("claude" "cursor" "kiro"); break ;;
        esac
    done
fi

if [ ${#TARGETS[@]} -eq 0 ]; then
    echo -e "${RED}✗ No targets selected!${NC}"
    exit 1
fi

# Determine target directories
CLAUDE_DIR="$HOME/.claude/skills"
CURSOR_DIR="$HOME/.cursor/skills"
KIRO_DIR="$HOME/.kiro/ai/skills"

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Selected targets:${NC}"
for tool in "${TARGETS[@]}"; do
    case "$tool" in
        claude) echo -e "  ${GREEN}☑${NC} Claude" ;;
        cursor) echo -e "  ${GREEN}☑${NC} Cursor" ;;
        kiro) echo -e "  ${GREEN}☑${NC} Kiro-CLI" ;;
    esac
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${MAGENTA}▸ Copying skills...${NC}"
echo ""

for tool in "${TARGETS[@]}"; do
    case "$tool" in
        claude)
            TARGET_DIR="$CLAUDE_DIR"
            TOOL_NAME="Claude"
            ;;
        cursor)
            TARGET_DIR="$CURSOR_DIR"
            TOOL_NAME="Cursor"
            ;;
        kiro)
            TARGET_DIR="$KIRO_DIR"
            TOOL_NAME="Kiro-CLI"
            ;;
    esac

    # Create directory if not exists
    mkdir -p "$TARGET_DIR"

    echo -e "${CYAN}▸ Copying to $TOOL_NAME${NC} ${DIM}($TARGET_DIR)${NC}"

    for skill in "${SELECTED_SKILLS[@]}"; do
        SOURCE="$SKILLS_DIR/$skill"
        rm -rf "$TARGET_DIR/$skill"
        ln -s "$SOURCE" "$TARGET_DIR/$skill"
        echo -e "    ${GREEN}✓${NC} $skill"
    done
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}✓ Done! Skills copied successfully.${NC}"
echo ""
echo -e "${CYAN}You can now use these skills in your IDEs.${NC}"
