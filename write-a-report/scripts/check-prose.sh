#!/usr/bin/env bash
# Report prose checks. Signals, not errors: everything here can be a deliberate choice.
# Usage: check-prose.sh <file> [memo|reference]

set -u
f="${1:-}"
tier="${2:-reference}"

if [ -z "$f" ] || [ ! -f "$f" ]; then
    echo "usage: check-prose.sh <file> [memo|reference]" >&2
    exit 2
fi

words=$(wc -w < "$f" | tr -d ' ')
lines=$(wc -l < "$f" | tr -d ' ')

count() { grep -oih -- "$1" "$f" 2>/dev/null | wc -l | tr -d ' '; }

echo "== $f"
echo "words: $words   lines: $lines"

# Word count against tier
case "$tier" in
    memo)
        [ "$words" -gt 700 ] && echo "FLAG  word count $words: a memo over ~700 words has stopped being a memo"
        ;;
    *)
        echo "note: reference tier, no word target"
        ;;
esac

# Em-dash density
em=$(grep -o -- "—" "$f" | wc -l | tr -d ' ')
if [ "$words" -gt 0 ]; then
    per1k=$(( em * 1000 / words ))
    echo "em-dashes: $em  (${per1k} per 1000 words)"
    [ "$per1k" -gt 5 ] && echo "FLAG  em-dash density: prefer commas, colons, full stops"
fi

# Bolded paragraph openers
bold=$(grep -c '^\*\*' "$f" | tr -d ' ')
echo "bolded paragraph openers: $bold"
[ "$bold" -gt 8 ] && echo "FLAG  many bolded openers: use headings for structure instead"

# Banned phrases
echo "-- phrases"
hit=0
for p in "worth noting" "worth recording" "worth stating" "it is worth" "load-bearing" \
         "genuinely" "materially" "meaningfully" "that said" "note that" "in terms of" "our own"; do
    n=$(count "$p")
    if [ "$n" -gt 0 ]; then echo "FLAG  \"$p\" x$n"; hit=$((hit+1)); fi
done
[ "$hit" -eq 0 ] && echo "none"

# Positional references
echo "-- positional references"
pos=$(grep -nioE "the (middle|first|second|last|left|right) (column|table|row|section)|the section above|the table below" "$f" | head -5)
if [ -n "$pos" ]; then echo "$pos" | sed 's/^/FLAG  /'; else echo "none"; fi

# Internal paths (only matters when the destination is external)
echo "-- internal references"
int=$(grep -noE "local/[A-Za-z0-9._/-]+|audit-notes/[A-Za-z0-9._/-]+|\`[A-Za-z0-9._/-]+\.md\`" "$f" | head -5)
if [ -n "$int" ]; then
    echo "$int" | sed 's/^/FLAG  /'
    echo "      (ignore if this document stays in the repo)"
else
    echo "none"
fi

echo "-- done. Flags are signals; keep any that are deliberate."
