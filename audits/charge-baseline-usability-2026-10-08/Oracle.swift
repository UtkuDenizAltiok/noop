import Foundation
func oracleOptionalState(_ mean: Double, _ spread: Double, _ status: BaselineStatus) -> BaselineState {
    BaselineState(baseline: mean, spread: spread,
        nValid: status == .calibrating ? 0 : (status == .provisional ? 6 : 14),
        nightsSinceUpdate: status == .stale ? 20 : 0, status: status)
}
let statuses: [BaselineStatus] = [.calibrating, .provisional, .trusted, .stale]
let hrv = oracleOptionalState(50, 8, .trusted), rhr = oracleOptionalState(60, 4, .trusted)
let respStates: [BaselineState?] = [nil] + statuses.map { oracleOptionalState(16, 2, $0) }
let effortStates: [BaselineState?] = [nil] + statuses.map { oracleOptionalState(45, 10, $0) }
for resp in respStates {
    for effort in effortStates {
        let score = RecoveryScorer.recovery(hrv: 55, rhr: 58, resp: 14,
            hrvBaseline: hrv, rhrBaseline: rhr,
            respBaseline: resp,
            sleepPerf: 0.85, skinTempDev: 0.2, recoveryIndexSlope: -0.5,
            effortBaseline: effort, priorDayEffort: 60)
        let hex = score.map { String($0.bitPattern, radix: 16) } ?? "nil"
        print("\(resp?.status.rawValue ?? "nil")/\(effort?.status.rawValue ?? "nil")|\(hex)")
    }
}
