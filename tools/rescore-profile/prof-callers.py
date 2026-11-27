#!/usr/bin/env python3
"""Who calls <symbol> between t0 and t1 in an exported `time-profile` table, by nearest named callers.
    python3 prof-callers.py <profile.xml> <t0> <t1> <symbol substring>"""
import sys, xml.etree.ElementTree as ET
from collections import Counter
path, t0, t1, target = sys.argv[1], float(sys.argv[2]), float(sys.argv[3]), sys.argv[4]
ids = {}
def reg(e):
    i = e.get('id')
    if i: ids[i] = e
    for c in e: reg(c)
root = ET.parse(path).getroot(); reg(root)
def res(e): return ids[e.get('ref')] if e is not None and e.get('ref') else e
callers = Counter()
for row in root.iter('row'):
    t = int(res(row.find('sample-time')).text) / 1e9
    if not (t0 <= t <= t1): continue
    ms = int(res(row.find('weight')).text) / 1e6
    bt = res(row.find('tagged-backtrace'))
    if bt is None: continue
    names = [res(f).get('name') for f in bt.iter('frame')]
    for i, n in enumerate(names):
        if n and target in n:
            chain = [x for x in names[i+1:i+8] if x and not x.startswith('0x') and 'partial apply' not in x and 'thunk' not in x][:4]
            callers[' <- '.join(c[:70] for c in chain)] += ms
            break
for k, v in callers.most_common(8): print(f"{v:7.0f} ms  {k}")
