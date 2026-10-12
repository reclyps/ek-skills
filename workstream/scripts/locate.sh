#!/usr/bin/env bash
# Print the absolute workstreams directory, or a named workstream inside it.
#
# Usage: locate.sh [--root <dir>] [name]
#
# Base is the main checkout root, so every worktree of a repo resolves to the same
# place; outside git it is the current directory. A relative --root resolves against
# that base. Default root is .workstreams. Prints the path; creates nothing.

set -euo pipefail

root=".workstreams"
name=""

while [ $# -gt 0 ]; do
    case "$1" in
        --root) root="${2:?--root needs a directory}"; shift 2 ;;
        -h|--help) echo "usage: locate.sh [--root <dir>] [name]"; exit 0 ;;
        -*) echo "ERROR: unknown option: $1" >&2; exit 2 ;;
        *) name="$1"; shift ;;
    esac
done

base="$PWD"
if common="$(git rev-parse --git-common-dir 2>/dev/null)"; then
    common="$(cd "$common" && pwd)"
    if [ "$(basename "$common")" = ".git" ]; then
        base="$(dirname "$common")"
    else
        # Bare repository with linked worktrees: no main checkout to anchor to.
        base="$(git rev-parse --show-toplevel)"
    fi
fi

case "$root" in
    /*) dir="$root" ;;
    "~"|"~/"*) dir="$HOME${root#\~}" ;;
    *) dir="$base/$root" ;;
esac

if [ -n "$name" ]; then
    dir="$dir/$name"
fi

echo "$dir"
