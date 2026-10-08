// Appended to verbatim original/candidate cleaning bodies by measure.py.
func equivalentCleaning(_ rr: [Double]) -> Bool {
    let old = OriginalCleaner.cleanRRGapAware(rr)
    let new = CandidateCleaner.cleanRRGapAware(rr)
    return old.nn.map(\.bitPattern) == new.nn.map(\.bitPattern)
        && old.contiguous == new.contiguous
        && OriginalCleaner.cleanRR(rr).map(\.bitPattern) == CandidateCleaner.cleanRR(rr).map(\.bitPattern)
}

func cleaningInput(_ count: Int, _ mixed: Bool) -> [Double] {
    (0..<count).map { i in
        if mixed && i % 31 == 0 { return 50 }
        if mixed && i % 47 == 0 { return 1500 }
        return 800 + Double((i * 17) % 101) / 4
    }
}

func cpuSeconds() -> Double {
    var usage = rusage()
    getrusage(RUSAGE_SELF, &usage)
    return Double(usage.ru_utime.tv_sec + usage.ru_stime.tv_sec)
        + Double(usage.ru_utime.tv_usec + usage.ru_stime.tv_usec) / 1e6
}

let alphabet: [Double] = [299, 300, 800, 960, 1200, 2000, 2001]
var checked = 0
for length in 0...6 {
    var combinations = 1
    for _ in 0..<length { combinations *= alphabet.count }
    for code in 0..<combinations {
        var rest = code
        var values: [Double] = []
        for _ in 0..<length {
            values.append(alphabet[rest % alphabet.count]); rest /= alphabet.count
        }
        precondition(equivalentCleaning(values), "Mismatch length=\(length) code=\(code)")
        checked += 1
    }
}
var additional: [[Double]] = [[], [.nan, .infinity, -.infinity], [800, 960, 800, 960, 800],
                             [300, 299, 800.25, 1500, 801.5, 2000, 2001]]
for n in [300, 36000, 108000] {
    additional.append(cleaningInput(n, false)); additional.append(cleaningInput(n, true))
}
for values in additional {
    precondition(equivalentCleaning(values), "Mismatch additional fixture")
    checked += 1
}
print("exact cleaning/adjacency comparison: \(checked) cases passed")

var checksum = 0
for count in [300, 36000, 108000] {
    for mixed in [false, true] {
        let values = cleaningInput(count, mixed)
        let iterations = max(10, 1_080_000 / count)
        checksum += OriginalCleaner.cleanRR(values).count + CandidateCleaner.cleanRR(values).count
        for trial in 0..<7 {
            for variant in trial % 2 == 0 ? ["original", "reuse"] : ["reuse", "original"] {
                let cpu = cpuSeconds()
                let wall = DispatchTime.now().uptimeNanoseconds
                for _ in 0..<iterations {
                    if variant == "original" {
                        checksum += OriginalCleaner.cleanRR(values).count
                        checksum += OriginalCleaner.cleanRRGapAware(values).nn.count
                    } else {
                        checksum += CandidateCleaner.cleanRR(values).count
                        checksum += CandidateCleaner.cleanRRGapAware(values).nn.count
                    }
                }
                let elapsed = Double(DispatchTime.now().uptimeNanoseconds - wall) / 1e9
                print(String(format: "trial=%d count=%d mixed=%@ variant=%@ iterations=%d cpu=%.6f wall=%.6f",
                             trial, count, String(mixed), variant, iterations, cpuSeconds() - cpu, elapsed))
            }
        }
    }
}
print("checksum=\(checksum)")
