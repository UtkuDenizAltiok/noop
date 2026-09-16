# The Lift Log

## What it does

- **Programs** — a name plus ordered exercise lines: working sets, one rep count, weight, max RPE (a ceiling,
  1–10), rest, note. Built in the editor or imported from the committed `.xlsx` template (`.csv` also works).
- **No catalogue.** Users name exercises and assign muscles; NOOP ships no exercise list and no
  exercise→muscle mapping.
- **The session is a sheet**: every set of every exercise is a row. Any pending set can be started at any time
  (machines get occupied). Finishing a set moves to the next set of the SAME exercise, then plan order.
  Green = working, amber band = rest, check = recorded.
- **The plan bends**: each exercise ends in an "Add set" row (⊕ appends, ⊖ drops the last pending set),
  changing this session only; finishing asks whether the program keeps the new counts.
- **Any set's numbers can be typed at any time.** A recorded set is edited in place; a pending one is held and
  applied when recorded.
- **Grey numbers stay grey** — this exercise earlier in the session, else last session, else the program
  target — until something is typed. The RPE field shows the line's max RPE grey, and a set left unrated saves
  it; a previous set's rating is only ever shown, never saved onto another set.
- **Finishing asks, never assumes** (one Save button, disabled until answered): sets with no typed numbers are
  **completed** with their grey numbers or **discarded** — saved as 0 kg × 0 reps, out of every figure,
  fillable later under Edit sets; if a set count changed, whether the program keeps it. A discard that would
  leave no set counting files nothing, and the sheet warns before Save.
- **A finished session can be edited** ("Edit sets"): weights, reps, RPE, warm-up marks, session RPE, sets added
  or removed. Only that session changes, never the program. Zeros show only here.
- **Two inputs advance**: the on-screen button, or a **double-tap on the strap**. One buzz confirms the tap;
  three mean the rest is nearly over. The phone can stay face-down all session. A strap double-tap under 8 s
  after the last one acted on is taken as a knock: no buzz, nothing moves, one log line.
- **The session outlives its screen**: minimise to a bar above the tab bar; a Lock Screen Live Activity shows
  state, exercise, reps × weight, live HR, the clock and the next set ("Next: Set 2 · Lat pulldown"). A finished
  rest reads 0:00 everywhere. A strap step lights a locked, dark Lock Screen and nothing more (a silent ActivityKit alert on the step's one update). Crash-safe
  snapshot in UserDefaults.
- **Typing moves with one tap**: with the keyboard open, a tap on another field puts the cursor there; a tap
  anywhere else puts the keyboard away and still does what it was aimed at.
- **Saved as a normal `workout`** (`source "manual"`, sport "Strength Training", `strain: nil`), so the engine
  fills strain from the heart rate the strap measured. Deleting a session deletes that workout.
- **Figures** (session detail + hub): volume (per exercise with "vs last time", session total with its
  comparability caption), Foster session load, Epley e1RM (≤ 12 reps, labelled estimated), RPE coverage, and
  estimated sets per muscle against a ~4 sets/week research reference. No composite score.

**The double-tap.** One gesture once reached the app twice: live, then again when the strap offloaded its event
log; the 1.2 s debounce cannot catch that, and each phantom silently skipped a set. It is de-duplicated on the
event's own timestamp, read-side only (the macOS Automations gesture shares the path and was verified). In the
15 Sep log all 16 taps the strap reported were dispatched and buzzed within 3 s, and all 14 held-back replays
sat within 9 s of an already-dispatched tap: misses are the strap not sensing the tap. In the 16 Sep log (the
file has the session from 21:54 on) the strap's own console reported 22 double-taps and all 22 were acted
on. Two of them came 3 s and 4 s after the tap that started a set — knocks the strap reported as taps — which is
why a strap tap under 8 s after the last acted-on one is held back. The same log showed the four slowest buzzes
(1.0–2.8 s) were the taps whose event also kicked a sync, so the tap is now handed on, and buzzed, first.

## Size and shape (measured 16 Sep 2026)

38 files the Lift Log owns: **6,933 code lines + 1,876 comment lines**, of which **~2,900 are tests** (42%).
Excludes upstream's own `LiftingImporter` (Hevy/Liftosaur) and the maintainers' `LiftMetrics.kt`.

- Biggest files: `LiftSessionView.swift` 860, `LiftLogStore.swift` 749, `LiftSessionEngineTests.swift` 651,
  `LiftLogStoreTests.swift` 629, `LiftSessionController.swift` 528, `LiftProgramItemSheet.swift` 481.
- **The largest single block** is the spreadsheet import — `LiftProgramSheetImporter` + `XlsxSheet` + the
  template generator and their tests, roughly 1,500 lines, a fifth of the feature. **Utku uses it and wants it
  kept** (16 Sep 2026): it is how he builds programs on a computer instead of typing them on a phone. It is
  self-contained (only the store APIs the editor uses, no write path of its own). **Settled:** ryanbr twice
  offered to review it as a separate PR — a review-workload question, never a code-quality one — and then merged
  it inside #2099 anyway, so it already ships upstream. Do not re-open the split, and never remove it.
- Everything else earns its place: no dead symbols (checked), no second implementation of a figure
  (`RULES.md` 2), and the comment ratio is the house style — comments say WHY, and several exist because a real
  gym session proved the alternative wrong.

## Where everything lives

### Storage — `Packages/WhoopStore`
| file | what |
|---|---|
| `Sources/WhoopStore/Database.swift` | migration `v46-lift-log`: `liftExercise`, `liftProgram`, `liftProgramItem`, `liftSession`, `liftSet` |
| `Sources/WhoopStore/LiftMuscle.swift` | closed 20-token vocabulary, 4 regions, `directSetCredit` 1.0 / `indirectSetCredit` 0.5 |
| `Sources/WhoopStore/LiftLogStore.swift` | row structs + 16 functions: upsert/read/delete for exercises, programs, items, sessions, sets (`deleteLiftSets`); `lastLiftSets`; `liftSetCounts` |
| `Tests/WhoopStoreTests/LiftLogStoreTests.swift` | 36 tests |

### Metrics — `Packages/StrandAnalytics`, and the Android twin
| file | what |
|---|---|
| `Sources/StrandAnalytics/LiftMetrics.swift` | `isPerformed(reps:)`, `volumeLoadKg`, `sessionLoad`, `estimatedOneRepMaxKg`, `perExercise`, `rpeProfile`, `muscleCounts`, `ReferenceDose`. Pure |
| `Tests/StrandAnalyticsTests/LiftMetricsTests.swift` · `LiftMetricsStoreAgreementTests.swift` | 27 · 6 tests |
| `android/app/src/main/java/com/noop/analytics/LiftMetrics.kt` · `…/data/LiftMuscle.kt` | Kotlin twins (#2232); nothing in the Android app calls them yet |
| `android/app/src/test/java/com/noop/analytics/LiftMetricsParityOracleTest.kt` · `…/data/LiftMuscleParityOracleTest.kt` | expected blocks = Swift stdout |
| Android storage | `LiftEntities.kt`, `WhoopDatabase.kt` (`MIGRATION_39_40`), `DeviceRegistryDao.kt`; no DAO reads lift sets; no Compose screens |

### Spreadsheet import — `Packages/StrandImport` and tooling
| file | what |
|---|---|
| `Sources/StrandImport/LiftProgramSheetImporter.swift` · `XlsxSheet.swift` | parses a filled template (incl. `Target max RPE`, 1–10); bounded `.xlsx` reader (`rawPart` is test support) |
| `Tests/StrandImportTests/LiftProgramSheetImporterTests.swift` | 24 tests, three read the SHIPPED template |
| `Tools/make_lift_program_template.py` → `docs/lift-log-program-template.xlsx` · `docs/LIFT_LOG_PROGRAM_IMPORT.md` | template generator and committed template · user guide |

### App — `Strand/` (compiles into BOTH macOS `Strand` and iOS `NOOPiOS`)
| file | what |
|---|---|
| `Data/LiftSessionEngine.swift` | pure slot state machine: stages, `slotAfter`, `carry`, `unenteredSlots`, add/remove set (max 20), undo |
| `Data/LiftSessionController.swift` | `@MainActor` owner: tick, buzzes, strap claim, pending input, persistence, `setsToSave`, `anyPerformed`, `setCountChanges`, `presentation(system:)` |
| `Data/LiftSessionPersistence.swift` | crash-safe `Codable` snapshot (`noop.activeLiftSession`); new fields must be optional |
| `Data/LiftFormat.swift` · `LiftMuscleNames.swift` · `HapticPrefs.swift` | formatting · localized muscle names · `haptics.liftRest` |
| `Screens/LiftLogView.swift` | hub: programs, weekly sets per muscle, history |
| `Screens/LiftProgramEditorSheet.swift` · `LiftProgramItemSheet.swift` · `LiftProgramImportSheet.swift` | program editor · one line · import |
| `Screens/LiftSessionView.swift` | the session sheet, ⊕/⊖, control bar, finish sheet (questions, warning) and `save()` |
| `Screens/LiftSessionBar.swift` · `LiftSessionDetailSheet.swift` · `LiftSessionEditSheet.swift` · `KeyboardDismiss.swift` | bar (with the next set) · finished session (performed sets only) · its editor · tap-outside keyboard helper (a UIKit window recognizer that stands aside for text inputs) |
| `BLE/FrameRouter.swift` · `App/AppModel.swift` | double-tap de-duplication, drop logs, tap handed on before the sync kick · gesture claim (synchronous) and debounce log |

iOS shell: `StrandiOS/App/StrandiOSApp.swift` creates the controller; `StrandiOS/App/RootTabView.swift` adds
More → Body → "Lift Log", the bar and the sheet. Lock Screen: `StrandiOSShared/LiftActivityAttributes.swift`,
`StrandiOSWidgets/LiftLiveActivity.swift` (no catalog: words arrive pre-localized),
`StrandiOS/Widgets/LiftLiveActivityController.swift` (the light-up alert), `StrandiOS/Resources/lift-step-silence.caf`.

### App tests — `StrandTests/`
`LiftSessionEngineTests` 56 · `LiftSessionPendingInputTests` 11 · `LiftSessionFinishTests` 14 ·
`LiftSessionEditTests` 8 · `LiftSessionPersistenceTests` 5 (old-format JSON: decides wipe or update) ·
`LiftSessionStrapTapTests` 5 · `FrameRouterDoubleTapDedupTests` 10 · `LiftFormatNumberTests` 10.
