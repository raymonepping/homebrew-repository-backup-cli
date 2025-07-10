# {{REPO_NAME}}

![status](https://img.shields.io/badge/generated--by-radar__love.sh-brightgreen)
![demo](https://img.shields.io/badge/demo-vault--radar--ready-blue)
![Oasis](https://img.shields.io/badge/inspired--by-Oasis-yellow)

> “I think you’re the same as me, we see things they’ll never see...” — *Oasis*

---

## 🎯 Purpose

A flexible CLI-driven pipeline that simulates realistic code leaks — secrets, PII, non-inclusive language to test HashiCorp Vault Radar.

> Build reproducible, randomized, multi-language leak scenarios in seconds — from repo to PR scan.

---

## ⚙️ How It Works

1. **Start the generator:**

   Just run:

   ```bash
   ./radar_love
   ```

   This launches interactive mode—where you're prompted to:
   - 🎤 Name your project (or get a random Oasis-inspired title)
   - 💻 Pick your preferred language (e.g., bash, python, node, etc.)
   - 🔐 Choose a leak scenario (AWS, GitHub, PII, Inclusivity...)
   - ✅ Decide whether to auto-commit and/or trigger PR scans
   - 🤖 Optionally merge the leaky branch into `main`

   Example of what it might run behind the scenes:

   ```bash
   radar_love --create true --repo-name "Wonderwall" \
     --build true --language "bash" --scenario "AWS" \
     --commit true --request true --merge-main
   ```

2. **Dependencies are checked for you:**

   Before anything starts, it runs a sanity check:
   ```
   🧪 Checking tools: gh jq awk sed shfmt shellcheck git shuf
   ✅ All dependencies satisfied.
   ```

3. **Files are auto-generated for the selected language/scenario:**

   ```
   📁 Fuckin-In-The-Bushes/
   ├── Vault_Radar_trigger.sh         # The leak simulation
   ├── Vault_Radar_input.json         # Your input definition
   ├── Vault_Radar_leaks_report.md    # Markdown summary
   ├── Vault_Radar_cleanup.sh         # Cleanup script
   └── sanity_check_report.md         # Lint output (if enabled)
   ```

4. **You can also run it manually with flags:**

   ```bash
   ./radar_love --repo-name "Wonderwall" \
     --build true --language python --scenario github \
     --commit true --request true --merge-main
   ```

---

Available flags:
| Flag         | Description                                                                 |
|--------------|-----------------------------------------------------------------------------|
| `--repo-name`| (Required for create/destroy) Name of the GitHub repo                       |
| `--create`   | Create/connect GitHub repo (default: true)                                  |
| `--fresh`    | Recreate the repo/folder if it exists (default: false)                      |
| `--build`    | Generate randomized demo files and commits (default: false)                 |
| `--commit`   | Run `commit_gh.sh` to stage/commit changes (default: false)                 |
| `--request`  | Trigger GitHub PR scan (default: false)                                     |
| `--merge-main`| Merge demo branch back into main                                           |
| `--status`   | Only show current git status and exit                                       |
| `--language` | Select language (bash, python, node, terraform, dockerfile)                 |
| `--scenario` | Focused scenario (`AWS`, `PII`, `GitHub`, etc.)                             |
| `--validate` | Validate preconditions & dependencies                                       |
| `--debug`    | Show parsed flags; `--debug compact` for inline format                      |
| `--quiet`    | Suppress output, ideal for automation                                       |
| `--help`     | Show usage help                                                             |
| `--version`  | Print CLI version                                                           |

---

## 🧪 Example Runs

```bash
# Run all with GitHub integration
./radar_love.sh --repo-name live-forever --build true --commit true --request true

# Just generate locally
./radar_love.sh --repo-name champagne --create false --build true

# Clean up local + GitHub
./radar_love.sh destroy --repo-name champagne --yes
```

---

## 📦 Output Files

| File                         | Description                               |
|------------------------------|-------------------------------------------|
| `Vault_Radar_trigger.sh`     | Bash leak demo                            |
| `Vault_Radar_trigger.py`     | Python leak demo                          |
| `Vault_Radar_trigger.js`     | Node leak demo                            |
| `Vault_Radar_trigger.tf`     | Terraform leak demo                       |
| `Vault_Radar_trigger.Dockerfile` | Dockerfile leak demo                  |
| `vault-scenarios.md`         | Auto-generated markdown from scenarios    |
| `Vault_Radar_leaks_report.md`| Generated report of leaks                 |
| `Vault_Radar_cleanup.sh`     | Clean-up script                           |
| `Vault_Radar_build.log`      | Builder log                               |
| `sanity_check_report.md`     | Optional, if linting is enabled           |

🚦 Example Usage:

- All leaks (default):
    ../vault_radar_builder.sh --output-path . --scenario AWS

- Bash + Python, with lint:
    ../vault_radar_builder.sh --output-path . --languages bash,python --lint

- Dry-run Node + Terraform:
    ../vault_radar_builder.sh --output-path . --languages node,terraform --dry-run

🔧 Customization

🧠 Vault_Radar_input.json — Edit/add leaks
🖼️ templates/ — Custom header/footer banners
🎯 Scenario filters — Focus on AWS, PII, etc.
🎲 Random output size — Optional realism
📝 Notes

🛡️ Compatibility
Tested with:

✅ HashiCorp Vault Radar

“In my mind my dreams are real...” — Oasis

These scripts are for demo/educational use only.

Never commit real secrets or PII.

Works with: HashiCorp Vault Radar (https://www.hashicorp.com/en/products/vault/hcp-vault-radar)

📅 Auto-generated by radar_love.sh on {{DATE}}

---

## 🧠 Learn More

- [🔐 Vault Radar](https://www.hashicorp.com/products/vault/hcp-vault-radar)
- [🧠 Blog: Main    : Radar_Love](https://medium.com/continuous-insights/radar-love-simulate-and-detect-leaks-in-secrets-pii-and-non-inclusive-language-before-its-c9706f43051f)
- [🔓 Blog: Part   I: Radar_Love](https://medium.com/continuous-insights/from-dream-to-demo-building-an-automated-secret-scanning-pipeline-064a64971f64)
- [🔐 Blog: Part  II: Radar_Love](https://medium.com/continuous-insights/part-ii-real-time-bash-automation-version-bumps-and-living-docs-battle-tested-and-d8edf88b1d5c)
- [🔒 Blog: Part III: Radar_Love](https://medium.com/continuous-insights/radar-love-part-iii-brewing-a-cli-revolution-12a054708d2f)
- [🌳 Blog: Part  IV: Radar_Love](https://medium.com/continuous-insights/part-iv-decision-trees-and-demo-workflows-v2-0-0-reload-and-repeat-7305b899353c)
- [🔏 Blog: Part   V: Radar_Love](https://medium.com/continuous-insights/part-v-auto-generated-docs-and-badges-from-scripts-to-self-explaining-pipelines-883dd52b7127)
---

🎶 “I’m not like you… I was born on a different cloud.” — *Oasis*
© 2025 Raymon Epping — Secret scanning demo CLI, proudly open source.

---

📅 Auto-generated on {{DATE}}  