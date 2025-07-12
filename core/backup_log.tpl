# 🛡️ Radar Love Project Backups

[![Backups](https://img.shields.io/badge/Backups-Automated-green)](#)
[![Integrity](https://img.shields.io/badge/Integrity-Checked-brightgreen)](#)
[![Last Backup](https://img.shields.io/badge/Last_Backup-{{LAST_BACKUP}}-blue)](#)

---

## 🔢 Last {{MAX_SUMMARY}} Backups

| Date/Time           | Tag         | Parent  | Commit    | Filename                        | Size     | SHA256                             | Status   |
|---------------------|-------------|---------|-----------|----------------------------------|----------|-------------------------------------|----------|
{{SUMMARY_ROWS}}

---

<details>
<summary>🔍 Exclusions (from `.backupignore` / config)</summary>

```
{{EXCLUSIONS}}
```
</details>

---

<details>
<summary>✅ Integrity Check Results</summary>

```
{{INTEGRITY}}
```
</details>

---

### 🔁 Restore & Prune Options

- 🔙 Basic restore: `./radar_backup.sh --restore <filename>`
- 🩹 Overwrite original: `./radar_backup.sh --recover`
- 🚨 Emergency tag restore: `./radar_backup.sh --emergency`
- 🧹 Manual prune: `./radar_backup.sh --prune --count <number>`

---

Variables explained:

- `{{LAST_BACKUP}}`: Latest backup tag
- `{{MAX_SUMMARY}}`: Number of summary rows to show (e.g. 5)
- `{{SUMMARY_ROWS}}`: Table rows with last backups info
- `{{EXCLUSIONS}}`: Text block with patterns
- `{{INTEGRITY}}`: Markdown/text block (passed/failed, hash check, etc)
✅ Restored v0.1.0_20250711_210331.tar.gz into folder ./backups/repository_backup_cli/v0.1.0_20250711_210331
❌ Restored v0.1.0_20250711_194022.tar.gz into folder ././backups/medium_bash/v0.1.0_20250711_194022 — checksum mismatch!
❌ Restored v0.1.0_20250711_194022.tar.gz into folder ././backups/medium_bash/v0.1.0_20250711_194022 — checksum mismatch!
✅ Restored v0.1.0_20250711_194732.tar.gz into folder ././backups/medium_bash/v0.1.0_20250711_194732
✅ Integrity check: PASSED (diff verified)
✅ Restored v0.1.0_20250711_194732.tar.gz into folder ././backups/medium_bash/v0.1.0_20250711_194732
✅ Integrity check: PASSED (diff verified)
✅ Restored v0.1.0_20250711_194732.tar.gz into folder ././backups/medium_bash/v0.1.0_20250711_194732
✅ Integrity check: PASSED (diff verified)
✅ Restored v0.1.0_20250711_194732.tar.gz into folder ././backups/medium_bash/v0.1.0_20250711_194732
❌ Restored v0.1.0_20250711_200514.tar.gz into folder ././backups/medium_bash/v0.1.0_20250711_200514 — content mismatch!
❌ Restored v0.1.0_20250711_222026.tar.gz into folder ././backups/medium_bash/v0.1.0_20250711_222026 — content mismatch!
❌ Restored v0.1.0_20250711_222026.tar.gz into folder ././backups/medium_bash/v0.1.0_20250711_222026 — content mismatch!
✅ Restored v0.1.0_20250711_235951.tar.gz into folder ./backups/medium_bash/v0.1.0_20250711_235951
✅ Restored v0.1.0_20250712_185018.tar.gz into folder ./backups/medium_bash/v0.1.0_20250712_185018
✅ Restored v0.1.0_20250712_185018.tar.gz into folder ./backups/medium_bash/v0.1.0_20250712_185018
✅ Restored v0.1.0_20250712_185018.tar.gz into folder ./backups/medium_bash/v0.1.0_20250712_185018
✅ Restored v0.1.0_20250711_235317.tar.gz into folder ./backups/medium_bash/v0.1.0_20250711_235317
