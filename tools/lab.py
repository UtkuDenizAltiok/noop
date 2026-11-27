#!/usr/bin/env python3
"""Read a NOOP developer file (Test Centre -> Developer export -> Make the developer file) on this Mac.

    python3.12 -I dist/tools/lab.py <noop-lab-....zip> [--days 60]

The protocol is handbook features/lab.md. The file holds the wearer's health data. It is unpacked under
dist/private/lab/<file name>/ (ignored, never committed or uploaded) and only aggregates are printed:
  - lab.json: the build, phone, settings and what the Simple screens concluded at export time;
  - what the file holds (backup tables and row counts, the strap log's size);
  - sleep truth: the "sleep times right" answers, and the nights the wearer corrected on the Sleep tab (the
    detected onset is kept beside the corrected one, `startTsAdjusted`);
  - the morning check-ins against Charge, Rest and Stress (Spearman rank correlation, n), the n-of-1
    validation of handbook features/checkup.md;
  - how the morning Stress number falls into its bands (finding S12);
  - what each Simple Trends chart would say over the last 30 and 90 days (finding S14);
  - per-day coverage of the main readings.
It discovers tables by their columns rather than by name, because the schema grows through migrations.
Read with python -I (the file is untrusted input); it never executes anything from the file.
"""
import json
import math
import os
import sqlite3
import sys
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
PRIVATE = HERE.parent / "private" / "lab"
SLEEP_TIMES_Q = "Check-in: sleep times right (1/0)"
CHECKIN = {"Check-in: rested (1-5)": "recovery", "Check-in: slept well (1-5)": "sleep_performance",
           "Check-in: relaxed (1-5)": "stress"}


def unpack(zip_path: Path) -> Path:
    out = PRIVATE / zip_path.stem
    out.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(zip_path) as z:
        for name in z.namelist():
            if name.startswith("/") or ".." in Path(name).parts:
                raise SystemExit(f"refusing a path outside the folder: {name}")
        z.extractall(out)
    backup = out / "noop-backup.noopbak"
    if backup.exists():
        with zipfile.ZipFile(backup) as z:
            for name in z.namelist():
                if name.startswith("/") or ".." in Path(name).parts:
                    raise SystemExit(f"refusing a path outside the folder: {name}")
            z.extractall(out / "backup")
    return out


def tables(db):
    rows = db.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name").fetchall()
    out = {}
    for (name,) in rows:
        cols = [r[1] for r in db.execute(f'PRAGMA table_info("{name}")')]
        count = db.execute(f'SELECT COUNT(*) FROM "{name}"').fetchone()[0]
        out[name] = (cols, count)
    return out


def ranks(values):
    order = sorted(range(len(values)), key=lambda i: values[i])
    r = [0.0] * len(values)
    i = 0
    while i < len(order):
        j = i
        while j + 1 < len(order) and values[order[j + 1]] == values[order[i]]:
            j += 1
        for k in range(i, j + 1):
            r[order[k]] = (i + j) / 2 + 1
        i = j + 1
    return r


def spearman(xs, ys):
    if len(xs) < 3:
        return None
    rx, ry = ranks(xs), ranks(ys)
    mx, my = sum(rx) / len(rx), sum(ry) / len(ry)
    sxy = sum((a - mx) * (b - my) for a, b in zip(rx, ry))
    sx = math.sqrt(sum((a - mx) ** 2 for a in rx))
    sy = math.sqrt(sum((b - my) ** 2 for b in ry))
    return sxy / (sx * sy) if sx > 0 and sy > 0 else None


def verdict(values, decimals=0):
    """SimpleTrendRules.verdict (Strand/Data/SimpleTrends.swift), the same arithmetic."""
    if len(values) < 4:
        return "too few"
    mid = len(values) // 2
    a, b = values[:mid], values[mid:]
    ma, mb = sum(a) / len(a), sum(b) / len(b)
    delta = mb - ma
    ra, rb = [v - ma for v in a], [v - mb for v in b]
    squares = sum(v * v for v in ra + rb)
    sd = math.sqrt(squares / (len(values) - 2))
    lagged = sum(h[i - 1] * h[i] for h in (ra, rb) for i in range(1, len(h)))
    rho = min(0.9, max(0.0, lagged / squares)) if squares > 0 else 0.0
    te = sd * math.sqrt(1 / len(a) + 1 / len(b)) * math.sqrt((1 + rho) / (1 - rho))
    bar = max(0.5 * sd, 2 * te)
    scale = 10 ** decimals
    amount = math.floor(abs(delta) * scale + 0.5) / scale
    if abs(delta) < bar or amount == 0:
        return f"about the same (change {delta:+.1f}, bar {bar:.1f}, r {rho:.2f})"
    return f"{'up' if delta > 0 else 'down'} {amount} (bar {bar:.1f}, r {rho:.2f})"


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not args:
        raise SystemExit(__doc__)
    days = 60
    if "--days" in sys.argv:
        days = int(sys.argv[sys.argv.index("--days") + 1])
    folder = unpack(Path(args[0]).expanduser())
    print(f"unpacked into {folder} (private, ignored)")
    lab_path = folder / "lab.json"
    lab = {}
    if lab_path.exists():
        lab = json.loads(lab_path.read_text())
        print(f"\n== lab.json (schema {lab.get('schema')}), exported {lab.get('exportedAt')}")
        for key in ("app", "device", "profile", "strap", "checkIn", "workouts"):
            print(f"  {key}: {lab.get(key)}")
        week = lab.get("week", {})
        print(f"  week {week.get('weekStart')}: engine balance {week.get('engineBalance')}; "
              f"Simple adherence {week.get('adherence')}")
        for line in week.get("engineFocalPoints", []):
            print(f"    engine: {line}")
        for line in week.get("simpleLines", []):
            print(f"    simple: {line}")
        changed = [t for t in lab.get("trends", []) if not str(t.get("verdict", "")).startswith(("aboutTheSame", "tooFew"))]
        print(f"  Simple Trends verdicts: {len(lab.get('trends', []))} chart-ranges, {len(changed)} say up or down"
              + "".join(f"\n    {t['chart']} over {t['range'] or 'all'} days: {t['verdict']}" for t in changed))
    for f in sorted(folder.iterdir()):
        if f.is_file():
            print(f"  {f.name}: {f.stat().st_size:,} bytes")
    dbs = list((folder / "backup").glob("*.sqlite"))
    if not dbs:
        raise SystemExit("no database in the backup")
    db = sqlite3.connect(f"file:{dbs[0]}?mode=ro", uri=True)
    t = tables(db)
    print("\n== tables (rows)")
    for name, (cols, count) in t.items():
        print(f"  {name}: {count:,}")

    # The day rows: the table with day, recovery and strain columns.
    daily = next((n for n, (c, _) in t.items() if {"day", "recovery", "strain"} <= set(c)), None)
    day_rows = {}
    if daily:
        cols = t[daily][0]
        for row in db.execute(f'SELECT * FROM "{daily}" ORDER BY day'):
            rec = dict(zip(cols, row))
            day_rows.setdefault(rec["day"], {}).update({k: v for k, v in rec.items() if v is not None})
    recent = sorted(day_rows)[-days:]
    print(f"\n== day rows ({daily}): {len(day_rows)} days, showing the last {len(recent)}")
    for key in ["recovery", "strain", "restingHr", "avgHrv", "totalSleepMin", "respRateBpm", "spo2Pct", "skinTempDevC"]:
        present = sum(1 for d in recent if key in day_rows[d])
        print(f"  {key}: {present} of {len(recent)} days")

    # Metric series (stress, sleep_performance): a table with key/day/value-like columns.
    series = {}
    for name, (cols, _) in t.items():
        lc = [c.lower() for c in cols]
        if "day" in lc and "value" in lc and ("key" in lc or "metric" in lc):
            kcol = cols[lc.index("key")] if "key" in lc else cols[lc.index("metric")]
            for k, d, v in db.execute(f'SELECT "{kcol}", day, value FROM "{name}"'):
                if v is not None:
                    series.setdefault(k, {})[d] = v
    if series:
        print(f"\n== metric series keys: {', '.join(sorted(series)[:30])}")

    # The morning Stress number is computed on screen, not stored: lab.json carries it (stressDaily).
    if lab_path.exists() and lab.get("stressDaily"):
        series["stress"] = {r["day"]: r["value"] for r in lab["stressDaily"]}

    # Check-ins: journal rows under the fixed questions, with a numeric value.
    journal = next((n for n, (c, _) in t.items() if {"day", "question"} <= set(c)), None)
    checkins = {}
    if journal:
        cols = t[journal][0]
        vcol = next((c for c in cols if c.lower() in ("numericvalue", "value")), None)
        if vcol:
            for q, d, v in db.execute(f'SELECT question, day, "{vcol}" FROM "{journal}" WHERE question LIKE "Check-in:%"'):
                if v is not None:
                    checkins.setdefault(q, {})[d] = v
    print(f"\n== morning check-ins: {', '.join(f'{q}: {len(v)} days' for q, v in checkins.items()) or 'none'}")
    right = checkins.get(SLEEP_TIMES_Q, {})
    if right:
        wrong_days = sorted(d for d, v in right.items() if v < 1)
        print(f"  sleep times right on {len(right) - len(wrong_days)} of {len(right)} mornings; wrong on: "
              + (", ".join(wrong_days) or "none"))
    sessions = next((n for n, (c, _) in t.items() if {"startTs", "endTs", "userEdited"} <= set(c)), None)
    if sessions:
        cols = t[sessions][0]
        edited = db.execute(f'SELECT startTs, endTs, startTsAdjusted FROM "{sessions}" WHERE userEdited = 1').fetchall()
        shifts = sorted((adj - start) / 60 for start, _, adj in edited if adj is not None)
        print(f"  nights corrected on the Sleep tab: {len(edited)}"
              + (f"; onset moved by median {shifts[len(shifts) // 2]:+.0f} min (range {shifts[0]:+.0f} to {shifts[-1]:+.0f})"
                 if shifts else "")
              + ". The corrected wake time replaces the detected one, so wake errors show only as 'wrong' answers.")
    for q, score in CHECKIN.items():
        answers = checkins.get(q, {})
        source = {d: r["recovery"] for d, r in day_rows.items() if "recovery" in r} if score == "recovery" \
            else series.get(score, {})
        shared = sorted(set(answers) & set(source))
        rho = spearman([answers[d] for d in shared], [source[d] for d in shared])
        sign = -1 if score == "stress" else 1   # relaxed (5 = calm) against stress (3 = strained)
        shown = "n/a" if rho is None else f"{sign * rho:+.2f}"
        print(f"  {q} against {score}: n {len(shared)}, rank agreement {shown}"
              + (" (sign flipped: a calm answer should meet a low stress)" if score == "stress" else ""))

    stress = series.get("stress", {})
    if stress:
        vals = [stress[d] for d in sorted(stress)[-days:]]
        high = sum(v >= 2.0 for v in vals)
        low = sum(v < 1.0 for v in vals)
        print(f"\n== S12, morning Stress bands over {len(vals)} days: high {high}, medium {len(vals) - high - low}, low {low}")

    print("\n== S14, what each Simple Trends chart would say")
    charts = {"Charge": "recovery", "Resting heart rate": "restingHr", "HRV": "avgHrv", "Effort": "strain"}
    for window in (30, 90):
        keys = sorted(day_rows)[-window:]
        for title, key in charts.items():
            vals = [day_rows[d][key] for d in keys if key in day_rows[d]]
            print(f"  last {window} days, {title}: {verdict(vals)} over {len(vals)} days")
        rest = series.get("sleep_performance", {})
        vals = [rest[d] for d in keys if d in rest]
        print(f"  last {window} days, Rest: {verdict(vals)} over {len(vals)} days")

    # Per-night coverage of the raw streams: is the strap's data complete and clean enough to trust a night?
    # R-R cleaning for this report only: 300-2000 ms, and a beat differing by more than 20 % from the one before
    # is flagged (the common successive-difference rule). NOOP's own cleaning may differ; compare, do not assume.
    if sessions and "hrSample" in t and "rrInterval" in t:
        nights = db.execute(f'SELECT startTs, endTs, startTsAdjusted, avgHrv, restingHr FROM "{sessions}" '
                            f'WHERE endTs - COALESCE(startTsAdjusted, startTs) >= 10800 ORDER BY endTs DESC LIMIT 30').fetchall()
        print(f"\n== raw streams, last {len(nights)} nights of 3 h or more")
        print("  night (end)        HR cover  HR gap  R-R n    R-R flagged  RMSSD(clean)  stored HRV  SpO2 n  resp n  skin n")
        for start, end, adj, stored_hrv, stored_rhr in nights:
            a = adj or start
            minutes = max(1, (end - a) // 60)
            hr = [r[0] for r in db.execute("SELECT ts FROM hrSample WHERE ts BETWEEN ? AND ? ORDER BY ts", (a, end))]
            covered = len({(ts - a) // 60 for ts in hr})
            gaps = [b - x for x, b in zip([a] + hr, hr + [end])]
            rr = [r[0] for r in db.execute("SELECT rrMs FROM rrInterval WHERE ts BETWEEN ? AND ? ORDER BY ts, ord", (a, end))]
            clean, flagged, prev = [], 0, None
            for v in rr:
                ok = 300 <= v <= 2000 and (prev is None or abs(v - prev) <= 0.2 * prev)
                if ok:
                    clean.append(v)
                else:
                    flagged += 1
                prev = v
            diffs = [b - x for x, b in zip(clean, clean[1:])]
            rmssd = math.sqrt(sum(d * d for d in diffs) / len(diffs)) if len(diffs) > 10 else None
            counts = [db.execute(f"SELECT COUNT(*) FROM {tb} WHERE ts BETWEEN ? AND ?", (a, end)).fetchone()[0]
                      if tb in t else 0 for tb in ("spo2Sample", "respSample", "skinTempSample")]
            from datetime import datetime
            when = datetime.fromtimestamp(end).strftime("%Y-%m-%d %H:%M")
            print(f"  {when}  {100 * covered / minutes:6.1f} %  {max(gaps) / 60:5.0f} m  {len(rr):6d}  "
                  f"{(100 * flagged / len(rr)) if rr else 0:8.1f} %  "
                  f"{rmssd if rmssd is not None else float('nan'):11.1f}  {stored_hrv or float('nan'):10.1f}  "
                  f"{counts[0]:6d}  {counts[1]:6d}  {counts[2]:6d}")

    log = folder / "report.txt"
    if log.exists():
        text = log.read_text(errors="replace").splitlines()
        print(f"\n== strap log: {len(text):,} lines")


if __name__ == "__main__":
    main()
