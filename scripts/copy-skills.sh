#!/bin/bash

# Copy skills to Claude/Cursor global skill folders

SKILLS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "========================================"
echo "   Copy Skills to Global Folders"
echo "========================================"
echo ""

# Step 1: List available skills
echo "Available skills in this project:"
echo ""

cd "$SKILLS_DIR"
SKILLS=()
for dir in */; do
    if [ -f "${dir}SKILL.md" ]; then
        SKILL_NAME="${dir%/}"
        SKILLS+=("$SKILL_NAME")
        echo "  [$(( ${#SKILLS[@]} ))] $SKILL_NAME"
    fi
done

if [ ${#SKILLS[@]} -eq 0 ]; then
    echo "No skills found in this project!"
    exit 1
fi

echo ""
echo "========================================"

# Step 2: Select skills
echo "Enter skill numbers to copy (comma-separated, or 'all'):"
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
    echo "No skills selected!"
    exit 1
fi

echo ""
echo "Selected skills:"
for skill in "${SELECTED_SKILLS[@]}"; do
    echo "  - $skill"
done

echo ""
echo "========================================"

# Step 3: Select target tools
echo "Copy to which tool(s)?"
echo "  [1] Claude only"
echo "  [2] Cursor only"
echo "  [3] Both Claude and Cursor"
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
        echo "Invalid selection!"
        exit 1
        ;;
esac

echo ""
echo "========================================"
echo "Copying skills..."
echo ""

for tool in "${TARGETS[@]}"; do
    if [ "$tool" = "claude" ]; then
        TARGET_DIR="$CLAUDE_DIR"
    else
        TARGET_DIR="$CURSOR_DIR"
    fi

    # Create directory if not exists
    mkdir -p "$TARGET_DIR"

    echo ">> Copying to $tool ($TARGET_DIR):"

    for skill in "${SELECTED_SKILLS[@]}"; do
        SOURCE="$SKILLS_DIR/$skill"

        # Remove existing symlink or folder
        rm -rf "$TARGET_DIR/$skill"

        # Create symlink
        ln -s "$SOURCE" "$TARGET_DIR/$skill"
        echo "    ✓ $skill"
    done
done

echo ""
echo "========================================"
echo "Done! Skills copied successfully."
echo ""
echo "You can now use these skills in Claude/Cursor."
