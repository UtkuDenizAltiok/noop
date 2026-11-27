# The developer loop: check-ins and the developer file

Utku's request (26 Nov 2026, chat 8), in two parts. First: "You may even create an additional export feature so
that you can get feedback from my whoop 5.0 - noop ... so it will be a improving loop". Then, refining it:
"this help improve noop should be for you (or any ai agent or a developer that develops this project) not for
the user ... you can use any type of data you want or even create a new thing or data to export if you think it
will benefit your developing and improving process ... Make the best noop app that also can be self improving
in this loop". He is not a coder; he answers a few questions and carries one file.

## The loop

1. **The phone collects.** Everything NOOP records (the database), what the strap and the app did (the strap
   log), and the one thing no sensor gives: the wearer's own account (the morning check-in).
2. **The wearer carries.** Test Centre → Developer export → "Make the developer file" → AirDrop to the Mac.
   About once a week, or when the architect asks.
3. **The architect analyses.** `python3.12 -I dist/tools/lab.py <file>` unpacks it into `dist/private/lab/`
   (ignored, never committed or uploaded) and prints the aggregates: check-ins against the scores, sleep-time
   truth, what the Simple screens concluded, the Stress band shares, coverage.
4. **The architect improves and checks on his own history.** A candidate algorithm is evaluated offline on the
   backup's data with the check-ins as referee, before anything ships (Rules 2 and 3: evidence first, both
   platforms, landed as instrumentation or behind a switch while the evidence is thin).
5. **A new build ships; the next file shows whether it helped.** Only aggregates enter the handbook, in the
   record below.

The phone side never sends anything by itself: the file leaves only through the share sheet, to his own Mac.
That keeps NOOP inside its offline rule (`AGENTS.md`: no server, no telemetry).

## What the developer file holds (`noop-lab-yyMMdd-HHmm.zip`)

| Entry | What | Why the developer needs it |
|---|---|---|
| `README.md` | What each entry is, the check-in questions, how to read it | A new agent can start from the file alone |
| `lab.json` (schema 1) | App and device facts, the settings the algorithms read (age, sex, height, weight, HRmax), the strap model, check-in counts, **each day's morning Stress** (computed on screen, not stored), **what Simple Trends says** for every range and chart, **the week**: the engine's sentences and balance beside Simple mode's lines, chips and adherence, the Workouts "Last 7 days" figures | What the app concluded at export time, which the backup alone cannot say without running the app |
| `noop-backup.noopbak` | The verified backup: `noop-backup.sqlite` (raw streams, day rows, sleep sessions with corrections beside detected times, workouts, journal) and `settings.json` | Replay: every algorithm can be re-run offline on the real data |
| `report.txt`, `meta.json`, raw capture, last crash | The Test Centre bundle, scrubbed of identifiers, capped at 20 MB | What the strap and the app did: syncs, drops, clock drift, decoding |

## The truth data, and the science behind it

- **Morning check-in** (Test Centre switch, default off): "How rested do you feel?", "How well did you sleep?",
  "How relaxed do you feel?", each 1 to 5 with 5 the good end, asked **full screen before the scores are seen**
  (so the answers are not anchored to them), in the morning: from 04:00, but not before 90 minutes ahead of the
  wearer's usual wake (median of recent nights), until 14:00. "Not now" asks again an hour later; "Skip today"
  stops for the day; the Test Centre card has "Answer this morning's check-in" (chat 10, after a check-in offered in the night
  report). Then, when NOOP saw a night of at least 3 hours ending in the last 18 hours (its fragments bridged
  like the Sleep tab's): "NOOP saw you fall asleep at 00:31 and wake at 07:52. Is that about right?" Right /
  Wrong; Wrong opens two time pickers whose times correct the night through the Sleep tab's edit path. Stored as journal numbers under fixed questions (`CheckIn.journalQuestions`,
  `CheckIn.sleepTimesQuestion`; a storage contract pinned by `CheckInTests`), so they ride every backup with no
  new table.
  - Self-reported well-being tracks acute and chronic training load more sensitively and consistently than
    common objective measures (Saw, Main and Gastin, Br J Sports Med 2016;50:281-291, systematic review of 56
    studies; read at abstract level). The short morning form scores a few items 1 to 5 (McLean et al., Int J
    Sports Physiol Perform 2010;5:367-383). Three items, one per morning number: rested ↔ Charge, slept well ↔
    Rest, relaxed ↔ Stress.
  - What it can prove: whether a score follows the wearer's own experience over weeks (rank correlation,
    n-of-1). What it cannot prove: physiological truth. Both are reported as such.
- **Sleep times**: NOOP already lets the wearer correct a night on the Sleep tab and keeps the detected onset
  beside the corrected one (`CachedSleepSession.startTs` immutable, `startTsAdjusted`, `userEdited`, #318).
  The check-in's Right/Wrong answer marks the nights to look at; a correction (now made in the check-in itself)
  measures the onset error exactly.
  Limit: a corrected **wake** time replaces the detected one, so wake errors show only as "Wrong" answers
  (preserving the detected wake would need a migration and its Room twin; a candidate for later).

## What the architect does with a file (the checklist)

1. Copy it into `dist/private/inbox/` (that is `~/Developer/noop/noop-private-utku/inbox/`), run `lab.py`, read the whole output.
2. Data health: rows per table, days covered, raw streams present (`hrSample`, `rrInterval`, `spo2Sample`,
   `respSample`, `skinTempSample`, `rawBatch`), the strap log's drops and syncs. Anything missing on a WHOOP 5.0
   is a bug candidate (upstream says 5.0's deeper metrics "are still being figured out").
3. Truth: check-ins against Charge, Rest and Stress (Spearman, n); "Wrong" sleep mornings and corrected onsets.
4. Findings: S12 (Stress band shares), S14 (how often Trends says up or down on real months), F23 (engine
   balance against Simple adherence), anything new.
5. Write aggregates only into the record below and the relevant feature page; fix first what his file shows.

## Ideas for later (each its own change)

- Workout effort rating after each session (session RPE x duration, Foster et al. 2001) against Effort.
- Preserve the detected wake time when the wearer corrects it (migration + Room twin).
- A raw-capture night on the WHOOP 5.0 (Test Centre raw data collector, already in the app) for PPG-based HRV
  and respiration work; ask Utku only with a defined question, it costs strap battery.
- The Test Centre's check-in switch also shows on the Mac app, which has no presenter for it (iOS only today).
- Per-night stream coverage is in `lab.py` (written against the simulator's empty tables, `hrSample`,
  `rrInterval`, `spo2Sample`, `respSample`, `skinTempSample`): check it on the first real file.

## Record (aggregates only)

- 27 Nov 2026 (chat 10): the check-in rebuilt as above; `lab.json` gained `stepCalibration` (the divisor in use,
  the last iPhone calibration and its paired 15-minute windows, `StepCalibration`). **No file is coming for now:**
  Utku declined (he wore the strap irregularly and will start fresh with the final build); do not ask for one
  until he offers it ([Rules](../RULES.md#settled-decisions), 27 Nov). The loop resumes after the fresh start.

- 26 Nov 2026: built (F1, `feat/developer-loop` `fc708070`, then `f1f90978`: the check-in is offered only while
  the app is active, because iOS wakes NOOP in the background for syncs and an offer then would use up the
  morning unseen). Checked in the simulator: the sheet before the scores, all four answers stored, the sleep
  question reading last night from the store (the in-memory list was empty at launch), the file made and read
  back by `lab.py`. No real file yet.
