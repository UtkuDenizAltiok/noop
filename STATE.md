# State

Updated **14 Nov 2026, end of chat 4**. Current facts and unfinished work only; the dated record is in
[History](HISTORY.md) and, for everything before 14 Nov, the [State archive](archive/state-until-2026-11-14.md).
The agent in the chat owns execution under [Rules](RULES.md): an architect chat (Claude Fable 5.2) plans,
reviews, stacks and ships; Opus 5.5 worker chats write the app code.

## Now

**Next chat (Fable 5.2 as architect): Simple mode v6, the most user-friendly NOOP.** Utku's direction of 14 Nov
is a rule ([Rules](RULES.md#settled-decisions)): Simple mode is only *simpler* today; it must become the mode a
wearer understands and uses without confusion, decided as fitness coach, physiologist, doctor and developer,
never by deleting information or features. Start from
[Simple mode → Next chat begins here](features/simple-mode.md#next-chat-begins-here-simple-mode-v6-the-most-user-friendly-noop).
Nothing of v6 is designed or built yet.

Open items, in order:
- [ ] **Simple mode v6** — walk, design, worker briefs, review, build (next chat).
- [ ] **Heart rate warning W1** (settings lines flood the strap log; small) and optionally **W2** (on/off at
  the limit) — [`high-hr-warning.md` §12](features/high-hr-warning.md#12-hardware-evidence-utkus-whoop-50-12-and-14-nov);
  ship with the first v6 build.
- [ ] **Utku: archive the two finished worker chats** in the app sidebar ("1 of 2: Simple mode, show everything
  in one tap" and "2 of 2: High heart rate warning (after 1)"); the app's safety check stopped the agent doing
  it. Their folders under `~/Developer/noop/.claude/worktrees/` go with them; nothing in them is unsaved.
- [ ] **Upstream is quiet** (no merge since 25 Oct, `upstream/main` `2a1de760`): no new upstream PRs, no
  close/reopen retries; answer a maintainer comment once if one appears.

Done in chat 4 (12–14 Nov; details in [History](HISTORY.md)): audit of the whole Simple mode diff and a new
roadmap; "Show everything on this screen" + "Report a problem" + Lift Log guard (worker 1); the high heart rate
warning (worker 2), checked on Utku's WHOOP 5.0 with all five checks passing; stack and phone build; a cleanup
of branches, folders and caches (14 Nov).

## Where everything is

**Phone:** `testing-latest` = `testing-build` `218aec72` = stack `25aa5f38` + `fork/ships-template`, NOOP 12.1.0
(439), GitHub run 43264856702, verified by its files on 12 Nov; installed on Utku's iPhone 16 Plus (his 14 Nov
strap log shows the warning working). Install = **just update** through AltStore, never delete first.
Release page: `https://github.com/UtkuDenizAltiok/noop/releases/tag/testing-latest`.

**Testing pipeline:** `testing-stack` `25aa5f38` (upstream `2a1de760` + our open PRs + Simple mode + #2906 + the
warning); `testing-build` `218aec72`. How to rebuild and ship: [Workflow §6](WORKFLOW.md#6-builds-for-utkus-phone)
and Simple mode → "How to work".

**Feature branches (fork only, not PRs):**
| Branch | Tip | Folder | What |
|---|---|---|---|
| `feat/simple-mode` | `258e0bf2` | `~/Developer/noop-simple` | Simple mode, Rounds 1–7 |
| `feat/high-hr-warning` | `f80aadc6` | `~/Developer/noop-hrwarn` | the warning; contains `feat/simple-mode` |

**Our open upstream PRs (17), all waiting on the maintainer:**
| PR | Branch | Folder |
|---|---|---|
| #2896 tab swipe | `fix/ios-tab-swipe-blank-tab` | none (branch only) |
| #2897 translations | `fix/ios-readiness-confidence-translations` | none |
| #2898 Info.plist | `fix/ios-info-plist-stalebattery` | none |
| #2899 skin temp once | `fix/charge-sheet-skin-temp-once` | none |
| #2900 one sleep need | `fix/sleep-hours-vs-needed-normative-need` | none |
| #2901 Trends "Average" | `fix/trends-window-average-label` | none |
| #2903 plain subtitles | `fix/plain-screen-subtitles` | `~/Developer/noop-subtitles` |
| #2904 skin temp unit | `fix/charge-skin-temp-unit` | `~/Developer/noop-skinunit` |
| #2905 sleep-debt source | `fix/sleep-debt-tile-source` | `~/Developer/noop-debtsrc` |
| #2906 wind-down uses the Sleep tab's need | `fix/wind-down-sleep-need` | `~/Developer/noop-winddown` |
| #2747 standard-HR integrity (CONFLICTING) | `codex/standard-hr-integrity` | `~/.codex/worktrees/standard-hr-integrity/noop` |
| #2724 resting HR one pass (CONFLICTING) | `codex/rhr-one-pass` | `~/.codex/worktrees/rhr-one-pass/noop` |
| #2722 SDNN quality | `codex/hrv-sdnn-quality` | `~/.codex/worktrees/hrv-spectral-power/noop` |
| #2717 docs navigation | `codex/docs-navigation` | `~/.codex/worktrees/docs-navigation/noop` |
| #2661 sync reminder | `ios-sync-reminder` | `~/Developer/noop-sync-reminder` |
| #2660 deleted sleep list | `ios-deleted-sleep` | `~/Developer/noop-deleted-sleep` |
| #2613 DREAMT respiration weight | `dreamt-psg` | `~/Developer/noop-dreamt` |

**Parked (kept on purpose, not active):** the Stress spectral-wording candidate `ec329949` (local only; folder
`~/Library/Caches/noop-handbook/stress-spectral-explanations-2026-10-08/staging-noop`, also in the retired-refs
bundle) and its fork branch `codex/stress-spectral-explanations`
([audit](audits/stress-spectral-explanations-2026-10-08/README.md)); the deferred original-WHOOP-app analysis;
the REA outreach records (`private/rea-2026-10-09/`).

**The fork holds exactly:** `main` (mirror of `upstream/main`), the 17 PR branches, the two feature branches,
`codex/stress-spectral-explanations`, `testing-stack`, `testing-build`, `handbook`; tags `fork/ships-template`
and `testing-latest`; one release.

## Local evidence and caches (this Mac only)

- **Private** (`dist/private/`, ignored, never uploaded): strap logs (`strap-logs/`, incl. Utku's 12 and 14 Nov
  logs), session evidence, drafts, the event log (`events.log`).
- **Caches** (`~/Library/Caches/noop-handbook/`, about 1 GB after the 14 Nov cleanup): logs and small evidence
  per audit, `verify/<commit>/` logs, and `retired/noop-retired-refs-2026-11-14.bundle`, one verified bundle (99
  refs) holding every old recovery copy (October staging tips) and every branch deleted on 14 Nov. Restore one
  with `git fetch ~/Library/Caches/noop-handbook/retired/noop-retired-refs-2026-11-14.bundle
  refs/retired/<path>:refs/heads/<name>`; list them with `git bundle list-heads <bundle>`. Build folders are
  not kept: they are rebuilt on demand.
- **Toolchain:** Xcode 27.2, XcodeGen, gh, Python 3.12 (`/opt/homebrew/bin/python3.12`). Simulator: iPhone 18
  Pro. Android runs in fork CI only.

## Next safe action

1. Read the 14 Nov rule in [Rules](RULES.md#settled-decisions), then
   [Simple mode → Next chat begins here](features/simple-mode.md#next-chat-begins-here-simple-mode-v6-the-most-user-friendly-noop).
2. Walk every Simple screen in the simulator as a first-time wearer; write Design v6 into the Simple mode page.
3. Split it into Opus 5.5 worker briefs (one worker at a time), with W1 in the first one; review, stack,
   `verify.sh`, ship; then ask Utku plain questions about what he sees.
