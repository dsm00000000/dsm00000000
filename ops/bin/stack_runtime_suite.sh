#!/usr/bin/env bash
set -Eeuo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
test -d "$REPO_ROOT/ops/portable/stack_snapshot_clean"
test -d "$REPO_ROOT/ops/shared/stack_runtime"
test -x "$REPO_ROOT/ops/bin/stackdoctor"
test -f "$REPO_ROOT/docs/STACK_RUNTIME_ABSORPTION.md"
test -f "$REPO_ROOT/docs/RUNNER_GLOBAL_Y_LOCAL.md"
test -f "$REPO_ROOT/docs/STACK_ABSORPTION_CLOSURE.md"
echo "suite OK :: $REPO_ROOT"
