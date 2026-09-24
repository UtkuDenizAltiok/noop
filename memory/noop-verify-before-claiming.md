---
name: noop-verify-before-claiming
description: "Verify every claim by running it: tests seen to fail, the full verify.sh loop, the app run, reviewer claims and rebases tested, usage measured before and after, BLE proven on the strap, strap logs read to the second — reading code and trusting reviewers have both been wrong here."
metadata:
  node_type: memory
  type: feedback
  originSessionId: ed340050-008d-44ae-be66-66b9c198334f
  modified: 2026-09-24T12:36:39.011Z
---

Several things believed true on this project turned out false, and each was caught only by running something. Utku
relies on my technical judgement precisely because he cannot check it himself.

**Why:** NOOP's worst bugs are silent wrong data that pass every test and build; app targets need local builds; BLE
only shows itself on a strap; and reviewers — the maintainer included — have been wrong in ways that sounded sure.

**How to apply:**
- **A new test must be seen to FAIL**: break the fix, watch it go red, restore byte-identical (sha256). Check the break
  landed (`git diff`) — zsh once left a "break" unapplied.
- **Run the whole loop** (`dist/tools/verify.sh`: packages, lint, i18n, parity ledger/ratchet/governance, macOS tests,
  iOS build) and build each commit of a series alone.
- **Measure a usage claim, don't argue it**: simulator CPU-s a minute, memory footprint, counts from the strap log,
  MetricKit on the phone (`dist/WORKFLOW.md` §11).
- **Prove background and BLE behaviour on the phone**, from the strap log: iOS suspends NOOP between Bluetooth events,
  restarts it in the background, and a force-quit app is not relaunched for Bluetooth.
- **Never read another object's derived state inside a `@Published` sink** (willSet; sinks run in no promised order):
  the Live HR banner read AppModel's stale median and missed WRIST_OFF (#2437, 24 Sep). My own merged comment had
  claimed the order was fixed — an assumption, not a fact.
- **Test a reviewer's claim before repeating it**; after a squash merge prove it equals the head
  (`git merge-tree --write-tree <squash>^ <head>` gives the squash's tree).
- **A tool result that differs between branches is checked on a clean checkout** before blaming code (`swift test`
  leaves `Packages/*/.build` for the parity scanner); test helpers never share a production function's name.
- **Read a strap log to the second, and say what it cannot show** (what iOS drew). My own log tool once called every
  Bluetooth on/off an app start — check a tool's labels against the raw lines.
- **Never wait on `pgrep -f pattern` from a command containing the pattern** — it matches itself forever.

See [[noop-project]], [[noop-handbook-is-mine]].
