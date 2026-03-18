#!/usr/bin/env bash
set -Eeuo pipefail
. "$(CDPATH= cd -- "$(dirname -- "$0")/../../bin" && pwd)/_common.sh"

OUTDIR="$HOME/Documents/dsmjpa/stack/var/runs/$(date -u +%Y%m%dT%H%M%SZ)__security_audit__$$"
mkdir -p "$OUTDIR"
OUT="$OUTDIR/summary.txt"
TMP="$OUTDIR/hits.tmp"
: > "$TMP"

scan_repo() {
  local repo="$1"
  local rp
  rp="$(repo_path_from_name "$repo")"
  [ -d "$rp" ] || return 0

  find "$rp" \
    -type d \( \
      -name .git -o -name node_modules -o -name vendor -o -name dist -o -name build -o \
      -name .venv -o -name venv -o -name __pycache__ -o -name exports -o -name var -o \
      -name attic -o -name _legacy \
    \) -prune -o \
    -type f -size -512k -print |
  while IFS= read -r f; do
    case "$f" in
      */ops/bin/security_audit_all.sh) continue ;;
      */ONECHUNK_*|*/onechunk/*|*/onechunkers/*) continue ;;
      *.pdf|*.png|*.jpg|*.jpeg|*.gif|*.webp|*.ico|*.tar|*.gz|*.enc|*.zip|*.woff|*.woff2|*.ttf|*.otf) continue ;;
      *.example|*.sample|*.template|*.tpl) continue ;;
      */env.example|*/.env.example|*/example.env|*/template.env) continue ;;
    esac

    grep -nE \
      '(BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|glpat-[A-Za-z0-9\-_]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z\-_]{20,}|sk_(live|test)_[0-9A-Za-z]{12,}|api[_-]?key[[:space:]]*[:=][[:space:]]*["'\'']?[A-Za-z0-9_\-\/+=]{16,}|secret[_-]?key[[:space:]]*[:=][[:space:]]*["'\'']?[A-Za-z0-9_\-\/+=]{16,}|token[[:space:]]*[:=][[:space:]]*["'\'']?[A-Za-z0-9_\-\/+=]{16,}|password[[:space:]]*[:=][[:space:]]*["'\'']?[^\ "'\''`]{10,})' \
      "$f" 2>/dev/null || true
  done |
  grep -viE \
    '(example|sample|template|dummy|placeholder|changeme|your_|<secret>|<token>|fake|mock|regex|guard|audit|expected|BEGIN .* PRIVATE KEY.*example|api[_-]?key.*(name|label|field)|secret[_-]?key.*(name|label|field)|token.*(name|label|field)|password.*(name|label|field))' \
  | sed "s|^|${repo}:|g" >> "$TMP"
}

while IFS= read -r repo; do
  [ -n "$repo" ] || continue
  scan_repo "$repo"
done < <(repo_names)

{
  echo "SECURITY_AUDIT_OUT=$OUTDIR"
  echo "----"
  if [ -s "$TMP" ]; then
    echo "POTENTIAL_REAL_HITS=1"
    sort -u "$TMP"
    exit 2
  else
    echo "POTENTIAL_REAL_HITS=0"
    echo "No high-signal hits after exclusions"
  fi
} | tee "$OUT"
