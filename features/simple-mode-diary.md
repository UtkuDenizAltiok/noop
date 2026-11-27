# Simple mode diary

The record behind [Simple mode](simple-mode.md): what Utku asked for on 4 Nov 2026, the first design, and each
round as it was built, with the findings and what happened to each. Current work and rules live on the main
page; this page is history and is not updated except to add a round.

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
- **Default ON in the fork**, because Utku asked for a simpler app. On the owner's phone the update changes Today and More
  straight away; the release note must say how to get the old view back (Settings → Simple mode off). For an
  upstream PR, propose default OFF, matching #2463.
- **Presentation only.** No score, formula, stored value, migration or backup key changes. Every number shown comes
  from the same code the full view uses. Swift and Kotlin analytics stay byte-identical because they are untouched.
- **Full mode stays identical to upstream** so future upstream merges stay easy. The wording fixes (the "Rest"
  pill, the Charge/Recovery mapping) apply in Simple mode only; they are worth proposing upstream separately.
- **Simple mode ignores the Full-mode Today layout** (order, hidden sections, Your Cards, Key Metrics choices) and
  does not change it. Turning Simple mode off brings the user's own layout back untouched.
- **Platforms:** iOS first (the owner's phone), and shared files must keep the macOS app compiling. Android is a
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
7. Testing build to the owner's phone per `WORKFLOW.md` §6: "just update". Tell him exactly what he will notice and how
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


## Round 5 (6 Nov 2026, evening): Today v5, the top answers three questions

`feat/simple-mode` commit `5050c8f3` (plan step 1). Presentation only; the full view is unchanged (checked in the
simulator with `-noop.simpleMode NO`).
- **"Your day"** replaces the greeting row + "In short" card: greeting with the Charge-state pill, then one card with
  the readiness pill (tap → guide entry "Your day and suggested Effort") and its sentence, then **Suggested Effort**:
  the range on the reader's scale, "An easy / a moderate / a hard day, based on your Charge", a bar (thin track,
  Effort fill in the Effort colour, the range as a taller outline in the Charge colour, `SimpleEffortBar`, drawn
  still) and one progress line ("So far 23. The range starts at 48." / "You're in the range." / "past the range.
  Take the rest of the day easy." / "No effort measured yet today."). The "show" expander is gone in Simple mode
  (it repeated the sentence). A plain zero-Effort note replaces the "50% of heart-rate reserve" one.
- **The range** is `CoupledView.optimalStrainRange` (upstream's approved task #43 mapping, already behind the
  Coupled view and the optimal-strain nudge), converted with `StrainScorer.effortValue(fromWhoopStrain:)` (14–18 →
  67–86, 10–14 → 48–67, 4–10 → 19–48). Rules in `Strand/Data/SimpleDayPlan.swift`: only for TODAY's OWN Charge
  (never a carried, calibrating or past-day score), and only beside a readiness verdict that says the same thing,
  because ReadinessEngine also weighs training load and breathing: primed → hard only; balanced → moderate or hard;
  strained/rundown → easy only; insufficient → any (no verdict to contradict). Progress is judged on the number as
  the ring prints it (`effortText`, the ring's own two expressions). The guide states the bands in words, not
  numbers, because a Charge of 66.6 prints "67" but maps to the moderate band (the mapping reads raw recovery).
- **"Last night" line** (asleep · needed, tap → Sleep, today only, hidden until the night is in the day row). It and
  the Simple Sleep tab's line share `SimpleDayPlan.sleepVersusNeed` + `durationText`: the day row's total (what the
  Rest score and the Coupled view read; upstream precedent) and the imported need, else `SleepModel.debtNeedMin`.
  Demo check: Today and Sleep both "6h 47m asleep · 7h 16m needed", stage card 6h 47m.
- **Charge readings:** the three that moved the score most first (|points|, ties keep order), "Show all N" /
  "Show fewer"; the bar scale stays the largest of all rows.
- **F8 fixed:** the calibrating row says "Breathing rate".
- **Honest sentence:** when readiness has no verdict but today's Charge is scored (Charge seeds at 4 nights,
  readiness needs 7), Simple mode says NOOP needs about a week before it weighs all signals and that the
  suggestion follows Charge alone; on a past day it no longer says "today's readings aren't in yet".
- 18 new strings, all nine locales (one-line entries inserted after `"strings": {`, as in "How to work"; the guide's
  readiness words use #2897's corrected pl/zh translations). The range figures go through `SimpleDayPlan.rangeText` because the
  i18n gate flags an interpolated `Text(verbatim:)` literal as un-extracted copy.

Verification (6 Nov): branch: NOOPiOS simulator build; StrandTests 2329 green (9 new in `SimpleDayPlanTests`, 2
skipped as before); i18n gate exit 0; doc lint clean; Tools 338 OK; parity acceptance 50 OK; simulator in light
and dark, full view unchanged, sleep line → Sleep tab, "Show all 5", pill → guide entry. Demo note: the first
launch after an old seed showed Charge "From 4 Nov" with no range (correct: an old Charge gives no advice); reseed
by uninstall + `--demo-seed` to get a day with today's own score.

Findings this round:
- **F9 verified, they differ:** `WindDownNudge.sleepNeedMinutes` is a stored `windDown.sleepNeedMinutes` (default
  8 h, clamped 5–11 h) that nothing on iOS writes; the ledger uses `SleepModel.debtNeedMin` (or WHOOP's imported
  need). Android `WindDownStore` has the same key. So a "Tonight" line from the nudge would contradict the debt
  card, and the Alarms copy "A calm nudge 8h 30m before your usual wake time" already states a different need from
  Sleep. Fix the nudge to the one need first (UPSTREAM, both platforms, it moves when the reminder fires: explain
  in the PR), then build Sleep v5's line on it.
- **F13 (UPSTREAM candidate, Apple only, a parity bug):** when today has no row, `LiquidTodayView.load()` calls
  `ReadinessEngine.evaluate(days:today: day?.day)` with `nil`, and the engine then reads the NEWEST row, so the
  verdict ("Maintain") can describe an older night while Charge shows "Earlier score · From 4 Nov". Android always
  passes a key (`TodayScreen.kt` `today = logicalDayKeyNow()` / `anchorKey`), so it says "insufficient" there.
  Fix: pass the selected day's key on Apple; test both platforms agree. It must ship WITH the F1 fix (or after it):
  on its own it makes the full view print F1's false "Still learning your baseline" every morning before the
  night syncs, where it currently prints an older night's verdict.
- **F14 (fork, fixed in `9060515b`):** the Rest ring carried a still-fresh earlier night (`TodayView.freshRestScore`
  tail fallback) with no date under it, unlike Charge's "From 4 Nov". Simple mode now prints "From 4 Nov" under it
  (`SimpleDayPlan.carriedRestDay`, unit-tested; the fresh demo seed could not show a carried Rest on 6 Nov, so the
  carried case is proven by the test only, and today's own score was checked to show no date).

## Round 6 (6 Nov 2026, night): the reminder's need, a "Tonight" row, Simple Workouts

**UPSTREAM [#2906](https://github.com/ryanbr/noop/pull/2906)** (F9, both platforms): the wind-down nudge keeps its
stored need equal to the Sleep tab's (`adoptSleepNeed` on each history change, writes only when the rounded need
moves), and the Apple Alarms copy states need + lead. Details, oracle and CI in State "Now". Its macOS `Strand` leg
was cancelled with no runner (the same GitHub capacity problem as #2896–#2900); a comment says so
(issuecomment-6693087675). Lesson: `git commit --amend` of a pushed commit is refused as destructive; build a
clean branch with `git merge --squash` from the old one instead (no force push, old branch untouched).

**Tonight row** (`feat/simple-mode` `256a2dc4`, plan step 2b, on Today rather than the Sleep tab: the evening
question belongs on the screen people open; the Sleep tab keeps its Alarms entry). In the Today sleep card,
under "Last night": "Aim to be asleep by 22:20" + "That gives you 8h 40m of sleep before your 07:00 wake. Your
wind-down reminder comes at 21:50." Rules (`SimpleDayPlan.tonightPlan`): only while the reminder is ON (#2353:
its wake time is otherwise an unused setting) and only while the fall-asleep time is ahead (not late evening,
not after midnight); the reminder's own inputs and wall-clock arithmetic, so "wind down at" is the minute the
notification fires (tested, incl. per-day wake times and #1863's early wake). If last night's line shows a
different need (WHOOP's imported need for that night), tonight's row leaves out its duration ("Your wind-down
reminder comes at 22:30, ahead of your 07:00 wake.") instead of printing a second need. Today observes the four
reminder keys (`SimpleDayPlan.ReminderKeys`, pinned by `WindDownMirrorKeyTests`) so switching the reminder off in
Alarms removes the row at once. Depends on #2906 for the need to equal the Sleep tab's (true in the stack).

**Simple Workouts** (`c94f3260`, plan step 3): Start / Add, the range picker, one summary card (typical Effort,
sessions, active time, "Mostly Walking"), the sessions, then the zone split in words with the guide's zones entry.
Left to the full view: Current/Archived, sport/source/search filters, multi-select, the stat tiles (they repeat
the card), the 13-week calorie map, per-sport breakdown, heart-rate-recovery trend, the per-row source badge
(it cut the date/time/duration line short) and the "Top sport 2×" tile. Simple mode shows the whole selected
range (no hidden ten-newest cut, so the summary counts what the picker names) and applies no leftover filter;
it skips the 100-day calorie read and the per-session HR reads (less work, not measured yet).

Verification: branch StrandTests 2338 green (new `SimpleTonightPlanTests`, `WindDownMirrorKeyTests`), i18n exit
0, doc lint, Tools 338, parity 50; simulator: Tonight row with the reminder on (and the no-number variant on the
demo's imported need), gone with it off; Simple Workouts top to bottom. Lesson (Rule 11 again): a test helper
named `instant(_:_:_:)` collided with `GarminExportParser.instant` and moved the parity baseline
(`test-only-callsite|Packages/StrandImport`); renamed to `tonightFixtureInstant`.

**Simple Settings** (`610c3505`, plan step 4): open: Simple mode, Profile, Units, Strap, Live notifications (iOS);
one closed "More settings" row (same `SettingsDisclosureGroup` as Advanced) holds Appearance, Streak, Features
(optional trackers) and Sync; Advanced and About unchanged. Simple mode also drops the "Settings" overline above
every card (upstream candidate: it is noise in the full view too). Backup stays in Advanced because Simple More
already lists "Backup & Sync" as its own screen. 3 new strings. Branch: StrandTests 2338, i18n 0, doc lint,
Tools 338; simulator checked.

**Alarms wording** (`0a6f3021`, plan step 5): Simple mode says the strap alarm's evidence plainly ("Confirmed on
WHOOP 4.0. Keep a backup alarm for anything you can't miss.") instead of "community wire capture + on-device test,
#535". The 5/MG experimental description and everything #2700 touches are left alone. NOT yet in the stack: add it
at the next stack rebuild. Branch: StrandTests 2338, i18n 0, doc lint, Tools 338.

## Round 7 (12 Nov 2026): show everything on this screen, Report a problem, Lift Log guard

Built by an Opus 5.5 worker from the brief below, reviewed by the architect (Fable 5.2), on the phone in build
`218aec72` (12 Nov). `a639d47a`: each simplified screen ends in "Show everything on this screen" (one funnel,
`SimpleModePrefs.isSimple`), Simple More became data (`SimpleMoreEntry`) with a test pinning the Lift Log,
"Report a problem" (Test Centre) joined Help, and the "All features" caption became true. `258e0bf2`: "Back to
the simple view" returns the screen to its top (it left a blank page on lazily built screens). The heart rate
warning was built the same day on `feat/high-hr-warning`: [its page](high-hr-warning.md).

#### Worker brief A1 (done) — "Nothing lost, one tap away" (copy this to an Opus 5.5 chat)

```text
You are an implementation worker for NOOP in ~/Developer/noop. Read AGENTS.md, dist/AGENTS.md and dist/RULES.md, then "How to work" and "Step 1 specification" in dist/features/simple-mode.md, and implement that specification exactly on the existing branch feat/simple-mode in its worktree ~/Developer/noop-simple. Do not redesign it: if the code contradicts the page, stop and report instead of improvising. Never hide, shorten or restyle any part of the Lift Log. Verify before you finish: NOOPiOS simulator build, Strand macOS build, StrandTests (every new test seen to fail once), Tools/i18n_audit.py --ci upstream/main, Tools/doc_comment_lint.py, the Tools unittest suite, and a simulator walk through Today, Sleep, Trends, Stress, Health and Workouts in Simple mode: tap "Show everything on this screen" on each, confirm the full layout appears, tap "Back to the simple view", and confirm the full view (Simple mode off) is unchanged. Commit and push the branch. Do NOT touch testing-stack, testing-build or any upstream PR. Hand back: the commit ids, the exact test counts, anything you could not verify, and every place where you had to deviate from the page and why.
```

#### Step 1 specification (built as `a639d47a` + `258e0bf2`)

- **One funnel.** `SimpleModePrefs.isSimple(stored: Bool, showingAll: Bool) -> Bool` (`stored && !showingAll`),
  unit-tested. In each of `LiquidTodayView`, `SleepView`, `TrendsView`, `StressView`, `HealthView`,
  `WorkoutsView`: rename the stored `@AppStorage` property to `simpleModeStored`, add
  `@State private var showAll = false` and `private var simpleMode: Bool { SimpleModePrefs.isSimple(stored:
  simpleModeStored, showingAll: showAll) }`. Every existing `simpleMode` read then follows by itself, including
  the `.task(id:)` strings that already carry it, so data the full layout needs is loaded when the row is tapped.
  `SettingsView` and `SmartAlarmView` are not changed (Settings already has "More settings"; Alarms only rewords).
- **One row.** New shared view `SimpleModeShowAllRow(showingAll: Binding<Bool>)` in
  `Strand/Screens/SimpleModeShowAllRow.swift` (design tokens only, the look of the "All features" row). Collapsed:
  title "Show everything on this screen", caption "The full version, with every card and tool." Expanded: title
  "Back to the simple view", no caption. It is the LAST element of each of the six screens whenever
  `simpleModeStored` is true (so it is there in both states), and absent when Simple mode is off.
- **It stays until tapped back** (or the app restarts). No auto-reset on leaving the screen: a reset on
  `onDisappear` would also fire when a detail screen is pushed, and the wearer would come back to a different
  layout.
- **Today:** with `showAll` the wearer's own full layout renders (their saved order, Key Metrics, Your Cards, Data
  sources) and the Customize button returns.
- **A true caption.** In `SimpleMoreIndex.allFeaturesRow` replace "Every screen and tool, exactly as before."
  with the existing string "Every screen and tool NOOP has." (already translated; remove the old key if nothing
  else uses it).
- **Help when something is wrong.** Simple More → Help gains "Report a problem" (`stethoscope`) → the Test Centre,
  between the guide and Settings: the strap log lives there and was three taps and a collapsed group away.
- **Lift Log guard (Utku's rule).** Make the Simple More list data: in `SimpleModePrefs`, an enum
  `SimpleMoreEntry` (one case per row, with its group) that `SimpleMoreIndex` renders through an exhaustive
  `switch` to `MoreDestination`. `SimpleModeTests` pins that the entries contain `.liftLog` in the Training
  group, and that every entry is rendered (the exhaustive switch makes a forgotten row a compile error).
- **Tests:** `isSimple` truth table; the Lift Log pin; the entry list has no duplicates. New strings (4): all
  nine locales.

**Ask Utku for** (only when useful): screenshots of anything confusing on his iPhone; whether the
suggested Effort range feels right on real days; a strap log if a number looks wrong.

## Round 8 (15 Nov 2026): the first-time-wearer walk behind Design v6

Chat 5, architect (Fable 5.2), no helper agents (Utku's instruction). The phone's exact code (`testing-stack`
`25aa5f38`) was built for the simulator in a scratch folder (`~/Developer/noop-v6walk`, detached), installed
fresh, and walked twice: once with no data (first launch) and once with the 120-day demo seed. Screenshots are in
`~/Library/Caches/noop-handbook/v6-walk/shots/` (this Mac only). Every screen was read as a person who has never
used a WHOOP. The demo carries WHOOP-imported figures, so where a finding could be a demo artefact it says so.
The design that answers these is [Simple mode → Design v6](simple-mode.md#design-v6-the-most-user-friendly-noop).

**First launch and first week**
- **W1.** The 12-step first-run wizard talks about "recovery, sleep and strain" and in slogans ("Three quiet
  promises", "Your thread starts here"). It never says Charge, Effort or Rest, the three words the app then uses,
  and never says what the first days will look like.
- **W2.** After setup Today shows three dashes and "Calibrating". Nothing says what comes when. The code has five
  different waiting times: Charge 4 nights (`Baselines.minNightsSeed`), full trust 14 (`minNightsTrust`), the
  day's advice about a week, a personal sleep need 7 nights (`Rest.minNeedNights`), stress against 30 days.
- **W3.** With the strap not connected, Today says "Strap not connected. Connect your strap to see live heart
  rate" and offers no button. Connecting lives in More → Live heart rate. The header shows only an unlabelled icon.

**Today**
- **W4.** Three round icon buttons in the header with no words (profile, add, strap).
- **W5.** A "WHOOP" badge on the score card (and twice on Sleep) that nothing explains. It marks imported figures.
- **W6.** Six words for three things: CHARGE/Recovery, EFFORT/Strain, REST/Sleep under the rings; the Sleep tab
  shows the Rest score with no name; the wizard says recovery/strain/sleep.
- **W7.** The score numbers carry no word. Is a Charge of 51 good? Only the ring colour hints. Effort "67" of what?
- **W8.** "Good afternoon" with a "Solid" pill beside it reads as a judgement of the person. It is how sure NOOP
  is of the score.
- **W9.** The "Maintain" pill is coach jargon; the sentence under it is clear.
- **W10.** "Suggested Effort 48–67" is good, but Effort has not been explained by that point.
- **W11.** In "What's behind your Charge" the dotted bar under each reading shows how much it moved the score, not
  the reading. "Rest 87" sits above an almost empty bar and looks like a low score.
- **W12.** The Steps and Calories bars fill toward hidden goals (10,000 steps and 800 kcal in
  `LiquidTodayView.ktileFor`). "Calories" are active calories only; the tile does not say so.
- **W13.** The heart-rate card opens "Deep Timeline": tabs "Windowed rMSSD", "SpO₂", a switch "Owned / All", and
  "Nothing offloaded for this window yet".
- **W14.** Tapping a score ring opens the statistics page (`MetricDetailView`): a table of readings with their
  source, "What correlates · Pearson r over the visible window · |r| ≥ 0.30, n ≥ 10", "sparse, widened to…". The
  biggest thing on the screen leads to the least plain screen in the app. (The simulator's tap tool did not open it;
  read in code: `detailRoute: .metric(HeroRingMetric.charge)`.)
- **W15.** "LAST WORKOUTS · 1 total" counts today only. A workout's Effort prints one decimal (39.7), the ring none.
- **W16.** The evening question (when should I go to bed?) is answered only if the wind-down reminder was switched
  on in Alarms. By default Today says nothing about tonight.

**Trends**
- **W18.** Two time controls on one screen (a week stepper on top, a range picker below) with nothing saying which
  part each one moves.
- **W19.** "+6%" chips with no "compared with what".
- **W20.** The week's sentence is jargon: "you leaned into the red. Watch for a recovery dip."
- **W21.** "Share recap" is the first button, before anything is explained.
- **W22.** "TRAILING 90 DAYS", "MEAN", "90 readings"; the number in each chart's corner has no label (it is the
  average).
- **W23.** No chart says in words whether it is going the right way.
- **W24.** Effort shows a decimal here (59.2) and none on Today.

**Sleep**
- **W25.** The score is "Rest" on Today and unnamed on the Sleep tab; the word under it is "Optimal".
- **W26.** Text drawn straight on the night picture is hard or impossible to read: the heading "Asleep duration",
  the movement note, the "partly recorded" note.
- **W28.** "Deep + REM sleep 2h 36m, typically 3h 14m" and the stage percentages carry no verdict and no normal
  range.
- **W29.** The sleep need is 8h 0m for nearly everyone (science finding S1). In the demo the top line says "8h 50m
  needed" (WHOOP's imported figure for that night) while the debt card below says "Sleep need 8h 0m".
- **W30.** Durations come in three shapes: "7h 39m", "7.3 h avg", a trend chip "−0.0 h"; "Balance −37m" beside
  "≈37m sleep debt".

**Stress**
- **W33.** The big number is not what the subtitle says (science finding S2).
- **W34.** Its sentence gives training advice ("A great day to push if you want to") while Today said "Maintain,
  a moderate day" for the same morning.
- **W35.** The number appears twice (ring and tile); comparison chips are cut off ("−5 vs…"); a good resting heart
  rate is printed in warning orange; "Calm time 23%" counts days, not time; the chart title is "STRESS · M"; eight
  range buttons here against six on Trends.

**Health monitor**
- **W36.** It opens with a sync card and never says in words whether the vital signs look normal.
- **W37.** Two ages on one screen: "Fitness Age" and "Body Age", two different numbers (demo data).
- **W38.** Jargon: "RESP RATE 14.2 rpm", "RAW SPO₂ · No raw SpO₂ decode…", "SKIN TEMP Δ +0.1 Δ°C", "State: Idle",
  "in-range", "baseline", "On-device · Unknown".
- **W39.** "Resp rate" here, "Breathing rate" on Today; "Blood O₂" here, "Blood oxygen" in the guide.
- **W40.** Check on the phone: the demo shows VO₂max 52 (very fit for a man of 30) beside "4 years older than your
  age". Probably the demo's stored values; the engine derives both from one model.

**Workouts**
- **W41.** "TYPICAL EFFORT 47.2 of 100 · Effort this week": what the number is, and whether the week was enough,
  is not said.
- **W42.** Session lines are cut off ("256…"); the blue number has no label.
- **W43.** "3.4h" in decimal hours.
- **W44.** The zone split has no meaning attached, and "Only sessions imported from WHOOP carry zones".

**Live, Alarms, More, the guide**
- **W45.** Live: "Start a live stream" (kept as it is; it is where the strap is connected).
- **W46.** Alarms: "to land at your usual wake time rested"; "Confirmed on WHOOP 4.0" for a 5.0 wearer (honest).
- **W47.** More has no row for the strap itself, and no row says what it is for ("Health monitor", "Breathe",
  "Coach").
- **W48.** The guide is good but it is a separate place; the explanation is rarely next to the number.

**Across screens**
- **W49.** Number shapes differ (decimals on scores, decimal hours).
- **W50.** Range pickers differ (7D/30D/90D/1Y/All; W/M/3M/6M/1Y/ALL; W/2W/3W/M/3M/6M/1Y/ALL).
- **W51.** Colour: a metric's own colour (orange for resting heart rate) is used for its value even when the
  value is good, so orange does not reliably mean "watch this".

**Science findings (checked in code, sources read on 15 Nov)**
- **S1. Sleep need is a flat 8 hours for almost every adult.** `AnalyticsEngine.Rest.personalizedNeedHours`: 8 h
  until 7 nights exist, then the wearer's upper-quartile night, never below 8 h (`populationNeedFloorHours`) and
  never above 9.5 h. So it can only go up, and only for people who often sleep more than 8 h. Age is passed only by
  the scoring engine (`IntelligenceEngine`), not by the Sleep tab, and every adult age gets 8 h, although the
  National Sleep Foundation recommends 7–8 h from 65 (Hirshkowitz 2015; the code comment says "65+: NSF 7–9").
  Is 8 h defensible? Yes as a starting target for a young adult: the recommended range is 7–9 h (NSF 2015; AASM and
  the Sleep Research Society: 7 or more), and the one laboratory study that measured it (Kitamura 2016, Sci Rep
  6:35812, PMC5075948, 15 healthy young men, nine nights of extended sleep) found an optimal sleep time of 8.41 h
  on average, between 7.29 and 9.26 h from person to person, about an hour more than they slept at home; one hour
  of such debt took four days to recover. Not defensible as a fixed truth for one person: needs differ by about two
  hours, fall with age, and NOOP can never learn that somebody needs less than 8 h. WHOOP does not use a flat
  figure: its help pages describe a personal baseline learned over the first weeks, plus extra for the day's strain
  and for sleep debt, minus naps, and a goal of 100, 85 or 70 % of that (its formula is not published).
- **S2. The daily "Stress" number is last night's resting heart rate and HRV against the 30-day normal**
  (`StressView`: two z-scores summed and squashed onto 0–3, 1.5 = your normal). It is the same information as
  Charge, turned upside down. The subtitle (ours, from #2903) says "while you were awake", which is true only of
  the "Stress through the day" line (`DaytimeStress`).
- **S3. Rest gives full marks for deep + REM at 50 % of sleep** (`Rest.restorativeTarget`), while sleep-laboratory
  norms for adults are roughly 13–23 % deep and 20–25 % REM, about 35–45 % together. NOOP's own stage estimate
  reads more REM than a laboratory does (History: DREAMT 19.9 % against 10.5 % of the night; the owner's nights read high
  too, private), so the high target roughly cancels the over-reading. Changing one without the other would make
  the score worse. A research item, not a v6 change.
- **S5. Hidden goals:** 10,000 steps (a round number from marketing, though close to where the benefit levels off
  for adults under 60: Paluch 2022, Lancet Public Health, 8,000–10,000) and 800 active kcal (no source).
- **S7. Zones only for imported sessions**, although NOOP has the heart rate of its own recorded sessions.
- **S9. Advice from several places:** Today's verdict (`ReadinessEngine`), the Stress sentence, the Trends
  sentence. Only one of them weighs everything.
- **S10. Sleep debt advice** ("sleep about 37m longer than your sleep need tonight") is right for a small debt;
  for a large one the laboratory evidence (Kitamura 2016) says recovery takes several nights.

## Round 9 (15–16 Nov 2026): v6 step 1, "Today answers", built by the architect chat

Utku answered "Yes, build it". Built on `feat/simple-mode` as `053ef4bd` (one commit) by the architect chat
itself; the warning's W1 as `4e7fd6f5` on `feat/high-hr-warning`. What it contains and where it left the design
is in [Simple mode → Step 1 as built](simple-mode.md#step-1-as-built-15-nov-featsimple-mode-053ef4bd).

**How it was checked**
- Branch (`~/Developer/noop-simple`): NOOPiOS simulator build; StrandTests on the Mac 2355, 0 failures, 2 skipped
  as before (12 new in `SimpleTodayV6Tests`); `i18n_audit.py --ci upstream/main` exit 0; doc lint clean; Tools
  338 OK.
- **Seen to fail:** every one of the 12 new tests went red in one run with its rule broken on purpose (12
  mutations, 158 assertion failures), then the four files were restored and compared by sha256. The warning's
  tests were run against the old monitor: five failed, among them `testAHeldStepperWritesOneLine` (the old code
  wrote 17 lines where the fix writes one).
- Simulator, demo data, evening: the strap line with Connect; "51 Medium · 67 Moderate · 87 Optimal"; "A normal
  training day"; with the reminder switched on by launch argument, "Aim to be asleep by 23:00 … You're about 35m
  behind on sleep, so a little earlier is better."; the two-way Charge bars; "Steps 8.715 · usually 8.700" and
  "Active calories 612 kcal · usually 520"; "Today's workouts … 40 EFFORT". With no data: "Aim for 8h 0m of sleep
  tonight". Not seen on screen (the demo's imported sleep need hides it, by the card's own rule): the reminder-off
  row with a time; its arithmetic is unit-tested.
- Stack `26f3bfe7` (fast-forward from `25aa5f38`; the catalogue merged by key with `xcmerge.py`, one comment-line
  conflict in `ChargeBreakdownFormat.swift` resolved by hand): `verify.sh` all steps passed (WhoopStore 645,
  StrandAnalytics 2160, StrandImport 327, doc lint, i18n, ledger, ratchet, governance 127, Mac tests 2408 with 0
  failures, iOS build), then a Release build for a real iPhone with the workflow's flags.

**Found while building**
- A `Group` with nothing inside has no view for `.task` to run on: the strap line's settle wait never started and
  the line never appeared. A zero-spacing `VStack` fixed it. Seen only because the simulator screen was looked
  at; no test would have caught it.
- The suggested ranges share their end points (10 is the top of the easy range and the bottom of the moderate
  one), so a word per range cannot agree with "in the range" at both ends. The word now takes the lower range at
  a shared point, like the card.
- The Steps tile's history has three sources (the strap's count, an imported one, the motion estimate). The usual
  day resolves each past day the way the tile resolves today, or "usually" would compare unlike things.
- The demo seed needs about 45 seconds on a busy Mac before the relaunch, not 15.


## Round 10 (16 Nov 2026): v6 step 2, "Tap a score, get an answer"

Chat 6, built by the architect chat itself. `feat/simple-mode` `8b59779a` (one commit). What it contains and
where it left the design: [Simple mode → Step 2 as built](simple-mode.md#step-2-as-built-16-nov-featsimple-mode-8b59779a).

**How it was checked**
- Branch: NOOPiOS simulator build; StrandTests on the Mac 2369, 0 failures, 2 skipped (14 new in
  `SimpleScorePageTests`); `i18n_audit.py --ci upstream/main` exit 0; doc lint clean; Tools 338 OK.
- **Seen to fail:** all 14 new tests went red in one run with their rules broken on purpose (14 mutations),
  then the two files were restored and compared by sha256.
- Simulator, demo data, light and dark: Charge "49 of 100 · Medium", the seven bars in the ring's own colours
  over the usual band, "In your usual range, 37–50.", all five readings with two-way bars; Effort "So far today
  34. Your usual full day is 46–69.", "No workouts recorded on this day."; Rest for an imported night ("This
  night's score is WHOOP's own…" with the night's figures); the Rest parts through a throwaway edit ("45 of 50 ·
  20 of 20 · 17 of 20 · 5 of 10 … the highest possible score is 95"); Heart rate with its plain empty state and
  the show-all row. Not seen: see "as built".
- Stack `d8ad0466`: `verify.sh` all steps passed (WhoopStore 645, StrandAnalytics 2160, StrandImport 327, doc
  lint, i18n, ledger, ratchet, governance 127, Mac tests 2422 with 0 failures, iOS build), then a Release build
  for a real iPhone. Phone build `9b5af016`, run 43849689116: success; release checked (target, five files,
  `.ipa` HTTP 200, sha256 `202af57e…`, its `de.lproj` holds the new strings).

**Found while building**
- **S11:** the Rest score every screen shows counts a fixed 8 h night and gives every night the neutral half
  of its regularity part, so no night can score above 95 (`Rest.composite(daily:)` with its defaults; the same
  on Android, `RestScorer.restFromDaily`). Said honestly on the page; a fix is a science change.
- "Higher than your usual 46" over-reads small differences: the first screenshot said a Rest of 93 was "lower
  than your usual 94". Replaced by the usual range (quartiles).
- A page that works a score out a second time can disagree with the ring. The ring hands over a snapshot
  instead; the first demo shortcut opened the page before Today had loaded and showed "0 of 4 nights" beside a
  Today that said 49, which is exactly the disagreement the snapshot prevents in real use (a wearer taps what
  they see).
- Numbers printed on top of the bars ran through the usual line; they sit under the bars now.
- F17 checked: the classic Charge sheet also passes the on-screen Rest for a carried row. Fixed for Simple
  mode, upstream candidate for the full view.

## Round 11 (16 Nov 2026): v6 step 3, "Sleep"

Chat 6. `feat/simple-mode` `9aba63cf` (one commit). What it contains:
[Simple mode → Step 3 as built](simple-mode.md#step-3-as-built-16-nov-featsimple-mode-9aba63cf).

**How it was checked**
- Branch: NOOPiOS simulator build; StrandTests on the Mac 2377, 0 failures, 2 skipped (8 new in
  `SimpleSleepV6Tests`); i18n gate exit 0; doc lint clean; Tools 338 OK.
- **Seen to fail:** all 8 new tests went red in one run (7 mutations, 80 assertion failures), then the two
  files were restored and compared by sha256.
- Simulator, demo data, light and dark, before and after: the ring's number and "of 100" readable, "REST ·
  Optimal", the panel "7h 11m asleep · 7h 44m needed / The need is WHOOP's figure for this night. / Imported
  from WHOOP"; "5m less than your usual"; the movement note and both section headings readable on the canvas
  (before: dark on the night picture); "Your sleep need 8h 0m" with its reason; "About 1h 12m behind on sleep …
  more than one night can repay"; the trend "Last 30 nights · average 7h 16m … Lately you slept about 6m less
  a night". Not seen: the Tonight card (the demo's imported need hides it, as on Today; its resolver is tested)
  and the ring's tap (read in code; the same route as Today's Rest ring).
- Stack `67a24b17`: `verify.sh` all steps passed (WhoopStore 645, StrandAnalytics 2160, StrandImport 327, doc
  lint, i18n, ledger, ratchet, governance 127, Mac tests 2430 with 0 failures, iOS build), then a Release build
  for a real iPhone. The phone build and its checks are in [State](../STATE.md) and [History](../HISTORY.md).

**Found while building**
- Laboratory stage percentages were left out on purpose (S3): the estimate over-reads REM, so norms beside it
  would mislead.
- **F20, F21** (both in the Simple mode page's "Carried" list).
- A first attempt to make the stage card state the day row's efficiency was taken out again: it made the
  card's first line disagree with the card's own Awake row. One fact, two readouts, inside one card is worse
  than across two screens.
- Today and the Sleep tab had no shared code for "Tonight"; they do now (`SimpleTonight.resolve`).

## Round 12 (22 Nov 2026): v6 step 4, "Is my body all right?"

Chat 7. `feat/simple-mode` `88964c18` (the step) and `99cc9650` (a fix to step 1 found while verifying it).
What step 4 contains: [Simple mode → Step 4 as built](simple-mode.md#step-4-as-built-22-nov-featsimple-mode-88964c18).

**How it was checked**
- Branch: NOOPiOS simulator build; i18n gate exit 0; doc lint clean; Tools 338 OK. StrandTests on the Mac
  2395: 18 new in `SimpleHealthV6Tests` all passed, and one step 1 test failed (below), fixed by `99cc9650`.
- **Seen to fail:** all 18 new tests went red in one run (14 mutations across three files, 69 assertion
  failures, no crash), then the files were restored and compared by sha256 (`break_step4.py`).
- Simulator (iPhone 18 Pro, demo data reseeded 22 Nov), light and dark: Health opens "All clear · Every reading
  below is in your normal range"; rows "Resting heart rate 51 bpm · In your normal range, 50–62.", HRV 57–101,
  breathing 12.4–16.6, blood oxygen "In the typical adult range, 95–100%.", skin "+0.1 °C · In your normal
  range, -0.7 – +0.8. · The change from your average skin temperature."; a row tap opens the guide at that entry;
  "Long-term estimates" with both cards; sync at the foot. Stress: "This morning · 0.4 · Low · Your resting heart
  rate was lower and your HRV higher than your normal…", markers "5 bpm lower than usual" (green: past one
  spread) and "1 ms higher than usual" (plain), "Calm days 7 of 30", "Stress · Last 30 days", six ranges. The
  rare states (two outside, learning, gap, no readings, the illness heads-up, an amber row and a learning row)
  were drawn through a throwaway edit, then restored by sha256. Simple mode off: both screens as upstream.
- Fixed while walking: "14.2 breaths/min" broke at the slash (the value now keeps one line and shrinks at the
  largest text sizes); "+0.1 °C" did not say it was a change; "about your age" was amber.

**Found while building**
- **A step 1 test failed in a summer-time zone:** `debtLedgerLookbackDays` counted days on the device's calendar
  between two noon-UTC dates, so a span across a clock change (3 Oct to 2 Nov) read 29 in Berlin or New York and
  30 in Istanbul, where the Mac was on 16 Nov. The three-day margin kept the read wide enough (no debt figure
  changed). Fixed in `99cc9650`; a new test pins three time zones and failed for two of them against the old code.
- **S12** (Stress bands: about a third of ordinary mornings land in High), **S13** (the adult ranges before 14
  nights flag ordinary people; the code's own age norms disagree), **F22** (the experimental blood-oxygen
  estimate is never labelled in the full view). All three in the Simple mode page.
- The design's "Right to within about 5 years" for Fitness age would have overstated it (its ±5 is a display
  constant); not used.

## Round 13 (27 Nov 2026): v6 step 6, "Welcome"

Chat 9. `feat/simple-mode` `f62dc758`. What step 6 contains:
[Simple mode → Step 6 as built](simple-mode.md#step-6-as-built-27-nov-featsimple-mode-f62dc758). (Step 5, chat 8,
has no round of its own here; its record is [Step 5 as built](simple-mode.md#step-5-as-built-26-nov-featsimple-mode-5a527b2c).)

**How it was checked**
- Branch: NOOPiOS simulator build; i18n gate exit 0; doc lint clean; Tools 338 OK; `SimpleWelcomeV6Tests` (12),
  `SimpleModeTests` (17) and `SimpleTodayV6Tests` (13) on the Mac, all passing.
- **Seen to fail:** all 12 new tests went red in one run (13 mutations across four files), then the files were
  restored and compared by sha256 (`break_step6.py`).
- Simulator (iPhone 18 Pro): with the demo data, the welcome sheet over Today, closing it stored the flag, More
  with "My strap / Not connected" first and the group captions, "My strap" opening Devices, the guide's "Start
  here" opening the same sheet. Then a fresh install launched past the terms and the wizard: What's New first,
  the welcome a second after it closed, then Today with "Getting to know you · 0 of 14 nights so far", the four
  steps unticked, and "Your day" saying why there is no advice yet; the card's ⓘ opening "How sure NOOP is"; the
  Activity ⓘ; Sleep's new empty state; Alarms' plain reminder line. Relaunched after reseeding: no second welcome.
- Stack `86451db1`: `verify.sh` all steps passed (Mac tests 2481). Phone build `be30b8dc`, run 45943129095,
  release checked (`de.lproj` "Wir lernen dich kennen").

**Found while building**
- Today is drawn under the first-run gates, so a once-only sheet presented from Today would have appeared behind
  them (or been dropped); it moved to the tab shell.
- The design's "your own sleep need" after 7 nights would have promised most wearers a figure they never see (the
  personal need only rises above 8 h for long sleepers); left out of the card until step 7.
- "Not synced since" would have been a daily false alarm on a WHOOP 5.0 whose history sync is experimental; not
  built.
- The welcome's first draft sent every wearer to a card only new wearers see; reworded ("While NOOP is still
  learning…").
- The guide called WHOOP's sleep score "Sleep score"; WHOOP's own term (its export's column) is "Sleep
  performance".
