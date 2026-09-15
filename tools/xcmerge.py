#!/usr/bin/env python3
"""Key-based three-way merge for Localizable.xcstrings during a rebase conflict.

    xcmerge.py BASE HEAD INCOMING OUT

BASE     = stage :1 (common ancestor)
HEAD     = stage :2 (the branch being rebased ONTO — upstream plus already-replayed commits)
INCOMING = stage :3 (the commit being replayed)

Result = HEAD's text verbatim, then:
  * every key INCOMING added or changed relative to BASE is set, copying INCOMING's exact text span;
  * every key INCOMING deleted relative to BASE is removed, but only if HEAD still holds BASE's value
    (a key upstream also changed is left alone and reported).
Formatting is never regenerated: spans are located by a small JSON tokenizer, so the catalog's
mix of compact and expanded entry styles, and its known duplicate key, are handled.
"""
import json, sys


def entry_spans(text):
    """Return [(key, start, end)] for every direct child of the top-level "strings" object.
    start..end covers the key, its value and one trailing comma (if present), plus the line's
    leading indentation, so removing the span removes the entry cleanly."""
    i, n = 0, len(text)
    depth = 0
    in_strings = False
    strings_depth = None
    spans = []

    def read_string(j):
        assert text[j] == '"'
        j += 1
        while True:
            c = text[j]
            if c == '\\':
                j += 2
                continue
            if c == '"':
                return j + 1
            j += 1

    def skip_ws(j):
        while j < n and text[j] in ' \t\r\n':
            j += 1
        return j

    def skip_value(j):
        j = skip_ws(j)
        c = text[j]
        if c == '"':
            return read_string(j)
        if c in '{[':
            d = 0
            while True:
                c = text[j]
                if c == '"':
                    j = read_string(j)
                    continue
                if c in '{[':
                    d += 1
                elif c in '}]':
                    d -= 1
                    if d == 0:
                        return j + 1
                j += 1
        while j < n and text[j] not in ',}]':
            j += 1
        return j

    # find the "strings" key at depth 1
    while i < n:
        c = text[i]
        if c == '"':
            end = read_string(i)
            key = json.loads(text[i:end])
            if depth == 1 and key == 'strings':
                j = skip_ws(end)
                assert text[j] == ':'
                j = skip_ws(j + 1)
                assert text[j] == '{'
                i = j + 1
                strings_depth = True
                break
            i = end
            continue
        if c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
        i += 1
    assert strings_depth, 'no "strings" object'

    # iterate children of the strings object
    while True:
        i = skip_ws(i)
        if text[i] == '}':
            break
        if text[i] == ',':
            i += 1
            continue
        line_start = text.rfind('\n', 0, i) + 1
        kend = read_string(i)
        key = json.loads(text[i:kend])
        j = skip_ws(kend)
        assert text[j] == ':'
        vend = skip_value(j + 1)
        k = skip_ws(vend)
        if text[k] == ',':
            vend = k + 1
        # include the rest of the line (newline) so removal leaves no blank line
        nl = text.find('\n', vend)
        stop = nl + 1 if nl != -1 and text[vend:nl].strip() == '' else vend
        spans.append((key, line_start, stop))
        i = vend
    return spans


def last_span(spans, key):
    hits = [s for s in spans if s[0] == key]
    return hits[-1] if hits else None


def main(base_p, head_p, inc_p, out_p):
    base_t, head_t, inc_t = (open(p, encoding='utf-8').read() for p in (base_p, head_p, inc_p))
    base, head, inc = (json.loads(t)['strings'] for t in (base_t, head_t, inc_t))

    added_or_changed = [k for k in inc if k not in base or inc[k] != base[k]]
    deleted = [k for k in base if k not in inc]

    out = head_t
    report = []
    # deletions first
    for k in deleted:
        if k not in head:
            continue
        if head[k] != base[k]:
            report.append(f'KEPT (upstream changed it too): {k!r}')
            continue
        sp = last_span(entry_spans(out), k)
        out = out[:sp[1]] + out[sp[2]:]
        report.append(f'removed: {k!r}')

    inc_spans = entry_spans(inc_t)
    for k in added_or_changed:
        if k in head and head[k] == inc[k]:
            continue
        src = last_span(inc_spans, k)
        chunk = inc_t[src[1]:src[2]]
        if not chunk.rstrip().endswith(','):
            chunk = chunk.rstrip('\n').rstrip() + ',\n'
        if k in head:
            sp = last_span(entry_spans(out), k)
            out = out[:sp[1]] + chunk + out[sp[2]:]
            report.append(f'replaced: {k!r}')
        else:
            anchor = out.index('"strings"')
            brace = out.index('{', anchor)
            nl = out.index('\n', brace) + 1
            out = out[:nl] + chunk + out[nl:]
            report.append(f'added: {k!r}')

    merged = json.loads(out)['strings']
    expect = dict(head)
    for k in deleted:
        if k in expect and head[k] == base[k]:
            del expect[k]
    for k in added_or_changed:
        expect[k] = inc[k]
    assert merged == expect, 'merged catalog does not match the expected key set'
    open(out_p, 'w', encoding='utf-8').write(out)
    print(f'xcmerge ok: {len(merged)} keys; ' + '; '.join(report[:12]) +
          (f' … (+{len(report)-12} more)' if len(report) > 12 else ''))


if __name__ == '__main__':
    main(*sys.argv[1:5])
