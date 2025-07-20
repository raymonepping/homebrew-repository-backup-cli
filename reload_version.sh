#!/usr/bin/env bash
set -euo pipefail

# === Config ===
FORMULA_DIR="Formula"
SLEEP_DURATION=3

# === Parse optional flags ===
PUBLISH_RELEASE=false
SKIP_REINSTALL=false
for arg in "$@"; do
  case "$arg" in
    --publish-gh-release) PUBLISH_RELEASE=true ;;
    --skip-reinstall) SKIP_REINSTALL=true ;;
  esac
done

# === Detect project root ===
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Find Formula file ===
FORMULA_FILE="$(find "$PROJECT_ROOT/$FORMULA_DIR" -maxdepth 1 -name '*.rb' | head -n 1)"
if [[ -z "$FORMULA_FILE" ]]; then
  echo "❌ No Formula .rb file found in $PROJECT_ROOT/$FORMULA_DIR"
  exit 1
fi

# === Get CLI/formula name (e.g., bump-version-cli) ===
FORMULA_BASENAME="$(basename "$FORMULA_FILE" .rb)"

# === Find the version to use (latest git tag, drop leading 'v') ===
VERSION="$(git -C "$PROJECT_ROOT" describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')"
if [[ -z "$VERSION" ]]; then
  echo "❌ No git tags found. Please tag your release before running this script."
  exit 1
fi

REPO_URL="https://github.com/${GITHUB_REPOSITORY:-raymonepping/homebrew-$FORMULA_BASENAME}"
TARBALL_URL="$REPO_URL/archive/refs/tags/v$VERSION.tar.gz"

echo ""
echo "📦 Updating Homebrew formula for $FORMULA_BASENAME to version $VERSION..."
echo "⏳ Waiting $SLEEP_DURATION s for GitHub to process tag..."
sleep $SLEEP_DURATION

# === Check tarball availability (try up to 5 times) ===
echo "🔎 Checking tarball availability..."
attempt=0
until curl --head --fail --silent "$TARBALL_URL" >/dev/null || (( attempt >= 5 )); do
  attempt=$((attempt + 1))
  echo "⏳ Tarball not ready yet. Retrying ($attempt/5)..."
  sleep 2
done

if ! curl --head --fail --silent "$TARBALL_URL" >/dev/null; then
  echo "❌ Tarball $TARBALL_URL is still not available after retrying."
  exit 1
fi

# === Compute SHA256 ===
SHA256=$(curl -sL "$TARBALL_URL" | shasum -a 256 | awk '{ print $1 }')
echo "🔐 SHA256: $SHA256"

# === Patch Formula ===
sed -i '' "s|url \".*\"|url \"$TARBALL_URL\"|" "$FORMULA_FILE"
sed -i '' "s|sha256 \".*\"|sha256 \"$SHA256\"|" "$FORMULA_FILE"

# Update version line if present
if grep -q 'version "' "$FORMULA_FILE"; then
  sed -i '' "s|version \".*\"|version \"$VERSION\"|" "$FORMULA_FILE"
fi

echo "📝 Formula updated."

# === Commit and push ===
cd "$PROJECT_ROOT"
if git diff --quiet "$FORMULA_FILE"; then
  echo "ℹ️ No changes to commit."
else
  git add "$FORMULA_FILE"
  git commit -m "🔖 $FORMULA_BASENAME: release v$VERSION"
  git push
fi

# === Create GitHub release (optional) ===
if [[ "$PUBLISH_RELEASE" == true ]]; then
  echo "📣 Publishing GitHub release..."
  gh release create "v$VERSION" --title "$FORMULA_BASENAME $VERSION" --notes "Release $VERSION" || echo "ℹ️ Tag v$VERSION already exists, skipping creation."
  echo "🌐 $REPO_URL/releases/tag/v$VERSION"
fi

# === Reinstall via Homebrew (optional) ===
if [[ "$SKIP_REINSTALL" == true ]]; then
  echo "⏭️  Skipping reinstall as requested via --skip-reinstall."
else
  echo "🍺 Reinstalling via Homebrew..."
  if brew list "$FORMULA_BASENAME" >/dev/null 2>&1; then
    brew uninstall --force "$FORMULA_BASENAME" || true
  fi
  brew install --formula --build-from-source "$FORMULA_FILE"

  echo "🔗 Relinking..."
  brew link --overwrite --force "$FORMULA_BASENAME" || true

  echo "✅ Verifying installed version..."
  BINARY_PATH="$(brew --prefix "$FORMULA_BASENAME" 2>/dev/null)/bin/${FORMULA_BASENAME//-/_}"
  if [[ -x "$BINARY_PATH" ]]; then
    "$BINARY_PATH" --version
  else
    # Fallback: try just the formula basename as a command
    if command -v "${FORMULA_BASENAME//-/_}" &>/dev/null; then
      "${FORMULA_BASENAME//-/_}" --version
    else
      echo "⚠️  CLI binary not found in PATH. You may need to run:"
      echo "  brew link --overwrite --force $FORMULA_BASENAME"
    fi
  fi
fi

echo "✅ Done."
