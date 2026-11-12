import Foundation

// MARK: - High heart rate warning: the decision
//
// The wearer sets a limit and a duration (for example 110 bpm for 90 s). While the AVERAGE heart rate over that
// duration is above the limit, the strap buzzes twice, and again every 5 s. Judging the average, not every single
// reading, means one wrong reading (a spike or a dropout) can neither start the warning nor stop it.
//
// Pure: no clock, no settings, no Bluetooth. The caller hands every readable heart-rate reading in with its time
// and gets back what to show and whether to buzz now. There is no timer: iOS suspends NOOP between Bluetooth
// events, so the 5-second rhythm is decided when a reading arrives (about once a second from a worn strap).

/// Decides, reading by reading, whether the high heart rate warning should be buzzing.
struct HighHRAlertEngine {
    /// The wearer's limit and the duration the average is taken over.
    struct Config: Equatable {
        var thresholdBpm: Int
        var windowSec: Int
    }

    /// What the warning is doing. `.measuring` until a full window of readings is in; then `.below` or `.alerting`.
    enum Phase: Equatable { case measuring, below, alerting }

    /// The result of one reading.
    struct Decision: Equatable {
        let phase: Phase
        /// Time-weighted average over the window; nil until at least one reading is in it.
        let averageBpm: Double?
        /// Median of the readings in the last `recentSec` seconds: the wearer's heart rate right now.
        let recentBpm: Int?
        /// Send the double buzz now.
        let buzz: Bool
    }

    /// Readings outside this range are not heart rates the strap measured; they change nothing.
    static let validBpm = 30...220
    /// The longest time one reading stands for. A gap longer than this counts as missing, not as that reading.
    static let maxHoldSec = 3.0
    /// What the oldest reading in the window stands for (there is no reading before it to measure from).
    static let oldestReadingSec = 1.0
    /// The share of the window readings must cover before the warning may judge it.
    static let minCoverage = 0.8
    /// How far back "right now" reaches: the median of these readings must also be above the limit.
    static let recentSec = 10.0
    /// The rhythm of the buzz while the warning holds.
    static let repeatSec = 5.0
    /// Slack on the rhythm, so readings arriving once a second give a buzz every 5 s rather than every 6.
    static let repeatToleranceSec = 0.5
    /// Two buzzes: one haptics command repeated twice.
    static let buzzLoops: UInt8 = 2

    private struct Reading {
        let t: TimeInterval
        let bpm: Int
    }

    /// Readings inside the window, oldest first.
    private var readings: [Reading] = []
    /// When readings (re)started after the window had emptied; a full window has to pass before any warning.
    private var armedAt: TimeInterval?
    /// When the last buzz was asked for. Kept across a short stop, so two buzzes are never closer than 4.5 s.
    private var lastBuzzAt: TimeInterval?
    /// Handed back unchanged (without a buzz) when a reading is not a heart rate.
    private var lastDecision = Decision(phase: .measuring, averageBpm: nil, recentBpm: nil, buzz: false)

    /// Take one reading and decide.
    mutating func ingest(bpm: Int, at now: TimeInterval, config: Config) -> Decision {
        // 1. Not a heart rate: change nothing.
        guard Self.validBpm.contains(bpm) else {
            return Decision(phase: lastDecision.phase, averageBpm: lastDecision.averageBpm,
                            recentBpm: lastDecision.recentBpm, buzz: false)
        }
        // 2. The clock moved back: what is stored no longer lines up with it.
        if let newest = readings.last, now < newest.t { reset() }
        // 3. Age readings out of the window; an empty window starts a new wait.
        let windowSec = Double(config.windowSec)
        let windowStart = now - windowSec
        if let keepFrom = readings.firstIndex(where: { $0.t > windowStart }) {
            if keepFrom > 0 { readings.removeFirst(keepFrom) }
        } else {
            readings.removeAll()
        }
        if readings.isEmpty { armedAt = now }
        // 4. Add this one.
        readings.append(Reading(t: now, bpm: bpm))
        // 5. Each reading stands for the time since the one before it (capped); the oldest for one second.
        var totalWeight = 0.0
        var weightedSum = 0.0
        for index in readings.indices {
            let weight = index == 0
                ? Self.oldestReadingSec
                : min(readings[index].t - readings[index - 1].t, Self.maxHoldSec)
            totalWeight += weight
            weightedSum += weight * Double(readings[index].bpm)
        }
        let covered = min(totalWeight, windowSec)
        let average = weightedSum / totalWeight
        // 6. Right now: the median of the last few seconds (the element at count / 2, as `AppModel.ingestHR`).
        let recentStart = now - Self.recentSec
        let recentValues = readings.filter { $0.t > recentStart }.map(\.bpm).sorted()
        let recent = recentValues[recentValues.count / 2]
        // 7. A full window: long enough since readings started, and enough of it covered.
        let full = now - (armedAt ?? now) >= windowSec && covered >= Self.minCoverage * windowSec
        // 8. The average AND right now above the limit (strictly).
        let threshold = Double(config.thresholdBpm)
        let alerting = full && average > threshold && Double(recent) > threshold
        // 9. Buzz at once, then every 5 s.
        var buzz = false
        if alerting, lastBuzzAt.map({ now - $0 >= Self.repeatSec - Self.repeatToleranceSec }) ?? true {
            buzz = true
            lastBuzzAt = now
        }
        // 10. What to show.
        let phase: Phase = !full ? .measuring : (alerting ? .alerting : .below)
        let decision = Decision(phase: phase, averageBpm: average, recentBpm: recent, buzz: buzz)
        lastDecision = decision
        return decision
    }

    /// Forget everything: the warning was switched off, or the clock moved back.
    mutating func reset() {
        readings.removeAll()
        armedAt = nil
        lastBuzzAt = nil
        lastDecision = Decision(phase: .measuring, averageBpm: nil, recentBpm: nil, buzz: false)
    }
}
