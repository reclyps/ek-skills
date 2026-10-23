#!/usr/bin/env bash
# Validate a workstream STATE.md against the mechanical rules in SKILL.md.
#
# Usage: check.sh <path-to-STATE.md>
# Exits 0 when valid; otherwise prints one ERROR line per problem and exits 1.

set -euo pipefail

max_lines=150
required=("Goal" "State" "Blockers" "Next actions" "Decisions" "Gotchas" "Live checks" "References")

file="${1:?usage: check.sh <path-to-STATE.md>}"
[ -f "$file" ] || { echo "ERROR: no such file: $file" >&2; exit 2; }

errors=0
fail() { echo "ERROR: $*"; errors=$((errors + 1)); }

lines="$(wc -l < "$file" | tr -d '[:space:]')"
[ "$lines" -le "$max_lines" ] || fail "$lines lines, cap is $max_lines; move detail to plans/ or research/ and link it"

grep -Eq '^Updated: [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*$' "$file" || fail "missing or malformed 'Updated: YYYY-MM-DD' line"
grep -Eq '^Status: (active|blocked|done)[[:space:]]*$' "$file" || fail "missing 'Status:' line, or value is not active, blocked or done"

for h in "${required[@]}"; do
    grep -Fxq "## $h" "$file" || fail "missing section heading: ## $h"
done

# History belongs in LOG.md; a dated session heading means it is accumulating in STATE.
if grep -Eiq '^#{2,4} .*(session|[0-9]{4}-[0-9]{2}-[0-9]{2})' "$file"; then
    fail "dated or per-session heading found; session history goes in LOG.md"
fi

untiered="$(awk '
    /^## / { in_next = ($0 == "## Next actions"); next }
    /<!--/ { in_comment = 1 }
    in_comment { if (/-->/) in_comment = 0; next }
    in_next && /^[0-9]+\. / && !/(deep|standard|light) \/ (high|medium|low)/ { print }
' "$file")"
if [ -n "$untiered" ]; then
    while IFS= read -r action; do
        fail "next action lacks '<deep|standard|light> / <high|medium|low>': $action"
    done <<< "$untiered"
fi

if [ "$errors" -gt 0 ]; then
    exit 1
fi
echo "OK: $file ($lines lines)"
