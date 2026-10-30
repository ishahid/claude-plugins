#!/usr/bin/env bash
# Regression checks for the plugin itself. Run from anywhere: ai-sdlc/evals/run.sh
# Needs bash and jq. Exits 1 if any check fails.
set -u

plugin=$(cd "$(dirname "$0")/.." && pwd)
repo=$(dirname "$plugin")
failures=0
pass() { echo "ok   $*"; }
fail() { echo "FAIL $*"; failures=$((failures + 1)); }

# Manifests agree on name and version.
pv=$(jq -r .version "$plugin/.claude-plugin/plugin.json")
mv=$(jq -r '.plugins[] | select(.name == "ai-sdlc") | .version' "$repo/.claude-plugin/marketplace.json")
[ "$pv" = "$mv" ] && pass "manifest versions match ($pv)" || fail "plugin.json is $pv but marketplace.json is $mv"
grep -q "^## $pv\$" "$plugin/CHANGELOG.md" && pass "CHANGELOG has $pv" || fail "CHANGELOG.md has no entry for $pv"

# Every skill and agent has valid frontmatter, and skill names match their folders.
for f in "$plugin"/skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$f")")
  name=$(sed -n 's/^name: //p' "$f" | head -1)
  desc=$(sed -n 's/^description: //p' "$f" | head -1)
  [ "$name" = "$dir" ] && [ -n "$desc" ] && pass "skill $dir" || fail "skill $dir: name or description is wrong"
done
for f in "$plugin"/agents/*.md; do
  base=$(basename "$f" .md)
  name=$(sed -n 's/^name: //p' "$f" | head -1)
  desc=$(sed -n 's/^description: //p' "$f" | head -1)
  tools=$(sed -n 's/^tools: //p' "$f" | head -1)
  if [ "$name" = "$base" ] && [ -n "$desc" ] && [ -n "$tools" ]; then pass "agent $base"; else fail "agent $base: name, description, or tools is wrong"; fi
  if grep -qE '^tools:.*(Edit|Write|NotebookEdit)' "$f"; then fail "agent $base must be read-only"; fi
done

# trace.sh passes the good fixture and catches each broken one.
for d in "$plugin"/evals/fixtures/*/; do
  name=$(basename "$d")
  out=$("$plugin/scripts/trace.sh" "$d" 2>&1); code=$?
  if [ -f "$d/expect.txt" ]; then
    if [ "$code" = 1 ] && grep -qF -- "$(cat "$d/expect.txt")" <<<"$out"; then pass "trace catches $name"; else fail "trace on $name: expected '$(cat "$d/expect.txt")', got: $out"; fi
  else
    [ "$code" = 0 ] && pass "trace accepts $name" || fail "trace on $name: $out"
  fi
done

# guard.sh behaviour.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/docs/ai-sdlc/f" "$tmp/src"
cat > "$tmp/docs/ai-sdlc/f/04-plan.md" <<'EOF'
- [ ] **T-1: Do it**
  - **Files:** `src/a.py`, `tests/test_a.py`
EOF
printf 'task=T-1\nmode=feature\ntests_locked=false\n' > "$tmp/docs/ai-sdlc/f/.current-task"

guard() { # option-value tool-input-json -> decision
  jq -n --arg cwd "$tmp" --argjson ti "$2" '{cwd: $cwd, tool_input: $ti}' |
    CLAUDE_PLUGIN_OPTION_GUARDRAILS=$1 "$plugin/hooks/guard.sh" |
    jq -r '.hookSpecificOutput.permissionDecision' | grep . || echo allow
}
expect() { [ "$3" = "$2" ] && pass "guard: $1" || fail "guard: $1 (expected $2, got $3)"; }

expect "off by default" allow "$(guard false "{\"file_path\":\"$tmp/src/other.py\",\"content\":\"x\"}")"
expect "allows a listed file" allow "$(guard true "{\"file_path\":\"$tmp/src/a.py\",\"content\":\"x\"}")"
expect "asks about an unlisted file" ask "$(guard true "{\"file_path\":\"$tmp/src/other.py\",\"content\":\"x\"}")"
expect "asks before Approved" ask "$(guard true "{\"file_path\":\"$tmp/docs/ai-sdlc/f/02-specs.md\",\"old_string\":\"Status:** Draft\",\"new_string\":\"Status:** Approved\"}")"
expect "allows other doc edits" allow "$(guard true "{\"file_path\":\"$tmp/docs/ai-sdlc/f/02-specs.md\",\"old_string\":\"a\",\"new_string\":\"b\"}")"
printf 'task=T-1\nmode=bugfix\ntests_locked=true\n' > "$tmp/docs/ai-sdlc/f/.current-task"
expect "denies test edits when locked" deny "$(guard true "{\"file_path\":\"$tmp/tests/test_a.py\",\"content\":\"x\"}")"
expect "allows code edits when locked" allow "$(guard true "{\"file_path\":\"$tmp/src/a.py\",\"content\":\"x\"}")"

echo
[ "$failures" = 0 ] && echo "all checks passed" || echo "$failures check(s) failed"
exit "$((failures > 0))"
