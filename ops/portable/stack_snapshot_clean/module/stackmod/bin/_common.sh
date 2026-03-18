#!/usr/bin/env bash
set -Eeuo pipefail

STACKMOD_ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
STACK_ROOT="$(CDPATH= cd -- "$STACKMOD_ROOT/.." && pwd)"
STACK_ROOT="$(CDPATH= cd -- "$STACK_ROOT/.." && pwd)"

repo_names() {
  cat <<NAMES
dsm00000000
stack
freelancer
trader
defier
NAMES
}

repo_path_from_name() {
  case "${1:-}" in
    dsm00000000) echo "$HOME/Documents/dsm00000000/dsm00000000" ;;
    stack) echo "$HOME/Documents/dsmjpa/stack" ;;
    freelancer) echo "$HOME/Documents/dsmjpa/freelancer" ;;
    trader) echo "$HOME/Documents/dsmjpa/trader" ;;
    defier) echo "$HOME/Documents/dsmjpa/defier" ;;
    *) return 1 ;;
  esac
}

have_cmd() { command -v "$1" >/dev/null 2>&1; }

log() { printf '[%s] %s\n' "$(date -u +%H:%M:%S)" "$*"; }

run_in_repo() {
  local repo="$1"; shift
  local rp
  rp="$(repo_path_from_name "$repo")"
  [ -d "$rp" ] || { log "SKIP repo not found: $repo -> $rp"; return 0; }
  (
    cd "$rp"
    "$@"
  )
}
