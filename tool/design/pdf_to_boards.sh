#!/usr/bin/env bash
# Turns a Claude Design PDF export (one board per page) into the layout of
# docs/design/panolar: one PNG per page in panolar/png/ and the page's text in
# panolar/SMAP-NN/<NN-board>/text.txt.
#
#   tool/design/pdf_to_boards.sh docs/design/kaynak/SMAP-15.pdf
#
# Needs poppler (brew install poppler): pdftoppm, pdftotext, pdfinfo.
set -euo pipefail
pdf="${1:?usage: tool/design/pdf_to_boards.sh <docs/design/kaynak/SMAP-NN.pdf>}"
name="$(basename "$pdf" .pdf)"                 # SMAP-15
root="$(cd "$(dirname "$0")/../.." && pwd)/docs/design/panolar"
mkdir -p "$root/png" "$root/$name"
pages="$(pdfinfo "$pdf" | awk '/^Pages:/ {print $2}')"
for ((p = 1; p <= pages; p++)); do
  text="$(pdftotext -layout -f "$p" -l "$p" "$pdf" -)"
  # The board's code ("14.3") and title are the first two non-empty lines.
  code="$(printf '%s\n' "$text" | sed -n '/[^[:space:]]/p' | head -1 | grep -oE '^[0-9]+\.[0-9]+' || true)"
  title="$(printf '%s\n' "$text" | sed -n '/[^[:space:]]/p' | sed -n '2p' | sed -E 's/^[[:space:]]+//')"
  slug="$(printf '%s %s' "${code:-p$p}" "$title" | sed -E 's/[^[:alnum:]çğıöşüÇĞİÖŞÜ]+/-/g; s/^-+|-+$//g' | cut -c1-70)"
  dir="$(printf '%02d-%s' $((p - 1)) "$slug")"
  mkdir -p "$root/$name/$dir"
  printf '%s\n' "$text" > "$root/$name/$dir/text.txt"
  pdftoppm -f "$p" -l "$p" -r 144 -png -singlefile "$pdf" "$root/png/${name}_${dir}"
  echo "$name/$dir"
done
