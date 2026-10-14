Default: open a file and its entry point comes first; the happy path reads as named steps, plumbing out of the way.

Worth doing:
- **Steps at one level**: entry point is a short sequence of calls named for what each produces or decides. Detail lives one level down.
- **Entry point first**: callers above callees; constants, config, helpers don't precede it. Where language or lint forces define-before-use, move helpers to another module rather than bury the entry point.
- **Plumbing in its own module**: escaping, transport, retries, serialization, platform glue behind a small interface. Split by what the code hides, not by size.
- **Step helpers stay close**: a helper serving one entry point lives in its file, below it.
- **Dispatch, don't interleave**: several cases → one named function per case; the entry point only picks.
- **Pull handling down**: a step resolves the failures it can itself; the caller sees only what it must decide on.

Never:
- Extract a fragment whose name restates its body, or whose signature is as heavy as its body.
- Split code that must be read together to be understood.
- Fight local idiom or lint on layout. Reach the goal by where code lives.

Test: reading only the entry point, could a newcomer say what it does, in order, without opening a helper?
