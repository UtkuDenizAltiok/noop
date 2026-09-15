---
name: lift-log-verify-before-claiming
description: "On the NOOP Lift Log, verify every claim by running it — tests seen to fail, features seen on screen, reviewer statements and rebases tested in a throwaway worktree — because reading code and trusting reviewers have both been wrong here."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 227b34a2-29a0-48aa-85c4-bae7f11cc8ad
  modified: 2026-09-15T10:59:18.109Z
---

Several things believed true on this project turned out false, and each was caught only by running
something. Utku relies on my technical judgement precisely because he cannot check it himself.

**Why:** the feature's bugs are silent wrong data; the app targets need local builds; and reviewers —
including the maintainer — have been wrong in ways that sounded authoritative.

**How to apply:**
- **A new test must be seen to FAIL.** Break the guard, watch it go red, restore. (14 Sep 2026: the
  set-removal test returned the dropped set's 80.0 without the fix.)
- **Run the app, don't infer from a build.** The simulator caught a wrapped header, a Lock Screen timer
  rendering wrong, and copy describing removed fields.
- **When a readout can be absent, check both states.** A hidden HR readout was reported as a missing
  feature.
- **Test a reviewer's claim before repeating it.** The maintainer said a pre-rebase merge would register
  `v46-lift-log` twice; I wrote that into the docs untested. He later found it was a grep counting a
  comment too, and a throwaway-worktree rebase showed add/add conflicts and one registration. Count
  the exact construct (`grep -c 'registerMigration("v46-lift-log"'`), not a bare string. A `.noopbak`
  rationale was likewise wrong (Android rejects iOS backups).
- **Prove a rebase kept the content:** compare the PR's patch before and after with `index`/`@@` lines
  stripped; for the string catalog compare the added entries.
- **Check a measurement against the codebase before accepting a style criticism** (the design-token
  review was directionally right and quantitatively overstated).
- **zsh does not word-split `$VAR`** (nor pass `--include=*.kt` through) — an xcodebuild "test" that
  errors in seconds did not run, and an empty diff over `$files` compared nothing; use `bash -c` with
  arrays and read the log before reporting a result.
- **After a merge by someone else, prove nothing was lost**: diff the squash against the PR head per
  file (15 Sep: only upstream's own catalog lines differed).
- **Run the whole loop, parity included** (`bash dist/tools/verify.sh`: ledger, ratchet and governance, not
  just tests). 15 Sep: overloads that compiled and passed everything were a ledger scan error, and #2099 left
  the governance tests red on `main` because nobody ran them.
- **An oracle harness proves itself**: the sections a change cannot affect must reproduce the old
  expected block byte-for-byte before its new output is trusted.
- **A rule mirrored in SQL must match exactly** (`<> 0`, not `> 0`), pinned by a test on the edge.

See [[noop-lift-log-project]], [[lift-log-docs-are-mine]].
