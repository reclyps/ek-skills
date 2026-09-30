#!/usr/bin/env python3
"""List every comment block a branch adds, with its file and new-file line range.

Usage: extract-comments.py BASE [PATH ...]

Diffs BASE...HEAD (only what the branch introduced) and prints one block per run of
consecutive added comment lines:

    ### S src/foo.ts:12-14      S = source, T = test
       /** The comment text,
       * as written. */

Line-based heuristics, not a parser: a trailing `code // note` counts, but a comment
marker inside a string can too. Exits 2 if git fails.
"""

import re
import subprocess
import sys
from pathlib import PurePosixPath

SLASH = {'.ts', '.tsx', '.js', '.jsx', '.mjs', '.cjs', '.java', '.kt', '.go', '.c', '.cc',
         '.cpp', '.h', '.cs', '.swift', '.rs', '.css', '.scss'}
HASH = {'.py', '.sh', '.bash', '.zsh', '.rb', '.yml', '.yaml', '.toml'}
DASH = {'.sql'}

# Whitespace before the marker keeps `https://` and `a--b` out.
TRAILING = {
    'slash': re.compile(r'\s//\s|\s/\*'),
    'hash': re.compile(r'\s#\s'),
    'dash': re.compile(r'\s--\s|\s/\*'),
}


def style_of(path):
    ext = PurePosixPath(path).suffix.lower()
    if ext in SLASH:
        return 'slash'
    if ext in HASH:
        return 'hash'
    if ext in DASH:
        return 'dash'
    return None


def is_test(path):
    parts = PurePosixPath(path).parts
    name = parts[-1]
    return 'tests' in parts or 'test' in parts or '.spec.' in name or '.test.' in name


def starts_comment(style, text):
    if style == 'hash':
        return text.startswith('#') and not text.startswith('#!')
    if text.startswith('/*') or text.startswith('{/*') or text.startswith('*'):
        return style in ('slash', 'dash')
    if style == 'slash':
        return text.startswith('//')
    return text.startswith('--')


def opens_block(style, text):
    return style in ('slash', 'dash') and ('/*' in text) and '*/' not in text.split('/*', 1)[1]


def extract(diff_text):
    blocks, current = [], None
    path, style, line_no, in_block = None, None, 0, False

    def flush():
        nonlocal current
        if current:
            blocks.append(current)
            current = None

    for raw in diff_text.splitlines():
        if raw.startswith('+++ '):
            flush()
            target = raw[4:]
            path = None if target == '/dev/null' else target[2:]
            style = style_of(path) if path else None
            in_block = False
            continue
        if raw.startswith('@@'):
            flush()
            line_no = int(re.search(r'\+(\d+)', raw).group(1))
            in_block = False
            continue
        if not raw.startswith('+') or raw.startswith('+++') or style is None:
            if not raw.startswith('-'):
                flush()
            continue

        line = raw[1:]
        text = line.strip()
        is_comment = in_block or starts_comment(style, text) or bool(TRAILING[style].search(line))
        if in_block and '*/' in text:
            in_block = False
        elif opens_block(style, text):
            in_block = True

        if is_comment and text:
            if current and current['path'] == path and current['end'] == line_no - 1:
                current['end'] = line_no
                current['lines'].append(text)
            else:
                flush()
                current = {'path': path, 'start': line_no, 'end': line_no, 'lines': [text]}
        else:
            flush()
        line_no += 1
    flush()
    return blocks


def main(argv):
    if len(argv) < 2 or argv[1] in ('-h', '--help'):
        print(__doc__.strip(), file=sys.stderr)
        return 0 if len(argv) >= 2 else 2
    base, paths = argv[1], argv[2:]
    cmd = ['git', 'diff', '-U0', '--no-color', '--no-ext-diff', f'{base}...HEAD', '--', *paths]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f'ERROR: {" ".join(cmd)}\n{result.stderr.strip()}', file=sys.stderr)
        return 2

    blocks = extract(result.stdout)
    for block in blocks:
        kind = 'T' if is_test(block['path']) else 'S'
        span = f"{block['start']}" if block['start'] == block['end'] else f"{block['start']}-{block['end']}"
        print(f"### {kind} {block['path']}:{span}")
        for text in block['lines']:
            print(f'   {text}')
    source = sum(1 for b in blocks if not is_test(b['path']))
    print(f'{len(blocks)} blocks ({source} source, {len(blocks) - source} test)', file=sys.stderr)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
