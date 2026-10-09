import Foundation

var checked = 0
var compatible = 0
var refused = 0
var newlyRefused = 0

func layoutExpectation(_ data: [UInt8]) -> Bool {
    guard let flags = data.first else { return false }
    // Independent SIG field-size table: flags + HR + optional energy.
    let prefix: Int
    switch flags & 0x09 {
    case 0x00: prefix = 2
    case 0x01: prefix = 3
    case 0x08: prefix = 4
    default: prefix = 5
    }
    if data.count < prefix { return false }
    return flags & 0x10 == 0 || stride(from: prefix, through: data.count, by: 2).contains(data.count)
}

func fail(_ message: String, _ data: [UInt8]) -> Never {
    fputs("\(message): \(data)\n", stderr)
    exit(1)
}

func check(_ data: [UInt8]) {
    let complete = layoutExpectation(data)
    if StandardHRMeasurement.hasCompleteFields(data) != complete { fail("layout mismatch", data) }
    let candidate = StandardHeartRate.parse(data)
    if complete {
        guard let old = OriginalStandardHeartRate.parse(data), let new = candidate else {
            fail("complete input refused", data)
        }
        if old.hr != new.hr || old.rr != new.rr || old.rrRawTicks != new.rrRawTicks || old.contact != new.contact {
            fail("complete reading changed", data)
        }
        compatible += 1
    } else {
        if candidate != nil { fail("incomplete input accepted", data) }
        if OriginalStandardHeartRate.parse(data) != nil { newlyRefused += 1 }
        refused += 1
    }
    checked += 1
}

func frame(_ flags: UInt8, hr: Int, words: [Int]) -> [UInt8] {
    var data = [flags, UInt8(hr & 255)]
    if flags & 1 != 0 { data.append(UInt8((hr >> 8) & 255)) }
    if flags & 8 != 0 { data += [0x34, 0x12] }
    if flags & 16 != 0 {
        for raw in words { data += [UInt8(raw & 255), UInt8((raw >> 8) & 255)] }
    }
    return data
}

for flags in UInt8.min...UInt8.max {
    for length in 0...64 {
        var data = [UInt8](repeating: 0xa5, count: length)
        if !data.isEmpty { data[0] = flags }
        check(data)
    }
    let hrs = flags & 1 == 0 ? Array(0...255) : [0, 29, 30, 72, 220, 221, 255, 256, 320, 65535]
    for hr in hrs { check(frame(flags, hr: hr, words: [0, 1, 64, 192, 1024, 65535])) }
}
for hr in 0...65535 {
    for flags: UInt8 in [0x01, 0x19, 0xff] { check(frame(flags, hr: hr, words: [64, 1024, 65535])) }
}
for raw in 0...65535 {
    for flags: UInt8 in [0x10, 0x11, 0x18, 0x19, 0xf0, 0xf1, 0xf8, 0xf9] {
        check(frame(flags, hr: 72, words: [raw, 65535 - raw]))
    }
}
var seed: UInt32 = 0x6e6f6f70
func next() -> UInt32 {
    seed = seed &* 1664525 &+ 1013904223
    return seed
}
for _ in 0..<1_000_000 {
    let length = Int(next() % 65)
    let data = (0..<length).map { _ in UInt8(truncatingIfNeeded: next() >> 16) }
    check(data)
}
let result: [String: Any] = ["checked": checked, "compatible": compatible, "refused": refused, "newlyRefused": newlyRefused,
                           "flags": 256, "lengthRange": "0...64", "randomSeed": "6e6f6f70"]
let encoded = try JSONSerialization.data(withJSONObject: result, options: [.sortedKeys])
print(String(decoding: encoded, as: UTF8.self))
