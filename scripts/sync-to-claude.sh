#!/bin/bash

# Sync all skills to the default Claude global skills folder

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

SKILLS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude/skills"

echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║   Sync Skills to Claude Global Folder ║${NC}"
echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════╝${NC}"
echo ""

# Step 1: List all skills
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

echo -e "${GREEN}✓ Found ${#SKILLS[@]} skills:${NC}"
for skill in "${SKILLS[@]}"; do
    echo -e "  ${GREEN}•${NC} $skill"
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"

# Step 2: Create Claude skills directory if it doesn't exist
mkdir -p "$CLAUDE_DIR"

echo -e "${CYAN}▸ Target: ${BOLD}Claude${NC} ${DIM}($CLAUDE_DIR)${NC}"
echo ""
echo -e "${MAGENTA}▸ Syncing skills...${NC}"
echo ""

# Step 3: Copy all skills using symlinks
for skill in "${SKILLS[@]}"; do
    SOURCE="$SKILLS_DIR/$skill"
    rm -rf "$CLAUDE_DIR/$skill"
    ln -s "$SOURCE" "$CLAUDE_DIR/$skill"
    echo -e "    ${GREEN}✓${NC} $skill"
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}✓ Done! All skills synced to Claude.${NC}"
echo ""
echo -e "${CYAN}You can now use these skills in Claude.${NC}"
