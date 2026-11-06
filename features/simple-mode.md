# Simple mode and the human-friendly NOOP project

## Start here (next chat)

**Goal** (Utku, 4–6 Nov 2026; rule in [Rules](../RULES.md#settled-decisions)): a calm, correct, efficient NOOP
that a first-time WHOOP wearer understands. Nothing important is lost: Simple mode is the calm view, Settings →
Simple mode off (or More → All features) shows everything. Utku hands over all operational work: decide, build,
verify, ship; never ask him routine questions (Rules, 6 Nov). He tests on a WHOOP 5.0 + iPhone 16 Plus (AltStore, "just
update"). 6 Nov: "I hate that the original looks like AI slop" — design carefully what to show, hide and emphasize.

**Where things are (6 Nov 2026, end of chat 2):**
- `feat/simple-mode` (worktree `~/Developer/noop-simple`): v1 `ee74a4a1`, v2 `6dca7333`, v3 `5269b8a6`, v4
  `6f073301` `a00000db` `74182550`. iOS + shared Mac code; no Android twin yet. Rounds 1–4 below.
- Phone: `testing-latest` = `testing-build` `5f63e6fa` (stack `af4a35d2` + template), NOOP 12.1.0 (439),
  verified 6 Nov. Just update.
- Upstream PRs (ours): #2896 tab swipe, #2897 translations, #2898 Info.plist, #2899 skin temp once, #2900 one
  sleep need, #2901 Trends "Average", #2903 plain subtitles, #2904 skin temp unit, #2905 sleep-debt source.
  CI: #2901 and #2903 fully green; #2904/#2905 running with Auto-fix on. **#2896–#2900 show a red X only
  because GitHub had no macOS runner** (annotation: "The job was not acquired by Runner of type hosted even
  after multiple attempts"): on these exact heads the NOOPiOS leg passed on 6 Nov and the Strand leg (with
  StrandTests) passed on 5 Nov; each attempt lost the other leg. `gh run rerun` needs admin; close + reopen
  re-runs everything on the same head (done twice on 6 Nov).
- Other worktrees: `~/Developer/noop-subtitles` (#2903), `noop-skinunit` (#2904), `noop-debtsrc` (#2905).

**How to work (what this chat learned):**
- Build: `xcodegen generate`, then `git checkout -- StrandiOS/Resources/Info.plist` (until #2898 merges);
  `xcodebuild -scheme NOOPiOS -destination 'platform=iOS Simulator,name=iPhone 18 Pro' CODE_SIGNING_ALLOWED=NO build`;
  full tests: `-scheme Strand -destination 'platform=macOS' test` (2331 tests on the stack).
- Python tools need `/opt/homebrew/bin/python3.12` (system python is 3.9) and a canonical `TMPDIR` (realpath),
  else 4 `test_check_source_references` tests fail on the macOS `/tmp` alias. CI gates to run before any PR:
  `i18n_audit.py --ci upstream/main`, `doc_comment_lint.py`, `python3.12 -m unittest discover -p "test_*.py"` in
  `Tools/`, and `tests.test_parity_governance_acceptance` (+ `--refresh-derived` for a combined stack).
- New or changed English strings need real translations for de/es/fr/pt-PT (hard gate) and it/pl/ru/zh-Hans/zh-Hant
  (ratchet; an English "translation" counts as an echo and fails). Add them with a small script that inserts
  one-line JSON entries after `"strings": {` in `Strand/Resources/Localizable.xcstrings`; merge catalogue conflicts
  by key with `dist/tools/xcmerge.py` (never by markers). Reusing an existing key avoids new translations.
- Simulator: `xcrun simctl launch "iPhone 18 Pro" com.noopapp.noop --demo-seed` (first launch seeds 120 synthetic
  days ending the day it ran; relaunch to see data; "today" may be unscored, swipe Today right for a scored day).
  The screenshot tool can show the frame before the last action: wait and take a second one. iOS 26 switches do not
  flip on tap in the tool; slide them. Turn Simple mode off without the UI: launch with `-noop.simpleMode NO`.
- Safety-check limits on this Mac: force-push is refused (use the merge-commit route in
  [Workflow §6](../WORKFLOW.md#6-builds-for-utkus-phone)); editing a posted GitHub comment was refused (get claims
  right before posting); a looped `gh pr checks` was refused once (the app's `ccd_pr get_status` or
  `gh run list --branch` work). In zsh always write `"${VAR}:refs/…"` (bare `$VAR:r` is a zsh modifier).
- Verify citations before writing them (one journal name was wrong in a draft commit message and was corrected).
- 6 Nov: the Mac's safety check refused `gh pr create`, `gh pr close`/`reopen` and the Auto-fix switch until Utku
  said yes in chat. When it blocks, tell him once which permission rule allows it (e.g. `Bash(gh pr close:*)`,
  `Bash(gh pr reopen:*)`, `Bash(gh pr create:*)`); never work around it.
- Foundation's `String(format:locale:)` rounds ties half-to-even and prints "-+0.0" (finding 16): for any
  one-decimal figure shared with Android, round explicitly half away from zero first.

**First 20 minutes of the next chat (carryover, in order):**
1. Start procedure (`checkpoint.sh status --net`, `upstream-check.sh`). If upstream moved, check our PR branches
   still merge; rebuild the stack only if needed.
2. PR care: read new comments on all nine PRs and answer each once. If #2896–#2900 are still red, close + reopen
   them ONCE at a quieter hour (one at a time, a few minutes apart); verify every job, not the run's conclusion.
3. Then start the plan below. Commit each step on `feat/simple-mode` (fork) unless it says UPSTREAM.

**The plan: Calm NOOP v5** (design reasoning in "Design v5" below; open findings F1–F12 there):
1. **Today v5** (Apple): the top of Today answers three questions without scrolling (check at 430 pt width):
   *How ready am I?* (rings + one-sentence why), *What should I do today?* (readiness word + suggested Effort
   range + progress so far), *How did I sleep / what about tonight?* (one sleep line, tap → Sleep). Then the
   Charge drivers (top 3 by points, "Show all"), activity, heart rate, last workout, opt-ins, guide link.
   Fix F8 (two names for breathing). Efficiency: skip loading what only hidden sections use (measure, Rule 1).
2. **Sleep v5:** a "Tonight" line from the wind-down resolver (`WindDownNudge`: wake − need − lead). First
   verify F9 (which sleep need it uses); show nothing when no wake time is set.
3. **Workouts (Simple):** lead with recent sessions and this week's summary; heart-rate-recovery trend, 13-week
   calories and the activity breakdown stay in the full view; zones explained in words.
4. **Settings (Simple):** inspect first (3,497 lines). Top: Simple mode, Profile, Units, Strap & devices,
   Notifications, Backup; everything else in one "Advanced" group. Remove nothing.
5. **Alarms:** copy check only. **Live:** leave as is (connect/re-pair lives there; its log is the evidence).
6. **First run / What's new:** plain wording in Simple mode; check F10.
7. **UPSTREAM small fixes**, both platforms where the code exists: F1, F2, F3, F5, F6 (one concern per PR).
8. **Android twin of Simple mode** (after iOS v5 settles) + `noop.simpleMode` in the `.noopbak` whitelist on both
   platforms (byte-identical contract); then propose Simple mode upstream, default OFF (#2463).
9. **Measurement audit:** F11 (finding 16 across other one-decimal figures, by twin oracle); then the Backlog
   biometric queue (evidence first, Rules 2–3).

Each step: build NOOPiOS + Strand, StrandTests, i18n gate (translations for all nine locales via the insertion
script), doc lint, Tools tests; simulator check in Simple and full view; then the testing stack + phone build
(Workflow §6). Tell Utku what he will notice.

**Ask Utku for** (only when useful): screenshots of anything confusing on the iPhone 16 Plus; whether the
suggested Effort range feels right on real days; a strap log if a number looks wrong.

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

**Show / emphasize / hide, screen by screen** (✓ done, → next):
| Screen | Show and emphasize | Hide in Simple (still in full view) |
|---|---|---|
| Today | ✓ rings + captions, ✓ plain Charge drivers, ✓ honest summary lines; → "Your day" card with suggested Effort range and progress; → one sleep line | ✓ Key Metrics, Your Cards, Start session beta, Data sources |
| Sleep | ✓ score, hours vs need, night card, debt ledger in words, trend; → "Tonight" bedtime line | ✓ sleep marks, body clock, stages vs typical, Night detail tiles |
| Trends | ✓ score trends, Average below its range | ✓ CTL/ATL/TSB, PDF export |
| Stress | ✓ level, markers vs your normal, day timeline, trend, guide link | ✓ Advanced HRV, method card |
| Health | ✓ sync, heart rate, vitals, skin temp, Fitness Age, Vitality | ✓ recovery contributors (duplicate), records/sources links |
| Workouts | → recent sessions first, weekly summary, zones in words | → HR-recovery trend, 13-week calories, activity breakdown |
| Settings | → essentials first | → everything else inside one Advanced group |
| Live, Alarms, Lift Log, Breathe | unchanged | — |

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
- **F8** (fork): Simple Today calls breathing "Breaths per minute" (calibrating rows) and "Breathing rate"
  (drivers, guide). Use one name.
- **F9** (must verify before step 2): which sleep need `WindDownNudge` uses versus the ledger's
  `SleepModel.normativeNeedMin`. If they differ, a bedtime line and the debt card would disagree: fix the
  resolver to the one need first (UPSTREAM if Android has the twin).
- **F10** (check): the 12.0.0 "What's new" says "WHOOP 4.0 is the supported path… deeper metrics for 5/MG are
  still being figured out", while NOOP scores Utku's 5.0 nightly. Verify against current upstream docs before
  reporting.
- **F11** (audit): one-decimal figures formatted through Foundation's locale formatter (finding 16) can differ
  from Android at a tie. Breathing and skin temperature are guarded; check the rest with a twin oracle.
- **F12** (efficiency, measure first): Simple Today and Simple Stress hide sections whose data is still loaded
  (Key Metrics sparks, Your Cards, Advanced HRV's `freqHRV`/`stressIndex` in `loadDaytime`). Skipping that work
  in Simple mode should cut CPU; prove it with before/after numbers (Rule 1) and keep the full view unchanged.

**Don't:** change a score, formula or stored value without evidence (Rules 2–3); remove a feature (hide it in
Simple mode); let two readouts of one fact disagree; touch the Live screen's layout; skip translations the gate
requires; let the full view drift from upstream (send full-view fixes upstream instead).

## History: what Utku asked for (4 Nov 2026)

In his words: the app is "AI slop" with "too many things in it". He can't tell what is too much, too little, good
or bad, so he asked for a careful analysis and a better version. He shared a WHOOP 5.0 user's feedback, summarised:

- Too much information, functionality and terminology, much of it unexplained.
- A regular user can't tell what matters or what to do with it.
- They are NOT asking to remove advanced features. They want the important things explained and the rest
  presented so it doesn't overwhelm first-time users: "a basic/advanced mode or better explanations for metrics".

So the goal is: **same app, same numbers, nothing deleted, but a calm default view that explains itself.**

## What is actually wrong (checked in code and in the simulator, 4 Nov)

The problem is less "too many features" than **repetition, two names for one thing, and no explanations**.

1. **The default Today repeats itself.** With default settings, Today shows HRV three times (Key Metrics tile,
   Recovery Vitals row, Your Cards card), resting heart rate three times, breathing twice, and each of the three
   scores twice (the big rings plus Key Metrics tiles). Sources: `KeyMetric.defaultOrder`
   (`Strand/Data/KeyMetricPrefs.swift`), `DashboardCard.defaultSelection` (`Strand/Screens/DashboardCards.swift`:
   stress, fitnessAge, vitality, hrv, restingHr), `recoveryVitalsSection` (`Strand/Liquid/LiquidTodayView.swift`).
2. **Two names for one thing.** The big ring says **Charge**, the tile below says **Recovery** for the same number;
   ring **Effort** vs tile **Strain**. A WHOOP user knows Recovery/Strain/Sleep and is never told the mapping.
3. **One word for two things.** The readiness pill next to the greeting says **"Rest"** on a low day
   (`readinessWord` in `LiquidTodayView.swift`) while **Rest** is also the sleep score.
4. **Jargon labels.** "Synthesis", "Recovery Vitals", "Provenance", "Live Body Console", "Lab Book",
   "Your Data, Fused", "Rhythm", "Intelligence". Screen subtitles are slogans instead of explanations:
   Trends "The thread of you over time.", Explore "Every signal, one tap deep.", Compare "Overlay signals, draw
   conclusions.", Insights "Interrogate what affects what.", Workouts "Every session, threaded together."
5. **More has 27 entries** in 4 groups (`StrandiOS/App/RootTabView.swift`), including five overlapping "insights"
   screens (What Moves You, Intelligence, Insights, Explore, Compare). Two different screens are both titled
   "Insights" (`InsightsHubView`, listed as "What Moves You", and `InsightsView`, listed as "Insights").
   Correction to what was said in chat: 27, not 28.
6. **Beta and diagnostic things sit on the main screen.** "Start session BETA" right under the scores; a
   "DATA SOURCES · Provenance" card at the bottom of Today; the Coach tab is shown even when no AI provider is set
   up (it needs the user's own API key, and it is the one feature that sends data off the phone).
7. **The explainer exists but is hard to read.** `ScoringGuideView` says Effort uses "heart-rate-reserve zones
   (Karvonen) … (Edwards / Banister) … a logarithmic 0-100 scale". Accurate, but not for a regular user. Its copy is
   marked "single approved source of truth, shared verbatim across macOS / iOS / Android", so leave it as the
   technical layer and add a plain layer in front of it.

Already fine, keep as is: Settings already collapses rarely used sections behind "Advanced" (`SettingsView`,
`SettingsDisclosureGroup`); Today sections can already be reordered and hidden (`TodayLayoutPrefs`); the scoring
guide's confidence labels (Calibrating / Building / Solid) are a good idea that just needs plain wording.

Observed but NOT yet confirmed, check before acting:
- Trends in the demo showed "CHARGE 50" at the top and "Week in review · CHARGE 41" lower on the same screen.
  Probably two different windows (this week so far vs last 7 days), but unlabelled. If confirmed, it breaks the
  AGENTS.md rule "two readouts of one fact must not disagree" and is its own small PR, not part of this one.
- In the simulator demo, Today showed "—" and "No data" for Charge while Trends had data. Likely a demo-seed
  artefact (no scored row for today). Confirm before assuming it is a real bug.
- Existing bug found while reading: the tab-swipe gesture in `RootTabView` steps tags with `selectedTab ± 1`
  clamped to 0…4. When Coach is off, tag 3 has no tab, so swiping from Sleep lands on a blank tab. Simple mode
  will hide Coach more often, so this must be fixed as part of the work (step through the visible tags instead).

## Upstream context (check again before starting)

- [ryanbr/noop#2463](https://github.com/ryanbr/noop/issues/2463) "Proposal: an opt-in Simple view" makes the same
  diagnosis. A community member (`andremiliano`) built an iOS prototype called "Glance" on their fork
  (`glance-prototype` branch), opt-in, off by default, not merged as of 4 Nov. **Before writing code, check whether
  Glance or any Simple view has landed upstream.** If it has, build on it instead of duplicating (Rules: never
  duplicate or undo upstream work).
- Upstream commit `18de275e` "take the workout Start back off Today" removes the big green Start workout button
  that the fork's `main` still shows. The fork's `main` was 26 commits behind upstream on 4 Nov; start from
  current `upstream/main`.

## The design

### Decisions

- **One switch: Settings → "Simple mode".** On = the calm view below. Off = today's app exactly as it is now.
  Nothing is deleted in either mode, and every feature stays reachable in Simple mode through More → All features.
- **Default ON in the fork**, because Utku asked for a simpler app. On his phone the update changes Today and More
  straight away; the release note must say how to get the old view back (Settings → Simple mode off). For an
  upstream PR, propose default OFF, matching #2463.
- **Presentation only.** No score, formula, stored value, migration or backup key changes. Every number shown comes
  from the same code the full view uses. Swift and Kotlin analytics stay byte-identical because they are untouched.
- **Full mode stays identical to upstream** so future upstream merges stay easy. The wording fixes (the "Rest"
  pill, the Charge/Recovery mapping) apply in Simple mode only; they are worth proposing upstream separately.
- **Simple mode ignores the Full-mode Today layout** (order, hidden sections, Your Cards, Key Metrics choices) and
  does not change it. Turning Simple mode off brings the user's own layout back untouched.
- **Platforms:** iOS first (Utku's phone), and shared files must keep the macOS app compiling. Android is a
  separate follow-up; say so in the PR (UI parity is feature-level, analytics are untouched).
- **Preference key:** `noop.simpleMode` (Bool), default `true`. Shared by name with Android later, like
  `noop.coachEnabled`. Not added to the `.noopbak` whitelist in this change (that is a byte-identical contract
  with Android; do it together with the Android twin).

### Today in Simple mode

Fixed order, top to bottom:

1. Header: day title, profile/settings button, add button, battery button. **Hide the Customise (sliders) button**
   in Simple mode, since the layout is fixed there.
2. Health alert banner and active-workout card stay exactly as now (safety and an in-progress workout must never be
   hidden).
3. **The three scores.** Same rings. Under each label add one small grey word: Charge → "Recovery",
   Effort → "Strain", Rest → "Sleep" (these words already exist in the catalogue: the Key Metrics tiles use
   "Recovery" and "Strain"). Tapping a ring still opens its history. Tapping the label opens the new plain guide
   (below) at that score instead of the technical scoring guide.
4. **Greeting + one sentence.** The existing synthesis card with the header "SYNTHESIS" renamed to "IN SHORT".
   The readiness pill words become Push / Maintain / **Go easy** (only "Rest" changes, to end the clash with the
   Rest score). The confidence pill (Calibrating, etc.) stays.
5. **"WHAT'S BEHIND YOUR CHARGE"** (the existing Recovery Vitals card, renamed). One caption line:
   "Charge is built mostly from these overnight readings." Each row gets a small hint under its name:
   HRV "higher is usually better", Resting heart rate "lower is usually better", Breaths per minute
   "steady is normal". Values, colours and tap-through routes unchanged.
6. **"TODAY'S ACTIVITY"**: two tiles, Steps and Calories, built with the existing `ktileFor(.steps)` /
   `ktileFor(.calories)` so the values match Full mode exactly. Check that `load()` fills their values even when the
   Key Metrics section is not shown, and render them without the "detailed" sparkline in Simple mode.
7. Heart rate card (unchanged).
8. Last workout card (unchanged).
9. The user's own opt-ins, unchanged and still self-hiding when off: menstrual cycle, journal, added cards,
   "looks like a workout?" suggestion.
10. A small card: **"What do these numbers mean?"** that opens the plain guide.

Hidden in Simple mode (all still in Full mode): Start session BETA, the Key Metrics grid, Your Cards, the Data
Sources card. Result: every number appears once.

### Tabs in Simple mode

Today · Trends · Sleep · More. The **Coach tab shows only if Coach is switched on AND an AI provider is set up**
(`AICoachEngine.isConfigured`; it is not `@Published`, so read it in `body` and accept that the tab appears on the
next redraw after setup). When the tab is hidden, Coach stays reachable from More. Handle every route that selects
tag 3: `router .coach` (notification tap, Today launcher) must open Coach as a sheet when its tab is hidden, never a
blank tab; switching Simple mode on while standing on Coach moves to Today (same as the existing coachEnabled
handling); the swipe gesture steps through visible tabs only.

### More in Simple mode (12 rows instead of 27)

- **YOUR BODY:** Live heart rate (`.live`), Health monitor (`.health`), Stress (`.stress`)
- **TRAINING:** Workouts (`.workouts`), Lift Log (`.liftLog`, Utku's finished feature), Breathe (`.breathe`)
- **TOOLS:** Alarms (`.alarms`), Coach (`.coach`, only when its tab is hidden and Coach is on)
- **YOUR DATA:** Apple Health (`.appleHealth`), Backup & Sync (`.backupSync`)
- **HELP:** What the numbers mean (new), Settings (`.settings`)
- Last row, set apart: **All features** — "Everything NOOP can do, in one list". Pushes the current grouped list
  unchanged (all 27 rows, same collapsible groups, same saved open/closed state).

Implementation shape: move the current four `moreSection` groups into a reusable view so the same list renders
both as the Full-mode More tab and as the pushed "All features" screen; add `MoreDestination.allFeatures` and
`.plainGuide`. Also add the "What the numbers mean" row to the Full list (in the App group) so the guide exists in
both modes. Check that Devices stays reachable in Simple mode (today: Live → Manage devices, and the router sheet).

### Settings

A new card at the very top, before Profile: title **"Simple mode"**, a switch, and the blurb: "Shows the essentials
and explains them. Turn it off to see every feature and arrange Today yourself. Nothing is deleted either way."
Everything else in Settings stays as it is.

### The plain guide: "What the numbers mean"

New shared view `Strand/Screens/PlainGuideView.swift` (iOS + macOS). Works as a pushed screen (from More and
Today) and as a sheet with a close button (from the score labels), optionally opening at one entry. Each entry is a
collapsed row (title + one line) that expands to a short paragraph. Score entries end with a "How NOOP calculates
it" button that opens the existing `ScoringGuideView` at that score, so the technical text keeps its single home.

Screen title "What the numbers mean"; subtitle "Plain explanations of every score and reading. Tap one to learn
more." Section headers: YOUR THREE SCORES · WHAT'S BEHIND YOUR CHARGE · SLEEP · OTHER NUMBERS · GOOD TO KNOW.
"Also called %@" line where an entry has a familiar other name.

Final English copy (each fact was checked against the code on 4 Nov; re-check the marked ones when building):

**YOUR THREE SCORES**

- **Charge** — also called Recovery. *How ready your body is today.*
  A score from 0 to 100, worked out while you sleep. It mostly compares your heart-rate variability and resting
  heart rate with your own normal, and also looks at your sleep, breathing and skin temperature. Higher means more
  ready. On a low day, take it easier and get to bed earlier.
- **Effort** — also called Strain. *How hard your heart has worked today.*
  Counts workouts and everyday activity, from 0 to 100 (or 0 to 21 if you chose that scale in Settings). It only
  goes up during the day and starts fresh each day. There's no perfect number: aim higher when your Charge is
  good, and lower when it's low. A score near 100 is rare.
- **Rest** — also called Sleep score. *How well you slept last night.*
  A score from 0 to 100. The biggest part is how long you slept compared with how much you needed. It also looks at
  how much of your time in bed was sleep, how much was deep and REM sleep, and how regular your bed and wake times
  are. Higher is better.

**WHAT'S BEHIND YOUR CHARGE**

- **Heart-rate variability (HRV)** — *Tiny changes in the time between heartbeats. Higher than your normal is good.*
  Measured in milliseconds (ms) while you sleep. Everyone's normal is different, so only compare it with your own.
  Alcohol, late meals, stress, illness and hard training usually push it down for a night or two.
- **Resting heart rate** — *Your heart rate at rest, measured while you sleep. Lower than your normal is good.*
  Measured in beats per minute (bpm). A few beats above your normal can come from a hard day, alcohol, heat, stress
  or an illness starting. It usually drops slowly as your fitness improves.
- **Breathing rate** — also called Respiratory rate. *Breaths per minute while you sleep. It barely changes from
  night to night.* Most adults breathe about 12 to 20 times a minute at rest. Because it is so steady, a clear jump
  above your normal is worth noticing: it can be an early sign of illness.
- **Skin temperature** — *How warm your skin is overnight.*
  NOOP shows it either as a temperature or as the change from your own normal. Small changes are normal. A rise
  that lasts a few nights can come with illness, heat or a hormonal cycle.
- **Blood oxygen (SpO₂)** — *How much oxygen your blood carries, estimated while you sleep.*
  Most healthy people read 95% or higher. Not every strap can measure it. A reading marked "strap estimate
  (unverified)" is a rough guide only. This is not a medical test.

**SLEEP**

- **Sleep need and sleep debt** — *How much sleep you need, and how far behind you are.*
  Sleep need is the amount NOOP aims for you each night. Sleep debt is sleep you've missed recently compared with
  that need. Paying it back takes a few longer or earlier nights, not one huge sleep.
  *(Verify when building: how sleep need is personalised; the default is 8 h, `Rest.defaultNeedHours`.)*
- **Sleep stages** — *Light, deep and REM sleep, plus short wake-ups.*
  Light sleep fills most of the night. Deep sleep is the most physically restoring and comes mostly early in the
  night. REM is dreaming sleep and comes more toward morning. Short wake-ups are normal. The strap estimates stages
  from heart rate and movement, so treat them as a guide, not a lab result.

**OTHER NUMBERS**

- **Stress** — *How "switched on" your body looked during the day, from 0 to 3.*
  Based on your heart rate and heart-rate variability while you're awake. 0 is calm and 3 is very high. Exercise
  raises your heart rate too, so NOOP tries to leave workout time out.
  *(Verify: the activity-masking in `StressDayCurve` / `DaytimeStress`.)*
- **Heart-rate zones** — *Five bands of effort, from easy (zone 1) to all-out (zone 5).*
  They're worked out from your profile, such as your age. Time in higher zones adds more to your Effort.
- **Estimates** — *Steps, calories, fitness age, VO₂ max and Vitality are helpful guesses, not exact measurements.*
  Steps and calories come from your strap or, if connected, from Apple Health. Fitness age, VO₂ max and Vitality
  are long-term fitness estimates that change slowly over weeks. Watch the direction, not the exact number.

**GOOD TO KNOW**

- **Calibrating, Building, Solid** — *How sure NOOP is about a score.*
  Calibrating means NOOP is still learning your normal, which takes about 4 nights of wear. Building means there's
  enough to show a score, but it will get more accurate. Solid means everything it needs is there. No data means
  there was nothing to score yet. If NOOP can't work out a score honestly, it shows a dash instead of guessing.
- **Why NOOP doesn't match the WHOOP app** — *Same ideas, different maths.*
  NOOP works everything out on your phone using published science. WHOOP's own formulas are private, so NOOP's
  scores usually move the same way as WHOOP's but won't match exactly. Both are estimates from a wrist strap, not
  medical advice.

## Files expected to change

| File | Change |
|---|---|
| `Strand/Data/SimpleModePrefs.swift` (new) | Key, default, the Simple Today section list, pure helpers for visible tabs and swipe stepping (testable). |
| `Strand/Screens/PlainGuideView.swift` (new) | The guide: entry model, sections, expand/collapse, sheet + pushed forms, link to `ScoringGuideView`. |
| `StrandiOS/App/RootTabView.swift` | Simple tabs, Coach routing when its tab is hidden, swipe fix, Simple More, All features, guide row. |
| `Strand/Liquid/LiquidTodayView.swift` | Simple section list, hero captions, label → plain guide, IN SHORT, Go easy, renamed vitals + hints, activity row, guide card, hide Customise. |
| `Strand/App/TabRoute.swift` | `case plainGuide` and its destination (check every exhaustive switch, macOS `RootView` too). |
| `Strand/Screens/SettingsView.swift` | Simple mode card at the top. |
| `Strand/Resources/Localizable.xcstrings` | Every new string with real translations for all nine shipped locales (see below). |
| `StrandTests/…` (new tests) | Default on; Simple Today list includes hero and excludes liveSession/keyMetrics/yourCards; Full layout prefs untouched; visible tabs with Coach on/off/configured; swipe never lands on a missing tag; guide entries have unique ids and non-empty text. |

Do not touch: analytics, storage, BLE, the `.noopbak` whitelist, `ScoringGuideView` copy, Android (separate PR).

## Requirements that make or break the build (learned 4 Nov)

- **Translations are a hard CI gate.** `Tools/i18n_audit.py --ci <base>` fails on any new string in
  `Strand/Resources/Localizable.xcstrings` missing **de, es, fr or pt-PT**, and blocks growth of missing **it, pl,
  ru, zh-Hans, zh-Hant**. It also counts "translations" that are just the English text. So every new string needs a
  real translation in all nine locales. Expect about 75 new strings; add them with a small script that edits the
  JSON catalogue, then run the gate. This is required CI work for a feature Utku asked for, not optional language
  work (see Rules, settled decisions).
- **`xcodegen generate` dirties `StrandiOS/Resources/Info.plist`** (it adds the `.stalebattery` background-task id
  that `project.yml` lists but the committed plist lacks). Restore it with `git checkout -- StrandiOS/Resources/Info.plist`
  before committing; it is not part of this change.
- **Doc comment lint:** insert new declarations above a neighbour's doc block, never between a doc block and its
  declaration (`AGENTS.md`).
- **Design tokens only:** `StrandPalette`, `StrandFont`, `NoopMetrics`, shared components; no hard-coded colours or
  sizes.
- **Shared files must compile for macOS too** (`LiquidTodayView`, `SettingsView`, `TabRoute`, the new guide).

## Verification checklist (all must pass before delivery)

1. `git fetch upstream`; re-check #2463 / Glance and upstream changes to `RootTabView`, `LiquidTodayView`,
   `SettingsView`, `TabRoute`. Create `feat/simple-mode` from `upstream/main`.
2. `xcodegen generate`, then build `NOOPiOS` for the simulator and `Strand` for macOS
   (`CODE_SIGNING_ALLOWED=NO`). Restore Info.plist afterwards.
3. `StrandTests` on macOS (`xcodebuild … -scheme Strand test`), including the new tests.
4. `python3 Tools/i18n_audit.py --ci upstream/main`, `python3 -m unittest discover` for `Tools/` (the
   tools-python suite reads app source and catalogues), and `Tools/doc_comment_lint.py`.
5. Simulator walk-through in BOTH modes, light and dark, plus the largest text size: Today top to bottom, every
   tab, More → every Simple row and All features → a few rows, the guide (pushed and as a sheet from each score
   label), Settings switch on/off and back, Coach routes with no provider. Demo data:
   `xcrun simctl launch "iPhone 18 Pro" com.noopapp.noop --demo-seed` (the first launch seeds; relaunch to see the
   data). The simulator screenshot tool can show the frame from before the last tap; take a second screenshot after
   a short wait before judging.
6. Before/after screenshots go in the PR and in `private/`.
7. Testing build to Utku's phone per `WORKFLOW.md` §6: "just update". Tell him exactly what he will notice and how
   to switch back (Settings → Simple mode off).

## Follow-ups (separate PRs, not part of this one)

- Android twin of Simple mode (Compose `TodayScreen`, More, Settings), plus the `.noopbak` key on both platforms.
- Rewrite the slogan subtitles into plain descriptions (list in "What is actually wrong", item 4).
- Give the two "Insights" screens different names; consider merging What Moves You / Intelligence / Insights /
  Explore / Compare into one "Patterns" hub in Full mode.
- Propose the "Rest" pill wording and the Charge = Recovery mapping upstream for Full mode too.
- Confirm or rule out the Trends 50 vs 41 observation.

## What was built (5 Nov 2026)

Everything in "The design" above, with these settled details:
- `Strand/Data/SimpleModePrefs.swift`: the key, the default, the Coach-tab rule, the visible-tab list and the swipe
  step (pure, tested), and `SimpleTodaySection` (its own enum, so the Android-shared `TodaySection` contract is
  untouched).
- `Strand/Screens/PlainGuideView.swift`: the guide, 15 entries in 5 groups, with the copy above (blood oxygen says
  "95 percent" in words so no `%` reaches a localized string).
- "What's behind your Charge" shows the Charge driver rows from `ChargeBreakdownWiring` (the classic Today sheet's
  resolver, same row, same inputs) once the baseline is learned, and the three vitals with reading hints while it
  calibrates. The separate skin-temperature row the classic sheet adds is not repeated (see findings).
- Coach configured state is re-read by a zero-size probe on appear and on every tab switch, so the tab shell never
  observes the Coach engine (which publishes on every streamed token).
- The Mac app uses the simple Today too when Simple mode is on; its sidebar is unchanged.
- 69 new catalogue strings, translated for all nine locales.

Verification (all on 5 Nov): NOOPiOS simulator build, Strand macOS build, StrandTests all green (11 new in
`SimpleModeTests`), `i18n_audit.py --ci upstream/main` exit 0, `doc_comment_lint.py` clean, Tools core 338 tests and
the parity-governance suites green (the 4 `test_check_source_references` failures seen with the default macOS temp
path are the known `/tmp` alias issue and pass with a canonical `TMPDIR`). Simulator walk-through: Simple Today on a
day with data and on an unscored day, the guide pushed and as a sheet from a score label, Simple More, All features
and a row inside it, the Settings switch both ways live (the simulator tap tool does not flip the iOS 26 switch; a
slide does), full view identical to upstream, light and dark. Stack: release build for a real iPhone green, parity
refresh through the guarded flow (`ratchet errors=0`), i18n gate exit 0; the only conflict was the catalogue, merged
by key with `xcmerge.py` (every key kept).

## Findings while building, and what happened to each

1. **Tab swipe could land on a blank tab** when the Coach tab is absent (iOS only; Android has no tab swipe). Fixed
   in Simple mode, and as a standalone upstream PR [ryanbr/noop#2896](https://github.com/ryanbr/noop/pull/2896)
   (`TabSwipe`, 5 tests). If it merges, switch `SimpleModePrefs.swipeTarget` / `visibleTabTags` to `TabSwipe`.
2. **Skin temperature printed twice** in the Apple Charge breakdown (driver row + `SkinTempDeviationRow`, same
   `skinTempDevC`); Android draws it once. Upstream PR [ryanbr/noop#2899](https://github.com/ryanbr/noop/pull/2899).
3. **Wrong Apple translations:** "Building" = "a building" (pl, pt-PT); "Push" = "push notification" (zh) and "to
   press" (pl). Now match Android's existing wording: [ryanbr/noop#2897](https://github.com/ryanbr/noop/pull/2897).
4. **Info.plist drift** after `xcodegen generate` (`.stalebattery` id): [ryanbr/noop#2898](https://github.com/ryanbr/noop/pull/2898).
5. **Recorded, not changed:** the skin-temperature driver prints "+0.0 C" with no degree sign and always in Celsius,
   even for a Fahrenheit user. It is analytics text pinned byte-for-byte on both platforms (`ChargeDrivers`
   `skinTempDevText` and its Kotlin twin), so it needs a two-platform, oracle-verified change, ideally formatting the
   unit at the display layer.
6. **Recorded, not changed:** German collisions (Recovery and Rest both "Erholung", Effort and Strain both
   "Belastung"), so the Simple captions repeat the label in German. Language work is lowest priority.
7. Unconfirmed, not chased: the Trends "CHARGE 50" vs "Week in review · CHARGE 41" pair; demo Today showing
   "0 total" workouts; demo Charge 41 beside positive driver rows (synthetic stored score, not a real disagreement).

The four upstream PRs (#2896–#2899) are not yet in the testing stack; add them at the next stack rebuild.

## Round 2 (5 Nov 2026, evening): Sleep and Trends, two more upstream fixes

Utku's direction: the main focus is a human-friendly, simple UI (nothing important lost); fix proven errors in
biometrics, sensors, methods or efficiency; no language work.

**Simple mode v2** (`feat/simple-mode` commit `6dca7333`):
- Sleep leads with the night: score, then "6h 42m asleep · 8h 0m needed" on its own panel (white text washed out
  in Light mode where the night scene fades), then the night card (bed/wake, stages, naps), sleep debt once (the
  ledger, with its plain advice), the hours-slept trend, and Alarms at the foot. Sleep marks, the body-clock dial,
  stages-vs-typical and the Night detail tiles stay in the full view. The need on the new line is the ledger's
  (`SleepModel.normativeNeedMin`, or the night's imported need), so they cannot disagree.
- Trends drops the mislabelled range-average trio, the CTL/ATL/TSB training-load chart and the PDF export row.
- Verified: NOOPiOS build, StrandTests 2314 green, i18n gate, doc lint, simulator walk-through of both tabs.

**Findings and fixes this round:**
8. **Two sleep-debt numbers on one Sleep tab** ("35m" tile vs "1h 31m" ledger in the demo): the tile takes an
   imported WHOOP debt verbatim, the ledger always computes NOOP's own; both just say "sleep debt". Simple mode
   shows the ledger only. Full view still shows both (candidate: label the tile's source or align the rule).
9. **"Hours vs needed" used a second sleep need** (mean sleep floored at 7.5h) while debt, the trend need line and
   the Rest score use the normative need (P75 floored at 8h): fixed on both platforms in
   [ryanbr/noop#2900](https://github.com/ryanbr/noop/pull/2900), with sources (Van Dongen 2003, Klerman & Dijk
   2005, Watson 2015, Hirshkowitz 2015) and tests on both sides.
10. **Trends "Week in review" averaged the 3M range, not the week**, above the range picker:
    [ryanbr/noop#2901](https://github.com/ryanbr/noop/pull/2901) moves it below the picker and titles it "Average"
    (both platforms, existing strings).
11. Not a bug: Effort shows one decimal on the 0–100 scale in the digest ("37.0"); that is the app-wide
    `effortDisplay` convention, only the Today ring is whole.
12. Upstream CI note: the NOOPiOS leg of App build on #2896/#2897/#2899 was cancelled with no runner ever assigned
    (infra, not code); a comment on each PR asks for a re-run (the fork cannot re-run upstream jobs).

## Round 3 (6 Nov 2026): plain wording on Simple Today and Simple Sleep

`feat/simple-mode` commit `5269b8a6`. Same numbers, same order, same rules; only words, only in Simple mode.
- **Charge rows** ("What's behind your Charge") go through `Strand/Screens/PlainChargeWording.swift`, a display-
  layer translator: "89 ms · 85 ms baseline · above baseline, supporting recovery" reads "89 ms · usually 85 ms ·
  Higher than your normal, which raised your Charge." The sentence is chosen by the signed points the chip
  prints, so it can never say "raised" beside a negative chip (pinned over 1,000+ rows from the real driver
  builder). "Sleep quality 92%" is the Rest score, so it reads "Rest 92". Unknown future verdicts fall back to
  the original text. The caption says what the chip number is.
- **Skin temperature** in those rows uses °F for a Fahrenheit reader (from the unrounded deviation, 9/5, no +32)
  and a degree sign. Finding 5 is fixed for Simple mode; the full view still prints "+0.4 C vs baseline".
- **Earlier score:** when today's Charge is not ready, the ring carries the latest scored day. Upstream's Liquid
  Today computes that day's caption ("Last night · 4 Nov") but never shows it, and its pill says "Last night"
  even for a days-old score. Simple mode shows the day under the ring and the pill says "Earlier score". The
  pill opens the guide at its entry (which now explains Earlier score), and the guide now scrolls to the entry
  it is opened at. Candidate upstream fix for the full view: show the carried day.
- **First nights:** the summary says "Learning what's normal for you: N of 4 nights so far…" instead of
  "Learning your baseline".
- **Sleep:** debt card title "Sleep debt", plain advice (need + debt tonight clears it; older shortfalls count
  less: the ledger's 0.55 carry), a line saying what the bars are, "Sleep need"; stage card "6h 49m in bed,
  asleep for 98% of it · stages are estimates" and "Deep + REM sleep"; plain movement-strip and partly-recorded
  notes.
- 36 new strings (all nine locales), 2 fork-only v1 strings replaced and removed.

Verification (6 Nov): branch: NOOPiOS simulator build, StrandTests 2320 green (6 new in
`PlainChargeWordingTests`), i18n gate exit 0, doc lint clean, Tools core 338 OK, parity acceptance 50 OK,
simulator check of Simple Today (carried day, rows, pill → guide at the entry), the calibrating state and
Simple Sleep. Stack `a863d3c8`: iPhone Release build, StrandTests 2337, i18n, parity acceptance; shipped as
`testing-build` `4d18cf00` (run 42115214139). Details in State.

Findings this round:
13. Carried Charge's day never shown in the Liquid Today, and the pill's "Last night" can be wrong (above).
14. The Sleep ring's "of 100" is faint white on the light ring face (both modes); not changed.
15. The guide opened at an entry did not scroll to it (fixed in v3).

## Round 4 (6 Nov 2026, morning): Simple Stress, two upstream measurement fixes, honest lines

**Simple mode v4** (`feat/simple-mode` `6f073301`, plus `a00000db`):
- **Stress** in Simple mode keeps the level, today's markers, the day's timeline and the trend. The Advanced HRV
  readouts and the method card stay in the full view; a link to the guide's Stress entry replaces the method
  card. Plain labels: "vs your 30-day normal", "Stress through the day", "Daily stress, from 0 (calm) to 3
  (very high)", and a timeline caption without "proxy"/"baseline".
- **"Still learning your baseline" was false** for anyone with history: readiness `.insufficient` mostly means
  today's row is not in yet (ReadinessEngine reads only today's row), so the line showed every morning before
  the night synced. Simple mode says "Today's readings aren't in yet. They arrive once your strap syncs last
  night's sleep." The full view still has the false line: upstream candidate (both platforms).
- **"Last night · 4 Nov" on the 6th:** the carry caption says "Last night" for anything up to two days old
  (`carryFreshnessDays = 2`). Simple mode shows only the date ("From 4 Nov"). Upstream candidate.
- `a00000db`: Simple mode's skin-temperature figure now rounds like the full view and Android (below).
- **Health monitor** (`74182550`): Simple mode leaves out the recovery contributors (they repeat Today's Charge
  drivers but score against their own simple average of prior nights, and their footnote says 14 days while
  the Charge seed is 4 nights: a full-view "two readouts" problem, upstream candidate) and the records/sources
  links (still in All features).
- Live was looked at and deliberately left alone: it is where people connect and re-pair, and its log card is
  the evidence Utku sends. Workouts and Alarms are still to review (roadmap item 2).

**Two upstream fixes, both platforms, opened 6 Nov as [#2904](https://github.com/ryanbr/noop/pull/2904) and
[#2905](https://github.com/ryanbr/noop/pull/2905)** after Utku's explicit yes (the Mac's safety check had first
refused `gh pr create` as "Create Public Surface"; an explicit request in chat let it through):
- `fix/charge-skin-temp-unit` `2d482919` (worktree `~/Developer/noop-skinunit`): the Charge breakdown's skin
  temperature ignored °F and had no degree sign, on both platforms. Display layer only. Fork Android CI
  42167206054 green (APK + unit tests). Oracle: Swift twin over 21 inputs per unit, stdout pasted into
  `ChargeDriverTempDeviationTest`.
- `fix/sleep-debt-tile-source` `a41d40d7` (worktree `~/Developer/noop-debtsrc`): finding 8. The Night detail
  tile now says "From WHOOP" when its latest value is WHOOP's imported figure (the ledger is always NOOP's).
  Fork Android CI 42168057358 green.

**Finding 16, Foundation formatting:** `String(format:locale:)` with `en_US_POSIX` prints "-+0.0" for a negative
zero and rounds a shortest-representation tie half-to-even (0.25 → 0.2, -0.05 → -0.0), while plain
`String(format:)` (C printf) and Java's Formatter differ again. Any one-decimal figure formatted that way can
differ from Android at a tie. Breathing is already guarded by `RecoveryScorer.displayRounded`; skin temperature
now is. Other one-decimal read-outs formatted with a locale are a candidate audit (measure before claiming).

