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

# Step 2: Select target tools with TUI
echo -e "${CYAN}Copy to which tool(s)?${NC}"
echo ""
echo -e "  ${YELLOW}◉${NC} ${BOLD}1)${NC} Claude only"
echo -e "  ${YELLOW}○${NC} ${BOLD}2)${NC} Cursor only"
echo -e "  ${YELLOW}◉${NC} ${BOLD}3)${NC} Both Claude and Cursor"
echo ""

# TUI for target selection
if [ "$USE_FZF" = true ]; then
    TARGET=$(printf '%s\n' "Claude only" "Cursor only" "Both" | fzf \
        --prompt="Select target > " \
        --height=~30% \
        --border \
        --layout=reverse \
        --color=header:italic)
    case "$TARGET" in
        "Claude only") TARGETS=("claude") ;;
        "Cursor only") TARGETS=("cursor") ;;
        "Both") TARGETS=("claude" "cursor") ;;
    esac
else
    read -r TARGET
    case $TARGET in
        1) TARGETS=("claude") ;;
        2) TARGETS=("cursor") ;;
        3) TARGETS=("claude" "cursor") ;;
        *)
            echo -e "${RED}✗ Invalid selection!${NC}"
            exit 1
            ;;
    esac
fi

CLAUDE_DIR="$HOME/.claude/skills"
CURSOR_DIR="$HOME/.cursor/skills"

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${MAGENTA}▸ Copying skills...${NC}"
echo ""

for tool in "${TARGETS[@]}"; do
    if [ "$tool" = "claude" ]; then
        TARGET_DIR="$CLAUDE_DIR"
    else
        TARGET_DIR="$CURSOR_DIR"
    fi

    # Create directory if not exists
    mkdir -p "$TARGET_DIR"

    echo -e "${CYAN}▸ Copying to $tool${NC} ${DIM}($TARGET_DIR)${NC}"

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
echo -e "${CYAN}You can now use these skills in Claude/Cursor.${NC}"
