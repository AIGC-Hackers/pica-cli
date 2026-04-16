#!/usr/bin/env bash
# Install pica CLI from the latest GitHub release.
# Usage: curl -fsSL https://raw.githubusercontent.com/AIGC-Hackers/pica-cli/main/install.sh | bash
set -euo pipefail

REPO="AIGC-Hackers/pica-cli"
ASSET="pica-bundle.tar.gz"
INSTALL_DIR="${PICA_INSTALL_DIR:-$HOME/.local/bin}"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
    return
  fi

  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{ print $1 }'
    return
  fi

  echo "error: sha256sum or shasum is required to verify the download" >&2
  exit 1
}

resolve_tag() {
  if [ "${1:-}" != "" ]; then
    echo "v${1#v}"
    return
  fi

  curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
    | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
    | head -n 1
}

require_command curl
require_command tar
require_command awk
require_command sed
require_command mktemp

tag=$(resolve_tag "${1:-}")
if [ -z "$tag" ]; then
  echo "error: failed to resolve latest pica release tag" >&2
  exit 1
fi

tmp_dir=$(mktemp -d)
install_tmp=""

cleanup() {
  rm -rf "$tmp_dir"
  if [ -n "$install_tmp" ]; then
    rm -f "$install_tmp"
  fi
}

trap cleanup EXIT

asset_url="https://github.com/$REPO/releases/download/$tag/$ASSET"
checksums_url="https://github.com/$REPO/releases/download/$tag/checksums.txt"
archive="$tmp_dir/$ASSET"

echo "Installing pica $tag to $INSTALL_DIR ..."

curl -fsSL "$asset_url" -o "$archive"
expected_sha=$(curl -fsSL "$checksums_url" | awk -v asset="$ASSET" '$2 == asset { print $1 }')

if [ -z "$expected_sha" ]; then
  echo "error: $ASSET is missing from checksums.txt for $tag" >&2
  exit 1
fi

actual_sha=$(sha256_file "$archive")
if [ "$actual_sha" != "$expected_sha" ]; then
  echo "error: checksum mismatch for $ASSET" >&2
  echo "expected: $expected_sha" >&2
  echo "actual:   $actual_sha" >&2
  exit 1
fi

tar -xzf "$archive" -C "$tmp_dir"

if [ ! -f "$tmp_dir/pica.js" ]; then
  echo "error: release archive does not contain pica.js" >&2
  exit 1
fi

if ! command -v bun >/dev/null 2>&1; then
  echo "bun runtime not found; installing ..."
  curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
fi

mkdir -p "$INSTALL_DIR"
install_tmp="$INSTALL_DIR/.pica.tmp.$$"
cp "$tmp_dir/pica.js" "$install_tmp"
chmod 0755 "$install_tmp"
mv -f "$install_tmp" "$INSTALL_DIR/pica"

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "hint: add $INSTALL_DIR to your PATH if it is not already" ;;
esac

"$INSTALL_DIR/pica" --help >/dev/null

echo "done: $INSTALL_DIR/pica"
