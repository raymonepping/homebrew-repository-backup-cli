# radar_love_cli 🔐

> “Cold and frosty morning. There’s not a lot to say. About the things caught in my mind..” — *Oasis*

[![brew install](https://img.shields.io/badge/brew--install-success-green?logo=homebrew&style=flat-square)](https://github.com/raymonepping/radar_love_cli)
[![status](https://img.shields.io/badge/ci-auto--generated-blue?style=flat-square)](./sanity_check_report.md)
[![badge](https://img.shields.io/badge/radar--ready-yes-critical?logo=githubactions&style=flat-square)](https://www.vaultproject.io/docs/secrets/radar)

---

## 🎯 What Is This?

`radar_love_cli` is a **modular, Homebrew-installable CLI** that lets you simulate realistic code leaks (secrets, PII, etc.) to test secret scanning pipelines with Vault Radar, TruffleHog, Gitleaks, and more.

---

## 🧰 How to Use

```bash
brew install raymonepping/tap/radar_love_cli
radar_love --create true --build true --commit true --request true
```

All flags are optional. This CLI wraps and coordinates a set of deeply integrated scripts.

---

## 📂 Structure

```
.
├── bin/                 # Main CLI symlink (radar_love)
├── core/                # Modular bash logic
│   ├── commit_gh.sh     # GitHub commit helper
│   ├── validate_env.sh  # Dependency checker
│   └── ...
├── templates/           # TPL/JSON banners
├── test/                # (Reserved for testing)
├── radar_love_cli.rb    # Homebrew formula
├── README.md            # This file
└── .brewinfo            # (Optional brew metadata)
```

---

## 🔑 Key Features

- ✅ One CLI to orchestrate your entire Radar demo  
- 🧪 Includes leak builders, commit triggers, PR scans  
- 📎 Built-in GitHub automation (via `gh`)  
- 🔍 Environment validator with `--validate`  
- 🧼 CI-ready with `--quiet`, `--debug`, and `--status`  

---

## ✨ Example Scenarios

```bash
# Minimal demo run with default values
radar_love

# Full cycle with debug and fresh rebuild
radar_love --fresh true --build true --commit true --request true --debug compact

# Validate dependencies only
radar_love --validate
```

---

## 🚧 Flags Reference

All supported flags can be viewed with:

```bash
radar_love --help
```

---

## 🧠 Philosophy

This toolkit was born from a simple need: demo secret-scanning tools in the most realistic way possible — without real leaks, with full automation, and with style.

It grew into a modular, CI-aware CLI that now installs via Homebrew.  
Because automation should automate itself. 🚀

> “And as the day was dawning. My plane flew away. With all the things caught in my mind..” — *Oasis*

---

© 2025 Raymon Epping

🧠 Powered by `radar_love.sh` — 📚 Related Articles

- 📖 [Part I – From Dream to Demo](https://medium.com/continuous-insights/from-dream-to-demo-building-an-automated-secret-scanning-pipeline-064a64971f64)  
- 🛠️ [Part II – From Vision to Version](https://medium.com/@raymonepping/from-vision-to-version-evolving-radar-love-with-flags-validation-and-ci-swagger-83610d549412)  
- 📦 Part III – Packaging `radar_love_cli` (TBD)
