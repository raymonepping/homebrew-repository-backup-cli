#!/usr/bin/env bash

# shellcheck disable=SC2034
VERSION="1.4.1"

run_decision_tree() {
  tput bold; echo "📦 Repository Backup CLI Decision Tree"; tput sgr0
  echo "📂 Target folder: $(pwd)"
  echo

  # 1. What do you want to do?
  echo "What would you like to do?"
  echo "  1) Create a backup"
  echo "  2) List existing backups"
  echo "  3) Restore latest backup"
  echo "  4) Restore oldest backup"
  echo "  5) Prune old backups"
  echo "  6) Recover (overwrite) from latest"
  echo "  7) Emergency restore (Git)"
  echo "  8) Show backup summary"
  echo "  9) Quit"
  read -n 1 -p "Select [1-9]: " choice; echo

  # 💡 If quit, exit now
  if [[ "$choice" == "9" || -z "$choice" ]]; then
    echo "👋 Exiting."
    exit 0
  fi

  # Set context-aware prompt wording
  case "$choice" in
    1)
      prompt_folder="Folder to back up"
      prompt_outdir="Backup storage directory (where new backup will be saved)"
      ;;
    2)
      prompt_folder="Folder to list backups for"
      prompt_outdir="Backup storage directory (where backups are kept)"
      ;;
    3)
      prompt_folder="Folder to restore into"
      prompt_outdir="Backup storage directory to restore from"
      ;;
    4)
      prompt_folder="Folder to restore into"
      prompt_outdir="Backup storage directory to restore from"
      ;;
    5)
      prompt_folder="Folder whose backups should be pruned"
      prompt_outdir="Backup storage directory (where old backups are stored)"
      ;;
    6)
      prompt_folder="Folder to recover/overwrite"
      prompt_outdir="Backup storage directory to recover from"
      ;;
    7)
      prompt_folder="Folder to emergency-restore into"
      prompt_outdir="Backup storage directory to restore from"
      ;;
    8)
      prompt_folder="Folder to show backup summary for"
      prompt_outdir="Backup storage directory (where backups are kept)"
      ;;
    *)
      prompt_folder="Folder"
      prompt_outdir="Backup storage directory"
      ;;
  esac

  # Use context-aware prompts
  read -e -p "$prompt_folder [$(pwd)]: " tgt
  TARGET="${tgt:-$(pwd)}"

  read -e -p "$prompt_outdir (ENTER for default ./backups): " outdir
  OUTPUT_DIR="${outdir:-}"

  if [[ "$choice" =~ ^(1|5)$ ]]; then
    read -e -p "How many backups to retain? [5]: " count
    COUNT="${count:-5}"
  fi

  DRYRUN=""
  read -n 1 -p "🧪 Dryrun/simulate mode? [y/N]: " dry; echo
  [[ "$dry" =~ ^[Yy]$ ]] && DRYRUN="--dryrun"

  CMD="repository_backup --target \"$TARGET\""
  [[ -n "$OUTPUT_DIR" ]] && CMD+=" --output-dir \"$OUTPUT_DIR\""
  [[ -n "$DRYRUN" ]] && CMD+=" $DRYRUN"

  case "$choice" in
    1) [[ -n "${COUNT:-}" ]] && CMD+=" --count $COUNT" ;;
    2) CMD+=" --list" ;;
    3) CMD+=" --restore-latest" ;;
    4) CMD+=" --restore-oldest" ;;
    5) [[ -n "${COUNT:-}" ]] && CMD+=" --prune --count $COUNT" ;;
    6) CMD+=" --recover" ;;
    7) CMD+=" --emergency-restore" ;;
    8) CMD+=" --summary" ;;
    *) echo "❌ Invalid choice."; return 1 ;;
  esac

  tput bold; echo "▶️  $CMD"; tput sgr0
  echo
  eval $CMD
}
