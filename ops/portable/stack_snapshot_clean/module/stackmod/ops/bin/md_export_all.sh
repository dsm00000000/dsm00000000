#!/usr/bin/env bash
set -Eeuo pipefail
. "$(CDPATH= cd -- "$(dirname -- "$0")/../../bin" && pwd)/_common.sh"

OUTBASE="$HOME/Documents/dsmjpa/stack/var/md_exports/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$OUTBASE"

md_to_html() {
  local in="$1" out="$2"
  {
    echo '<!doctype html><html><head><meta charset="utf-8"><title>md export</title></head><body><pre>'
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$in"
    echo '</pre></body></html>'
  } > "$out"
}

export_repo() {
  local repo="$1"
  local rp repo_out
  rp="$(repo_path_from_name "$repo")"
  [ -d "$rp" ] || return 0
  repo_out="$OUTBASE/$repo"
  mkdir -p "$repo_out"
  find "$rp" \
    -type d \( -name .git -o -name node_modules -o -name .venv -o -name venv -o -name exports -o -name var -o -name attic \) -prune -o \
    -type f -name '*.md' -size -512k -print |
  while IFS= read -r md; do
    rel="${md#$rp/}"
    html="$repo_out/${rel%.md}.html"
    pdf="$repo_out/${rel%.md}.pdf"
    mkdir -p "$(dirname "$html")"
    md_to_html "$md" "$html"
    if command -v wkhtmltopdf >/dev/null 2>&1; then
      wkhtmltopdf "$html" "$pdf" >/dev/null 2>&1 || true
    elif command -v pandoc >/dev/null 2>&1; then
      pandoc "$md" -o "$pdf" >/dev/null 2>&1 || true
    fi
  done
  echo "md export ok: $repo -> $repo_out"
}

while IFS= read -r repo; do
  [ -n "$repo" ] || continue
  export_repo "$repo"
done < <(repo_names)
