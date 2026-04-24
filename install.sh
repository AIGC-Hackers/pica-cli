#!/usr/bin/env bash
# Install pica CLI from the public release repository.
# Usage: curl -fsSL https://raw.githubusercontent.com/AIGC-Hackers/pica-cli/main/install.sh | bash
set -euo pipefail

REPO="AIGC-Hackers/pica-cli"
MANIFEST_ASSET="pica-manifest.json"
INSTALL_DIR="${PICA_INSTALL_DIR:-$HOME/.local/bin}"
PICA_HOME="${PICA_HOME:-$HOME/.local/share/pica}"
PICA_CLI_HOME="$PICA_HOME/cli"
PICA_VERSIONS_DIR="$PICA_CLI_HOME/versions"
PICA_CURRENT_LINK="$PICA_CLI_HOME/current"
BUN_INSTALL_SCRIPT_URL="https://bun.sh/install"

fail() {
  echo "pica installer: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
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

  fail "sha256sum or shasum is required to verify the download"
}

normalize_version() {
  local value
  value="${1#v}"
  value="${value%%-*}"
  value="${value%%+*}"
  echo "$value"
}

version_ge() {
  local left right
  local left_major left_minor left_patch
  local right_major right_minor right_patch

  left="$(normalize_version "$1")"
  right="$(normalize_version "$2")"

  IFS=. read -r left_major left_minor left_patch <<<"$left"
  IFS=. read -r right_major right_minor right_patch <<<"$right"

  left_major="${left_major:-0}"
  left_minor="${left_minor:-0}"
  left_patch="${left_patch:-0}"
  right_major="${right_major:-0}"
  right_minor="${right_minor:-0}"
  right_patch="${right_patch:-0}"

  if (( left_major != right_major )); then
    (( left_major > right_major ))
    return
  fi

  if (( left_minor != right_minor )); then
    (( left_minor > right_minor ))
    return
  fi

  (( left_patch >= right_patch ))
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

json_value() {
  local key="$1"
  sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1
}

resolve_bun_bin() {
  if command -v bun >/dev/null 2>&1; then
    command -v bun
    return
  fi

  if [ -x "$HOME/.bun/bin/bun" ]; then
    echo "$HOME/.bun/bin/bun"
    return
  fi

  return 1
}

ensure_bun() {
  local minimum_version bun_bin current_version

  minimum_version="$1"
  bun_bin="$(resolve_bun_bin || true)"
  current_version=""

  if [ -n "$bun_bin" ]; then
    current_version="$("$bun_bin" --version)"
  fi

  if [ -n "$current_version" ] && version_ge "$current_version" "$minimum_version"; then
    return
  fi

  # Keep first install aligned with the CLI updater: Bun comes from the official
  # installer, and pica owns only the JS bundle plus the current pointer.
  echo "Installing Bun v$minimum_version..."
  curl -fsSL "$BUN_INSTALL_SCRIPT_URL" | bash -s "bun-v$minimum_version"
  export PATH="$HOME/.bun/bin:$PATH"

  bun_bin="$(resolve_bun_bin || true)"
  [ -n "$bun_bin" ] || fail "Bun installation completed but bun is still not on PATH"

  current_version="$("$bun_bin" --version)"
  version_ge "$current_version" "$minimum_version" || \
    fail "installed Bun version $current_version is below required version $minimum_version"
}

write_wrapper() {
  mkdir -p "$INSTALL_DIR"
  cat > "$INSTALL_DIR/pica" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

PICA_HOME="${PICA_HOME:-$HOME/.local/share/pica}"

if command -v bun >/dev/null 2>&1; then
  PICA_BUN="$(command -v bun)"
elif [ -x "$HOME/.bun/bin/bun" ]; then
  PICA_BUN="$HOME/.bun/bin/bun"
else
  echo "pica: Bun is missing. Re-run the installer." >&2
  exit 1
fi

exec "$PICA_BUN" "$PICA_HOME/cli/current/pica.js" "$@"
EOF
  chmod 0555 "$INSTALL_DIR/pica"
}

require_command curl
require_command tar
require_command awk
require_command sed
require_command mktemp

tag="$(resolve_tag "${1:-}")"
[ -n "$tag" ] || fail "failed to resolve pica release tag"

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

manifest_url="https://github.com/$REPO/releases/download/$tag/$MANIFEST_ASSET"
manifest_path="$tmp_dir/$MANIFEST_ASSET"

echo "Installing pica $tag ..."
curl -fsSL "$manifest_url" -o "$manifest_path"

manifest_content="$(cat "$manifest_path")"
bundle_url="$(printf '%s\n' "$manifest_content" | json_value "url")"
bundle_sha="$(printf '%s\n' "$manifest_content" | json_value "sha256")"
minimum_bun_version="$(printf '%s\n' "$manifest_content" | json_value "minimumBunVersion")"
bundle_version="$(printf '%s\n' "$manifest_content" | json_value "version")"

[ -n "$bundle_url" ] || fail "manifest is missing bundle.url"
[ -n "$bundle_sha" ] || fail "manifest is missing bundle.sha256"
[ -n "$minimum_bun_version" ] || fail "manifest is missing minimumBunVersion"
[ -n "$bundle_version" ] || fail "manifest is missing version"

ensure_bun "$minimum_bun_version"

archive="$tmp_dir/pica-bundle.tar.gz"
extract_dir="$tmp_dir/extract"
mkdir -p "$extract_dir"

curl -fsSL "$bundle_url" -o "$archive"

actual_sha="$(sha256_file "$archive")"
[ "$actual_sha" = "$bundle_sha" ] || \
  fail "bundle checksum mismatch: expected $bundle_sha, got $actual_sha"

tar -xzf "$archive" -C "$extract_dir"
[ -f "$extract_dir/pica.js" ] || fail "release archive does not contain pica.js"

target_dir="$PICA_VERSIONS_DIR/$bundle_version"
mkdir -p "$target_dir"
cp "$extract_dir/pica.js" "$target_dir/pica.js"
chmod 0555 "$target_dir/pica.js"

mkdir -p "$(dirname "$PICA_CURRENT_LINK")"
ln -sfn "$target_dir" "$PICA_CURRENT_LINK"

write_wrapper

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "Add $INSTALL_DIR to your PATH if it is not already." ;;
esac

echo "Installed pica v$bundle_version to $INSTALL_DIR/pica"
