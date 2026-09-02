# Proposal: a Lift Log (gym log book) — designed, built, and looking for a steer before PRs

I've built a strength log book for NOOP and would like to contribute it upstream. It's working on a
branch and I'd rather check the shape with you now than open PRs you have to unpick.

**Branch:** `UtkuDenizAltiok/noop@lift-log-ui` (three commits: schema → programs → session loop)

## What it does

Build a program once — a name and an ordered list of exercise lines carrying the *targets* (working
sets, rep range, target RPE, rest, a technique note) — then run it at the gym by tapping through it:
warm-up → set → rest → set → … → cool-down → save. The finished session lands in `workout` as an
ordinary row, so it shows in Workouts and Today like anything else.

**No exercise catalogue ships.** The user types whatever they call a movement; it's remembered in
`liftExercise` with the muscle group they gave it and offered back next time. A shipped
exercise→muscle mapping felt like both a permanent maintenance burden and a correctness claim about
someone else's technique.

Exercise *names* are free text; muscle *groups* are a closed 20-token enum, because a per-muscle
rollup only means anything if the same muscle always lands in the same bucket.

## It does not touch Effort

Worth stating up front, because the obvious request is "make lifting raise my strain".

There's no validated public path from typed sets × reps × weight to a cardiovascular-strain
equivalent. WHOOP's own Muscular Load isn't that calculation either — per their R&D writeup it runs
PUSH's velocity-based algorithms over the strap's accelerometer and gyroscope, under a model that
is unpublished and not peer-reviewed. Deriving our own from strap motion is exactly the case
`CLAUDE.md` warns about (the withdrawn PPG→HR estimate, #194).

So the session is written with `strain: nil` and the existing engine fills it from the heart rate the
strap actually measured over that window (`rescoreManualWorkouts` → `ManualWorkoutRescore.scored` →
`StrainScorer`). Wear the strap and you get an honest HR-derived Effort; the typed numbers never feed
it. This matches what the Hevy/Liftosaur import path already decided.

## The four decisions I made, and would change on request

**1. Sets are rows, not JSON.** A queryable `liftSet` table on the `labMarker` pattern rather than a
`workout.zonesJSON`-style blob. "What did I lift for this last time" is the read the whole feature
exists for, and JSON can only answer it by decoding every session ever recorded. Five tables
(`liftExercise`, `liftProgram`, `liftProgramItem`, `liftSession`, `liftSet`) in migration
`v40-lift-log`, every one carrying `deviceId` and listed in `DeviceRegistryStore.deviceScopedTables`
— including the child tables, since they join by id and a "delete all my data" would otherwise strip
the parents and leave every logged set behind.

**2. The session goes under the strap `deviceId` as `source: "manual"`** — the path
`AppModel.endWorkout` already uses — so it inherits overlap dedup, the strain fill above, and
delete/merge, rather than repeating what the `"lifting"` deviceId does. `liftSession` is pinned to its
workout row by that table's own natural key `(deviceId, startTs, sport)`, UNIQUE.

**3. Android is pinned `ios_only`, with a stated reason.** Not out of preference: I have no way to
build or test Android locally, and shipping a Room twin I'd never run seemed worse than an honest,
documented gap. Both `schema_oracle.json` copies carry the pin and the reason, verified
byte-identical; nothing here feeds a score, so a device without these tables computes identical
metrics. **Android CI is green on the branch** — `assembleFullDebug` + `testFullDebugUnitTest` both
pass, so `SchemaOracleTest` accepts the pin and the cross-copy identity check holds.

**This is the decision I'd most like your view on.** If you'd rather the Room twin land in the same
change, that's a blocker I can't clear alone and I'd want to find someone who can build and test it
properly rather than guess at it.

**4. `More → Body → Lift Log`, next to Workouts.** No centre-FAB quick action — it'd cost a
`QuickAction` case, a `QuickActionSheet` row, a hard-coded detent height and a Home-Screen mapping for
the same reach.

## The rest timer

The ask was "buzz me 5 seconds before rest ends". A sideloaded background build can't reliably
vibrate a locked phone — which `SmartAlarmView.honestyCard` already says about the smart alarm. So,
in order: **buzz the strap** via `AppModel.buzz(loops:gate:)` (works pocketed, thanks to
`bluetooth-central`), gated behind a new `HapticPrefs.liftRest` key; a foreground phone haptic reusing
`IntervalTimerView`'s bumped-token `.sensoryFeedback` idiom; and a `UNTimeIntervalNotificationTrigger`
backup with the same plain wording the alarm screen uses.

The countdown is anchored to an absolute instant and persisted like `ActiveWorkoutPersistence`, rather
than `IntervalTimerView`'s decrementing `Int` — verified by killing the app mid-rest and reopening to
find it had kept counting.

**A running session also claims the strap's double-tap** so a set can be logged without picking the
phone up, handing the gesture back to the user's configured action when the session ends. That part
still needs validating on real hardware, which I'm doing this week.

## A possible bug, happy to split out

`IntelligenceEngine.realWorkouts` queries only the strap `deviceId` and `"apple-health"`, never
`"lifting"` — so a detected bout gets persisted on top of an imported lift session covering the same
window. Read-time `dropDetectedShadows` hides it from the list, but the row is still there and still
counted by anything reading the store directly, and `sourceLabel`'s `.lifting → "lifting"` trace token
is unreachable as a result. Same on Android (`IntelligenceEngine.kt:2085`). Want that as its own
issue?

## Scope and how I'd split the PRs

One concern each: **(1)** the schema + store + tests, **(2)** the UI. Nothing in either touches
scoring. Per-muscle set counts and session load are a later, separate change — the counting method
there is load-bearing enough to deserve its own discussion rather than riding along.

Both app targets compile locally (`app-build.yml` being off), the package tests and the i18n and
doc-comment gates pass, and the 30-odd new strings are translated across all nine shipped locales.

Happy to be told any of this is the wrong shape before I open anything.
