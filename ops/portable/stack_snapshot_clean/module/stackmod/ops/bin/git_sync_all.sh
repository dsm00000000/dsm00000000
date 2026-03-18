#!/usr/bin/env bash
set -Eeuo pipefail
. "$(CDPATH= cd -- "$(dirname -- "$0")/../../bin" && pwd)/_common.sh"

sync_one() {
  local repo="$1"
  local rp
  rp="$(repo_path_from_name "$repo")"
  [ -d "$rp/.git" ] || { log "SKIP no git repo: $repo"; return 0; }
  (
    cd "$rp"
    git add -A
    if ! git diff --cached --quiet; then
      git commit -m "sync: ${repo} $(date -u +%Y-%m-%dT%H:%M:%SZ)" || true
    fi
    git push origin HEAD || true
    if git remote get-url gitlab >/dev/null 2>&1; then
      git push gitlab HEAD || true
    fi
  )
}

while IFS= read -r repo; do
  [ -n "$repo" ] || continue
  sync_one "$repo"
done < <(repo_names)
