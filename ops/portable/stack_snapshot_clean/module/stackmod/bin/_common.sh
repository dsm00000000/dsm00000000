#!/usr/bin/env bash
set -Eeuo pipefail

repo_root_from_script() {
  local src="${BASH_SOURCE[0]}"
  local dir
  dir="$(cd "$(dirname "$src")" && pwd)"
  case "$dir" in
    */ops/shared/stack_runtime/bin) cd "$dir/../../.." && pwd ;;
    */ops/portable/stack_snapshot_clean/module/stackmod/bin) cd "$dir/../../../../.." && pwd ;;
    */ops/bin) cd "$dir/../.." && pwd ;;
    *) cd "$dir/.." && pwd ;;
  esac
}

stackmod_root_from_script() {
  local src="${BASH_SOURCE[0]}"
  local dir
  dir="$(cd "$(dirname "$src")" && pwd)"
  case "$dir" in
    */ops/shared/stack_runtime/bin) cd "$dir/.." && pwd ;;
    */ops/portable/stack_snapshot_clean/module/stackmod/bin) cd "$dir/.." && pwd ;;
    *) cd "$dir/.." && pwd ;;
  esac
}

repo_names() {
  printf "%s\n" dsm00000000 trader defier marketer
}

repo_path_from_name() {
  case "${1:-self}" in
    self|repo|current|stack) repo_root_from_script ;;
    dsm00000000) printf "%s\n" "$HOME/Documents/dsm00000000/dsm00000000" ;;
    trader)      printf "%s\n" "$HOME/Documents/dsmjpa/trader" ;;
    defier)      printf "%s\n" "$HOME/Documents/dsmjpa/defier" ;;
    marketer)    printf "%s\n" "$HOME/Documents/dsmjpa/marketer" ;;
    *) return 1 ;;
  esac
}

repo_path() {
  repo_path_from_name "${1:-self}"
}

log() {
  printf "[stackmod] %s\n" "$*"
}

run_in_repo() {
  local repo="$1"; shift
  local rp
  rp="$(repo_path_from_name "$repo")"
  [ -d "$rp" ] || { log "missing repo path: $repo"; return 1; }
  ( cd "$rp" && "$@" )
}
