// Oracle for StrapLogArchiveTest.kt (branch strap-log-on-disk): two fixed scenarios, each export printed exactly —
// the Swift StrapLogArchive is the reference. Paste the KEPT and PRUNED blocks as the test's ORACLE_KEPT and
// ORACLE_PRUNED; keep these scenarios in step with the test's. Run in a checkout of that branch:
//   swiftc -O Strand/BLE/StrapLogArchive.swift ~/Developer/noop/dist/tools/oracle/strap-log/main.swift \
//     -o "$TMPDIR/strap-oracle" && "$TMPDIR/strap-oracle"
import Foundation
let t0 = Date(timeIntervalSince1970: 1_790_000_000)
func scenario(budget: Int) -> String {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent("strap-oracle-\(UUID().uuidString)")
    try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    func run(_ s: Double) -> StrapLogArchive {
        StrapLogArchive(directory: dir, budgetBytes: budget, segmentBytes: 100, now: t0.addingTimeInterval(s))
    }
    let first = run(0)
    first.importLegacy(StrapLogArchive.legacyRingLines(
        generations: [["===== previous app session, 1 line(s), rolled at 2026-09-20T10:00:00Z (this launch) =====",
                       "ring run"]],
        tail: ["ring tail"], now: t0))
    for i in 1...3 { first.append("first \(i)") }
    let long = run(100)
    for i in 1...40 { long.append(String(format: "long %02d", i)) }
    let last = run(200)
    last.append("current 1")
    return last.exportText()
}
/// Storage refused (iOS before the first unlock), then open: what memory holds, and what the next run reads.
func lockedScenario() -> (held: String, after: String) {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent("strap-oracle-\(UUID().uuidString)")
    let fm = FileManager.default
    try! fm.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? fm.setAttributes([.posixPermissions: 0o700], ofItemAtPath: dir.path); try? fm.removeItem(at: dir) }
    func run(_ s: Double) -> StrapLogArchive {
        StrapLogArchive(directory: dir, budgetBytes: 250, segmentBytes: 100, now: t0.addingTimeInterval(s))
    }
    try! fm.setAttributes([.posixPermissions: 0o500], ofItemAtPath: dir.path)
    let locked = run(0)
    for i in 1...40 { locked.append(String(format: "locked %02d", i)) }
    let held = locked.exportText()
    try! fm.setAttributes([.posixPermissions: 0o700], ofItemAtPath: dir.path)
    for i in 1...64 { locked.append(String(format: "open %02d", i)) }
    return (held, run(100).exportText())
}
print("KEPT<<", scenario(budget: 4096), ">>KEPT", separator: "")
print("PRUNED<<", scenario(budget: 250), ">>PRUNED", separator: "")
let locked = lockedScenario()
print("LOCKED_HELD<<", locked.held, ">>LOCKED_HELD", separator: "")
print("LOCKED_AFTER<<", locked.after, ">>LOCKED_AFTER", separator: "")
