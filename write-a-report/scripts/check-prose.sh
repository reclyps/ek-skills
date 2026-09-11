#!/usr/bin/env bash
# Report prose checks.
#
# Flags default to FIX. A flag you keep is a decision to surface to the reader of your
# handover, named and with a reason — not one to make silently while drafting.
#
# Usage: check-prose.sh <file> [memo|reference]

set -u
f="${1:-}"
tier="${2:-reference}"

if [ -z "$f" ] || [ ! -f "$f" ]; then
    echo "usage: check-prose.sh <file> [memo|reference]" >&2
    exit 2
fi

flags=0
flag() { flags=$((flags+1)); echo "FLAG  $*"; }

# Prose-only view: drop fenced code, tables, headings, link targets. Pattern checks run
# against this so a code sample or a URL cannot trip a phrase rule.
prose=$(mktemp)
trap 'rm -f "$prose"' EXIT
awk '
    /^[[:space:]]*```/ { fence = !fence; next }
    fence { next }
    /^[[:space:]]*\|/ { next }
    /^[[:space:]]*#/  { next }
    { gsub(/\]\([^)]*\)/, "]"); print }
' "$f" > "$prose"

words=$(wc -w < "$f" | tr -d ' ')
pwords=$(wc -w < "$prose" | tr -d ' ')
lines=$(wc -l < "$f" | tr -d ' ')
[ "$pwords" -lt 1 ] && pwords=1

echo "== $f"
echo "words: $words   prose words: $pwords   lines: $lines"

# --- tier -------------------------------------------------------------------
case "$tier" in
    memo)
        mins=$(( (words + 219) / 220 ))
        echo "note: ~${mins} min read. The target is a single page a manager reads once and"
        echo "      comes away with the gist and the takeaway. It is not a word budget."
        echo "      Never cut or reword a sentence to move this number. If the memo runs long,"
        echo "      drop a section or move it to the reference document."
        [ "$words" -gt 1100 ] && flag "word count $words: past a single page — relocate a section, do not compress prose"
        ;;
    *)
        echo "note: reference tier, no length target"
        ;;
esac

# --- mechanical -------------------------------------------------------------
em=$(grep -o -- "—" "$prose" | wc -l | tr -d ' ')
per1k=$(( em * 1000 / pwords ))
echo "em-dashes: $em  (${per1k} per 1000 words)"
[ "$per1k" -gt 5 ] && flag "em-dash density: prefer commas, colons, full stops"

bold=$(grep -c '^\*\*' "$f" | tr -d ' ')
echo "bolded paragraph openers: $bold"
[ "$bold" -gt 8 ] && flag "many bolded openers: use headings for structure instead"

# --- lexical ----------------------------------------------------------------
# Patterns are regex, not literals: hyphen-or-space, inflections, contractions.
scan() {
    local label="$1" pat="$2"
    local n
    n=$(grep -oiE -- "$pat" "$prose" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$n" -gt 0 ]; then
        flag "$label x$n  — $(grep -oiE -- "$pat" "$prose" | sort -u | head -3 | tr '\n' '/' | sed 's:/$::')"
    fi
}

echo "-- filler"
before=$flags
scan "worth-noting"        "\bworth (not|record|stat|mention)ing\b"
scan "it is worth"         "\bit'?(s| is) worth\b"
scan "intensifier"         "\b(genuinely|materially|meaningfully|significantly|substantially)\b"
scan "filler transition"   "\b(that said|note that|of course|indeed|to be clear|as noted)\b"
scan "in terms of"         "\bin terms of\b"
scan "our own"             "\bour own\b"
scan "important to note"   "\bit'?(s| is) (important|worth) (to note|noting)\b"
scan "hedged verb"         "\b(may potentially|could arguably|it appears that|seems to suggest|somewhat|fairly|relatively)\b"
[ "$flags" -eq "$before" ] && echo "none"

echo "-- register (ops/appraisal voice)"
before=$flags
scan "landed/shipped"      "\b(landed|lands|shipped|ships|rolled out)\b"
scan "unlocks"            "\b(unlocks?|unlocked|unlocking)\b"
scan "surfaced"            "\b(surfaced|surfaces|surfacing)\b"
scan "wired up"            "\bwired (up|in|together)\b"
scan "is real"             "\b(is|are|was|were|feels?) real\b"
scan "the real X"          "\b(the|a) real (risk|problem|issue|cost|concern|question|answer|work)\b"
scan "load bearing"        "\bload[- ]bearing\b"
scan "buys you"            "\bbuys? (you|us|them)\b"
scan "earns its place"     "\bearns? (its|their) (place|keep)\b"
scan "carries weight"      "\bcarr(y|ies|ied) (weight|risk|the)\b"
scan "beats X"             "\b[a-z]+ beats [a-z]+\b"
scan "cheap/expensive to"  "\b(cheap|expensive|costly|free) to\b"
scan "non-trivial"         "\bnon-?trivial\b"
scan "first-class"         "\bfirst[- ]class\b"
scan "under the hood"      "\bunder the hood\b"
scan "surface area"        "\bsurface area\b"
scan "the ask/delta"       "\bthe (ask|delta|lift|shape of)\b"
scan "out of the box"      "\bout of the box\b"
scan "at a high level"     "\bat a high level\b"
scan "table stakes"        "\btable stakes\b"
scan "moving parts"        "\bmoving parts\b"
scan "blast radius"        "\bblast radius\b"
scan "happy path"          "\bhappy path\b"
scan "corporate verb"      "\b(leverage|leveraging|utilize|utilise|orchestrat|streamlin)[a-z]*\b"
scan "brochure adjective"  "\b(robust|seamless|comprehensive|holistic|granular|actionable|scalable)\b"
scan "essay register"      "\b(delve|underscore|underscores|pivotal|testament|landscape|realm|tapestry|navigat[a-z]+ the)\b"
scan "plays a key role"    "\bplays? (a )?(key|crucial|vital|pivotal|central) role\b"
[ "$flags" -eq "$before" ] && echo "none"

# --- syntactic --------------------------------------------------------------
# The structural tells. No word list reaches these.
echo "-- structure"
before=$flags

show() {
    local label="$1" pat="$2" limit="${3:-0}"
    local n
    n=$(grep -oiE -- "$pat" "$prose" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$n" -gt "$limit" ]; then
        flag "$label x$n"
        grep -oiE -- "$pat" "$prose" | sort -u | head -3 | sed 's/^/        /'
    fi
}

# "It isn't X; it's Y" / "Not X, but Y" / "X, not Y" — the correction cadence.
show "antithesis (isn't X, it's Y)" "\b(is|are|was|were)n'?t? ?(not)? [^.,;:]{2,45}[,;] (it'?s|they'?re|it is|but|rather)"
show "not X, but Y"                 "\bnot [^.,;:]{2,45}, but\b"
show ", not Y (corrective tail)"    "[a-z]{3,}, not [a-z][^.]{2,40}\." 2

# Adverb-comma openers.
show "adverb opener" "(^|\. )(Notably|Critically|Importantly|Crucially|Ultimately|Fundamentally|Realistically|Practically|In practice|In short|Put simply|Simply put|In other words|At bottom),"

# Colon-label sentence starts.
show "colon label" "(^|\. )(The upshot|The point|The catch|The result|The tradeoff|The answer|Bottom line|What this means|One caveat|The short version)[:—]"

# Triads.
tri=$(grep -oiE -- "[a-z]{3,}, [a-z][^,.]{2,30}, and [a-z]" "$prose" | wc -l | tr -d ' ')
tri1k=$(( tri * 1000 / pwords ))
echo "triads: $tri  (${tri1k} per 1000 words)"
[ "$tri1k" -gt 4 ] && flag "triad density: vary the count, use two when there are two"

# Repeated paragraph openers.
rep=$(awk 'BEGIN{prev=1} /^[[:space:]]*$/{prev=1;next} prev==1{gsub(/^[*_#> -]+/,""); print $1; prev=0}' "$prose" \
      | tr 'A-Z' 'a-z' | sed 's/[^a-z]//g' | grep -v '^$' | sort | uniq -c | sort -rn | head -1)
repn=$(echo "$rep" | awk '{print $1}')
repw=$(echo "$rep" | awk '{print $2}')
if [ -n "${repn:-}" ] && [ "${repn:-0}" -gt 3 ]; then
    flag "paragraph openers: \"$repw\" starts $repn paragraphs"
fi

# Sentence rhythm. Model prose clusters at 15-25 words with low variance; the giveaway
# is uniformity, plus the short punchline dropped after a long sentence.
awk '
    { buf = buf " " $0 }
    END {
        gsub(/\*\*/, "", buf); gsub(/[[:space:]]+/, " ", buf)
        n = split(buf, s, /[.!?]+ +/)
        c = 0; prevw = 0; punch = 0
        for (i = 1; i <= n; i++) {
            gsub(/^[ *_>-]+/, "", s[i])
            w = split(s[i], a, " ")
            if (w < 2) { prevw = 0; continue }
            c++; len[c] = w; sum += w
            if (w >= 12 && w <= 28) band++
            if (w <= 4 && prevw >= 18) punch++
            prevw = w
        }
        if (c < 6) { printf "sentences: %d (too few to judge rhythm)\n", c; exit }
        mean = sum / c
        for (i = 1; i <= c; i++) { d = len[i] - mean; ss += d * d }
        sd = sqrt(ss / c)
        pct = int(band * 100 / c)
        cv = (mean > 0) ? sd / mean : 0
        printf "sentences: %d   mean %.1f words   sd %.1f   variation %.2f   %d%% in the 12-28 band\n", c, mean, sd, cv, pct
        # Uniformity alone is fine in a terse memo. Uniform AND parked in the model house
        # style of 12-28 words is the cadence tell. Both must hold.
        if (cv < 0.45 && pct > 50)
            printf "FLAG  cadence: variation %.2f with %d%% of sentences in the 12-28 band — put a short one next to a long one\n", cv, pct
        else if (pct > 70)
            printf "FLAG  %d%% of sentences sit in the 12-28 word band: the cadence is the tell\n", pct
        if (punch > 1) printf "FLAG  punchline fragments x%d: short sentence dropped after a long one\n", punch
    }
' "$prose" > /tmp/.rhythm.$$ 2>/dev/null
cat /tmp/.rhythm.$$
flags=$(( flags + $(grep -c '^FLAG' /tmp/.rhythm.$$ | tr -d ' ') ))
rm -f /tmp/.rhythm.$$

[ "$flags" -eq "$before" ] && echo "(structure clean)"

# --- references -------------------------------------------------------------
echo "-- positional references"
pos=$(grep -nioE "the (middle|first|second|last|left|right) (column|table|row|section)|the section above|the table below" "$f" | head -5)
if [ -n "$pos" ]; then echo "$pos" | sed 's/^/FLAG  /'; flags=$((flags+1)); else echo "none"; fi

echo "-- internal references"
int=$(grep -noE "local/[A-Za-z0-9._/-]+|audit-notes/[A-Za-z0-9._/-]+|\`[A-Za-z0-9._/-]+\.md\`" "$f" | head -5)
if [ -n "$int" ]; then
    echo "$int" | sed 's/^/FLAG  /'
    echo "      (ignore if this document stays in the repo)"
    flags=$((flags+1))
else
    echo "none"
fi

# --- verdict ----------------------------------------------------------------
echo
if [ "$flags" -eq 0 ]; then
    echo "0 flags."
else
    [ "$flags" -eq 1 ] && n="1 flag" || n="$flags flags"
    echo "$n. The default is to fix. If you keep one, name it in the handover"
    echo "with the reason, so the user gets to overrule you."
fi
