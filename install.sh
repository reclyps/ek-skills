#!/usr/bin/env bash
# Install the skills in this repo into every agent directory that reads them.
#
# Each skill is installed as a REAL directory whose files are symlinks back to the
# repo. Agent skill scanners list directory entries and filter on isDirectory(), which
# is false for a symlinked directory — so a symlinked skill folder is invisible to some
# harnesses (GitHub Copilot CLI, notably). A real directory passes that filter, and the
# file symlinks inside are followed by every reader.
#
# Because the files are links, editing a skill takes effect immediately. Re-run this
# only when a file is added, removed or renamed, or when a skill itself is.
#
# Usage: install.sh [--dry-run] [--no-prune]

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
marker=".ek-skills-managed"
dry=0
prune=1

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run)  dry=1; shift ;;
        --no-prune) prune=0; shift ;;
        -h|--help)  echo "usage: install.sh [--dry-run] [--no-prune]"; exit 0 ;;
        *)          echo "unknown option: $1" >&2; exit 2 ;;
    esac
done

targets=("$HOME/.claude/skills" "$HOME/.agents/skills")

say() { [ "$dry" -eq 1 ] && echo "would $*" || echo "$*"; }
run() { [ "$dry" -eq 1 ] || "$@"; }

# A directory in this repo is a skill if it holds a SKILL.md.
skills=()
for d in "$repo"/*/; do
    name="$(basename "$d")"
    case "$name" in _*|.*) continue ;; esac
    [ -f "$d/SKILL.md" ] && skills+=("$name")
done

if [ "${#skills[@]}" -eq 0 ]; then
    echo "no skills found in $repo" >&2
    exit 1
fi

# Only ever replace something this script owns: a directory carrying our marker, or a
# symlink pointing into this repo (the layout used before this script existed).
# Anything else — npx-installed skills, hand-made directories — is left alone.
ours() {
    local p="$1"
    [ -f "$p/$marker" ] && return 0
    if [ -L "$p" ]; then
        case "$(readlink "$p")" in
            "$repo"/*|*/dev/ek-skills/*) return 0 ;;
        esac
    fi
    return 1
}

installed=0
skipped=0
pruned=0

for target in "${targets[@]}"; do
    echo "== $target"
    run mkdir -p "$target"

    for name in "${skills[@]}"; do
        dest="$target/$name"

        if [ -e "$dest" ] || [ -L "$dest" ]; then
            if ! ours "$dest"; then
                echo "   skip $name — exists and is not managed by this script"
                skipped=$((skipped + 1))
                continue
            fi
            run rm -rf "$dest"
        fi

        say "install $name"
        run mkdir -p "$dest"
        run touch "$dest/$marker"

        # Mirror directories, symlink files. Absolute targets, so the links survive
        # wherever the agent directory itself lives.
        while IFS= read -r rel; do
            case "$rel" in .git/*|*/.DS_Store|.DS_Store) continue ;; esac
            src="$repo/$name/$rel"
            if [ -d "$src" ]; then
                run mkdir -p "$dest/$rel"
            else
                run mkdir -p "$(dirname "$dest/$rel")"
                run ln -sfn "$src" "$dest/$rel"
            fi
        done < <(cd "$repo/$name" && find . -mindepth 1 \( -name .git -prune \) -o -print | sed 's|^\./||')

        installed=$((installed + 1))
    done

    # Remove skills this script installed that no longer exist in the repo — renames
    # and deletions propagate without being remembered.
    if [ "$prune" -eq 1 ] && [ -d "$target" ]; then
        for dest in "$target"/*/; do
            [ -d "$dest" ] || continue
            name="$(basename "$dest")"
            [ -f "$dest/$marker" ] || continue
            found=0
            for s in "${skills[@]}"; do [ "$s" = "$name" ] && found=1; done
            if [ "$found" -eq 0 ]; then
                say "prune $name — no longer in the repo"
                run rm -rf "$dest"
                pruned=$((pruned + 1))
            fi
        done
    fi
done

echo
echo "${#skills[@]} skills × ${#targets[@]} targets: $installed installed, $pruned pruned, $skipped skipped"
[ "$dry" -eq 1 ] && echo "(dry run — nothing changed)"
exit 0
