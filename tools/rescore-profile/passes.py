#!/usr/bin/env python3
"""Re-score passes in a strap log: count, CPU, per hour, gaps, and a replay of a background spacing rule
(a backgrounded pass runs only if the last one STARTED >= N min before).  python3 passes.py <strap-log.txt>"""
import re, sys, collections
ts_re = re.compile(r'\[(\d\d:\d\d:\d\d)\]')
last = None; rows = []; cur = None
for i, line in enumerate(open(sys.argv[1], errors='replace'), 1):
    m = ts_re.search(line)
    if m: last = m.group(1)
    if 're-score: trigger=' in line:
        cur = {'line': i, 't': last, 'trig': line.split('trigger=')[1].split()[0]}
    elif 're-score: cost' in line and cur:
        cpu = re.search(r'cpu=([\d.]+)s', line); bg = 'backgrounded=true' in line
        cur['cpu'] = float(cpu.group(1)) if cpu else None; cur['bg'] = bg; rows.append(cur); cur = None
    elif 're-score: done' in line and cur:
        n = re.search(r'scored (\d+) night', line); cur['n'] = int(n.group(1)) if n else None
print('passes', len(rows), 'cpu total', round(sum(r['cpu'] or 0 for r in rows), 1), 'bg cpu', round(sum(r['cpu'] or 0 for r in rows if r['bg']), 1))
print('first', rows[0]['t'], 'last', rows[-1]['t'])
by = collections.defaultdict(lambda: [0, 0.0])
for r in rows:
    h = (r['t'] or '??')[:2]; by[h][0] += 1; by[h][1] += r['cpu'] or 0
for h in sorted(by): print(h, by[h][0], round(by[h][1], 1))
# gaps between consecutive pass starts (minutes)
def sec(t): hh, mm, ss = map(int, t.split(':')); return hh*3600+mm*60+ss
gaps = []
for a, b in zip(rows, rows[1:]):
    if a['t'] and b['t']:
        g = (sec(b['t']) - sec(a['t'])) % 86400; gaps.append(g/60)
gaps.sort(); print('gap median min', round(gaps[len(gaps)//2], 1), 'min', round(gaps[0], 1), 'max', round(gaps[-1], 1))
# simulate: a backgrounded pass runs only if >= SPACING min since the last pass START; foreground always runs
for spacing in (20, 25, 30):
    lastrun = None; kept = []; t0 = sec(rows[0]['t']); day = 0; prev = None
    for r in rows:
        s = sec(r['t'])
        if prev is not None and s < prev: day += 86400
        prev = s; s += day
        if (not r['bg']) or lastrun is None or s - lastrun >= spacing*60:
            kept.append(r); lastrun = s
    print(f'spacing {spacing}: passes {len(kept)} cpu {round(sum(k["cpu"] or 0 for k in kept),1)}')
