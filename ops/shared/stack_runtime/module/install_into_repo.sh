#!/usr/bin/env bash
set -Eeuo pipefail

TARGET="${1:?usage: install_into_repo.sh /abs/path/to/repo}"
NAME="${2:-$(basename "$TARGET")}"
SELF_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
STACKMOD="$SELF_ROOT/stackmod"

[ -d "$TARGET" ] || { echo "missing target repo: $TARGET" >&2; exit 1; }

mkdir -p "$TARGET/ops/portable"
rm -rf "$TARGET/ops/portable/stackmod"
cp -R "$STACKMOD" "$TARGET/ops/portable/stackmod"

mkdir -p "$TARGET/ops/bin"

cat > "$TARGET/ops/bin/status.sh" <<'WRAP'
#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)"
echo "repo=$(basename "$ROOT")"
echo "pwd=$ROOT"
git -C "$ROOT" status --short || true
WRAP

cat > "$TARGET/ops/bin/run_real.sh" <<'WRAP'
#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)"
LOCKDIR="${XDG_RUNTIME_DIR:-/tmp}/repo-run-locks"
mkdir -p "$LOCKDIR"
exec 9>"$LOCKDIR/$(basename "$ROOT").lock"
flock -n 9 || { echo "run_real locked" >&2; exit 1; }

if [ -x "$ROOT/ops/bin/_run_real_impl.sh" ]; then
  exec "$ROOT/ops/bin/_run_real_impl.sh" "$@"
fi

echo "run_real: no _run_real_impl.sh yet"
WRAP

cat > "$TARGET/ops/bin/verify_all.sh" <<'WRAP'
#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)"
FAIL=0

for f in "$ROOT/ops/bin/status.sh" "$ROOT/ops/bin/verify_all.sh" "$ROOT/ops/bin/run_real.sh"; do
  [ -x "$f" ] || { echo "missing executable: $f" >&2; FAIL=1; }
done

for t in verify test check; do
  if [ -f "$ROOT/Makefile" ] && make -C "$ROOT" -n "$t" >/dev/null 2>&1; then
    make -C "$ROOT" "$t" || FAIL=1
  fi
done

grep -RIn --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=vendor --exclude='*.pdf' --exclude='*.png' --exclude='*.jpg' '\brun\.sh\b' "$ROOT" && FAIL=1 || true

echo "VERIFY_RC=$FAIL"
exit "$FAIL"
WRAP

chmod +x "$TARGET/ops/bin/status.sh" "$TARGET/ops/bin/run_real.sh" "$TARGET/ops/bin/verify_all.sh"
echo "installed portable stackmod into: $TARGET"
