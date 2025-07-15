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

  # Get target folder (default to pwd)
  read -e -p "Folder to backup/restore [$(pwd)]: " tgt
  TARGET="${tgt:-$(pwd)}"

  # Output dir (optional)
  read -e -p "Output directory for backups (ENTER for default ./backups): " outdir
  OUTPUT_DIR="${outdir:-}"

  # --count for prune/backup
  if [[ "$choice" =~ ^(1|5)$ ]]; then
    read -e -p "How many backups to retain? [5]: " count
    COUNT="${count:-5}"
  fi

  DRYRUN=""
  read -n 1 -p "🧪 Dryrun/simulate mode? [y/N]: " dry; echo
  [[ "$dry" =~ ^[Yy]$ ]] && DRYRUN="--dryrun"

  # Build command
  CMD="repository_backup --target \"$TARGET\""
  [[ -n "$OUTPUT_DIR" ]] && CMD+=" --output-dir \"$OUTPUT_DIR\""
  [[ -n "$DRYRUN" ]] && CMD+=" $DRYRUN"

  case "$choice" in
    1) # backup
      [[ -n "${COUNT:-}" ]] && CMD+=" --count $COUNT"
      ;;
    2) CMD+=" --list" ;;
    3) CMD+=" --restore-latest" ;;
    4) CMD+=" --restore-oldest" ;;
    5) [[ -n "${COUNT:-}" ]] && CMD+=" --prune --count $COUNT" ;;
    6) CMD+=" --recover" ;;
    7) CMD+=" --emergency-restore" ;;
    8) CMD+=" --summary" ;;
    9) echo "👋 Exiting."; return 0 ;;
    *) echo "❌ Invalid choice."; return 1 ;;
  esac

  tput bold; echo "▶️  $CMD"; tput sgr0
  echo
  eval $CMD
}
