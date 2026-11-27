# State

Updated **27 Nov 2026**. Current facts and unfinished work only; finished work is in [History](HISTORY.md).

## Now

**NOOP 13.0.0 is the owner's own project and his fresh-start build.** On 27 Nov 2026 Utku made NOOP independent of
the original repository (Rules → Settled decisions), asked for the whole project to be cleaned up for any future
agent, and starts wearing his WHOOP 5.0 with a fresh install of 13.0.0 for about two weeks without prompting.
When he returns he may use a different AI; everything needed is in this handbook.

- **The final build:** `main` `d0b8954e` (release commit "NOOP 13.0.0, its own project"), `verify.sh` all steps
  passed (Mac tests 2491, 2 skipped, 0 failures; StrandAnalytics 2187; iOS build), Android CI 46035735555 success,
  Release iPhone build 13.0.0 (440) passed locally. GitHub "Testing build (fork)" run **46037328950** from `main`.
  **Release checked** (27 Nov): target `d0b8954e`, five files all v13.0.0 (`NOOP-ios-unsigned-v13.0.0.ipa` HTTP 200,
  sha256 `473cf455…`), the German strings inside. This is the build the owner installs for his fresh start.
- **What 13.0.0 holds beyond 12.0.0:** Simple mode v6 (steps 1–7), the high heart rate warning, the developer loop
  (morning check-in, developer export), the sleep onset and the wake rescoring (PSG-measured), "fell asleep / woke",
  the nap questions, one sleep need (own or automatic by age), the Sleep Regularity Index in Rest, the week's WHO
  minutes from heart rate, the iPhone step calibration, F17, F12, and every fix listed in History since September.
- **Install:** a fresh start (delete NOOP, install the `.ipa` from the release with AltStore, set up, no backup
  restored). Later builds are "just update".

### Open work, in order

1. **F11, one-decimal parity** (cosmetic): 97 Swift and 80 Kotlin sites print one-decimal figures; at a value just
   under a half (0.15 is stored as 0.1499…) Swift's `%.1f` and Java's `String.format` can print different last
   digits. No score or stored value is affected; the iPhone shows the Swift side. Pair the shared figures, one
   rounding helper per platform with an oracle, Android first where only its text differs. The site list is
   regenerated with `grep -rn '%.1f'` over the app targets and `android/app/src/main`.
2. **Full-view fixes that used to wait for the original maintainers** (now ordinary NOOP work, each its own change,
   both platforms where the code exists; details in [Simple mode](features/simple-mode.md) → Design v5 findings):
   F1 (readiness says "Still learning your baseline" every morning before the night syncs), F13 (with no row for
   today the readiness verdict reads an older night), F2 (a carried score captioned "Last night" when older), F3
   (Health's recovery contributors repeat the Charge drivers with another baseline), F5 (the Sleep ring's "of 100"
   faint on the light face), F6 (Stress chips truncated at phone width), F16 (the wrist-alerts switch does not cover
   heart-rate-zone coaching), F18 (Live Sessions' background tick), F21 (the sleep trend's average).
3. **The Android twin of Simple mode** and `noop.simpleMode` in the `.noopbak` whitelist on both platforms
   (Simple mode is iOS-only today). Large; plan it in steps like v6.
4. **With the owner's files, when he offers them** (`features/lab.md`; the questions are in Backlog "With his
   file"): REM share, S12's share of High mornings, the S3 restorative target by age, nap thresholds, the step
   divisor's windows, check-in answers against the scores, the regularity index on real weeks.
5. **The handbook's old history (owner's choice).** The pages on GitHub are clean since 27 Nov, but the `handbook`
   branch's older commits still hold the personal details that were removed. The owner said yes, but the agent's
   safety check refuses rewriting public history. The local branch `handbook-clean` holds the same files as one
   clean commit (the full old history is in the private `backups/`). The owner can replace the branch himself in
   Terminal: `cd ~/Developer/noop/handbook && git push --force-with-lease=handbook:$(git rev-parse origin/handbook)
   origin handbook-clean:handbook && git reset --soft handbook-clean` (recreate `handbook-clean` from the current
   tree first if the handbook changed since: `git branch -f handbook-clean $(git commit-tree HEAD^{tree} -m "…")`).
   GitHub keeps unreachable old commits for a while; only GitHub support can purge them, on his request.
6. **Needs evidence first:** S13 (a nocturnal norm for resting heart rate and RMSSD by age, Backlog); W2 (the
   heart rate warning's on/off at the limit, only if it annoys in real use); Vitality's regularity input.

## Where everything is

- **Repository:** [UtkuDenizAltiok/noop](https://github.com/UtkuDenizAltiok/noop). `main` = the product (13.0.0);
  `handbook` = this handbook. History branches (kept): the 17 branches of the old pull requests to the original
  repository, `feat/simple-mode`, `feat/developer-loop`, `feat/high-hr-warning`, `feat/v6-step7-and-feedback`,
  `testing-stack`, `testing-build` and the tag `fork/ships-template` (the pipeline before 27 Nov). The original
  repository is not a remote any more; GitHub still labels the repository "forked from ryanbr/noop", which is
  harmless (only GitHub support can remove the label, on the owner's request).
- **The release the owner installs from:** `https://github.com/UtkuDenizAltiok/noop/releases/tag/testing-latest`
  (bundle `com.noopapp.noop`, "NOOP Staging"; five files: iPhone `.ipa`, Mac `.zip`, two Android `.apk`, the Lift
  Log program template).
- **On the owner's Mac:** `~/Developer/noop/` holds `app/` (main), `handbook/` (this branch; linked as
  `app/dist`), `noop-private-utku/` (his private files, never published; its `README.md` lists them; reached as
  `handbook/private`), `datasets/` (PhysioNet sleep-accel). Build products and logs: `~/Library/Caches/noop-handbook/`.
  The simulator is "iPhone 18 Pro". Toolchain: Xcode 27.2, XcodeGen, gh, Python 3.12.

## Next safe action

1. Start procedure ([Sessions](SESSIONS.md)): `bash dist/tools/checkpoint.sh status --net` from `~/Developer/noop/app`.
   Expect `main` at `47135074` or later (docs after the release commit), the handbook equal to `origin/handbook`,
   no other worktrees, no job running.
2. (Done 27 Nov; repeat only if the release changes.) The 13.0.0 release check: `bash dist/tools/release-check.sh <the release's target commit>
   "Counted from the minutes your heart rate spent at each level during workouts (a workout without its own readings by its average): moderate from %lld bpm, vigorous from %lld bpm, for your maximum of %lld."`
   must show five files, the `.ipa` at HTTP 200 and the German string. If run 46037328950 failed, rerun "Testing build (fork)" on `main`.
3. Then open work item 1 (F11), unless the owner reports something from the phone: that comes first.
