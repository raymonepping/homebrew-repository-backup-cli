#!/usr/bin/env bash
set -euo pipefail

FORMULA_FILE="radar_love_cli.rb"

# Check if formula file exists
if [[ ! -f "$FORMULA_FILE" ]]; then
  echo "❌ Formula file '$FORMULA_FILE' not found!"
  exit 1
fi

# Fetch latest tag
TAG=$(git describe --tags --abbrev=0)
TAR_URL="https://github.com/raymonepping/radar_love_cli/archive/refs/tags/${TAG}.tar.gz"

# Fetch and calculate SHA256
echo "📦 Downloading $TAR_URL..."
curl -sSL "$TAR_URL" -o temp.tar.gz
SHA=$(shasum -a 256 temp.tar.gz | awk '{print $1}')
rm temp.tar.gz

# Confirm before applying (optional)
echo "🔍 Updating formula to:"
echo "  • Tag:     $TAG"
echo "  • URL:     $TAR_URL"
echo "  • SHA256:  $SHA"
echo

# Update fields in the formula
sed -i '' \
  -e "s|^\(\s*url\s*\).*|\1\"$TAR_URL\"|" \
  -e "s|^\(\s*sha256\s*\).*|\1\"$SHA\"|" \
  -e "s|^\(\s*version\s*\).*|\1\"${TAG#v}\"|" \
  "$FORMULA_FILE"

echo "✅ Formula '$FORMULA_FILE' updated successfully to $TAG"
