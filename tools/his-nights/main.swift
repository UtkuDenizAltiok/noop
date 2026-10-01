import Foundation
import SQLite3
import StrandAnalytics
import WhoopProtocol

// See run.sh. Reads sleepSession (my-whoop-noop) and the strap's streams (my-whoop), with the app's scoring
// filter on R-R: WHOOP 5 channels (5, 7) and not tsSuspect (#1073, #2371).
let path = CommandLine.arguments[1]
var db: OpaquePointer?
guard sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else { print("cannot open \(path)"); exit(1) }
func rows(_ sql: String, _ body: (OpaquePointer) -> Void) {
    var st: OpaquePointer?
    guard sqlite3_prepare_v2(db, sql, -1, &st, nil) == SQLITE_OK, let s = st else { print("bad sql \(sql)"); exit(1) }
    while sqlite3_step(s) == SQLITE_ROW { body(s) }
    sqlite3_finalize(s)
}
var nights: [(Int, Int)] = []
rows("SELECT startTs, endTs FROM sleepSession WHERE deviceId = 'my-whoop-noop' AND endTs - startTs >= 10800 ORDER BY startTs") {
    nights.append((Int(sqlite3_column_int64($0, 0)), Int(sqlite3_column_int64($0, 1))))
}
func pct(_ labels: [String]) -> (deep: Double, rem: Double, light: Double, wake: Double) {
    let sleep = Double(labels.filter { $0 != "awake" && $0 != "wake" }.count)
    func p(_ s: String) -> Double { sleep == 0 ? .nan : 100 * Double(labels.filter { $0 == s }.count) / sleep }
    return (p("deep"), p("rem"), p("light"), 100 * Double(labels.count - Int(sleep)) / Double(max(1, labels.count)))
}
func labels(_ segs: [StageSegment], _ start: Int, _ end: Int) -> [String] {
    var out: [String] = []
    var e = ((start + 29) / 30) * 30
    while e < end {
        let mid = e + 15
        out.append(segs.first { mid >= $0.start && mid < $0.end }?.stage ?? "awake")
        e += 30
    }
    return out
}
func fmt(_ v: Double) -> String { v.isNaN ? "  –  " : String(format: "%5.1f", v) }
let df = DateFormatter(); df.dateFormat = "MM-dd HH:mm"
print("night         min   variant                 deep%  REM%  light% (of sleep)  wake% (of window)   z present / mean z of REM-called")
var tot: [String: [Double]] = [:]
for (start, end) in nights {
    let lo = start - 330, hi = end + 390
    var hr: [HRSample] = [], grav: [GravitySample] = [], rr: [RRInterval] = []
    rows("SELECT ts, bpm FROM hrSample WHERE deviceId = 'my-whoop' AND ts >= \(lo) AND ts < \(hi) ORDER BY ts") {
        hr.append(HRSample(ts: Int(sqlite3_column_int64($0, 0)), bpm: Int(sqlite3_column_int64($0, 1))))
    }
    rows("SELECT ts, x, y, z FROM gravitySample WHERE deviceId = 'my-whoop' AND ts >= \(lo) AND ts < \(hi) ORDER BY ts") {
        grav.append(GravitySample(ts: Int(sqlite3_column_int64($0, 0)), x: sqlite3_column_double($0, 1),
                                  y: sqlite3_column_double($0, 2), z: sqlite3_column_double($0, 3)))
    }
    rows("""
        SELECT ts, rrMs FROM rrInterval WHERE deviceId = 'my-whoop' AND ts >= \(lo) AND ts < \(hi)
        AND srcChannel IN (5, 7) AND (tsSuspect IS NULL OR tsSuspect <> 1) ORDER BY ts, ord, seq
        """) { rr.append(RRInterval(ts: Int(sqlite3_column_int64($0, 0)), rrMs: Int(sqlite3_column_int64($0, 1)))) }
    let rrQ = rr.map { RRInterval(ts: $0.ts, rrMs: Int((Double($0.rrMs) / 15.625).rounded() * 15.625)) }
    let mins = (end - start) / 60
    let head = "\(df.string(from: Date(timeIntervalSince1970: TimeInterval(start))))  \(String(format: "%4d", mins))   "
    let shippedSegs = SleepStagerV2.stageSession(start: start, end: end, grav: grav, hr: hr, rr: rr, resp: [])
    let shippedL = labels(shippedSegs, start, end)
    var variants: [(String, RecipeConfig, [RRInterval])] = []
    var c = RecipeConfig.shipped; variants.append(("port shipped (±0.6)", c, rr))
    c = .shipped; c.respWeight = 0.3; variants.append(("symmetric ±0.3", c, rr))
    c = .shipped; c.respWeight = 0.0; variants.append(("off", c, rr))
    c = .shipped; c.respShape = .remOnly; variants.append(("remOnly 0.6", c, rr))
    c = .shipped; variants.append(("shipped, R-R at 1/64 s", c, rrQ))
    let s = pct(shippedL)
    print(head + "SleepStagerV2 (app)    " + "\(fmt(s.deep)) \(fmt(s.rem)) \(fmt(s.light))              \(fmt(s.wake))")
    tot["SleepStagerV2 (app)", default: []] += [s.deep, s.rem, s.light, s.wake]
    for (name, cfg, r) in variants {
        let (feats, lab) = V2Recipe.stageEpochsDetailed(start: start, end: end, grav: grav, hr: hr, rr: r, resp: [], cfg: cfg)
        let p = pct(lab)
        let present = feats.filter { $0.respReg != nil }.count
        var same = ""
        if name.hasPrefix("port shipped") {
            let norm: (String) -> String = { $0 == "awake" ? "wake" : $0 }
            let a = lab.map(norm), b = shippedL.map(norm)
            let diff = zip(a, b).filter { $0.0 != $0.1 }.count
            same = diff == 0 && a.count == b.count ? "  (= app, every epoch)"
                : "  (≠ app: \(diff) epochs differ at \(zip(a, b).enumerated().filter { $0.1.0 != $0.1.1 }.map { "#\($0.0) \($0.1.0)/\($0.1.1)" }), \(a.count) vs \(b.count) epochs)"
        }
        print(String(repeating: " ", count: head.count) + name.padding(toLength: 23, withPad: " ", startingAt: 0)
              + "\(fmt(p.deep)) \(fmt(p.rem)) \(fmt(p.light))              \(fmt(p.wake))   \(present)/\(feats.count)\(same)")
        tot[name, default: []] += [p.deep, p.rem, p.light, p.wake]
    }
}
print("\nmean over \(nights.count) nights            deep%  REM%  light% (of sleep)  wake%")
for name in ["SleepStagerV2 (app)", "port shipped (±0.6)", "symmetric ±0.3", "off", "remOnly 0.6", "shipped, R-R at 1/64 s"] {
    let v = tot[name] ?? []
    func m(_ k: Int) -> Double { let xs = stride(from: k, to: v.count, by: 4).map { v[$0] }.filter { !$0.isNaN }; return xs.reduce(0, +) / Double(max(1, xs.count)) }
    print("  " + name.padding(toLength: 34, withPad: " ", startingAt: 0) + "\(fmt(m(0))) \(fmt(m(1))) \(fmt(m(2)))              \(fmt(m(3)))")
}
