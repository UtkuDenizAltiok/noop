func oracleInput(_ count: Int, _ mixed: Bool) -> [Double] {
    (0..<count).map { i in
        if mixed && i % 31 == 0 { return 50 }
        if mixed && i % 47 == 0 { return 1500 }
        return 800 + Double((i * 17) % 101) / 4
    }
}

func oracleHash(_ words: [UInt64]) -> String {
    var hash: UInt64 = 14695981039346656037
    for word in words { hash = (hash ^ word) &* 1099511628211 }
    return String(hash, radix: 16)
}

var fixtures: [[Double]] = (0...8).map { oracleInput($0, true) }
fixtures += [[.nan, .infinity, -.infinity, 800, 801, 802],
             [300, 299, 800.25, 1500, 801.5, 2000, 2001],
             [800, 960, 800, 960, 800, 960, 800],
             [800, 960.0000000000001, 800, 960.0000000000001, 800],
             [2000, 2000, 1600, 1600, 300, 300, 300]]
for count in [300, 36000, 108000] {
    fixtures.append(oracleInput(count, false)); fixtures.append(oracleInput(count, true))
}
for (index, input) in fixtures.enumerated() {
    let clean = OriginalCleaner.cleanRR(input)
    let gap = OriginalCleaner.cleanRRGapAware(input)
    print("\(index)|\(clean.count)|\(oracleHash(clean.map(\.bitPattern)))|\(oracleHash(gap.nn.map(\.bitPattern)))|\(oracleHash(gap.contiguous.map { $0 ? 1 : 0 }))")
}
