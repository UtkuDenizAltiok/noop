#!/usr/bin/env python3
"""Read an exported NOOP strap log (More → Test Centre → Strap log → Save…) the way the Lift Log needs it.

    python3 dist/tools/strap-log.py <log.txt>          both reports
    python3 dist/tools/strap-log.py <log.txt> runs     which app runs the file holds, and what fills them
    python3 dist/tools/strap-log.py <log.txt> taps     every double-tap in the newest run: sensed, acted on, buzzed

Standard library only; any Python 3.9+. Read-only. Times print in this computer's time zone; for a log from
another zone run it as `TZ=Europe/Berlin python3 …` (the strap log's own clock lines are the phone's local time).

How the file is built (Strand/BLE/LiveState.swift): each app PROCESS keeps its newest 5,000 entries (+256 slack)
in memory; the export prints the saved tails of up to three earlier processes ("previous app session" headers,
each capped at 1,000 lines and only as current as its last 32-line save), then the running process
("current app session"). A process's first line is "Central state: …", so a run that starts without it lost its
beginning to the cap. A header's "rolled at <UTC>" is when the NEXT process started, not when its lines ended.

The strap narrates itself in CONSOLE_LOGS frames ("strap: " lines, split at arbitrary points), each record
stamped with the strap's millisecond tick: "NN, <tick>: SENSORS: IMU double tap detected". That tick is anchored
to wall time through the `strap time` the app prints for the same double-taps.
"""
import collections
import datetime as dt
import re
import sys

KNOCK_WINDOW_S = 8   # LiftSessionController.strapKnockWindowSec
CLOCK = re.compile(r"^\[(\d\d:\d\d:\d\d)\] ")


def split_runs(lines):
    """[(header, first_index, lines)] — the earlier-run tails, then the current run."""
    runs, header, start = [], None, 0
    for i, line in enumerate(lines):
        if line.startswith("===== "):
            if header is not None:
                runs.append((header, start, lines[start:i]))
            header, start = line.strip("= ").strip(), i + 1
    if header is not None:
        runs.append((header, start, lines[start:]))
    return runs


def entries(run_lines):
    """One entry per logged line: a console piece's continuation lines belong to the entry before them."""
    return [l for l in run_lines if l and not l.startswith(" ")]


def category(entry):
    body = CLOCK.sub("", entry)
    rules = [
        ("heart rate received (one a second)", lambda b: b.startswith("standard-hr transport host-received")),
        ("heart rate saved", lambda b: b.startswith("standard-hr transport")),
        ("strap console pieces", lambda b: b.startswith("strap: ")),
        ("sync with the strap", lambda b: b.startswith("Backfill") or "Historical Data" in b),
        ("scoring pass", lambda b: b.startswith(("re-score", "analyzeRecent", "sleep ", "rhr ", "resp ", "hrv",
                                                 "effort ", "workout detect", "Dedup"))),
        ("Lift Log / double-tap lines", lambda b: "Double-tap" in b or "Lift Log" in b),
        ("buzz commands", lambda b: "Run Haptics" in b or "RUN_HAPTIC" in b),
    ]
    return next((name for name, test in rules if test(body)), "other")


def report_runs(lines):
    print("APP RUNS IN THIS FILE")
    previous_last = None
    for header, first, run_lines in split_runs(lines):
        clocks = [m.group(1) for l in run_lines for m in [CLOCK.match(l)] if m]
        es = entries(run_lines)
        starts_in_file = any("Central state:" in l for l in run_lines[:5])
        print(f"\n- {header}")
        print(f"  lines {first + 1}-{first + len(run_lines)} · {len(es)} entries · "
              f"clock {clocks[0] if clocks else '?'} → {clocks[-1] if clocks else '?'}")
        print("  its start IS in the file" if starts_in_file
              else "  its start is NOT in the file (the head was dropped: cap, or a 1,000-line tail)")
        if previous_last and clocks:
            print(f"  nothing in the file between {previous_last} and {clocks[0]}")
        top = collections.Counter(category(e) for e in es).most_common(4)
        print("  mostly: " + " · ".join(f"{n} {name}" for name, n in top))
        rolled = re.search(r"rolled at (\S+Z)", header)
        if rolled:
            started = dt.datetime.strptime(rolled.group(1), "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=dt.timezone.utc)
            print(f"  the next app run started at {started.astimezone().strftime('%H:%M:%S')} (local)")
        previous_last = clocks[-1] if clocks else previous_last


def console_records(run_lines):
    """(tick_ms, message) from the reassembled strap console text, de-duplicated, in tick order."""
    pieces, inside = [], False
    for line in run_lines:
        if line.startswith("strap: "):
            pieces.append(line[7:]); inside = True
        elif inside and (line.startswith(" ") or line == ""):
            pieces.append("\n" + line)
        else:
            inside = False
    text = "".join(pieces)
    found = re.finditer(r"\d{1,3}, (\d{6,10}): (.*?)(?=\n| \d{1,3}, \d{6,10}: |$)", text)
    return sorted({(int(m.group(1)), m.group(2).strip()) for m in found})


def report_taps(lines):
    header, first, run = split_runs(lines)[-1]
    print(f"\nDOUBLE-TAPS IN THE NEWEST RUN ({header}, from line {first + 1})")
    records = console_records(run)
    sensed = [t for t, m in records if "IMU double tap detected" in m]
    buzzes = [t for t, m in records if "Command Run haptics" in m]
    syncs = [t for t, m in records if "Command Send Historical Data" in m]
    strap_times = sorted({int(x) for l in run for x in re.findall(r"strap time (\d+)", l)})
    app = collections.Counter()
    for l in run:
        body = CLOCK.sub("", l)
        if body.startswith("Double-tap → "): app["handed to the app (Double-tap → …)"] += 1
        elif "not acted on" in body and "Lift Log" in body: app["held back as a knock (Lift Log)"] += 1
        elif "Double-tap ignored" in body: app["ignored by the 1.2 s debounce"] += 1
        elif "already handled" in body: app["replay suppressed (already handled)"] += 1
        elif "late during a sync" in body: app["arrived late through a sync, not acted on"] += 1
    print(f"  strap sensed {len(sensed)} double-taps (its own console)")
    for name, n in app.most_common():
        print(f"  {n:3d}  {name}")
    if not sensed:
        return
    # Anchor the strap's ms tick to unix time: the most common whole-second offset between a sensed tap
    # and a `strap time` the app printed.
    offsets = collections.Counter(round(t - s / 1000) for t in strap_times for s in sensed)
    offset = offsets.most_common(1)[0][0] if offsets else None
    zone = dt.datetime.now().astimezone().tzinfo
    print("\n  sensed at   tap→buzz  note" + ("" if offset is not None else "   (no strap time to anchor clock)"))
    previous = None
    for s in sensed:
        buzz = next((b for b in buzzes if b >= s), None)
        sync_first = buzz is not None and any(s <= x <= buzz for x in syncs)
        when = (dt.datetime.fromtimestamp(offset + s / 1000, zone).strftime("%H:%M:%S")
                if offset is not None else f"tick {s}")
        delay = f"{(buzz - s) / 1000:5.2f} s" if buzz is not None else "   none"
        notes = []
        if sync_first: notes.append("a sync request reached the strap before the buzz")
        if previous is not None and (s - previous) / 1000 < KNOCK_WINDOW_S:
            notes.append(f"{(s - previous) / 1000:.1f} s after the previous tap (knock window {KNOCK_WINDOW_S} s)")
        print(f"  {when}  {delay}  {'; '.join(notes)}")
        previous = s
    print("\n  Within the time this run covers, a tap missing above was never sensed by the strap, so no app code saw it.")


def main(argv):
    if len(argv) < 2 or argv[2:3] not in ([], ["runs"], ["taps"]):
        print(__doc__.split("\n\n")[0]); return 2
    lines = open(argv[1], encoding="utf-8", errors="replace").read().splitlines()
    what = argv[2] if len(argv) > 2 else "all"
    if what in ("all", "runs"): report_runs(lines)
    if what in ("all", "taps"): report_taps(lines)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
