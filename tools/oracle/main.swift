import Foundation
import StrandAnalytics
import WhoopStore

func row(_ ord: Int, _ ex: String, _ w: Double?, _ r: Int?, _ rpe: Double?, _ warm: Bool,
         _ p: LiftMuscle?, _ sec: [LiftMuscle]) -> LiftSetRow {
    LiftSetRow(id: "s\(ord)", deviceId: "d", sessionId: "x", ord: ord, exercise: ex,
               primaryMuscle: p, secondaryMuscles: sec, setIndex: ord + 1,
               weightKg: w, reps: r, rpe: rpe, isWarmup: warm,
               startTs: nil, endTs: nil, restSec: nil, note: nil)
}

let sets = [
    row(0, "Bench", 60.0, 12, 7.0, true, .chest, [.triceps, .frontDelts]),
    row(1, "Bench", 100.0, 5, 8.0, false, .chest, [.triceps, .frontDelts]),
    row(2, "Bench", 90.0, 10, 9.5, false, .chest, [.triceps, .chest]),
    row(3, "Bench", 120.0, 1, nil, false, .chest, []),
    row(4, "Row", 80.0, 13, 6.0, false, .lats, [.biceps]),
    row(5, "Row", 70.0, 8, nil, false, .lats, [.biceps]),
    row(6, "Curl", nil, 10, 8.0, false, .biceps, []),
    row(7, "Curl", 20.0, nil, 8.0, false, .biceps, []),
    row(8, "Plank", 0.0, 0, nil, false, nil, []),
    row(9, "Dip", 50.0, 6, 8.5, false, .chest, [.triceps, .triceps, .chest, .frontDelts, .triceps]),
    row(10, "Bench", 100.0, 0, 9.0, false, .chest, [.triceps]),
]

func f(_ d: Double?) -> String {
    guard let d else { return "nil" }
    return String(format: "%.6f", locale: Locale(identifier: "en_US_POSIX"), d)
}
func i(_ v: Int?) -> String { v.map(String.init) ?? "nil" }

var out: [String] = []
out.append("== volumeLoadKg ==")
out.append(f(LiftMetrics.volumeLoadKg(sets)))
out.append(f(LiftMetrics.volumeLoadKg([])))
out.append(f(LiftMetrics.volumeLoadKg([sets[0]])))

out.append("== sessionLoad ==")
for (r, d) in [(8.0, 3600), (0.0, 3600), (7.5, 0), (6.0, 90)] {
    out.append(f(LiftMetrics.sessionLoad(sessionRpe: r, durationSec: d)))
}
out.append(f(LiftMetrics.sessionLoad(sessionRpe: nil, durationSec: 3600)))

out.append("== estimatedOneRepMaxKg ==")
for (w, r) in [(100.0, 1), (100.0, 5), (90.0, 10), (80.0, 12), (80.0, 13), (0.0, 5), (100.0, 0)] {
    out.append(f(LiftMetrics.estimatedOneRepMaxKg(weightKg: w, reps: r)))
}
out.append(f(LiftMetrics.estimatedOneRepMaxKg(weightKg: nil, reps: 5)))
out.append(f(LiftMetrics.estimatedOneRepMaxKg(weightKg: 100.0, reps: nil)))

out.append("== isPerformed ==")
for r in [0, nil, 5] as [Int?] {
    out.append("\(LiftMetrics.isPerformed(reps: r))")
}
out.append("\(sets.filter { LiftMetrics.isPerformed(reps: $0.reps) }.count)")

out.append("== normalisedSecondaries ==")
for s in sets {
    let sec = s.secondaryMuscles
    out.append("\(s.ord)|" + (sec.isEmpty ? "[]" : sec.map { "\($0)" }.joined(separator: ",")))
}

out.append("== perExercise ==")
for s in LiftMetrics.perExercise(sets) {
    out.append("\(s.exercise)|\(s.workingSets)|\(s.warmupSets)|\(f(s.volumeKg))|" +
               "\(f(s.bestWeightKg))|\(i(s.bestReps))|\(f(s.bestEstimatedOneRepMaxKg))")
}

out.append("== rpeProfile ==")
for p in [LiftMetrics.rpeProfile(sets), LiftMetrics.rpeProfile(sets, threshold: 7.0), LiftMetrics.rpeProfile([])] {
    out.append("\(f(p.mean))|\(p.ratedSets)|\(p.unratedSets)|\(p.setsAtOrAboveThreshold)|\(f(p.threshold))")
}

out.append("== muscleCounts ==")
let mc = LiftMetrics.muscleCounts(sets)
for m in LiftMuscle.allCases {
    let fr = mc.fractional[m], di = mc.direct[m], ind = mc.indirect[m]
    if fr == nil && di == nil && ind == nil { continue }
    out.append("\(m)|\(f(fr))|\(i(di))|\(i(ind))")
}

out.append("== constants ==")
out.append("\(LiftMetrics.oneRepMaxRepCeiling)")
out.append(f(LiftMetrics.hardSetRpeThreshold))
out.append(f(LiftMetrics.ReferenceDose.hypertrophyMinimumSetsPerWeek))
out.append(f(LiftMetrics.ReferenceDose.strengthMinimumSetsPerWeek))
out.append(f(LiftMetrics.ReferenceDose.strengthPlateauSetsPerWeek))
print(out.joined(separator: "\n"))
