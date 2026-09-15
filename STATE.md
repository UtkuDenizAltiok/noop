# State

**Updated 15 Sep 2026.** The only file that changes every session. Replace, don't append — history goes in
`HISTORY.md`.

## Upstream (`ryanbr/noop`)

| PR | what | state |
|---|---|---|
| [#2098](https://github.com/ryanbr/noop/pull/2098) | `v46-lift-log` schema, Room twin, Android delete/re-key | merged 14 Sep, squash `8818477d` |
| [#2099](https://github.com/ryanbr/noop/pull/2099) | the app | merged 15 Sep, squash `4453a089` (our `45caa744` + ryanbr's empty-session guard `fed714cb`) |
| [#2232](https://github.com/ryanbr/noop/pull/2232) | Kotlin `LiftMetrics` twin + oracle tests (by the maintainers) | merged 15 Sep, `eb34f3c8` |
| [#2233](https://github.com/ryanbr/noop/pull/2233) | parity-governance repair; `main` green again after #2099 left it red (#2229) | merged 15 Sep, `36b49dbe` |
| follow-up | the second gym session's changes | **not opened** — see below |

**Unanswered:** ryanbr's 15 Sep 04:07 comment on #2099 (he added the guard and invited a reply). The reply is
drafted in `NEXT_PR.md`; it goes out right after the follow-up opens, with Utku's yes.

## Open work

- **Work branch:** `lift-log-discard-and-edit` — `641564a2` (app) + `a7f2ad08` (Kotlin twin), originally on
  `eb34f3c8`. **Locally rebased onto `upstream/main` `c430ca0b` as `0a55bc8c`** (content identical; local tag
  `backup/pre-rebase` = the pre-rebase tip). **Not yet re-verified or pushed**; the fork still holds the
  verified `a7f2ad08`.
- **What it does:** one Save button; discarded sets kept as 0 kg × 0 reps (hidden from every figure, fillable in
  Edit sets); add/remove sets in Edit sets; ryanbr's guard reads "no set counts" with a warning before Save;
  SQL mirrors `reps != 0`; Kotlin twin and oracle in step.
- **Testing build on Utku's phone:** `775a1819` (branch `lift-log-build`), assets verified. Just update, no wipe.

## Blocked

- **Xcode 27 was installed and its license is not accepted**, so `swift`, `xcodebuild` and `/usr/bin/python3`
  refuse to run. Utku opens Xcode once and clicks Agree (or runs `sudo xcodebuild -license accept`).

## Next

1. After the license: `bash dist/tools/verify.sh` on `0a55bc8c` (first run on Xcode 27 — read new warnings).
   It now includes the parity ratchet and governance tests, which answer the open question below.
2. Push the rebased branch (`WORKFLOW.md` §7), `Android CI` on it, `bash dist/tools/ship-build.sh`, delete the
   local `backup/pre-rebase` tag.
3. **Open question — `WhoopStore.deleteLiftSets` is a new Swift-only function.** `Tools/PARITY_GOVERNANCE.md`
   treats a new unpaired declaration as debt (twin, or a disposition), and #2163 says a disposition cannot
   settle `add-unpaired-function`. If the ratchet flags it, prefer removing the new identity over adding debt
   (e.g. an existing store shape), else a Kotlin twin; never leave `main` to go red after merge (#2229).
4. Utku's gym session on the next build: one Save; discard → zeros hidden in the summary, fillable in Edit
   sets; add/remove in Edit sets; the nothing-typed discard warning; does weight → reps need two taps
   (`BACKLOG.md` 7).
5. With his yes: `NEXT_PR.md`.

## Last verified counts (`a7f2ad08` on `eb34f3c8`, Xcode 26)

WhoopStore 600 · StrandAnalytics 2021 · StrandTests 1885 (only the two locale-dependent `TodayCarryOverTests`
fail) · iOS build · doc lint · i18n · ledger adds no finding · Kotlin oracle = Swift stdout · Android CI green ·
parity-governance: identical to `main` (then red on `main`, #2229).

## The fork, exactly

- Branches: `main` (mirror of `upstream/main`, `c430ca0b`), `lift-log-discard-and-edit`, `lift-log-build`,
  `lift-log-handbook`.
- Tags: `fork/ships-template`, `testing-latest`, plus upstream's version tags.
- Retired refs removed 15 Sep are in `~/Developer/noop-retired/noop-retired-refs-2026-09-15.bundle`
  (Utku may delete it any time).
