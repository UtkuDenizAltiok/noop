# REA for WHOOP / NOOP — 9 Oct 2026

**Utku's actual request:** use REA to study the original WHOOP app and use what we learn to
improve NOOP across the whole app. The initial assessment/post focused too narrowly on packet
fields. He corrected that on 9 Oct and asked for normal, simple language. The original app is
the target; inspecting NOOP alone would not answer his request.

**Recommendation:** start with the original Android app because REA has an explicit APK/JADX
workflow. Study connection/sync, data handling, sleep/workouts, local calculations, screens,
background work and battery use. Find which work the app does itself and which it asks servers
to do; app inspection cannot reveal code that exists only on those servers. Keep useful findings,
then choose and verify NOOP changes rather than promise that every area will improve.

No original WHOOP app has been inspected yet. REA was not installed or executed and no NOOP
source, formula, device command or build changed. The technical evidence below establishes
possible tool capabilities, not a completed reverse-engineering result.

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

## First practical step and verification

Obtain a genuine original WHOOP Android app package for private, static inspection. Record its
source, package ID, version, SHA-256 and signing identity; a download-page claim alone is not
verification. A package may include split APKs, so record which files are present and missing.
The 9 Oct filename search found no WHOOP-named APK/IPA in this checkout, Downloads or the
handbook cache. Public APKMirror listings are an acquisition lead, not a file already obtained
or verified. No credentials or health export are needed for static inspection.

Check scoped REA/JDK/JADX prerequisites and actual package/provider capabilities before running
analysis. Keep app files and recovered material in ignored/private cache storage, outside NOOP
source and public handbook commits. Read the app without launching it, touching a strap or
signing in. Begin by mapping connection/sync and data-to-score paths, then examine the other
areas above; report unknown or server-only parts plainly. A small known-source fixture is an
optional tool check, not a replacement for studying the original app.

Each finding must point to its app/version evidence and be checked independently where possible.
Before a NOOP change, define the benefit and its test, preserve upstream's clean-room/scope rules,
and keep Swift/Kotlin parity. UI observation can suggest behaviour; decompiled code is not a
ready-made implementation to paste into NOOP. Better health estimates still need independent
measurements. This is a research plan and corrected outreach, not completed original-app analysis.

## Outreach and recovery

Utku explicitly chose **post to REA's GitHub; he will name Reddit/Discord destinations**. REA's
issue-template configuration directs questions to Discussions; Q&A is the appropriate category.
The existing question was edited after Utku clarified the scope, with the title
**Can REA help us study the original WHOOP app and improve NOOP?** and a simpler body covering
the areas above. No second topic was created. It accurately describes a NOOP contributor and
an untested REA use case; no claim of collaboration or accuracy achieved.
**[Q&A #1343](https://github.com/morluto/rea/discussions/1343) published once**, 9 Oct 17:45:16 UTC,
under `UtkuDenizAltiok`; independent API readback verified number/URL/author/category/title/full body,
and public web readback confirmed visibility. The corrected title/body/author/category were independently read back after the edit; correction
is complete. Zero comments at that check. Reddit and Discord remain unposted drafts for this broader request until their
destinations are supplied and current rules checked.

Local source: `/Users/utk/Library/Caches/noop-handbook/rea-2026-10-09/source`.
Ignored `private/rea-2026-10-09/` retains metadata, npm version/digest, PR snapshots, exact outreach
text and posting readback. The source snapshot can be reacquired from its public pinned commit;
private records are not uploaded by handbook backup. Seven existing own PRs retain their exact
heads/full successful check rosters and no new unanswered feedback at this research boundary.
