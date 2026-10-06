#!/usr/bin/env bash
# Export each Mermaid block in a shape doc to a .mmd source and a .svg, named after the
# `## ` heading above it (components, sequence).
#
# Labels render as plain SVG text, not HTML: Confluence drops <foreignObject>, which
# leaves HTML labels blank.
#
# Usage: export-svg.sh <doc.md> [outdir]    (outdir defaults to <doc>-diagrams beside the doc)

set -euo pipefail

doc="${1:-}"
if [ -z "$doc" ] || [ ! -f "$doc" ]; then
    echo "usage: export-svg.sh <doc.md> [outdir]" >&2
    exit 2
fi

if ! command -v mmdc >/dev/null 2>&1; then
    echo "ERROR: mmdc not found; install with: npm install -g @mermaid-js/mermaid-cli" >&2
    exit 1
fi

config="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/mermaid-svg.json"
outdir="${2:-${doc%.md}-diagrams}"
mkdir -p "$outdir"

awk -v outdir="$outdir" '
    /^## / {
        slug = tolower(substr($0, 4))
        gsub(/[^a-z0-9]+/, "-", slug)
        gsub(/^-|-$/, "", slug)
    }
    /^[[:space:]]*```mermaid/ {
        name = (slug == "" ? "diagram" : slug)
        seen[name]++
        if (seen[name] > 1) name = name "-" seen[name]
        file = outdir "/" name ".mmd"
        printf "" > file
        inblock = 1
        next
    }
    inblock && /^[[:space:]]*```/ { close(file); print file; inblock = 0; next }
    inblock { print > file }
' "$doc" | while read -r mmd; do
    svg="${mmd%.mmd}.svg"
    mmdc -q -i "$mmd" -o "$svg" -c "$config" -b white
    echo "$svg"
done
