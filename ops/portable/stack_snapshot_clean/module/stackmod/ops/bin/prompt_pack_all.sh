#!/usr/bin/env bash
set -Eeuo pipefail
. "$(CDPATH= cd -- "$(dirname -- "$0")/../../bin" && pwd)/_common.sh"

OUTDIR="$HOME/Documents/dsmjpa/stack/var/promptpacks"
mkdir -p "$OUTDIR"
TS="$(date -u +%Y%m%dT%H%M%SZ)"

is_text_candidate() {
  case "$1" in
    *.md|*.txt|*.sh|*.bash|*.zsh|*.py|*.js|*.ts|*.json|*.yaml|*.yml|*.toml|*.ini|*.cfg|*.env|*.sql)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

pack_one() {
  local repo="$1"
  local rp out
  rp="$(repo_path_from_name "$repo")"
  [ -d "$rp" ] || return 0
  out="${OUTDIR}/${TS}__${repo}__prompt.txt"
  {
    echo "# PROMPTPACK ${repo}"
    echo
    find "$rp" \
      -type d \( -name .git -o -name node_modules -o -name .venv -o -name venv -o -name exports -o -name var -o -name attic \) -prune -o \
      -type f -size -512k -print |
    while IFS= read -r f; do
      is_text_candidate "$f" || continue
      case "$f" in
        *.pdf|*.png|*.jpg|*.jpeg|*.gif|*.webp|*.ico|*.tar|*.gz|*.enc|*.zip|*.woff|*.woff2|*.ttf|*.otf)
          continue
          ;;
      esac
      echo
      echo "===== FILE: ${f#$rp/} ====="
      sed -n '1,220p' "$f"
    done
  } > "$out"
  echo "promptpack ok: $repo -> $out"
}

while IFS= read -r repo; do
  [ -n "$repo" ] || continue
  pack_one "$repo"
done < <(repo_names)
