#!/usr/bin/env bash
# sync.sh - pull latest dotfiles and re-apply symlinks
# Safe to run repeatedly (idempotent)

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Dotfiles dir: $DOTFILES_DIR"

# Pull latest
git -C "$DOTFILES_DIR" pull --ff-only

# Re-run linux bootstrap to refresh symlinks
"$DOTFILES_DIR/bootstrap/linux.sh" --symlinks-only
