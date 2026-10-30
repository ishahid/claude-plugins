#!/usr/bin/env bash
# Mechanical traceability check for one feature folder: trace.sh docs/ai-sdlc/<slug>
# Prints one "FAIL: ..." line per problem and exits 1, or prints "OK" and exits 0.
set -u

dir=${1:?usage: trace.sh <feature folder>}
fail=0
say() { echo "FAIL: $*"; fail=1; }
has() { grep -qE "(^|[^A-Za-z])$1([^0-9]|\$)" "$2"; }

for doc in 01-intent 02-specs 03-design 04-plan; do
  [ -f "$dir/$doc.md" ] || say "$doc.md is missing"
done
[ "$fail" = 0 ] || exit 1

for doc in 01-intent 02-specs 03-design 04-plan; do
  grep -qE 'Status:\*\*[[:space:]]*Approved' "$dir/$doc.md" || say "$doc.md is not Approved"
done

intent=$dir/01-intent.md specs=$dir/02-specs.md design=$dir/03-design.md plan=$dir/04-plan.md

goals=$(grep -E '^\| *G-[0-9]+' "$intent" | grep -oE 'G-[0-9]+' | sort -u)
reqs=$(grep -E '^### (NFR|FR)-[0-9]+' "$specs" | grep -oE '(NFR|FR)-[0-9]+' | sort -u)

for g in $goals; do
  has "$g" "$specs" || say "goal $g is not referenced in 02-specs.md"
done
for g in $(grep -oE 'G-[0-9]+' "$specs" | sort -u); do
  grep -qx "$g" <<<"$goals" || say "$g is referenced in 02-specs.md but not defined in 01-intent.md"
done

for r in $reqs; do
  has "$r" "$design" || say "$r is not referenced in 03-design.md"
  has "$r" "$plan" || say "$r is not referenced in 04-plan.md"
done
for doc in 03-design 04-plan; do
  for r in $(grep -oE '(NFR|FR)-[0-9]+' "$dir/$doc.md" | sort -u); do
    grep -qx "$r" <<<"$reqs" || say "$r is referenced in $doc.md but not defined in 02-specs.md"
  done
done

[ "$fail" = 0 ] && echo OK
exit "$fail"
