---
name: noop-project
description: "NOOP (offline WHOOP companion app; fork UtkuDenizAltiok/noop of ryanbr/noop): since 24 Sep 2026 the journey is to make the whole app the best for WHOOP straps — optimised, low usage, better biometrics — with me as owner and decider. Start every session from the handbook in dist/ (branch handbook)."
metadata:
  node_type: memory
  type: project
  originSessionId: ed340050-008d-44ae-be66-66b9c198334f
  modified: 2026-09-30T13:45:00.000Z
---

NOOP (`~/Developer/noop`; fork `UtkuDenizAltiok/noop`, upstream `ryanbr/noop`) is an offline, on-device companion app
for WHOOP straps (iOS, macOS, Android). **Journey 2, from 24 Sep 2026:** Utku asked me to make the WHOLE of NOOP
"perfect, optimized, clean, sleek, efficient, fast and low usage" (memory, CPU, GPU, battery, for strap and iPhone),
with better algorithms and biometrics where I can — "more robust and reliable than WHOOP itself" — and made me the
owner and decider of the journey. Journey 1 (the Lift Log gym log book and the Live HR banner, 2–24 Sep) is finished:
11 PRs merged upstream; its reference lives in `dist/features/`. By 30 Sep, 19 of ours are merged (journey 2 adds
#2420, #2444, #2569, #2574, #2575, #2576); open: #2612 (30-min background re-score spacing, phone-verified) and
#2613 (SleepStagerV2 RSA weight 0.6 → 0.3 on DREAMT PSG with R-R; `Tools/SleepPSG` now reads DREAMT, restricted:
local only, aggregates only). Utku's standing principle (28 Sep): lower usage by doing the same work cheaper, never by doing less
(`RULES.md`); measure with Time Profiler on a copy of his backup (`dist/tools/rescore-profile/`), judge biometrics
against PSG truth (`Tools/SleepPSG`: sleep-accel and DREAMT), per subject, not one matching night.

**Start every session with the handbook in `dist/`** (a worktree of the public branch `handbook`): `README.md` (its
start prompt), `STATE.md` ("Now" first), `RULES.md`, `WORKFLOW.md`, `BACKLOG.md`; then
`bash dist/tools/checkpoint.sh status --net` and `bash dist/tools/upstream-check.sh`. The handbook, not this memory,
is the source of truth for where things stand.

The maintainers merge within hours and fix things themselves; Swift and Kotlin must stay byte-identical (parity
oracle). Every change ships to Utku's phone as a testing build and is judged by real use.

See [[noop-working-with-utku]], [[noop-handbook-is-mine]], [[noop-verify-before-claiming]], [[noop-ship-the-build]],
[[noop-pr-communication]].
