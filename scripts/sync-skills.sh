#!/usr/bin/env bash

# sync-skills.sh - Sync Claude skills to other AI apps (Cursor, Codex, etc.)
#
# Usage:
#   ./sync-skills.sh                    # Sync Claude skills to all supported apps
#   ./sync-skills.sh help               # Show this help message
#   ./sync-skills.sh --source /path     # Use custom source directory
#   ./sync-skills.sh --apps cursor      # Sync to specific app(s)
#   ./sync-skills.sh --dry-run          # Show what would be synced without making changes
#
# Supported apps: cursor, codex, claude (other)

set -e

# Default configuration
SOURCE_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
DRY_RUN=false
APPS=""

# Supported AI apps and their skills directories
CURSOR_SKILLS="$HOME/.cursor/skills"
CODEX_SKILLS="$HOME/.codex/skills"
CLAUDE_SKILLS="$HOME/.claude/skills"

# Colors for output (vibrant palette)
RED='\033[0;31m'          # Error
GREEN='\033[0;32m'        # Success
YELLOW='\033[1;33m'       # Warning
BLUE='\033[0;34m'         # Info/headers
CYAN='\033[0;36m'         # Skills/paths
MAGENTA='\033[0;35m'      # Accent
NC='\033[0m' # No Color

usage() {
    echo -e "${CYAN}sync-skills.sh${NC} - ${MAGENTA}Sync Claude skills to other AI apps${NC}

${YELLOW}USAGE${NC}
    sync-skills.sh [options]

${YELLOW}OPTIONS${NC}
    ${GREEN}-s, --source DIR${NC}    Source skills directory (default: ~/.claude/skills)
    ${GREEN}-a, --apps APPS${NC}    Target apps: cursor, codex, claude (default: all except source)
    ${GREEN}-d, --dry-run${NC}      Preview changes without applying
    ${GREEN}-h, --help${NC}         Show this help message

${YELLOW}EXAMPLES${NC}
    sync-skills.sh              # Sync to cursor and codex
    sync-skills.sh help        # Show help
    sync-skills.sh --apps cursor    # Sync only to cursor
    sync-skills.sh --dry-run        # Preview changes

${YELLOW}ENVIRONMENT${NC}
    ${CYAN}CLAUDE_SKILLS_DIR${NC}    Override default source directory
"
    exit 0
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get target directory for app
get_target_dir() {
    case "$1" in
        cursor) echo "$CURSOR_SKILLS" ;;
        codex)  echo "$CODEX_SKILLS" ;;
        claude) echo "$CLAUDE_SKILLS" ;;
        *)      echo "" ;;
    esac
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        help|--help|-h)
            usage
            ;;
        -s|--source)
            SOURCE_DIR="$2"
            shift 2
            ;;
        -a|--apps)
            APPS="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

# If no apps specified, use all except the source
if [ -z "$APPS" ]; then
    # Determine default apps based on source
    if [ "$SOURCE_DIR" = "$CLAUDE_SKILLS" ]; then
        APPS="cursor,codex"
    elif [ "$SOURCE_DIR" = "$CURSOR_SKILLS" ]; then
        APPS="codex,claude"
    elif [ "$SOURCE_DIR" = "$CODEX_SKILLS" ]; then
        APPS="cursor,claude"
    else
        APPS="cursor,codex,claude"
    fi
fi

# Validate source directory
if [ ! -d "$SOURCE_DIR" ]; then
    log_error "Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

log_info "Source directory: $SOURCE_DIR"
log_info "Target apps: $APPS"
echo ""

# Get list of skills from source
SKILLS=""
for f in "$SOURCE_DIR"/*; do
    if [ -d "$f" ]; then
        skill_name=$(basename "$f")
        SKILLS="$SKILLS $skill_name"
    fi
done

SKILLS=$(echo "$SKILLS" | xargs)  # trim whitespace

if [ -z "$SKILLS" ]; then
    log_warning "No skills found in $SOURCE_DIR"
    exit 0
fi

skill_count=$(echo "$SKILLS" | wc -w | tr -d ' ')
log_info "Found $skill_count skills: $SKILLS"
echo ""

# Sync each app
IFS=',' read -ra APP_ARRAY <<< "$APPS"
for app in "${APP_ARRAY[@]}"; do
    app=$(echo "$app" | xargs)  # trim whitespace
    target_dir=$(get_target_dir "$app")
    
    if [ -z "$target_dir" ]; then
        log_error "Unknown app: $app"
        continue
    fi
    
    # Create target directory if it doesn't exist
    if [ ! -d "$target_dir" ]; then
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$target_dir"
            log_info "Created directory: $target_dir"
        else
            log_info "Would create directory: $target_dir"
        fi
    fi

    echo -e "${BLUE}=== Syncing to $app ===${NC}"

    linked_count=0
    skipped_count=0

    for skill in $SKILLS; do
        source_path="$SOURCE_DIR/$skill"
        
        # Skip if source doesn't exist
        if [ ! -d "$source_path" ]; then
            continue
        fi

        # Check if link already exists
        if [ -e "$target_dir/$skill" ]; then
            # Check if it's already a symlink to the correct source
            if [ -L "$target_dir/$skill" ]; then
                existing_target=$(readlink "$target_dir/$skill")
                if [ "$existing_target" = "$source_path" ] || [ "$existing_target" = "$source_path/" ]; then
                    log_info "  ${GREEN}✓${NC} $skill (already linked)"
                    ((skipped_count++))
                    continue
                fi
            fi
            
            if [ "$DRY_RUN" = false ]; then
                # Backup existing file/directory
                backup="${target_dir}/${skill}.backup.$(date +%s)"
                mv "$target_dir/$skill" "$backup"
                log_warning "  Backed up existing $skill to $(basename "$backup")"
            else
                log_warning "  Would replace existing: $skill"
            fi
        fi

        if [ "$DRY_RUN" = true ]; then
            log_info "  Would link: $skill -> $source_path"
        else
            ln -s "$source_path" "$target_dir/$skill"
            log_success "  Linked: $skill"
        fi
        ((linked_count++))
    done

    echo ""
    if [ "$DRY_RUN" = true ]; then
        log_info "Would link: $linked_count, skipped: $skipped_count"
    else
        log_success "Synced to $app: $linked_count linked, $skipped_count already up to date"
    fi
    echo ""
done

if [ "$DRY_RUN" = true ]; then
    log_info "Dry run complete. Run without --dry-run to apply changes."
else
    log_success "All syncs complete!"
    log_info "You may need to restart your AI app(s) for new skills to be recognized."
fi
