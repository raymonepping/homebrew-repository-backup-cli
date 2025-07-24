# repository_backup.sh 🌳

> "Structure isn't boring – it's your first line of clarity." — *You (probably during a cleanup)*

[![brew install](https://img.shields.io/badge/brew--install-success-green?logo=homebrew)](https://github.com/raymonepping/homebrew-repository_backup.sh)
[![version](https://img.shields.io/badge/version-1.7.1-blue)](https://github.com/raymonepping/homebrew-repository_backup.sh)

---

## 🧭 What Is This?

repository_backup.sh is a Homebrew-installable, wizard-powered CLI.

---

## 🚀 Quickstart

```bash
brew tap 
brew install /repository_backup.sh
repository_backup.sh
```

---

Want to customize?

```bash
export FOLDER_TREE_HOME=/opt/homebrew/opt/..
```

---

## 📂 Project Structure

```
./
├── bin/
│   ├── CHANGELOG_repository_backup.md*
│   └── repository_backup.sh*
├── core/
│   ├── .backup.json
│   ├── .backupignore
│   ├── backup_decision_tree.sh
│   ├── backup_log.tpl
│   ├── CHANGELOG_repository_backup_lib.md
│   ├── footer.tpl
│   ├── header.tpl
│   ├── README.tpl
│   └── repository_backup_lib.sh*
├── Formula/
│   └── repository-backup-cli.rb
├── templates/
│   ├── .keep
│   ├── footer.tpl
│   ├── header.tpl
│   └── README.tpl
├── test/
│   ├── .gitkeep
│   └── .keep
├── tpl/
│   ├── readme_01_header.tpl
│   ├── readme_02_project.tpl
│   ├── readme_03_structure.tpl
│   ├── readme_04_body.tpl
│   ├── readme_05_quote.tpl
│   ├── readme_06_article.tpl
│   └── readme_07_footer.tpl
├── .backup.hcl
├── .backup.json
├── .backup.yaml
├── .backupignore
├── .brewinfo
├── .version
├── FOLDER_TREE.md
├── LICENSE
├── README.md.old
├── reload_version.sh*
├── repos_report.md
├── sanity_check.md
└── update_formula.sh*

7 directories, 38 files
```

---

## 🧭 What Is This?

repository-backup-cli is a Homebrew-installable, wizard-powered CLI for creating, restoring, and managing smart backups of your GitHub repositories and project folders.
It’s especially useful for:

- Developers and teams who want versioned, tag-aware backups—no more lost code or forgotten history
- Anyone who needs fast, repeatable recovery for GitHub repos or project folders (with support for prune, dryrun, and restore)
- Automating disaster recovery and snapshotting in CI/CD or local scripts

---

## 🔑 Key Features

- Backup one or many GitHub repositories with a single command
- Smart backup cataloging with tagging, ignore rules, and backup summaries
- Supports full, incremental, and emergency restore flows
- Optional dry-run and integrity verification with checksums (MD5, etc.)
 
Markdown summaries for every operation—easy to audit and share

Modular structure for easy scripting and Homebrew upgrades

---

### Auto-generate a Homebrew audit report

```bash
repository_backup.sh
```

---

### ✨ Other CLI tooling available

✅ **brew-brain-cli**  
CLI toolkit to audit, document, and manage your Homebrew CLI arsenal with one meta-tool

✅ **bump-version-cli**  
CLI toolkit to bump semantic versions in Bash scripts and update changelogs

✅ **commit-gh-cli**  
CLI toolkit to commit, tag, and push changes to GitHub

✅ **folder-tree-cli**  
CLI toolkit to visualize folder structures with Markdown reports

✅ **radar-love-cli**  
CLI toolkit to simulate secret leaks and trigger GitHub PR scans

✅ **repository-audit-cli**  
CLI toolkit to audit Git repositories and folders, outputting Markdown/CSV/JSON reports

✅ **repository-backup-cli**  
CLI toolkit to back up GitHub repositories with tagging, ignore rules, and recovery

✅ **repository-export-cli**  
CLI toolkit to export, document, and manage your GitHub repositories from the CLI

✅ **self-doc-gen-cli**  
CLI toolkit for self-documenting CLI generation with Markdown templates and folder visualization

---

## 🧠 Philosophy

repository_backup.sh 

> Some might say that sunshine follows thunder
> Go and tell it to the man who cannot shine

> Some might say that we should never ponder
> On our thoughts today ‘cos they hold sway over time

---

## 📘 Read the Full Medium.com article

📖 [Article](..) 

---

© 2025 Your Name  
🧠 Powered by self_docs.sh — 🌐 Works locally, CI/CD, and via Brew
