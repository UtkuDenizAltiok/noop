import Foundation
import Combine

// MARK: - High heart rate warning: the running part
//
// Owned by `AppModel` and wired in its init, never from a screen: iOS restarts NOOP in the background and may build
// no view at all. Every readable heart-rate reading from a worn strap reaches `ingest`, which asks the pure engine
// what to do and sends the double buzz when it says so. No timer: the rhythm is decided on each reading's arrival.
//
// An `ObservableObject` of its own rather than a `@Published` on `AppModel`, which would redraw every screen that
// observes the model; only the card's status line observes this.
//
// While the switch is off, the whole cost of a reading is one settings read.

/// Runs the high heart rate warning on the live heart rate and reports what it is doing.
@MainActor
final class HighHRAlertMonitor: ObservableObject {
    /// What the warning is doing right now, for the card's status line.
    enum Status: Equatable {
        /// The switch is off.
        case off
        /// On, with no live heart rate coming in.
        case waiting
        /// On, collecting a full window of readings before it may judge.
        case measuring
        /// On, and the average is at or under the limit (or the heart rate right now is).
        case below(average: Int)
        /// On, and over the limit. `buzzDelivered` is false when the buzz could not be sent to the strap.
        case alerting(average: Int, buzzDelivered: Bool)
    }

    @Published private(set) var status: Status

    /// Writes one line to the strap log. `AppModel` stamps it with the time.
    var log: (String) -> Void
    /// Sends the double buzz; false when it could not be sent (strap not connected or not fully paired:
    /// `AppModel.canBuzz`).
    var sendBuzz: () -> Bool

    private let defaults: UserDefaults
    private var engine = HighHRAlertEngine()

    // One over-the-limit stretch ("episode"), for the strap log: it opens on the first alerting reading and closes
    // when the heart rate is back under the limit, the live heart rate stops, or the switch goes off.
    private var inEpisode = false
    private var episodeBuzzes = 0
    private var episodeUndeliveredLogged = false
    /// Whether the last buzz asked for reached the strap. Read when an episode reopens inside the 4.5-s spacing.
    private var lastBuzzDelivered = false
    /// The settings the last on/off line described, so a line is written only when they change.
    private var loggedSettings: (enabled: Bool, config: HighHRAlertEngine.Config)

    init(defaults: UserDefaults = .standard,
         log: @escaping (String) -> Void = { _ in },
         sendBuzz: @escaping () -> Bool = { false }) {
        self.defaults = defaults
        self.log = log
        self.sendBuzz = sendBuzz
        let prefs = HighHRAlertPrefs.current(defaults)
        loggedSettings = prefs
        status = prefs.enabled ? .waiting : .off
    }

    /// One readable heart-rate reading from a worn strap.
    func ingest(bpm: Int, now: Date = Date()) {
        let prefs = HighHRAlertPrefs.current(defaults)
        guard prefs.enabled else {
            if status != .off { switchedOff() }
            return
        }
        let decision = engine.ingest(bpm: bpm, at: now.timeIntervalSince1970, config: prefs.config)
        let average = Int((decision.averageBpm ?? 0).rounded())
        let recent = decision.recentBpm ?? 0
        let window = prefs.config.windowSec
        switch decision.phase {
        case .measuring:
            // Readings thinned out mid-stretch: not over the limit, and not back under it either, so the stretch
            // stays open and its closing line is written when the engine can judge again.
            setStatus(.measuring)
        case .below:
            if inEpisode {
                log("High HR warning: back under the limit (now \(recent), \(window)-s average \(average)) "
                    + "after \(Self.buzzCount(episodeBuzzes))")
                endEpisode()
            }
            setStatus(.below(average: average))
        case .alerting:
            if decision.buzz {
                lastBuzzDelivered = sendBuzz()
                if lastBuzzDelivered { episodeBuzzes += 1 }
            }
            if !inEpisode {
                inEpisode = true
                if lastBuzzDelivered {
                    log("High HR warning: over the limit (\(window)-s average \(average), now \(recent)); "
                        + "buzzing every 5 s")
                } else {
                    logUndelivered()
                }
            } else if !lastBuzzDelivered, !episodeUndeliveredLogged {
                logUndelivered()
            }
            setStatus(.alerting(average: average, buzzDelivered: lastBuzzDelivered))
        }
    }

    /// The live heart rate was cleared (strap off the wrist, unreadable or silent, or the link dropped). The engine
    /// keeps its readings; they age out of the window by themselves.
    func heartRateCleared() {
        guard HighHRAlertPrefs.current(defaults).enabled else {
            if status != .off { switchedOff() }
            return
        }
        switch status {
        case .measuring, .below, .alerting:
            log("High HR warning: paused, no live heart rate")
            endEpisode()
        case .off, .waiting:
            break
        }
        setStatus(.waiting)
    }

    /// The card changed the switch, the limit or the duration.
    func settingsChanged() {
        let prefs = HighHRAlertPrefs.current(defaults)
        if prefs.enabled {
            if !loggedSettings.enabled || loggedSettings.config != prefs.config {
                log("High HR warning: on (above \(prefs.config.thresholdBpm) bpm for \(prefs.config.windowSec) s)")
            }
            if status == .off { setStatus(.waiting) }
        } else {
            if loggedSettings.enabled { log("High HR warning: off") }
            switchedOff()
        }
        loggedSettings = prefs
    }

    private func switchedOff() {
        engine.reset()
        endEpisode()
        setStatus(.off)
    }

    private func logUndelivered() {
        log("High HR warning: over the limit but no buzz was sent (strap not connected or not fully paired)")
        episodeUndeliveredLogged = true
    }

    private func endEpisode() {
        inEpisode = false
        episodeBuzzes = 0
        episodeUndeliveredLogged = false
    }

    private func setStatus(_ new: Status) {
        if status != new { status = new }
    }

    private static func buzzCount(_ n: Int) -> String {
        n == 1 ? "1 buzz" : "\(n) buzzes"
    }
}
