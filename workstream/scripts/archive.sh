#!/usr/bin/env bash
# Move a finished workstream (or any working folder) into the archive and index it.
#
# Usage: archive.sh [--root <dir>] [--project <name>] [--month YYYY-MM] <source-dir> <name> <summary>
#
# Root is --root, else $WORKSTREAM_ARCHIVE_ROOT; there is no default, so with neither
# it exits 2. Project defaults to the main checkout's folder name, so every worktree
# files under the same project; outside git it is the current directory's name.
# Month defaults to the current month. Destination: <root>/<project>/<month>-<name>/.
# Appends one line to <root>/<project>/INDEX.md. Refuses to overwrite.

set -euo pipefail

root="${WORKSTREAM_ARCHIVE_ROOT:-}"
project=""
month="$(date +%Y-%m)"

while [ $# -gt 0 ]; do
    case "$1" in
        --root) root="${2:?--root needs a directory}"; shift 2 ;;
        --project) project="${2:?--project needs a name}"; shift 2 ;;
        --month) month="${2:?--month needs YYYY-MM}"; shift 2 ;;
        -h|--help) echo "usage: archive.sh [--root <dir>] [--project <name>] [--month YYYY-MM] <source-dir> <name> <summary>"; exit 0 ;;
        -*) echo "ERROR: unknown option: $1" >&2; exit 2 ;;
        *) break ;;
    esac
done

[ $# -eq 3 ] || { echo "ERROR: need <source-dir> <name> <summary>" >&2; exit 2; }
src="$1"; name="$2"; summary="$3"

[ -n "$root" ] || { echo "ERROR: no archive root; set WORKSTREAM_ARCHIVE_ROOT or pass --root" >&2; exit 2; }
[ -d "$src" ] || { echo "ERROR: no such directory: $src" >&2; exit 2; }
[[ "$month" =~ ^[0-9]{4}-[0-9]{2}$ ]] || { echo "ERROR: --month must be YYYY-MM" >&2; exit 2; }

case "$root" in
    "~"|"~/"*) root="$HOME${root#\~}" ;;
esac

if [ -z "$project" ]; then
    project="$(basename "$PWD")"
    if common="$(git rev-parse --git-common-dir 2>/dev/null)"; then
        common="$(cd "$common" && pwd)"
        if [ "$(basename "$common")" = ".git" ]; then
            project="$(basename "$(dirname "$common")")"
        else
            project="$(basename "$common" .git)"
        fi
    fi
fi

dest="$root/$project/$month-$name"
[ ! -e "$dest" ] || { echo "ERROR: already archived: $dest" >&2; exit 1; }

mkdir -p "$root/$project"
mv "$src" "$dest"

index="$root/$project/INDEX.md"
[ -f "$index" ] || printf '# %s archive\n\n' "$project" > "$index"
printf -- '- [%s](%s/): %s\n' "$month-$name" "$month-$name" "$summary" >> "$index"

echo "$dest"
