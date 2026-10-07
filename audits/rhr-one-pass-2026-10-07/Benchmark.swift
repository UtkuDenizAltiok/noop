import Foundation
import Darwin

@inline(never) func exerciseRhr(_ rows: [HRSample], start: Int, end: Int, repeats: Int) -> String {
    var result = ""
    for _ in 0..<repeats {
        let floor = SleepStager.sessionRestingHR(start: start, end: end, hr: rows)
        let line = SleepStager.rhrBinGateLogLine(day: "synthetic", sessions: [(start, end)], hr: rows,
                                               shippedFloor: floor ?? 0)
        result = "\(floor.map(String.init) ?? "nil")|\(line ?? "nil")"
    }
    return result
}
func processCPU() -> Double {
    var t = timespec()
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t)
    return Double(t.tv_sec) + Double(t.tv_nsec) / 1e9
}
let repeats = Int(CommandLine.arguments.dropFirst().first ?? "21") ?? 21
let start = 1_000_000, end = start + 8 * 3600
for (name, cadence, padding, reverse) in [
    ("dense-night", 1, 0, false), ("dense-54h-read", 1, 23 * 3600, false),
    ("sparse-night", 30, 0, false), ("reversed-night", 1, 0, true)
] {
    var rows = stride(from: start - padding, through: end + padding, by: cadence).map {
        HRSample(ts: $0, bpm: 55 + (($0 - start + padding) / 300) % 30)
    }
    // A thin low bin makes the diagnostic exercise its full output, too.
    rows.removeAll { $0.ts >= end - 300 && $0.ts < end }
    rows.append(HRSample(ts: end - 100, bpm: 30))
    if reverse { rows.reverse() }
    let before = processCPU(), wall = ProcessInfo.processInfo.systemUptime
    let output = exerciseRhr(rows, start: start, end: end, repeats: repeats)
    print("\(name) rows=\(rows.count) repeats=\(repeats) cpu=\(processCPU() - before) wall=\(ProcessInfo.processInfo.systemUptime - wall) result=\(output)")
}
