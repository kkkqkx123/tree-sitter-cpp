#!/usr/bin/env bash
# Publish the vendored tree-sitter-cpp fork to crates.io as
# `kkkqkx-tree-sitter-cpp`.
#
# The `tree-sitter-cpp` name on crates.io belongs to an unrelated
# third-party publisher, so this fork is published under the
# `kkkqkx-tree-sitter-cpp` package name while keeping the
# `tree_sitter_cpp` library name for source compatibility.
#
# Usage:
#   ./publish.sh           # real publish
#   ./publish.sh --dry-run # cargo publish --dry-run
set -euo pipefail

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

CRATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

name=$(sed -n 's/^name *= *"\(.*\)".*/\1/p' "$CRATE_DIR/Cargo.toml" | head -1)
version=$(sed -n 's/^version *= *"\(.*\)".*/\1/p' "$CRATE_DIR/Cargo.toml" | head -1)
if [[ -z "$name" || -z "$version" ]]; then
    echo "ERROR: could not determine package name/version." >&2
    exit 1
fi

echo "=== Publishing $name v$version ==="

# Skip if this version is already on crates.io (User-Agent is
# required by the crates.io API).
if curl -sf -A "tree-sitter-cpp-publish-script" -o /dev/null "https://crates.io/api/v1/crates/$name/$version"; then
    echo "Skipping $name v$version: already published."
    exit 0
fi

cd "$CRATE_DIR"
if $DRY_RUN; then
    cargo publish --dry-run --allow-dirty --registry crates-io
else
    cargo publish --allow-dirty --registry crates-io
fi

echo "$name v$version published successfully."
