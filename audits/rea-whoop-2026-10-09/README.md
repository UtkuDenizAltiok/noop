# REA for WHOOP / NOOP — 9 Oct 2026

**Recommendation:** REA is worth a bounded tool evaluation for protocol research. It is not a
WHOOP connector or a validated biometric model. The most useful eventual outcome is independently
verified packet interpretation, not reproducing a proprietary recovery score. No NOOP source,
formula, device command or build changed in this assessment; REA was not installed or executed.

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

## The question worth investigating

NOOP's WHOOP 5 historical decoder already records `spo2_candidate_82`. Its source documents
contradictory observations between devices, so it remains instrumentation and cannot write a
shipped SpO₂ metric or feed recovery/illness gates. REA could help identify the candidate field's
width, units, sentinels or firmware-dependent interpretation. This is an inferred opportunity,
not a result obtained with REA. [Current reviewed NOOP decoder](https://github.com/ryanbr/noop/blob/eae23433c2948d1df6e39e7607ec94fcf34a28b7/Packages/WhoopProtocol/Sources/WhoopProtocol/Interpreter.swift#L624).

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

## Bounded validation before adopting the tool

First evaluate one public, source-owned NOOP parser fixture using synthetic packets and a compiled
artifact with known results. Record exact artifact hash, REA/package/provider versions, offsets,
reported coverage/unknowns and elapsed investigation time. Compare recovered statements and
outputs against source plus the existing parser oracle, including valid, truncated and sentinel
cases. Success means correct, reproducible evidence with no invented semantics and useful effort
saved over current tools; a convincing narrative is insufficient. No personal health data,
official WHOOP code, firmware or strap writes are required for this readiness check.

Only if that works and answers a concrete missing question should an independently verified
WHOOP protocol-fact investigation follow, with provenance, hardware/firmware identity and
cross-device capture checks. Any shipped metric change is a separate implementation/validation
task under the existing parity and science rules. This assessment does not start either pilot.

## Outreach and recovery

Utku explicitly chose **post to REA's GitHub; he will name Reddit/Discord destinations**. REA's
issue-template configuration directs questions to Discussions; Q&A is the appropriate category.
Publish one technical question, accurately describing a NOOP contributor and an untested REA
use case. No duplicate tracker, promotion-only issue or claim of collaboration/accuracy achieved.
**[Q&A #1343](https://github.com/morluto/rea/discussions/1343) published once**, 9 Oct 17:45:16 UTC,
under `UtkuDenizAltiok`; independent API readback verified number/URL/author/category/title/full body,
and public web readback confirmed visibility. Zero comments at readback; no REA response yet. Reddit
and Discord remain unposted drafts until their destinations are supplied and current rules checked.

Local source: `/Users/utk/Library/Caches/noop-handbook/rea-2026-10-09/source`.
Ignored `private/rea-2026-10-09/` retains metadata, npm version/digest, PR snapshots, exact outreach
text and posting readback. The source snapshot can be reacquired from its public pinned commit;
private records are not uploaded by handbook backup. Seven existing own PRs retain their exact
heads/full successful check rosters and no new unanswered feedback at this research boundary.
