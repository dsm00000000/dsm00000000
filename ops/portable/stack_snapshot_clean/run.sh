#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$ROOT"

TS="$(date -u +%Y%m%dT%H%M%SZ)"
ARCHIVE="_stack_finalize/${TS}"
REPORT="${ARCHIVE}/STACK_RUN_REPORT.txt"

say() { printf '[%s] %s\n' "$(date -u +%H:%M:%S)" "$*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

append_report() {
  {
    echo
    echo "===== $1 ====="
    shift
    "$@" 2>&1 || true
  } >> "$REPORT"
}

ensure_clean_except_archive() {
  local out
  out="$(git status --short | grep -vE '^\?\? _stack_finalize/' || true)"
  [ -z "$out" ] || {
    echo "$out"
    die "repo is not clean"
  }
}

commit_if_needed() {
  git add .
  if ! git diff --cached --quiet; then
    git commit -m "ok"
  else
    echo "[sync] nothing to commit"
  fi
}

say "0) precheck limpio"
ensure_clean_except_archive

mkdir -p "$ARCHIVE"
: > "$REPORT"

say "1) verificaciones de estado"
test -f README.md || die "missing README.md"
test -f contracts/final_state.md || die "missing contracts/final_state.md"
test -f module/stackmod/contracts/portable_contract.md || die "missing portable_contract.md"
test -f STACK_RETIRED || die "missing STACK_RETIRED"
test -f STABLE_SYSTEM || die "missing STABLE_SYSTEM"

say "2) verificar bin públicos"
for f in \
  bin/lockctl \
  bin/repo_path \
  bin/snapshot_decrypt \
  bin/snapshot_encrypt \
  bin/ssh_once \
  bin/stackall \
  bin/stackctl \
  bin/stackdoctor \
  bin/stackdump \
  bin/stacktree
do
  test -f "$f" || die "missing $f"
  test -x "$f" || die "not executable $f"
done

say "3) verificar módulo portable"
test -f module/install_into_repo.sh || die "missing module/install_into_repo.sh"
test -f module/stackmod/MODULE_VERSION || die "missing module/stackmod/MODULE_VERSION"

say "4) smoke sintáctico"
while IFS= read -r f; do
  bash -n "$f" || die "bash -n failed: $f"
done < <(
  find bin module -type f \
    | grep -E '(\.sh$|^bin/|^module/install_into_repo\.sh$|^module/stackmod/bin/|^module/stackmod/ops/bin/)'
)

say "5) doctor"
append_report "stackdoctor" bin/stackdoctor

say "6) repos"
append_report "repos ls" bin/stackctl repos ls

say "7) tree"
append_report "stacktree" bin/stacktree

say "8) sync"
commit_if_needed
git push origin main
git push gl main
git status

say "9) done"
echo "REPORT=$ROOT/$REPORT"
