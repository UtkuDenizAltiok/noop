#!/usr/bin/env python3
"""How often each R-R value near 500 ms occurs in a NOOP backup, and at what strap heart rate (upstream #2371).

    python3 dist/tools/rr-fill.py <backup.noopbak | whoop.sqlite>

#2371: on a WHOOP 5/MG an exact rrMs = 500 appears ~20x more often than its neighbours and is stored as a real beat.
The question before a fix: does the strap ALSO send 500 as a real interval (120 bpm, exercise)? Per WHOOP 5 transport
(srcChannel 5 = v18 history, 6 = live type-40, 7 = standard 0x2A37) this prints:
  - the counts at 490..510 ms: the spike and its neighbours;
  - the same split by the strap's own heart rate in that second (hrSample at the same ts), with the spike's size
    (count at 500 / mean of 495-499 and 501-505): an excess only at rest means a filter keyed on the heart rate keeps
    real 500 ms beats; an excess at every rate means 500 is a filler whatever the rate;
  - the run lengths of consecutive 500s.
Reads locally and prints counts only. A backup is personal health data: never commit one, or this output with it.
"""
import os
import sqlite3
import sys
import tempfile
import zipfile
from collections import Counter, defaultdict

if len(sys.argv) != 2:
    sys.exit(__doc__)
src = sys.argv[1]
tmp = None
if zipfile.is_zipfile(src):
    z = zipfile.ZipFile(src)
    names = [n for n in z.namelist() if n.endswith(".sqlite")]
    if not names:
        sys.exit(f"no .sqlite entry in {src}: {z.namelist()}")
    tmp = tempfile.mkdtemp(prefix="rr-fill-")
    for n in z.namelist():   # the -wal/-shm companions, if the backup carries them
        if n.startswith(names[0]):
            z.extract(n, tmp)
    db_path = os.path.join(tmp, names[0])
else:
    db_path = src
db = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)

CHANNELS = {5: "v18 history", 6: "live type-40", 7: "standard 0x2A37"}
BANDS = [(0, 70), (70, 90), (90, 110), (110, 130), (130, 250)]


def band(bpm):
    if bpm is None:
        return "no HR"
    for lo, hi in BANDS:
        if lo <= bpm < hi:
            return f"{lo}-{hi}"
    return "other"


def spike(c):
    near = [c.get(v, 0) for v in (495, 496, 497, 498, 499, 501, 502, 503, 504, 505)]
    mean = sum(near) / len(near)
    return f"{c.get(500, 0) / mean:5.1f}x" if mean else "  n/a"


total = dict(db.execute("SELECT srcChannel, COUNT(*) FROM rrInterval WHERE srcChannel IN (5, 6, 7) "
                        "GROUP BY srcChannel"))
print(f"R-R rows by WHOOP 5 channel: " + ", ".join(f"{CHANNELS[k]} {v}" for k, v in sorted(total.items())))
if not total:
    sys.exit("no labelled WHOOP 5 beats in this database")

rows = db.execute("""
    SELECT r.srcChannel, r.rrMs, h.bpm FROM rrInterval r
    LEFT JOIN hrSample h ON h.deviceId = r.deviceId AND h.ts = r.ts
    WHERE r.srcChannel IN (5, 6, 7) AND r.rrMs BETWEEN 490 AND 510""")
by_ch = defaultdict(Counter)
by_band = defaultdict(lambda: defaultdict(Counter))
for ch, rr, bpm in rows:
    by_ch[ch][rr] += 1
    by_band[ch][band(bpm)][rr] += 1

for ch in sorted(by_ch):
    c = by_ch[ch]
    print(f"\n== {CHANNELS[ch]} (srcChannel {ch}): 500 ms = {c.get(500, 0)} of {total[ch]} beats "
          f"({100 * c.get(500, 0) / total[ch]:.2f}%), spike {spike(c)}")
    print("   " + "  ".join(f"{v}:{c.get(v, 0)}" for v in range(490, 511)))
    print("   by the strap's heart rate that second (count at 500 · spike):")
    for b in [f"{lo}-{hi}" for lo, hi in BANDS] + ["no HR"]:
        bc = by_band[ch].get(b)
        if bc:
            print(f"     {b:>8} bpm: {bc.get(500, 0):6d} · {spike(bc)}   (490-510 total {sum(bc.values())})")

# Run lengths of consecutive 500s, per device and channel, in stored order.
runs = defaultdict(Counter)
cur = {}
for dev, ch, rr in db.execute("SELECT deviceId, srcChannel, rrMs FROM rrInterval WHERE srcChannel IN (5, 6, 7) "
                              "ORDER BY deviceId, srcChannel, ts, ord, seq"):
    key = (dev, ch)
    if rr == 500:
        cur[key] = cur.get(key, 0) + 1
    elif cur.get(key):
        runs[ch][cur.pop(key)] += 1
for (dev, ch), n in cur.items():
    if n:
        runs[ch][n] += 1
print("\nruns of consecutive 500 ms beats (length: count):")
for ch in sorted(runs):
    print(f"   {CHANNELS[ch]}: " + ", ".join(f"{k}: {v}" for k, v in sorted(runs[ch].items())))
if tmp:
    import shutil
    shutil.rmtree(tmp, ignore_errors=True)
