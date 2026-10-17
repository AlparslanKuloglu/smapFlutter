#!/usr/bin/env bash
# Creates (or reuses) a git worktree for a task: tool/wt.sh <task-id> [base]
# The worktree lives next to the repo in ../smapFlutter-wt/<task-id> on branch
# task/<task-id>. [base] is the branch it starts from: the second argument,
# else $WT_BASE, else redesign/main (the integration branch).
set -euo pipefail
id="${1:?usage: tool/wt.sh <task-id> [base-branch]}"
base="${2:-${WT_BASE:-redesign/main}}"
root="$(git rev-parse --show-toplevel)"
dir="$(dirname "$root")/smapFlutter-wt/$id"
if [ -d "$dir" ]; then echo "$dir"; exit 0; fi
git -C "$root" worktree add -q -b "task/$id" "$dir" "$base"
echo "$dir"
