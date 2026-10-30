#!/usr/bin/env bash
# ai-sdlc guardrails, run before Edit/Write/MultiEdit. Off unless the "guardrails" plugin option is true.
#   1. Asks before a stage document is set to "Status: Approved".
#   2. While a build task is active, asks before editing a file the task doesn't list.
#   3. While a bug-fix task has its tests locked, denies edits to test files.
set -u

enabled="${CLAUDE_PLUGIN_OPTION_GUARDRAILS:-${CLAUDE_PLUGIN_OPTION_guardrails:-false}}"
[ "$enabled" = "true" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
file=$(jq -r '.tool_input.file_path // empty' <<<"$input")
[ -n "$file" ] || exit 0
cwd=$(jq -r '.cwd // empty' <<<"$input")
cwd=${cwd:-$PWD}
rel=${file#"$cwd"/}

respond() {
  jq -n --arg d "$1" --arg r "$2" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: $d, permissionDecisionReason: $r}}'
  exit 0
}

approved='Status:\*\*[[:space:]]*Approved'

case "$rel" in
  docs/ai-sdlc/*/0[1-4]-*.md)
    new=$(jq -r '[.tool_input.content, .tool_input.new_string, (.tool_input.edits // [] | .[].new_string)] | map(select(. != null)) | join("\n")' <<<"$input")
    old=$(jq -r '[.tool_input.old_string, (.tool_input.edits // [] | .[].old_string)] | map(select(. != null)) | join("\n")' <<<"$input")
    if [ -z "$old" ] && [ -f "$file" ]; then old=$(cat "$file"); fi
    if grep -qE "$approved" <<<"$new" && ! grep -qE "$approved" <<<"$old"; then
      respond ask "This marks $rel as Approved. Approval is the user's sign-off, so confirm they have given it."
    fi
    exit 0
    ;;
  docs/*|.claude/*)
    exit 0
    ;;
esac

marker=""
for m in "$cwd"/docs/ai-sdlc/*/.current-task; do
  [ -f "$m" ] && { marker=$m; break; }
done
[ -n "$marker" ] || exit 0

task=$(sed -n 's/^task=//p' "$marker" | head -1)
locked=$(sed -n 's/^tests_locked=//p' "$marker" | head -1)

case "$rel" in
  test/*|tests/*|*/test/*|*/tests/*|*/__tests__/*|*.test.*|*.spec.*|*_test.*|test_*|*/test_*)
    if [ "$locked" = "true" ]; then
      respond deny "Tests are locked for $task (bug fix: the failing test is written, now fix the code). If the test is wrong, tell the user and set tests_locked=false in $(basename "$(dirname "$marker")")/.current-task."
    fi
    ;;
esac

plan="$(dirname "$marker")/04-plan.md"
if [ -n "$task" ] && [ -f "$plan" ]; then
  block=$(awk -v t="**$task:" '
    index($0, t) { p = 1; next }
    p && (/^- \[[ x]\] \*\*T-/ || /^##/) { p = 0 }
    p
  ' "$plan")
  if ! grep -qF -- "$rel" <<<"$block"; then
    respond ask "$rel is not listed under $task in $(basename "$plan"). If this edit is needed, update the task in the plan in the same step."
  fi
fi
exit 0
