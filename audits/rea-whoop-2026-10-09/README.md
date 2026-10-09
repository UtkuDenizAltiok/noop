# REA for WHOOP / NOOP — 9 Oct 2026

**Latest outreach scope, 10 Oct:** ask whether REA could help NOOP across syncing, data/calculations,
sleep/workouts, screens and battery use, and invite experienced community members to investigate. Use the
owner's requested plain newcomer wording: he does not know much about REA or coding. Current work is these
questions, not a claim that original-app analysis or a score improvement has happened.

**Recommendation:** ask people who know REA what is possible, whether relevant work already exists and
whether someone is interested in helping. The earlier Android/JADX assessment below is retained technical
reference. It does not establish how WHOOP's app works or authorize a new local investigation.

No original WHOOP app acquired/inspected; REA not installed/run. No NOOP source/formula/device command/build
changed during this outreach. Latest continuation scope is saved privately and linked from State.

## Evidence and confidence

Reviewed REA commit **3edb2172def0e0bd9076f23148f0c41cd2f341a3**, a clean shallow source snapshot
with successful Git object verification. GitHub API reported 40,233 stars / 6,226 forks at the
initial 9 Oct check; popularity is not proof of correctness. Repository `package.json` and the
public npm registry both reported **rea-agents 6.2.0**. This does not prove source/package byte
equivalence or provider readiness. The older installation-guide release checkpoint remains 5.0.0;
select capabilities from the actual connected server before a pilot.

| Finding | Evidence | Implication for NOOP |
|---|---|---|
| Static Android APK analysis uses caller-supplied JADX and a full JDK. | [Android analysis](https://github.com/morluto/rea/blob/3edb2172def0e0bd9076f23148f0c41cd2f341a3/docs/android-analysis.md); `src/android/`. | Potentially useful for locating parsers, widths, constants and references; no live strap observation is established. |
| Apple/native inspection supplies symbols, metadata, references and provider-backed pseudocode. Swift metadata has explicit unsupported forms; the documented real Swift verification lane includes dSYM companions. | [Native investigation](https://github.com/morluto/rea/blob/3edb2172def0e0bd9076f23148f0c41cd2f341a3/docs/native-investigation.md); [testing](https://github.com/morluto/rea/blob/3edb2172def0e0bd9076f23148f0c41cd2f341a3/docs/testing.md). | Useful diagnostic capability to evaluate, not evidence that an arbitrary official iOS app can be fully inspected. |
| Native call observation launches an owned host process under LLDB; the implementation provider is `native-macos`. | `src/native/LldbCallTracer.ts`, `NativeMacOSProvider.ts`; native-investigation guide. | Do not assume physical-iPhone or Android BLE tracing, automatic packet capture, return-value observation or complete runtime coverage. |
| No WHOOP/Bluetooth/GATT/HCI-specific implementation or guidance was found in the searched source/docs/tests/bridge/skill/website directories. GitHub issue/PR searches for WHOOP and Bluetooth returned zero; three existing discussions had unrelated titles. | Pinned source search and GitHub API readbacks. | Integration value is a hypothesis. A web search returning other WHOOP projects is not a REA demonstration. |
| Retained network captures mean HAR or mitmproxy web captures. | [Network-capture guide](https://github.com/morluto/rea/blob/3edb2172def0e0bd9076f23148f0c41cd2f341a3/docs/web-network-captures.md). | Do not mistake this feature for a Bluetooth HCI/GATT capture reader. |
| Analysis is local; an agent receives its results under the model provider's policy. Local provider execution is not a sandbox. | [REA README](https://github.com/morluto/rea/blob/3edb2172def0e0bd9076f23148f0c41cd2f341a3/README.md), [Security](https://github.com/morluto/rea/blob/3edb2172def0e0bd9076f23148f0c41cd2f341a3/SECURITY.md). | Keep initial artifacts synthetic/public and the tool outside NOOP's shipped dependencies. Local execution alone is not a privacy guarantee for model-visible evidence. |

## What to look for in the original app

| Area | Questions for the review | What a useful NOOP change must prove |
|---|---|---|
| Connection and sync | Pairing, reconnects, acknowledgements, missing/out-of-order readings, clocks and retry handling. | More reliable collection without lost/duplicated data or unsafe strap commands. |
| Data and calculations | Field meaning, units, quality checks, local preprocessing and calls to server-provided results. | Independently verified facts and unchanged clean-input results, or stronger reference accuracy. |
| Sleep and workouts | Detection, edits, late-arriving data, workout lifecycle and correction behaviour. | Reproducible user benefit, with independent sleep/cardiac references for physiological changes. |
| Screens and explanations | Navigation, chart behaviour, controls, missing-data displays and helpful feedback. | Clearer behaviour in NOOP's own design; no copied assets or text. |
| Background work and battery | Scheduling, caching, duplicate work and sensor/radio use. | Measured saving with the same data, results and freshness. |

WHOOP's [official Android listing](https://play.google.com/store/apps/details?id=com.whoop.android)
identifies the target as `com.whoop.android`; public product/help pages describe features but do
not establish how they are implemented. Those descriptions help build the question list, not
prove local algorithms or performance. [Features](https://www.whoop.com/us/en/product-feature/),
[activity/sleep handling](https://support.whoop.com/s/article/Automatic-and-Manual-Activity-Detection).

The earlier SpO₂ candidate remains one possible question inside this wider review, not its scope
or priority. [NOOP's reviewed decoder](https://github.com/ryanbr/noop/blob/eae23433c2948d1df6e39e7607ec94fcf34a28b7/Packages/WhoopProtocol/Sources/WhoopProtocol/Interpreter.swift#L624)
records conflicting observations across devices; it cannot back a shipped metric yet.

NOOP's [facts-vs-code rule](https://github.com/ryanbr/noop/blob/eae23433c2948d1df6e39e7607ec94fcf34a28b7/docs/CONTRIBUTING.md#L684)
allows attributed protocol facts as unvalidated candidates, independently reimplemented and
verified from captures. Decompiled implementations/literals/assets, WHOOP firmware and DRM
circumvention remain excluded. Neither REA's MIT license nor an AI summary changes that boundary.

Better field interpretation could improve available input and expose errors. It does not prove
physiological accuracy. Sleep staging still requires independent PSG labels with held-out people
and coverage/missing-data checks; HR/HRV needs synchronized cardiac-reference evidence where
appropriate. [DREAMT](https://physionet.org/content/dreamt/2.0.0/) is one existing sleep-validation
reference, not WHOOP ground truth or a new dataset downloaded here. Matching WHOOP alone is not
proof of improvement. Its [official API](https://developer.whoop.com/api/) offers authenticated
account data including already-computed scores; REA cannot infer unavailable cloud-side code
from a client binary. An API dependency would also change NOOP's offline strap-sync model.

## Reference prerequisites for a possible investigation

A genuine original Android package and private static inspection would need source, package ID, version,
SHA-256/signing identity and split-file coverage verified; a download-page claim alone is insufficient.
The 9 Oct filename search found no WHOOP-named APK/IPA in this checkout, Downloads or the
handbook cache. Public APKMirror listings are an acquisition lead, not a file already obtained
or verified. No credentials or health export are needed for static inspection.

Scoped REA/JDK/JADX and actual provider capabilities would need checking. Any future materials must stay
outside NOOP source/public handbook, with independently verified findings and server-only unknowns stated.
These are reference prerequisites, not a next action under the current outreach scope.

Each finding must point to its app/version evidence and be checked independently where possible.
Before a NOOP change, define the benefit and its test, preserve upstream's clean-room/scope rules,
and keep Swift/Kotlin parity. UI observation can suggest behaviour; decompiled code is not a
ready-made implementation to paste into NOOP. Better health estimates still need independent
measurements. No original-app analysis has been completed; current questions seek community advice and voluntary help.

## Outreach and recovery

The owner clarified on 10 Oct that he had not sent the Reddit/Discord messages and authorized the agent to
publish through his signed-in browser. The old assumed-sent record is superseded. After further wording
instructions, all five places now say he does not know REA/coding much, ask whether it could improve NOOP
and invite experienced people to help. No owner commitment to perform analysis and no personal health data.

Existing [NOOP #2752](https://github.com/ryanbr/noop/issues/2752), **Could someone use REA to help improve
NOOP?**, and [REA Q&A #1343](https://github.com/morluto/rea/discussions/1343), **Could REA help improve NOOP
by studying the original WHOOP app?**, were edited in place and independently read back exactly, with mutual
links. Both remain without replies at the current check. NOOP Discussions disabled, so one proposal issue was
used; no new/duplicate GitHub topic needed.

| Place | Why | Verified message |
|---|---|---|
| [r/NoopBand](https://www.reddit.com/r/NoopBand/) | Current official NOOP community; users can name useful improvements. Civility/no-spam rules read. | [Published post](https://www.reddit.com/r/NoopBand/comments/1x2043f/could_studying_the_original_whoop_app_with_rea/) |
| [NOOP Discord](https://discord.com/invite/wKgyqVdjrP) | Existing developers; `#dev-talk` is more appropriate than `#general` for this question. Rules read. | [Sent message](https://discord.com/channels/1523991899336216696/1524343656075628654/1558258467045646459) |
| [REA Discord](https://discord.gg/GkcryMnJDM) | Experienced REA users; `#general` explicitly invites questions/help. Rules read. | [Sent message](https://discord.com/channels/1556595354999332884/1556595356199030809/1558260192364204194) |

One post/message per community, verified as owner account and exact final text. Reddit's rich editor did not
persist its first edit; saved Markdown edit and final page readback proved the correction. NOOP's final edit
was replaced with normal keyboard selection/paste after a DOM fill appended old text; exact saved readback
proves only the final wording remains. Stale Discord GitHub previews were suppressed; links remain clickable.
REA joined using the existing account's in-app Join Server UI, English role only; optional research roles skipped.
No new account, credentials, private file upload or software installation. Temporary anonymous invite tab closed;
original Discord/GitHub tabs retained, published Reddit tab marked as a deliverable.

No official REA subreddit was found in its current official community links/search. Discord and GitHub are its
linked communities; this does not prove no unofficial subreddit exists. No wider mass crossposting.

Current ignored `private/rea-2026-10-09/posting-status.json` and `posting-2026-10-10/` own exact bodies,
URLs/authors/screenshots, publication/correction readbacks and the latest continuation boundary. Read those
before any proposed REA-related execution. Public technical evidence is in this audit; private scope/evidence
depend on this Mac. Seven own PRs unchanged/full green/no new feedback at 10 Oct check; #2724's existing merge
conflict remains, six others mergeable. No app implementation/rebuild/release or running analysis job.
