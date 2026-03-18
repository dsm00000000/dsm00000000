#!/usr/bin/env bash
set -Eeuo pipefail
. "$(CDPATH= cd -- "$(dirname -- "$0")/../../bin" && pwd)/_common.sh"

OUTDIR="$HOME/Documents/dsmjpa/stack/var/backups"
mkdir -p "$OUTDIR"

backup_one() {
  local repo="$1"
  local rp
  rp="$(repo_path_from_name "$repo")"
  [ -d "$rp" ] || return 0
  "$STACKMOD_ROOT/bin/snapshot_encrypt" "$rp" "$OUTDIR" >/dev/null
  echo "backup ok: $repo"
}

while IFS= read -r repo; do
  [ -n "$repo" ] || continue
  backup_one "$repo"
done < <(repo_names)
