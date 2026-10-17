#!/usr/bin/env bash
# Fails when app code uses a pattern AGENTS.md "UI rules" forbids (plan FIN2:
# the `Color(0x` counter, target 0, plus the other banned APIs) or when a UI
# file outgrows the size limits of docs/SMAP_UI_Uygulama_Rehberi.md §6.
# Usage: tool/ui_rules.sh   (from the repo root)
set -uo pipefail
dirs=(lib/features lib/shared lib/app)
fail=0
check() {
  local label="$1" pattern="$2"
  local hits
  hits=$(grep -rEn --include='*.dart' "$pattern" "${dirs[@]}" \
    | grep -v '\.gr\.dart:' | grep -Ev ':[0-9]+:\s*//' || true)
  if [ -n "$hits" ]; then
    echo "::error::$label"
    echo "$hits"
    fail=1
  fi
}
check 'Color(0x… — use context.appColors' 'Color\(0x'
check 'Colors.* — use context.appColors' '(^|[^A-Za-z0-9_.])Colors\.'
check 'TextStyle( — use context.appText + copyWith' '(^|[^A-Za-z0-9_.])TextStyle\('
check 'Icons.* / CupertinoIcons.* — use phosphor_flutter' '(^|[^A-Za-z0-9_])(Cupertino)?Icons\.'
check 'Dialogs and snack bars — use AppSheet / ToastService' 'showDialog|AlertDialog|showModalBottomSheet|SnackBar\('
check 'MaterialPageRoute / Navigator.push — use auto_route' 'MaterialPageRoute|Navigator\.push'
check 'print( — use AppLogger' '(^|[^A-Za-z0-9_.])print\('
check 'fontSize: — use a context.appText style' 'fontSize:'
check 'Widget _build…() helpers — split into widget classes' 'Widget _build'
dirs=(lib/features/*/presentation lib/shared/ui)
check 'Duration( in UI — use AppMotion / SmapDurations' '(^|[^A-Za-z0-9_])Duration\('

# Size limits (lines): a screen's *_view.dart 250, a `part of` file 300, any
# *_viewmodel.dart 500, any other presentation or kit file 400. Generated
# code and the debug galleries are not counted.
oversize=""
while IFS= read -r file; do
  lines=$(wc -l < "$file" | tr -d ' ')
  if grep -m1 -v '^[[:space:]]*$' "$file" | grep -q '^part of'; then limit=300
  elif [[ $file == *_viewmodel.dart ]]; then limit=500
  elif [[ $file == */presentation/*_view.dart ]]; then limit=250
  else limit=400
  fi
  if [ "$lines" -gt "$limit" ]; then
    oversize+="$file: $lines lines (limit $limit)"$'\n'
  fi
done < <(
  { find lib/features/*/presentation lib/shared/ui -name '*.dart'
    find lib -name '*_viewmodel.dart'; } \
    | grep -Ev '/debug/|\.(g|gr|mapper|freezed)\.dart$' | sort -u
)
if [ -n "$oversize" ]; then
  echo "::error::File too long — split it (UI guide §6)"
  printf '%s' "$oversize"
  fail=1
fi
exit $fail
