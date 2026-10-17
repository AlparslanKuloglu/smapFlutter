#!/usr/bin/env bash
# Formats the app's Dart files: every tracked *.dart except lib/vendor, a
# third-party fork with its own (older) language version that `dart format .`
# would rewrite. Extra arguments go to `dart format`, e.g.
#   tool/format.sh                                # format in place
#   tool/format.sh --output=none --set-exit-if-changed   # check only (CI)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
git ls-files -z -- '*.dart' ':!:lib/vendor/**' | xargs -0 dart format "$@"
