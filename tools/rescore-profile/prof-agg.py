#!/usr/bin/env python3
"""Aggregate an exported Time Profiler `time-profile` table between t0 and t1 seconds (trace time): self time by
binary and function, inclusive time for app/store/sqlite frames.  python3 prof-agg.py <profile.xml> <t0> <t1>"""
import sys, xml.etree.ElementTree as ET
from collections import Counter
path, t0, t1 = sys.argv[1], float(sys.argv[2]), float(sys.argv[3])
ids = {}
def reg(e):
    i = e.get('id')
    if i: ids[i] = e
    for c in e: reg(c)
tree = ET.parse(path); root = tree.getroot(); reg(root)
def res(e): return ids[e.get('ref')] if e is not None and e.get('ref') else e
selfc, incl, bins, total = Counter(), Counter(), Counter(), 0
for row in root.iter('row'):
    st = res(row.find('sample-time')); t = int(st.text) / 1e9
    if not (t0 <= t <= t1): continue
    w = res(row.find('weight')); ms = int(w.text) / 1e6 if w is not None else 1.0
    bt = res(row.find('tagged-backtrace'))
    if bt is None: bt = res(row.find('backtrace'))
    if bt is None: continue
    frames = [res(f) for f in bt.iter('frame')]
    names = []
    for f in frames:
        b = f.find('binary'); b = res(b) if b is not None else None
        names.append((f.get('name'), b.get('name') if b is not None else '?'))
    if not names: continue
    total += ms
    selfc[names[0]] += ms; bins[names[0][1]] += ms
    for n in set(n for n in names if n[1] in ('NOOP', 'NOOP Staging', 'WhoopStore', 'StrandAnalytics', 'GRDB', 'libsqlite3.dylib')):
        incl[n] += ms
print(f"samples in window: {total:.0f} ms")
print("\n== self time by binary"); [print(f"{v:8.0f} ms  {k}") for k, v in bins.most_common(12)]
print("\n== self time by function"); [print(f"{v:8.0f} ms  {k[1]}: {k[0][:150]}") for k, v in selfc.most_common(30)]
print("\n== inclusive, app/store/sqlite frames"); [print(f"{v:8.0f} ms  {k[1]}: {k[0][:150]}") for k, v in incl.most_common(45)]
