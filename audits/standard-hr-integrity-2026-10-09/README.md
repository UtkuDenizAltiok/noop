# Complete standard heart-rate measurement fields — 9 Oct 2026

## Assessment and chosen boundary

Source baseline: `eae23433c2948d1df6e39e7607ec94fcf34a28b7`, the current 12.1.0 beta after
upstream's ECG, battery-pack, Stress-witness and four merged own repairs. This extends the
[pipeline audit](../biometric-pipeline-2026-10-07/README.md) and
[buffer assessment](../hrv-clean-buffer-2026-10-08/README.md); it does not repeat their measurements.

| Area | Current evidence and decision |
|---|---|
| Frame/clock/history/storage | Keep existing CRC, write-before-ack, raw-record retention, source labels and within-second ordering. Standard-HR packets enter live state and collection through three parsers; all accept incomplete energy or dangling R-R fields. Protect this boundary before plausible partial data is published/persisted. |
| HRV/sleep/respiration | Existing SDNN and RHR PRs remain separate. Spectral units/grid/time defects remain; packed coarse timestamps prevent blindly reconstructing beat times from row timestamps. No estimator or physiological threshold change without coupled varying-signal/reference validation. |
| Scores/baselines | Charge eligibility is now upstream with exact submitted-source proof. Do not duplicate it or tune weights against absent private recordings. |
| Radio/CPU/memory/battery | Preserve connection, cadence, sampling and all complete readings. Earlier larger re-score costs require representative private replay. No resource-saving claim from this bounds repair. |
| UI/privacy/maintenance | Upstream owns the new battery-pack and ECG work. Privacy docs merged; six own PRs remain pending. Keep language work parked. Preserve the testing-ref recovery bundle and finish the existing refresh in the final combined delivery. |
| Backups/data | Deletion-marker archive discussion remains #2720's separate work. No schema, migration, export or backup format change. |

The selected priority is packet integrity: complete mandatory/declared known fields before any effects.
The original production Swift parser was compiled standalone. `[08,48]` and `[08,48,ff]` publish HR 72
despite a missing/incomplete declared energy value; `[10,48,00,04,ff]` publishes HR 72 and R-R 1000 ms
while silently discarding the final byte. Private baseline output: cache `deep-2026-10-09/original-malformed.txt`.

## Independent contract and research

The Bluetooth SIG Heart Rate Service defines flag-selected 8/16-bit HR, a UINT16 energy field and complete
little-endian R-R words. The Profile requires collectors to ignore reserved flag bits. The bounds gate will
leave numeric conversion, WHOOP 5 raw-ms handling, contact decoding, empty R-R compatibility and ignored
undeclared trailers unchanged. It does not invent a new physiological rejection rule.
[Heart Rate Service](https://www.bluetooth.com/wp-content/uploads/Files/Specification/HTML/HRS_v1.0/out/en/index-en.html),
[Heart Rate Profile](https://www.bluetooth.com/wp-content/uploads/Files/Specification/HTML/HRP_v1.0/out/en/index-en.html).

The 2026 HRV rigor guideline distinguishes ECG and optical inputs and cautions against interpreting wearable
HRV beyond its measurement/processing limitations. This supports keeping input integrity separate from a claim
of improved physiological accuracy. The current publisher abstract/full-page index was retrieved this session;
no personal recording or independent ECG validation is available here.
[Carter et al., 2026](https://journals.physiology.org/doi/full/10.1152/ajpheart.00041.2026).

## Preregistered before source edits

- Introduce one pure Swift/Kotlin complete-field predicate in the protocol layer; apply it before decoding or
  effects in Apple StandardHeartRate, Android StandardHeartRate and Android WHOOP's deliberately separate parser.
  Preserve the separate WHOOP field decoder and its hardware-established raw-ms choice.
- Reject missing HR bytes, incomplete declared energy, and an odd R-R tail when R-R is declared. Preserve
  all complete-known-field inputs, RFU flags, empty R-R compatibility, unknown trailer behavior, HR values,
  raw ticks, converted milliseconds and contact state. No handshake/write/transport/storage/formula change.
- Check every 256 flags at lengths 0…64 against an independent layout expectation. Compare old/new parser
  outputs directly for every UInt16 HR at representative flags, every UInt16 R-R word across both HR formats,
  energy/contact/RFU combinations, multi-word/boundary fixtures and a deterministic random corpus.
- Pin valid production Swift stdout verbatim in matched Swift/Kotlin tests. Run new malformed-input tests against
  the original parser; fail assertions, not an app-host crash. Mutation-test the shared predicate and each production
  gate; restore source hashes exactly. Warn Utku before an expected-failure Android fork run.
- Verify the actual caller gates before effects, full Apple build/tests, Kotlin debug build/full JVM suite,
  derived parity gates, exact-head upstream check roster/actual steps, combined-stack iOS/Android/Swift checks,
  then release/ref/asset/download/IPA integrity. Source journaling and retained logs precede public actions.
- A simulator can establish launch/render behavior; it cannot establish real strap transport. Preserve/restore
  original simulator state if used. After verified delivery, request only the necessary normal live-HR/log
  observation on the new phone build; hardware acceptance and malformed-packet frequency remain unproven until
  observed. No battery, sleep/HRV accuracy or frequency-of-fault claim.

## Results

Source committed locally at `d84f5a14e7b7896ce2fb177dfbb681e73bdf36b4`. An unhosted SwiftPM probe imports the verbatim production
parser/contact/predicate and real test files with module imports adapted. Original parser: exactly the two
new malformed methods failed (80 assertions, no unexpected failure), other controls passed. Fixed parser:
six tests passed. Removing energy/R-R completeness in the copied production predicate caused 4,240 assertions
to fail without unexpected errors; source restored by SHA256. Each of three production gate bypasses failed
exactly one source-wiring assertion, then its whole file was restored byte-for-byte. These do not prove GATT
runtime behavior; Android's existing JVM harness cannot construct the full client without Android services.

The direct compiled comparison checked 1,771,584 inputs; all 1,478,185 complete-known-field outputs matched,
293,399 incomplete inputs were refused. This initial run used WIP source digests, not an exact committed-head
claim; final-head and newly-refused counts will be recorded before publication. Core masks cover all 256 flags
at 65 lengths on both platforms. 27 preserved control rows come verbatim from original production Swift
[stdout](expected-original.txt); the [header oracle](HeaderOracle.swift) has
[eight patterns](expected-completeness.txt) independently checked against the SIG prefix table.

Full native/Apple/Android/PR/combined verification and delivery remain pending. Current progress lives in
[State](../../STATE.md). Reproduce source comparisons with `python3 run.py <code-worktree> <cache-directory>`.

