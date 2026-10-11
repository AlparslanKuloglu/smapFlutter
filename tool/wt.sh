#!/usr/bin/env bash
# Creates (or reuses) a git worktree for a plan task: tool/wt.sh <task-id>
# Worktrees live next to the repo in ../smapFlutter-wt/<task-id> on branch task/<task-id>, based on redesign/main.
set -euo pipefail
id="${1:?task id}"
root="$(git rev-parse --show-toplevel)"
dir="$(dirname "$root")/smapFlutter-wt/$id"
if [ -d "$dir" ]; then echo "$dir"; exit 0; fi
git -C "$root" worktree add -q -b "task/$id" "$dir" redesign/main
echo "$dir"
