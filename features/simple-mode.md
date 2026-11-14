# Simple mode and the human-friendly NOOP project

## Next chat begins here: Simple mode v6, the most user-friendly NOOP

**Utku's direction, 14 Nov 2026 (rule in [Rules](../RULES.md#settled-decisions)):** Simple mode is today only
*simpler* than the full NOOP. It must become the most user-friendly mode, so a wearer understands and uses the app
without confusion, decided from four viewpoints (fitness coach, physiologist, doctor, software developer), and never
by deleting information or features. He is not the expert; the architect decides. He asked that design and
building wait for this next chat, run on Claude Fable 5.2 as architect, with Opus 5.5 workers implementing.

**What exists to build on** (all on the phone since 12 Nov, build `218aec72`): Simple mode v5 (Rounds 1–6 below),
"Show everything on this screen" on six screens (`258e0bf2`), "Report a problem" in More, the Lift Log guard test,
and the high heart rate warning ([its page](high-hr-warning.md), hardware-checked 14 Nov). Everything is reviewed,
committed, pushed and on the testing stack `25aa5f38`; nothing is running.

**Suggested first moves** (suggestions only; the next architect decides):
1. **Walk every Simple screen as a first-time wearer** in the simulator (build and seed: "How to work" below) and
   write down every moment of confusion: a word a newcomer does not know, a number with no meaning attached, two
   names for one thing, a card whose point is unclear, a missing "so what do I do?", a screen whose title does not
   say what question it answers. That list, not the full view, is v6's starting point.
2. **Judge each screen from the four viewpoints** and the wearer's real day: morning (did I recover, how hard
   today), after training (how hard was it), evening (when to sleep), over weeks (am I improving), and rarely a
   warning (illness signs, strap problems). Also the first launch and first week, when there is no baseline yet.
3. **Write "Design v6" into this page:** principles, then screen by screen (Today, Sleep, Trends, Stress, Health,
   Workouts, Live, More, Settings, the first-run flow), the exact copy, what each number is compared with, and
   what stays one tap away. Keep the presentation-only boundary and the parity rules.
4. **Split it into small worker briefs**, one at a time on `feat/simple-mode`; review each diff; stack; build;
   then ask Utku specific, plain questions on the phone ("on Today, could you tell what to do today?").

**Known inputs to weigh** (not decisions): open findings F12, F16, F17, F18 (Audit verdict below); each score
carries an invented name plus a WHOOP caption (Charge "Recovery", Effort "Strain", Rest "Sleep") — check whether
that helps or confuses; numbers like HRV and resting heart rate need "compared with your normal" everywhere;
Utku's 6 Nov remark that the original "looks like AI slop" (design carefully what to show and emphasise); the
heart rate warning's two small follow-ups W1 and W2 ([§12](high-hr-warning.md#12-hardware-evidence-utkus-whoop-50-12-and-14-nov)),
best shipped with the first v6 build.

**Working with Utku:** plain everyday words, no technical terms; never ask him about builds, Git or GitHub; end
every answer with one to three simple numbered next steps; tell him plainly when a build is ready before he tests.

## Ground rules and how to work

**Goal** (Utku, 4–6 Nov 2026; rule in [Rules](../RULES.md#settled-decisions)): a calm, correct, efficient NOOP
that a first-time WHOOP wearer understands. Nothing important is lost: Simple mode is the calm view, Settings →
Simple mode off (or More → All features) shows everything. Utku hands over all operational work: decide, build,
verify, ship; never ask him routine questions (Rules, 6 Nov). He tests on a WHOOP 5.0 + iPhone 16 Plus (AltStore, "just
update"). 6 Nov: "I hate that the original looks like AI slop" — design carefully what to show, hide and emphasize.

**Lift Log stays fully available in Simple mode (Utku, 6 Nov night; rule in [Rules](../RULES.md#settled-decisions)).**
His own feature (gym sessions with records and taps, merged upstream). Never hide, shorten or restyle any part of it
in Simple mode. Checked 6 Nov: More → Training → Lift Log (Simple list, `RootTabView` `MoreRow(.liftLog)`) and All
features; `LiftLogView` has no Simple-mode branch; the active-session bar (`LiftSessionBar`) sits at the app root in
both modes; Settings keeps "Lift Log session" (Live notifications) and the lifting-friendly Effort switch (Banister,
in Units) open in Simple mode. Only cosmetic difference: Simple Workouts hides every row's source badge, so a lifting
row no longer says "Lifting" there (one line to bring back if he wants it). The guard test exists since 12 Nov (`SimpleModeTests`).

**Where things are:** branches, folders, the testing stack and the phone build are listed once, in
[State](../STATE.md). Simple mode lives on `feat/simple-mode` (folder `~/Developer/noop-simple`); the heart rate
warning on `feat/high-hr-warning` (folder `~/Developer/noop-hrwarn`), which contains `feat/simple-mode`.

**How to work (what the chats learned):**
- Build: `xcodegen generate`, then `git checkout -- StrandiOS/Resources/Info.plist` (until #2898 merges);
  `xcodebuild -scheme NOOPiOS -destination 'platform=iOS Simulator,name=iPhone 18 Pro' CODE_SIGNING_ALLOWED=NO build`;
  full tests: `-scheme Strand -destination 'platform=macOS' test` (2338 on the branch, 2365 on the stack).
- Python tools need `/opt/homebrew/bin/python3.12` and a canonical `TMPDIR` (`export TMPDIR=$(realpath "$TMPDIR")`).
  Gates before any commit: `Tools/i18n_audit.py --ci upstream/main`, `Tools/doc_comment_lint.py`,
  `python3.12 -m unittest discover -p "test_*.py"` in `Tools/` (includes `tests.test_parity_governance_acceptance`).
- Translations: every new English string needs all nine locales (de/es/fr/pt-PT hard gate; it/pl/ru/zh ratchet; an
  English echo fails). Insert one-line JSON entries after `"strings": {` with a small script (count `%@`/`%lld`;
  use positional `%1$@` where word order changes, e.g. zh); merge catalogue conflicts by key with
  `dist/tools/xcmerge.py`. A `Text(verbatim: "\(a)–\(b)")` literal is flagged as un-extracted copy: build such
  strings in a helper (`SimpleDayPlan.rangeText`).
- Rule 11 bites: a test helper named like ANY production function (same name + arity, any package) moves the parity
  baseline (`instant(_:_:_:)` vs `GarminExportParser.instant`). Prefix test helpers (`tonightFixture…`).
- Doc comments: insert a new declaration ABOVE a neighbour's doc/`//` comment, never between it and its line.
- Simulator: `xcrun simctl launch "iPhone 18 Pro" com.noopapp.noop --demo-seed` seeds 120 days ending that day
  (uninstall first to reseed); relaunch to see data. Launch args set prefs for one run: `-noop.simpleMode NO`,
  `-windDown.enabled YES -windDown.wakeMinutes 420`. The screenshot can lag one action: wait, shoot again.
  Coordinates are points (screenshot px ÷ 3). The demo carries WHOOP-imported sleep needs (7h 16m).
- Phone build: add commits to the stack as a fast-forward (cherry-pick onto `origin/testing-stack` in a scratch
  worktree, verify iPhone Release build + StrandTests + gates, push), then `testing-build` by the merge-commit route
  ([Workflow §6](../WORKFLOW.md#6-builds-for-utkus-phone)), dispatch "Testing build (fork)", verify release target,
  five assets, IPA HTTP 200 and a new string in the IPA's `de.lproj`. The macOS leg takes ~25–30 min. A superseded
  running build may be cancelled (`gh run cancel`) and replaced by one combined build.
- Android is tested on the fork only: `gh workflow run "Android CI" --ref <branch>` (push does not trigger it).
- Safety-check limits on this Mac: force-push and `git commit --amend` of a pushed commit are refused (build a clean
  branch with `git merge --squash` instead); `gh pr create`, close/reopen and the Auto-fix switch need Utku's yes in
  chat (permission rules `Bash(gh pr create:*)` etc.); `sleep N; cmd` chains are refused (use an `until` loop or a
  background job). In zsh write `"${VAR}:refs/…"`.
- Foundation's `String(format:locale:)` rounds ties half-to-even (finding 16): round half away from zero first for
  any one-decimal figure shared with Android. Verify citations before writing them.


### Audit verdict (12 Nov, the whole Simple mode diff read against the goal)

The work is sound: presentation only, every number from the code the full view uses, one resolver per fact
(sleep need, Effort range, Tonight times), tested, and the full view untouched. The Lift Log is whole. One real
gap and three smaller ones:

- **F15 (the real gap, fork, fix first): hidden things are NOT one tap away.** Every simplified screen reads the
  one global switch, so the parts it hides can only be seen by turning Simple mode off for the whole app. That
  includes working tools, not just extra charts: Trends' PDF export and training-load chart, Workouts' filters,
  search and multi-select (merge, bulk delete), Sleep's manual sleep marks and body clock, Stress's Advanced HRV,
  Health's records and sources links, Today's Customize. Opening one of these screens from More → All features
  shows the simplified screen again, so the caption there, "Every screen and tool, exactly as before.", is not
  true. This breaks the project's own rule ("the detail one tap away") and Utku's ("nothing important lost").
  Fix: step 1 below.
- **F16 (UPSTREAM candidate, iOS):** the "Enable wrist alerts" help says "Off keeps the strap quiet no matter
  what else is on", but HR-zone coaching (`AppModel.coachZone`) buzzes without reading that switch. Say what the
  switch really covers, or make it cover everything. Read in code only; not checked on a strap.
- **F17 (verify before acting):** when the Charge ring carries an earlier day, the "What's behind your Charge"
  rows come from that earlier day but the "Rest" row is fed the Rest score now on screen
  (`ChargeBreakdownWiring.breakdown(… row: priorScored ?? day, sleepPerfPercent: restScore)`), which can be a
  different night. Check what the classic Charge sheet passes; if it is the same, it is an upstream candidate.
- **F18 (upstream, low):** `LiveSessionRunner` says it ticks on every heart-rate reading in the background, but
  the reading is published only when its value changes, so a steady heart rate gives it no tick. Found while
  designing the high heart rate warning; relevant only to Live Sessions (beta).
- **Not yet seen on a real phone.** All of Simple mode has been checked in the simulator only. Rule 12 says real
  use finds what matters: Utku's first days with it outrank every list here.

### The roadmap (architect, 12 Nov; updated 14 Nov)

How the work is done (Rules, 12 Nov): the architect chat plans, writes briefs, reviews, stacks and ships the phone
build; **Opus 5.5 worker chats write the app code**, one brief each, and hand back a pushed branch. Nothing reaches
the phone before its diff has been read against its brief. One worker builds and tests at a time on this Mac.

**Phase A — done 12–14 Nov:** "Show everything on this screen" (F15, `a639d47a` `258e0bf2`), the high heart rate
warning (`f80aadc6`, [checked on the strap](high-hr-warning.md#12-hardware-evidence-utkus-whoop-50-12-and-14-nov)),
both reviewed, on stack `25aa5f38` and phone build `218aec72`. The brief and specification are in the
[diary](simple-mode-diary.md#round-7-12-nov-2026-show-everything-on-this-screen-report-a-problem-lift-log-guard).

**Phase B — Simple mode v6, the most user-friendly NOOP (next chat)**, from "Next chat begins here" above. It
takes in what was queued here: a first-run screen that explains the three scores and where everything is; F12
(do not load what Simple mode does not show, measured first, Workflow §11); F17; the warning's W1 (and W2 if
wanted). Whatever Utku reports from the phone comes first.

**Phase C — upstream, only when it is active again** (check at every Start; do nothing while it is quiet)
- Answer any maintainer comment once; rebase #2747/#2724 only when a maintainer engages.
- Then, one small PR each, a few at a time: F1 + F13 together (both platforms), F2, F3, F5, F6, F16, the
  redundant "Settings" overline.
- The high heart rate warning: an issue first, with the phone evidence.

**Phase D — Android and the proposal:** Android twin of Simple mode + `noop.simpleMode` in the `.noopbak`
whitelist on both platforms, then propose Simple mode upstream, default OFF (#2463). Only after v6 settles and
upstream is active; nobody here can test Android on a strap, so every Kotlin change runs in fork CI and says so.

**Phase E — measurement quality:** F11 audit (one-decimal figures by twin oracle), then the Backlog biometric
queue (evidence first, Rules 2–3).

## Design v5: the calm NOOP (chat 2's plan, 6 Nov)

**How a regular wearer uses a WHOOP band** (physician + coach view): in the morning they want to know whether
they recovered and how hard to go today; after training, how hard it was; in the evening, when to go to bed;
over weeks, whether things are improving; and, rarely but importantly, a warning when the body looks off
(illness signs, a strap problem). Everything else is detail for the curious.

**Rules for Simple mode** (apply to every screen):
- Lead with the answer, then the reason, then the detail one tap away. One number per fact; one name per thing
  (Charge / Effort / Rest, with Recovery / Strain / Sleep as small captions).
- Compare with "your normal", not raw numbers alone; say whether higher or lower is good.
- Warnings first (health alert, strap off or disconnected, active workout). Old data carries its date; missing
  data is a dash, never a zero; never claim what was not measured (AGENTS "a diagnostic may only assert…").
- No lab metrics, provenance, betas or duplicate cards in Simple mode; they stay in the full view and All
  features. Short sentences, but complete: what it is, whether it is good, what to do.
- Simple mode should also do less work: do not compute what it does not show (measure before claiming).
- **Whatever a screen hides is one tap away on that same screen** (12 Nov, F15): each simplified screen ends
  with "Show everything on this screen". Hiding a working tool behind the app-wide switch counts as removing it.

**Show / emphasize / hide, screen by screen** (✓ done, → next):
| Screen | Show and emphasize | Hide in Simple (still in full view) |
|---|---|---|
| Today | ✓ rings + captions (dates on carried Charge/Rest), ✓ "Your day" (verdict + suggested Effort range + progress), ✓ sleep card (Last night + Tonight), ✓ top-3 Charge readings | ✓ Key Metrics, Your Cards, Start session beta, Data sources |
| Sleep | ✓ score, hours vs need (one resolver with Today), night card, debt ledger in words, trend (Tonight lives on Today) | ✓ sleep marks, body clock, stages vs typical, Night detail tiles |
| Trends | ✓ score trends, Average below its range | ✓ CTL/ATL/TSB, PDF export |
| Stress | ✓ level, markers vs your normal, day timeline, trend, guide link | ✓ Advanced HRV, method card |
| Health | ✓ sync, heart rate, vitals, skin temp, Fitness Age, Vitality | ✓ recovery contributors (duplicate), records/sources links |
| Workouts | ✓ Start/Add, range, one summary card, sessions, zones in words | ✓ filters/search, Current/Archived, multi-select, stat tiles, 13-week calories, breakdown, HR-recovery trend, source badges |
| Settings | ✓ Simple mode, Profile, Units, Strap, Live notifications | ✓ "More settings" (Appearance, Streak, Features, Sync), Advanced (unchanged), "Settings" overline |
| Alarms | ✓ plain strap-alarm evidence (`0a6f3021`) | the capture method and issue number |
| Lift Log | **everything, always** (Utku's rule, 6 Nov) | nothing, ever |
| Live, Breathe | unchanged | — |

**The suggested Effort range** (step 1): NOOP already has an approved, presentation-only mapping,
`CoupledView.optimalStrainRange(recovery:)` (byte-identical with Android's `optimalStrainRange`): Charge ≥ 67 →
14–18, 34–66 → 10–14, < 34 → 4–10 on the 0–21 axis. Effort's 0–21 display is a linear rescale of NOOP's 0–100
(`UnitFormatter.effortScaleFactor = 21/100`), so on 0–100 the bands are about 67–86, 48–67 and 19–48: compute
them through the unit helper, never hard-code. NOOP's Effort is not WHOOP's Strain, so present it as a rule of
thumb from your Charge ("Suggested Effort today: 48–67, a moderate day"), with progress so far, and explain it in
the guide. Before surfacing it, read the band's history (task #43 comments on both platforms).

**Open findings (the diary)** — fix with evidence; UPSTREAM ones as separate small PRs:
- **F1** (UPSTREAM, both): readiness `.insufficient` summary "Still learning your baseline" shows whenever
  today's row is missing, i.e. every morning before the night syncs. Simple mode fixed (v4).
- **F2** (UPSTREAM): carried-score caption says "Last night" for scores up to two days old
  (`carryFreshnessDays = 2`). Simple mode shows only the date (v4).
- **F3** (UPSTREAM): Health "Recovery contributors" repeat the Charge drivers with a simple-average baseline; the
  footnote says baselines take 14 days while the Charge seed is 4 nights. Check Android for a twin.
- **F4** (done as #2905): two sleep-debt numbers on one Sleep tab.
- **F5** (UPSTREAM): the Sleep ring's "of 100" is faint white on the light ring face (both modes).
- **F6** (UPSTREAM): Stress tiles truncate their comparison chips ("+2 vs…") at phone width.
- **F7** (done as #2904): Charge breakdown skin temperature ignored °F.
- **F8** (fork, done in v5): one name, "Breathing rate".
- **F9** (fixed upstream as #2906, `eb0391a0`; Round 5): the nudge's need was a
  stored default 8 h nothing set on either platform; it now follows the Sleep tab's need.
- **F13** (UPSTREAM candidate): with no row for today the readiness verdict reads the newest row (an older night)
  beside an "Earlier score" Charge (Round 5).
- **F14** (fork, done `9060515b`): a carried Rest ring now names its day (Round 5).
- **F10** (checked 6 Nov, no change): the 12.0.0 "What's new" expectation ("WHOOP 4.0 is the supported path… deeper
  metrics for 5/MG are still being figured out") matches upstream's current README (WHOOP 5.0 / MG row and the
  "analysis limits" section: live HR confirmed, some overnight inputs unavailable or incomplete on 5/MG). Honest,
  consistent with the docs; not a bug.
- **F11** (audit): one-decimal figures formatted through Foundation's locale formatter (finding 16) can differ
  from Android at a tie. Breathing and skin temperature are guarded; check the rest with a twin oracle.
- **F12** (efficiency, measure first): Simple Today and Simple Stress hide sections whose data is still loaded
  (Key Metrics sparks, Your Cards, Advanced HRV's `freqHRV`/`stressIndex` in `loadDaytime`). Skipping that work
  in Simple mode should cut CPU; prove it with before/after numbers (Rule 1) and keep the full view unchanged.

**Don't:** change a score, formula or stored value without evidence (Rules 2–3); remove a feature (hide it in
Simple mode); let two readouts of one fact disagree; touch the Live screen's layout; skip translations the gate
requires; let the full view drift from upstream (send full-view fixes upstream instead).

## Diary

How Simple mode got here (the 4 Nov request, the first design, Rounds 1–7, every finding and what
happened to it): [Simple mode diary](simple-mode-diary.md).
