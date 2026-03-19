#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
case "$SCRIPT_DIR" in
  */ops/shared/stack_runtime/ops/bin) REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)" ;;
  */ops/portable/stack_snapshot_clean/module/stackmod/ops/bin) REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../.." && pwd)" ;;
  *) REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)" ;;
esac
OUTBASE="$REPO_ROOT/var/promptpacks"
mkdir -p "$OUTBASE"
printf "%s\n" "$OUTBASE"
