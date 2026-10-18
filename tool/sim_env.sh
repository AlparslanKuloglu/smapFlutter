#!/usr/bin/env bash
# Sets debug start values (read by `debugLaunchEnv`) for the app on an iOS
# simulator, without a rebuild. They go to files in the app's temporary folder,
# because `SIMCTL_CHILD_<NAME>=… xcrun simctl launch` does not reach the app on
# iOS 26 simulators. The app must be installed; launch it afterwards.
#
#   tool/sim_env.sh booted SHELL_PREVIEW_TAB=3          # coach preview: Hesap
#   tool/sim_env.sh booted GALLERY_PAGE=12 GALLERY_DARK=true
#   tool/sim_env.sh booted --clear
#
# Names: SHELL_PREVIEW_TAB (with a --dart-define=SHELL_PREVIEW build),
# GALLERY_PAGE, GALLERY_DARK, GALLERY_LARGE_TEXT, GALLERY_REDUCE_MOTION,
# GALLERY_SEMANTICS (gallery build, -t lib/main_gallery.dart).
set -euo pipefail
device="${1:?usage: tool/sim_env.sh <device|booted> NAME=value ... | --clear}"
shift
bundle="${SMAP_BUNDLE_ID:-com.studentmap.smap}"
dir="$(xcrun simctl get_app_container "$device" "$bundle" data)/tmp/launch_env"
mkdir -p "$dir"
if [ "${1:-}" = "--clear" ]; then
  rm -f "$dir"/*
  exit 0
fi
for pair in "$@"; do
  name="${pair%%=*}"
  value="${pair#*=}"
  printf '%s\n' "$value" > "$dir/$name"
done
