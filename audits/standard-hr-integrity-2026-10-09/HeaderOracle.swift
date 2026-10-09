import Foundation
for flags: UInt8 in [0x00, 0x01, 0x08, 0x09, 0x10, 0x11, 0x18, 0x19] {
    var bits = ""
    for length in 0...64 {
        var data = [UInt8](repeating: 0, count: length)
        if !data.isEmpty { data[0] = flags }
        bits += StandardHRMeasurement.hasCompleteFields(data) ? "1" : "0"
    }
    print(String(format: "%02x", flags) + "|" + bits)
}
