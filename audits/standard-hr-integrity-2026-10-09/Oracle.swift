import Foundation

// Complete-field compatibility corpus. Compile with the verbatim original production parser.
let controlFrames: [[UInt8]] = [
    [0x00, 72], [0x02, 0], [0x04, 220], [0x06, 255],
    [0x01, 0x00, 0x01], [0x07, 0xff, 0xff],
    [0x08, 72, 0, 0], [0x09, 0x40, 1, 0xff, 0xff],
    [0x10, 60], [0x11, 0x40, 1], [0x18, 65, 0xff, 0], [0x19, 0xff, 0xff, 0xff, 0xff],
    [0x10, 60, 0, 4], [0x16, 72, 0, 4], [0x18, 65, 0xff, 0, 0, 4],
    [0x19, 0x40, 1, 0x34, 0x12, 0, 4], [0x10, 58, 0, 2, 0, 4],
    [0x10, 72, 0, 0, 0x40, 0, 0xc0, 0, 0xff, 0xff],
    [0xe0, 72], [0xe0, 72, 0xff], [0xf0, 72, 0, 4], [0xf6, 72, 0, 2, 0, 4],
    [0xf9, 0x40, 1, 0, 0, 0, 4], [0xfe, 72, 0, 0, 0, 4],
    [0xff, 0x40, 1, 0, 0, 1, 0], [0x00, 72, 0xff, 0, 4], [0x01, 0x40, 1, 0xff]
]
for data in controlFrames {
    let hex = data.map { String(format: "%02x", $0) }.joined()
    guard let reading = StandardHeartRate.parse(data) else { fatalError("control refused: \(hex)") }
    print("\(hex)|\(reading.hr)|\(reading.rr.map(String.init).joined(separator: ","))|\(reading.rrRawTicks.map(String.init).joined(separator: ","))|\(reading.contact.rawValue)")
}
