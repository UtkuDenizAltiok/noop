#!/usr/bin/env python3
"""Timeline of the live heart rate in a NOOP strap log: real readings, zeros, silences, clears, app background moments.

    python3 dist/tools/hr-timeline.py <strap-log.txt> [--from HH:MM:SS] [--to HH:MM:SS]

Built for the strap-off / strap-on work (LIVE_HR.md). It reads only lines NOOP already writes:
  - `standard-hr transport host-received hostUnixSec=…` (one a second, under the Test Centre HRV / Connection mode):
    acceptedHRRows=1 → a real reading, rejectedHRRows=1 → a 0 bpm / unreadable one;
  - `… host-received summary windowSec=… samples=…` (one a minute otherwise): how many readings a window held;
  - `HR notify: N bpm` (every 30 s while readings flow), `HR: skin contact …`, `HR: 3 unreadable samples …`,
    `HR: no readable heart-rate sample …` (the clears), `flush-attempt reason=background|foreground|termination`
    (app state; termination = its screen discarded), `Central state:` (a new app run), `Connected —` /
    `Disconnected`, `Toggle Realtime HR`;
  - from #2422's builds on (24 Sep 2026): `Live HR banner: …` (started, picked up, renewed, ended, gone, the dash
    and back) and `Strap: WRIST_ON` / `Strap: WRIST_OFF` (the strap's own word that it went on or came off).
A gap of minutes with no line at all while the link is up is the strap saying nothing (a WHOOP 5.0 off the wrist).
Runs of per-second readings are folded into one line. Personal data stays local: print, do not commit, a log.
"""
import re
import sys

args = sys.argv[1:]
if not args:
    sys.exit(__doc__)
path = args[0]
start = args[args.index("--from") + 1] if "--from" in args else "00:00:00"
end = args[args.index("--to") + 1] if "--to" in args else "99:99:99"

stamp = re.compile(r"^\[(\d\d:\d\d:\d\d)\]")
events = []
for line in open(path, encoding="utf-8", errors="replace"):
    m = stamp.match(line)
    if not m or not (start <= m.group(1) <= end):
        continue
    t = m.group(1)
    if "host-received hostUnixSec" in line:
        acc = int(re.search(r"acceptedHRRows=(\d+)", line).group(1))
        rej = int(re.search(r"rejectedHRRows=(\d+)", line).group(1))
        events.append((t, "real" if acc else ("zero" if rej else "none")))
    elif "host-received summary windowSec" in line:
        s = re.search(r"windowSec=(\d+) samples=(\d+) gapMaxSec=(\d+) acceptedHRRows=(\d+)", line)
        events.append((t, f"minute summary: {s.group(2)} readings in {s.group(1)} s, "
                          f"{s.group(4)} real, longest gap {s.group(3)} s"))
    elif "HR notify:" in line:
        events.append((t, "HR notify " + line.split("HR notify: ")[1].split(",")[0].strip()))
    elif re.search(r"HR: (skin contact|3 unreadable|no readable)", line):
        events.append((t, line[len(t) + 3:].strip()[:110]))
    elif (r := re.search(r"flush-attempt reason=(background|foreground)", line)):
        events.append((t, f"app → {r.group(1)}"))
    elif "flush-attempt reason=termination" in line:
        events.append((t, "app closed (its screen discarded: swiped away, or by iOS)"))
    elif "] Central state:" in line:
        events.append((t, "NOOP started (a new app run)"))
    elif re.search(r"\] (Live HR banner|Strap: WRIST_)", line):
        events.append((t, line[len(t) + 3:].strip()[:110]))
    elif re.search(r"\] (Connected —|Disconnected)", line):
        events.append((t, line[len(t) + 3:].strip()[:80]))
    elif "Toggle Realtime HR payload=" in line:
        events.append((t, "realtime HR " + ("on" if "payload=01" in line else "off")))

out, run = [], None
for t, k in events:
    if k in ("real", "zero"):
        if run and run[0] == k:
            run[2], run[3] = t, run[3] + 1
            continue
        if run:
            out.append(f"{run[1]}–{run[2]}  {run[3]} {run[0]} reading(s)")
        run = [k, t, t, 1]
        continue
    if run:
        out.append(f"{run[1]}–{run[2]}  {run[3]} {run[0]} reading(s)")
        run = None
    out.append(f"{t}  {k}")
if run:
    out.append(f"{run[1]}–{run[2]}  {run[3]} {run[0]} reading(s)")
print("\n".join(out))
