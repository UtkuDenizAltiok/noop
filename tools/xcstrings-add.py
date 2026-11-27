#!/usr/bin/env python3
"""Add, reword or drop fork strings in Localizable.xcstrings without reformatting the 6 MB catalogue.

    python3.12 dist/tools/xcstrings-add.py <Localizable.xcstrings> <spec.json> [--dry-run]

spec.json (every part optional):
    {
      "add":     { "English key": {"de": "…", "es": "…", "fr": "…", "it": "…", "pl": "…",
                                   "pt-PT": "…", "ru": "…", "zh-Hans": "…", "zh-Hant": "…"} },
      "replace": [ {"old": "old English key", "new": "new English key", "values": { …nine locales… }} ],
      "remove":  [ "English key nothing reads any more" ]
    }

What it does, and refuses to do:
  * "add" inserts each key as ONE line right after `"strings": {` (the fork's own entries live there), with
    the English value equal to the key.
  * "replace" rewrites an entry on the line where the old key stands; "remove" deletes that line. Both work
    only on one-line entries (the fork's). An upstream entry spread over several lines is refused: edit it by
    hand or leave it.
  * Every translation must cover all nine locales, must not be the English text again (the i18n gate counts an
    echo as missing), and must carry the same placeholders as the key (%@, %lld, %d, %.1f …; positional forms
    such as %2$@ are counted too, for languages that reorder).
  * The result must parse as JSON and hold exactly the expected number of keys, or nothing is written.
After a run: Tools/i18n_audit.py --ci upstream/main, then build (a key used through a variable, like a section
heading passed to LocalizedStringKey, is not extracted by the compiler and exists only because it is here).
First used for Simple mode v6 step 1 (16 Nov 2026).
"""
import json
import re
import sys

LOCALES = ["de", "es", "fr", "it", "pl", "pt-PT", "ru", "zh-Hans", "zh-Hant"]
SPEC = re.compile(r"%(?:(\d+)\$)?([-+0 #]*\d*(?:\.\d+)?(?:lld|ld|d|@|f|s))")


def placeholders(text):
    """The conversion kinds in a string, sorted, ignoring position markers and literal %%."""
    return sorted(m.group(2) for m in SPEC.finditer(text.replace("%%", "")))


def check(key, values):
    missing = [loc for loc in LOCALES if loc not in values]
    extra = [loc for loc in values if loc not in LOCALES]
    if missing or extra:
        sys.exit(f"{key!r}: locales missing {missing} unexpected {extra}")
    for loc, value in values.items():
        if value == key:
            sys.exit(f"{key!r}: the {loc} text is the English text again")
        if placeholders(value) != placeholders(key):
            sys.exit(f"{key!r}: {loc} has placeholders {placeholders(value)}, the key has {placeholders(key)}")


def entry(key, values):
    locs = {"en": {"stringUnit": {"state": "translated", "value": key}}}
    for loc in LOCALES:
        locs[loc] = {"stringUnit": {"state": "translated", "value": values[loc]}}
    return ("    " + json.dumps(key, ensure_ascii=False) + ": "
            + json.dumps({"localizations": locs}, ensure_ascii=False) + ",")


def main():
    args = [a for a in sys.argv[1:] if a != "--dry-run"]
    dry = "--dry-run" in sys.argv[1:]
    if len(args) != 2:
        sys.exit(__doc__)
    path, spec_path = args
    spec = json.load(open(spec_path, encoding="utf-8"))
    text = open(path, encoding="utf-8").read()
    catalog = json.loads(text)["strings"]
    lines = text.split("\n")
    if lines[2].strip() != '"strings": {':
        sys.exit("line 3 is not '\"strings\": {': the catalogue's layout changed, read it before editing")

    def one_line(key):
        prefix = "    " + json.dumps(key, ensure_ascii=False) + ": "
        hits = [i for i, line in enumerate(lines) if line.startswith(prefix)]
        if len(hits) != 1 or not lines[hits[0]].rstrip().endswith("},"):
            sys.exit(f"{key!r}: not a one-line entry ({len(hits)} match); edit it by hand")
        return hits[0]

    expected = len(catalog)
    for item in spec.get("replace", []):
        old, new, values = item["old"], item["new"], item["values"]
        if old not in catalog:
            sys.exit(f"replace: {old!r} is not in the catalogue")
        if new in catalog and new != old:
            sys.exit(f"replace: {new!r} is already in the catalogue")
        check(new, values)
        lines[one_line(old)] = entry(new, values)
    for key in spec.get("remove", []):
        if key not in catalog:
            sys.exit(f"remove: {key!r} is not in the catalogue")
        del lines[one_line(key)]
        expected -= 1
    added = []
    for key, values in spec.get("add", {}).items():
        if key in catalog:
            sys.exit(f"add: {key!r} is already in the catalogue (reuse it)")
        check(key, values)
        added.append(entry(key, values))
        expected += 1
    lines[3:3] = added

    out = "\n".join(lines)
    after = json.loads(out)["strings"]
    if len(after) != expected:
        sys.exit(f"expected {expected} keys, got {len(after)}: nothing written")
    print(f"{'would write' if dry else 'wrote'}: +{len(added)} added, {len(spec.get('replace', []))} replaced, "
          f"{len(spec.get('remove', []))} removed; {len(catalog)} -> {len(after)} keys")
    if not dry:
        open(path, "w", encoding="utf-8").write(out)


if __name__ == "__main__":
    main()
