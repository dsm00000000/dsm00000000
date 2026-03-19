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

repo_path() {
  local key="${1:-}"
  local repo_root
  repo_root="$(repo_root_from_script)"
  case "$key" in
    self|repo|stack|current) echo "$repo_root" ;;
    dsm00000000) echo "$HOME/Documents/dsm00000000/dsm00000000" ;;
    trader) echo "$HOME/Documents/dsmjpa/trader" ;;
    defier) echo "$HOME/Documents/dsmjpa/defier" ;;
    marketer) echo "$HOME/Documents/dsmjpa/marketer" ;;
    *) return 1 ;;
  esac
}

main() {
  repo_path "${1:-self}"
}

main "$@"
