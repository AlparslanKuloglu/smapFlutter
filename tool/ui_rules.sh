#!/usr/bin/env bash
# Fails when app code uses a pattern AGENTS.md "UI rules" forbids (plan FIN2:
# the `Color(0x` counter, target 0, plus the other banned APIs).
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
exit $fail
