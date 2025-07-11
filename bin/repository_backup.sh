#!/usr/bin/env bash
# --- repository_backup.sh ---
# CLI wrapper for modular backup via --target directory
# v1.1.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="$SCRIPT_DIR/../core/repository_backup_lib.sh"

# shellcheck source=../core/repository_backup_lib.sh
source "$LIB"

# Default settings
# shellcheck disable=SC2034
VERSION="1.1.1"
TARGET=""
COUNT=5
DRYRUN="false"
LIST="false"
LATEST="false"
PRUNE="false"
RECOVER="false"

# --- Help ---
show_help() {
  echo "📦 repository_backup.sh (v$VERSION)"
  echo
  echo "Usage:"
  echo "  $0 --target ./your_folder [--dryrun]"
  echo
  echo "Options:"
  echo "  --target    Folder to backup (required)"
  echo "  --list      List backups for a target folder"
  echo "  --latest    Show only the most recent backup"
  echo "  --prune     Remove old backups (default: false)"
  echo "  --restore   Restore from a backup archive (e.g., ./backups/your_folder/backup_20231001.tar.gz)"
  echo "  --count     How many recent backups to retain (default: 5)"
  echo "  --dryrun    Simulate, don’t create backup"
  echo "  --help      Show this help"
  echo
  echo "Example:"
  echo "  $0 --target ./medium_bash"
}

# --- Argument parsing ---
while [[ $# -gt 0 ]]; do
  case "$1" in
  --target)
    TARGET="${2:-}"
    shift 2
    ;;
  --restore)
    RESTORE="${2:-}"
    shift 2
    ;;
  --list)
    LIST="true"
    shift
    ;;
  --prune)
    PRUNE="true"
    shift
    ;;
  --latest)
    LATEST="true"
    shift
    ;;
  --count)
    COUNT="${2:-5}"
    shift 2
    ;;
  --dryrun)
    DRYRUN="true"
    shift
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

# --- Setup derived paths ---
BACKUP_DIR="./backups/$(basename "$TARGET")"
CATALOG_DIR="./backups/catalogs/$(basename "$TARGET")"

CONFIG_FILE="$TARGET/.backup.json"
IGNORE_FILE="$TARGET/.backupignore"
MDLOG="$CATALOG_DIR/backup_log.md"
TPL="$SCRIPT_DIR/../core/backup_log.tpl"

if [[ "$PRUNE" == "true" ]]; then
  # backup_count=$(find "$BACKUP_DIR" -maxdepth 1 -name '*.tar.gz' | wc -l)

  all_backups=($(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null))
  if ((${#all_backups[@]} > COUNT)); then
    to_delete=("${all_backups[@]:COUNT}")
    echo "🧹 Pruning backups: keeping $COUNT, removing ${#to_delete[@]}"
    for file in "${to_delete[@]}"; do
      echo "🗑️  $(basename "$file")"
      rm -f "$file"
    done
  else
    echo "✅ No backups to prune."
  fi
  exit 0
fi

# --- List backups ---
if [[ "$LIST" == "true" ]]; then
  echo "📦 Backup List for: $(basename "$TARGET")"
  echo "------------------------------------------"
  echo "📂 Target: $(basename "$TARGET")"
  printf "📜 Found %2d backups (showing latest %s):\n" \
    "$(ls "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)" "$COUNT"

  echo
  echo "🗃️  Backups:"
  # ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -n "$COUNT" | while read -r file; do
  find "$BACKUP_DIR" -maxdepth 1 -name '*.tar.gz' -print0 | xargs -0 ls -t 2>/dev/null | head -n "$COUNT" | while read -r file; do

    size=$(du -h "$file" | cut -f1)
    printf "  - %-35s [%5s]\n" "$(basename "$file")" "$size"
  done

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

  BASE_DIR="$(dirname "$RESTORE")"
  BASE_NAME="$(basename "$RESTORE" .tar.gz)"
  DEST="$BASE_DIR/$BASE_NAME"

  echo "📦 Restoring from: $RESTORE"
  mkdir -p "$DEST"
  tar -xzf "$RESTORE" -C "$DEST"
  echo "✅ Archive restored to: $DEST"
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

# --- Ensure .backup.json exists ---
if [[ ! -f "$CONFIG_FILE" ]]; then
  cat >"$CONFIG_FILE" <<EOF
{
  "include": [
    "LICENSE",
    "README.md"
  ],
  "exclude": [
    "github/*"
  ]
}
EOF
  echo "📄 Created template: $CONFIG_FILE"
fi

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
# radar_backup_create "$root" "$backup_dir" "$mdlog" "$tpl" "$count" "$dryrun" "$config_file"
radar_backup_create "$TARGET" "$BACKUP_DIR" "$MDLOG" "$TPL" "$COUNT" "$DRYRUN" "$CONFIG_FILE"

# --- Prune old backups after creation (respect --count) ---
# --- Prune old backups after creation (respect --count) ---
# all_backups=($(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null))
mapfile -t all_backups < <(find "$BACKUP_DIR" -maxdepth 1 -name '*.tar.gz' -print0 | xargs -0 ls -t 2>/dev/null)
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
