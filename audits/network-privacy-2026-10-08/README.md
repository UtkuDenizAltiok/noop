# Network/privacy guidance — 8 Oct 2026

The whole-system [7 Oct pipeline review](../biometric-pipeline-2026-10-07/README.md) and
[8 Oct priorities](../charge-baseline-usability-2026-10-08/README.md) remain the source/biometric assessment.
This session extends the documentation boundary identified by cleanup tracker
[#2708](https://github.com/ryanbr/noop/issues/2708), rather than repeating sensor experiments.

## Decision and proof required

Recovering the saved next task found no unfinished delivery, active job, unanswered review or matching repair.
All seven existing PRs retained their recorded heads and green expected rosters. The backup-storage issue remains
parked; phone observations and personal data export remain deferred. Source base: `8e94d559`.

Network/privacy reconciliation was chosen because current user and contributor guides make directly disproven
claims about permission, payloads and defaults. They affect informed choices now and can be corrected using
source/official platform evidence, without speculative physiology changes or another phone test. Completion
requires one canonical inventory, correct guide links, preserved setup/contribution instructions, unchanged
runtime/build inputs and the expected documentation PR checks on its exact head.

## Established findings

| Boundary | Source evidence at `8e94d559` | Documentation correction |
| --- | --- | --- |
| Android permission | `android/app/src/main/AndroidManifest.xml` declares `INTERNET` | Remove four contrary assertions; identify install-time permission and retain backup controls. |
| Release reads | Swift `UpdateAvailability.defaultEnabled` and Kotlin `DEFAULT_ENABLED` are true; `UpdateChecker`/`UpdateCheck` request public GitHub releases | Document automatic/default-on versus manual checks; no health payload does not mean no HTTP request or visible IP. |
| AI configuration | Swift `isConfigured`/`resolvedKey` and Kotlin `CoachViewModel` permit explicitly connected Custom servers without a key | Describe provider setup, rather than asserting no key means no calls. A LAN server is not on-device. |
| AI triggers/payloads | `AICoach.send`, `refreshModels`, `startBriefIfNeeded`, `generateBrief`, provider clients and Android twins | Document conversation, consent-gated summaries, model queries and enabled briefs. Apple/Gemini can attach a rendered chart through a separate opt-in. |
| Oura cloud import | `OuraConfig.xcconfig`, guarded app files, OAuth/client/credential code | Preserve default compile-time exclusion and practical own-app setup. Describe auth/query requests separately from inbound health data. |
| Android push | `SelfHostedPushSettings`, `PushHttpTransport`, `PushEndpointPolicy` | Preserve default-off one-way export, authenticated capability reads, local IDs and configured endpoint boundary. |
| macOS sandbox | `Strand.entitlements` includes `network.client` | Correct the claim that the OS restricts connections to two named features/destinations. |
| Indirect services | `WorkoutDetailView.WorkoutRouteMap` builds a local overlay in `MKMapView` and frames its region | Separate platform map traffic from direct HTTP clients; no claim that local route rendering guarantees zero network. |

The direct API inventory across Apple app source, packages and Android found AI, Oura cloud import, updates and
push clients. `SseDeltas` is a pure parser, not another client; dependency URLs resolve during builds. Indirect
MapKit/browser/Health/sideloader service behaviour is explicitly separate. This is a source audit, not packet-capture
proof of every OS/service request or provider's processing/retention behaviour.

Official documentation checked on 8 Oct:
[Android INTERNET permission](https://developer.android.com/reference/android/Manifest.permission#INTERNET)
defines socket access as a normal permission;
[Apple network.client](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.network.client)
permits initiating outgoing connections, rather than imposing a destination list;
[GitHub latest release](https://docs.github.com/en/rest/releases/releases#get-the-latest-release)
documents the public release-read endpoint. Apple [MapKit documentation](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/LocationAwarenessPG/MapKit/MapKit.html)
describes framework-provided map imagery; possible network loading is an inference from that framework and the
actual `MKMapView` integration, not a measured traffic result. No physiology or energy improvement is claimed.

## Verification and preservation

Six documentation files are changed. The other 120 Markdown pages and all app/package/test/tool/workflow/config
trees are unchanged. All 126 Markdown pages were checked for local file targets with no new broken targets;
new fragment links were resolved and three legacy heading anchors retained. GitHub Markdown rendering of all
six changed files was checked for structure, including the inventory table and retained anchors.
Source hygiene and diff-scoped i18n passed with Python 3.12. The initial local i18n invocation used macOS's
Python 3.9 and could not load the tool; the corrected 3.12 invocation passed. The private render validator initially
expected a bare table tag; GitHub emits `table role="table"`. Correcting that parser expectation passed without
changing the documents.

Private recovery/API inventories, 22 source hashes, validator and JSON results are retained in
`private/network-privacy-2026-10-08/`. Rendered HTML and gate logs are in cache
`network-privacy-2026-10-08/`. No personal data is included in this audit. Current PR head/checks/delivery and
the next safe action live in [State](../../STATE.md); documentation-only changes require no app build or release.
