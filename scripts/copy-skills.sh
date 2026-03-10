#!/bin/bash

# Copy skills to Claude/Cursor global skill folders

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

SKILLS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "${BLUE}${BOLD}========================================${NC}"
echo -e "${BLUE}${BOLD}   Copy Skills to Global Folders${NC}"
echo -e "${BLUE}${BOLD}========================================${NC}"
echo ""

# Step 1: List available skills
echo -e "${CYAN}Available skills in this project:${NC}"
echo ""

cd "$SKILLS_DIR"
SKILLS=()
for dir in */; do
    if [ -f "${dir}SKILL.md" ]; then
        SKILL_NAME="${dir%/}"
        SKILLS+=("$SKILL_NAME")
        echo -e "  ${YELLOW}[$(( ${#SKILLS[@]} ))]${NC} ${BOLD}$SKILL_NAME${NC}"
    fi
done

if [ ${#SKILLS[@]} -eq 0 ]; then
    echo -e "${RED}No skills found in this project!${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}========================================${NC}"

# Step 2: Select skills
echo -e "${CYAN}Enter skill numbers to copy (comma-separated, or 'all'):${NC}"
read -r SELECTION

SELECTED_SKILLS=()

if [ "$SELECTION" = "all" ]; then
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

if [ ${#SELECTED_SKILLS[@]} -eq 0 ]; then
    echo -e "${RED}No skills selected!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Selected skills:${NC}"
for skill in "${SELECTED_SKILLS[@]}"; do
    echo -e "  ${GREEN}✓${NC} $skill"
done

echo ""
echo -e "${BLUE}========================================${NC}"

# Step 3: Select target tools
echo -e "${CYAN}Copy to which tool(s)?${NC}"
echo -e "  ${YELLOW}[1]${NC} Claude only"
echo -e "  ${YELLOW}[2]${NC} Cursor only"
echo -e "  ${YELLOW}[3]${NC} Both Claude and Cursor"
echo ""
read -r TARGET

CLAUDE_DIR="$HOME/.claude/skills"
CURSOR_DIR="$HOME/.cursor/skills"

case $TARGET in
    1)
        TARGETS=("claude")
        ;;
    2)
        TARGETS=("cursor")
        ;;
    3)
        TARGETS=("claude" "cursor")
        ;;
    *)
        echo -e "${RED}Invalid selection!${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Copying skills...${NC}"
echo ""

for tool in "${TARGETS[@]}"; do
    if [ "$tool" = "claude" ]; then
        TARGET_DIR="$CLAUDE_DIR"
    else
        TARGET_DIR="$CURSOR_DIR"
    fi

    # Create directory if not exists
    mkdir -p "$TARGET_DIR"

    echo -e "${CYAN}>> Copying to $tool${NC} ${YELLOW}($TARGET_DIR)${NC}:"

    for skill in "${SELECTED_SKILLS[@]}"; do
        SOURCE="$SKILLS_DIR/$skill"

        # Remove existing symlink or folder
        rm -rf "$TARGET_DIR/$skill"

        # Create symlink
        ln -s "$SOURCE" "$TARGET_DIR/$skill"
        echo -e "    ${GREEN}✓${NC} $skill"
    done
done

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}${BOLD}Done! Skills copied successfully.${NC}"
echo ""
echo -e "${CYAN}You can now use these skills in Claude/Cursor.${NC}"
