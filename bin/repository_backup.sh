#!/usr/bin/env bash
# --- repository_backup.sh ---
# CLI wrapper for modular backup via --target directory
# v1.1.0

set -euo pipefail

# shellcheck disable=SC2034
SCRIPT_NAME="$(basename "$0")"
# shellcheck disable=SC2034
VERSION="1.7.2"

# --- Core Target/Action ---
TARGET=""
COUNT=5

# --- Backup & Restore Modes ---
DRYRUN="false"
LIST="false"
LATEST="false"
PRUNE="false"
RECOVER="false"
RESTORE_OLDEST="false"
RESTORE_LATEST="false"
FORCE="false"
EMERGENCY_RESTORE="false"
OUTPUT_DIR=""


# --- Reporting/Output ---
SUMMARY="false"
OUTPUT_FORMAT="plain"

: "${REPO_BACKUP_HOME:=${REPO_BACKUP_HOME:-/opt/homebrew/opt/repository-backup-cli/share/repository-backup-cli}}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_BACKUP_HOME="${REPO_BACKUP_HOME:-/opt/homebrew/opt/repository-backup-cli/share/repository-backup-cli}"

# Handle --version
if [[ "${1:-}" == "--version" ]]; then
  echo "$SCRIPT_NAME v$VERSION — supersonic backup CLI"
  exit 0
fi

if [[ $# -eq 0 ]]; then
  # Try to source and run decision tree
  decision_paths=(
    "$SCRIPT_DIR/backup_decision_tree.sh"
    "$SCRIPT_DIR/../core/backup_decision_tree.sh"
    "$SCRIPT_DIR/../lib/backup_decision_tree.sh"
    "/opt/homebrew/share/repository-backup-cli/core/backup_decision_tree.sh"
  )
  found_tree_wizard=false
  for dp in "${decision_paths[@]}"; do
    if [[ -f "$dp" ]]; then
      source "$dp"
      run_decision_tree
      found_tree_wizard=true
      break
    fi
  done

  if [[ "$found_tree_wizard" == false ]]; then
    echo "❌ Could not locate repository_decision_tree.sh"
    exit 1
  fi
  exit 0
fi

# --- Help ---
show_help() {
  echo "📦 repository_backup.sh (v$VERSION)"
  echo
  echo "Usage:"
  echo "  $0 --target ./your_folder [--dryrun]"
  echo
  echo "Options:"
  echo "  --target            Folder to backup (required)"
  echo "  --output-dir        Directory to store backup archives (default: ./backups/<target>)"
  echo "  --list              List backups for a target folder              [dryrun supported]"
  echo "  --latest            Show only the most recent backup              [dryrun supported]"
  echo "  --prune             Remove old backups (default: false)           [dryrun supported]"
  echo "  --restore           Restore from a backup archive                 [dryrun supported]"
  echo "  --restore-latest    Restore most recent backup                    [dryrun supported]"
  echo "  --restore-oldest    Restore oldest available backup               [dryrun supported]"
  echo "  --recover           Recover backup and overwrite folder           [dryrun supported]"
  echo "  --emergency-restore Restore tracked files from latest Git tag     [dryrun supported]"
  echo "  --summary           Show summary output of recent backups"
  echo "  --output            Output format: plain | markdown | md"
  echo "  --count             How many recent backups to retain (default: 5)"
  echo "  --dryrun            Simulate, don’t create or modify anything"
  echo "  --force             Force overwrite of existing restore folder"
  echo "  --help              Show this help"
  echo "  --version           Show version information and exit"
  echo
  echo "Example:"
  echo "  $0 --target ./medium_bash --restore-latest --dryrun"
}

# ---- Parse arguments *before* sourcing lib or debug calls ---
while [[ $# -gt 0 ]]; do
  case "$1" in
  --target)
    TARGET="$2"
    shift 2
    ;;
  --output-dir)
    OUTPUT_DIR="$2"
    shift 2
    ;;    
  --restore)
    RESTORE="$2"
    shift 2
    ;;
  --force)
    FORCE=true
    shift
    ;;
  --restore-oldest)
    RESTORE_OLDEST=true
    shift
    ;;
  --restore-latest)
    RESTORE_LATEST=true
    shift
    ;;
  --recover)
    RECOVER=true
    shift
    ;;
  --emergency-restore)
    EMERGENCY_RESTORE=true
    shift
    ;;
  --list)
    LIST=true
    shift
    ;;
  --prune)
    PRUNE=true
    shift
    ;;
  --latest)
    LATEST=true
    shift
    ;;
  --count)
    COUNT="$2"
    shift 2
    ;;
  --output)
    OUTPUT_FORMAT="$2"
    shift 2
    ;;
  --summary)
    SUMMARY=true
    shift
    ;;
  --dryrun)
    DRYRUN=true
    shift
    ;;
  --version)
    echo "📦 $SCRIPT_NAME (v$VERSION)"
    exit 0
    ;;
  --help | -h)
    show_help
    exit 0
    ;;
  *)
    echo "❌ Unknown option: $1"
    show_help
    exit 1
    ;;
  esac
done

# --- Source lib after parsing (now DEBUG is set correctly!) ---
if [[ -f "$SCRIPT_DIR/../core/repository_backup_lib.sh" ]]; then
  LIB="$SCRIPT_DIR/../core/repository_backup_lib.sh"
  MODE="LOCAL"
else
  LIB="$REPO_BACKUP_HOME/core/repository_backup_lib.sh"
  MODE="BREW"
fi
source "$LIB"


# Near the end of the script after parsing and sourcing
if [[ "$RECOVER" == "true" ]]; then
  BACKUP_DIR="./backups/$(basename "$TARGET")"
  LATEST_FILE=$(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -n 1)

  if [[ -z "$LATEST_FILE" ]]; then
    backup_err "❌ No backups found to recover from."
    exit 1
  fi

  if [[ "$LIST" == "true" ]]; then
    echo "📦 Recoverable backups for: $(basename "$TARGET")"
    echo "-----------------------------------------------"
    find "$BACKUP_DIR" -maxdepth 1 -name '*.tar.gz' -print0 | xargs -0 ls -t 2>/dev/null | while read -r file; do
      size=$(du -h "$file" | cut -f1)
      printf "  - %-35s [%5s]\n" "$(basename "$file")" "$size"
    done
    exit 0
  fi

  backup_info "💾 Recovering from: $LATEST_FILE"
  recover_backup "$BACKUP_DIR" "$LATEST_FILE" "$TARGET" "$DRYRUN" "$FORCE"
  exit $?
fi



# --- Validation ---
if [[ -z "$TARGET" ]]; then
  echo "❌ --target is required."
  show_help
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "❌ Target directory not found: $TARGET"
  exit 1
fi

# --- Setup config format + dynamic config file path ---
CONFIG_EXT="json"
CONFIG_TOOL="jq"
if command -v hclq &>/dev/null; then
  CONFIG_EXT="hcl"
  CONFIG_TOOL="hclq"
elif command -v yq &>/dev/null; then
  CONFIG_EXT="yaml"
  CONFIG_TOOL="yq"
fi

CONFIG_FILE="$TARGET/.backup.${CONFIG_EXT}"
echo "🛠️  Using config format: .$CONFIG_EXT (via $CONFIG_TOOL)"

# --- Setup derived paths ---
if [[ -n "$OUTPUT_DIR" ]]; then
  BACKUP_DIR="${OUTPUT_DIR}/$(basename "$TARGET")"
  CATALOG_DIR="${OUTPUT_DIR}/catalogs/$(basename "$TARGET")"
else
  BACKUP_DIR="./backups/$(basename "$TARGET")"
  CATALOG_DIR="./backups/catalogs/$(basename "$TARGET")"
fi
# BACKUP_DIR="./backups/$(basename "$TARGET")"
# CATALOG_DIR="./backups/catalogs/$(basename "$TARGET")"

# CONFIG_FILE="$TARGET/.backup.json"
IGNORE_FILE="$TARGET/.backupignore"
MDLOG="$CATALOG_DIR/backup_log.md"

if [[ -f "$SCRIPT_DIR/../core/backup_log.tpl" ]]; then
  # Local (from dev folder)
  TPL="$SCRIPT_DIR/../core/backup_log.tpl"
else
  # Homebrew (from installed prefix)
  TPL="$REPO_BACKUP_HOME/core/backup_log.tpl"
fi


# --- List Backups ---
if [[ "$LIST" == "true" ]]; then
  echo "📦 Backup List for: $(basename "$TARGET")"
  echo "------------------------------------------"
  echo "📂 Target: $(basename "$TARGET")"
  total=$(find "$BACKUP_DIR" -name '*.tar.gz' 2>/dev/null | wc -l)
  printf "📜 Found %2d backups (showing latest %s):\n" "$total" "$COUNT"
  echo -e "\n🗃️  Backups:"
  find "$BACKUP_DIR" -maxdepth 1 -name '*.tar.gz' -print0 | xargs -0 ls -t 2>/dev/null | head -n "$COUNT" | while read -r file; do
    size=$(du -h "$file" | cut -f1)
    printf "  - %-35s [%5s]\n" "$(basename "$file")" "$size"
  done
  exit 0
fi

if [[ "$SUMMARY" == "true" ]]; then
  render_summary "$MDLOG" "$COUNT" "$OUTPUT_FORMAT"
  exit 0
fi

if [[ "$PRUNE" == "true" ]]; then
  radar_backup_prune "$BACKUP_DIR" "$COUNT" "$DRYRUN"
  exit 0
fi

# --- Latest only ---
if [[ "$LATEST" == "true" ]]; then
  latest_file=$(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -n 1)
  if [[ -n "$latest_file" ]]; then
    size=$(du -h "$latest_file" | cut -f1)
    echo "📦 Latest backup: $(basename "$latest_file") [$size]"
    echo "$latest_file"
    exit 0
  else
    echo "❌ No backups found in $BACKUP_DIR"
    exit 1
  fi
fi

if [[ -n "${RESTORE:-}" ]]; then
  if [[ ! -f "$RESTORE" ]]; then
    echo "❌ File not found: $RESTORE"
    exit 1
  fi

  echo "📦 Restoring from: $RESTORE"
  restore_backup_with_diff "$RESTORE" "$(dirname "$RESTORE")" "$TPL" "$FORCE" "$DRYRUN"
  exit 0
fi

if [[ "$RESTORE_LATEST" == "true" || "$RESTORE_OLDEST" == "true" ]]; then
  if [[ "$RESTORE_LATEST" == "true" ]]; then
    selected_file=$(find "$BACKUP_DIR" -maxdepth 1 -name '*.tar.gz' -print0 | xargs -0 ls -t 2>/dev/null | head -n 1)
    label="latest"
  elif [[ "$RESTORE_OLDEST" == "true" ]]; then
    selected_file=$(find "$BACKUP_DIR" -maxdepth 1 -name '*.tar.gz' -print0 | xargs -0 ls -tr 2>/dev/null | head -n 1)
    label="oldest"
  fi

  if [[ -z "${selected_file:-}" ]]; then
    echo "❌ No backups found in $BACKUP_DIR"
    exit 1
  fi

  BASE_DIR="$(dirname "$selected_file")"
  BASE_NAME="$(basename "$selected_file" .tar.gz)"
  DEST="$BASE_DIR/$BASE_NAME"

  echo "📦 Restoring $label: $selected_file"
  mkdir -p "$DEST"
  tar -xzf "$selected_file" -C "$DEST"
  echo "✅ Archive restored to: $DEST"

  log_restore_summary "$selected_file" "$DEST" "$TPL"
  log_restore_entry "$label" "$selected_file" "$DEST" "$TARGET" "$MDLOG" "$TPL"
  exit 0
fi

# --- Ensure required directories exist ---
ensure_dirs_exist() {
  local dirs=("$@")
  for dir in "${dirs[@]}"; do
    [[ -d "$dir" ]] || mkdir -p "$dir"
  done
}

ensure_dirs_exist "$BACKUP_DIR" "$CATALOG_DIR"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "📄 Creating default config: $CONFIG_FILE"
  case "$CONFIG_EXT" in
  json)
    cat >"$CONFIG_FILE" <<EOF
{
  "include": ["LICENSE", "README.md", "*.sh"],
  "exclude": ["github/*"]
}
EOF
    ;;
  yaml)
    cat >"$CONFIG_FILE" <<EOF
include:
  - LICENSE
  - README.md
  - "*.sh"
exclude:
  - github/*
EOF
    ;;
  hcl)
    cat >"$CONFIG_FILE" <<EOF
include = ["LICENSE", "README.md", "*.sh"]
exclude = ["github/*"]
EOF
    ;;
  esac
fi
echo "🛠️  Using config format: .$CONFIG_EXT (via $CONFIG_TOOL)"

# --- Ensure .backupignore exists ---
if [[ ! -f "$IGNORE_FILE" ]]; then
  cat >"$IGNORE_FILE" <<EOF
# Ignore node_modules, git, and temp files
.git/
*.swp
backup/
restore_*
bin/.DS_Store
EOF
  echo "📄 Created template: $IGNORE_FILE"
fi

# --- Ensure Git tag if folder is tracked ---
ensure_git_tag "$TARGET"

# --- Run backup ---
radar_backup_create "$TARGET" "$BACKUP_DIR" "$MDLOG" "$TPL" "$COUNT" "$DRYRUN" "$CONFIG_FILE"

# --- Prune old backups after creation (respect --count) ---
mapfile -d '' -t all_backups < <(find "$BACKUP_DIR" -maxdepth 1 -name '*.tar.gz' -print0 | sort -rz)
if ((${#all_backups[@]} > COUNT)); then
  to_delete=("${all_backups[@]:COUNT}")
  echo "🧹 Pruning old backups: keeping latest $COUNT, removing ${#to_delete[@]}..."
  for file in "${to_delete[@]}"; do
    echo "🗑️  $(basename "$file")"
    [[ "$DRYRUN" == "false" ]] && rm -f "$file"
  done
else
  echo "✅ No pruning needed: total backups = ${#all_backups[@]}, within limit ($COUNT)."
fi

if [[ "$EMERGENCY_RESTORE" == "true" ]]; then
  perform_emergency_restore "$TARGET"
  exit 0
fi
