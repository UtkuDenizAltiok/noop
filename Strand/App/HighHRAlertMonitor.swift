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
    /// Whether this stretch already logged that readings went too sparse to judge (once per stretch).
    private var episodeSparseLogged = false
    /// Whether the last buzz asked for reached the strap. Read when an episode reopens inside the 4.5-s spacing.
    private var lastBuzzDelivered = false
    /// The settings the last on/off line described, so a line is written only when they change.
    private var loggedSettings: (enabled: Bool, config: HighHRAlertEngine.Config)
    /// A changed limit or duration that the strap log has not been told about yet. It is written once it has
    /// stayed the same for `settingsSettleSeconds`, checked when the next reading arrives (no timer): a held
    /// stepper changes the value several times a second, and a line for every step put 47 and 60 lines into
    /// two evenings' logs. Switching on or off is still logged at once.
    private var pendingConfig: (config: HighHRAlertEngine.Config, changedAt: Date)?
    /// How long a changed limit or duration must stay the same before it is logged.
    static let settingsSettleSeconds: TimeInterval = 2

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
        logSettledSettings(now: now)
        let decision = engine.ingest(bpm: bpm, at: now.timeIntervalSince1970, config: prefs.config)
        let average = Int((decision.averageBpm ?? 0).rounded())
        let recent = decision.recentBpm ?? 0
        let window = prefs.config.windowSec
        // Every over/back line names the limit it was judged against, so each stands on its own in a log
        // where the settings line may be hours earlier or not written yet.
        let limit = prefs.config.thresholdBpm
        switch decision.phase {
        case .measuring:
            // Readings thinned out mid-stretch: not over the limit, and not back under it either, so the stretch
            // stays open and its closing line is written when the engine can judge again. Said once per stretch:
            // in the background check it tells readings that arrived too thinly apart from an app never woken.
            if inEpisode, !episodeSparseLogged {
                log("High HR warning: paused, too few readings to judge")
                episodeSparseLogged = true
            }
            setStatus(.measuring)
        case .below:
            if inEpisode {
                log("High HR warning: back under the limit of \(limit) bpm (now \(recent), \(window)-s average \(average)) "
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
                    log("High HR warning: over the limit of \(limit) bpm (\(window)-s average \(average), now \(recent)); "
                        + "buzzing every 5 s")
                } else {
                    logUndelivered(limit: limit)
                }
            } else if !lastBuzzDelivered, !episodeUndeliveredLogged {
                logUndelivered(limit: limit)
            }
            setStatus(.alerting(average: average, buzzDelivered: lastBuzzDelivered))
        }
    }

    /// The live heart rate was cleared (strap off the wrist, unreadable or silent, or the link dropped). The engine
    /// keeps its readings; they age out of the window by themselves.
    func heartRateCleared(now: Date = Date()) {
        guard HighHRAlertPrefs.current(defaults).enabled else {
            if status != .off { switchedOff() }
            return
        }
        logSettledSettings(now: now)
        switch status {
        case .measuring, .below, .alerting:
            log("High HR warning: paused, no live heart rate")
            endEpisode()
        case .off, .waiting:
            break
        }
        setStatus(.waiting)
    }

    /// The card changed the switch, the limit or the duration. Switching on or off is logged at once; a changed
    /// limit or duration waits until it has settled (`pendingConfig`).
    func settingsChanged(now: Date = Date()) {
        let prefs = HighHRAlertPrefs.current(defaults)
        if prefs.enabled {
            if !loggedSettings.enabled {
                log("High HR warning: on (above \(prefs.config.thresholdBpm) bpm for \(prefs.config.windowSec) s)")
                loggedSettings = prefs
                pendingConfig = nil
            } else if prefs.config == loggedSettings.config {
                // Stepped back to what the log already says: nothing to tell it.
                pendingConfig = nil
            } else if pendingConfig?.config != prefs.config {
                pendingConfig = (prefs.config, now)
            }
            if status == .off { setStatus(.waiting) }
        } else {
            if loggedSettings.enabled { log("High HR warning: off") }
            pendingConfig = nil
            loggedSettings = prefs
            switchedOff()
        }
    }

    /// Writes the changed limit or duration once it has stayed the same for `settingsSettleSeconds`.
    private func logSettledSettings(now: Date) {
        guard let pending = pendingConfig,
              now.timeIntervalSince(pending.changedAt) >= Self.settingsSettleSeconds else { return }
        log("High HR warning: changed to above \(pending.config.thresholdBpm) bpm for \(pending.config.windowSec) s")
        loggedSettings.config = pending.config
        pendingConfig = nil
    }

    private func switchedOff() {
        engine.reset()
        endEpisode()
        setStatus(.off)
    }

    private func logUndelivered(limit: Int) {
        log("High HR warning: over the limit of \(limit) bpm but no buzz was sent (strap not connected or not fully paired)")
        episodeUndeliveredLogged = true
    }

    private func endEpisode() {
        inEpisode = false
        episodeBuzzes = 0
        episodeUndeliveredLogged = false
        episodeSparseLogged = false
    }

    private func setStatus(_ new: Status) {
        if status != new { status = new }
    }

    private static func buzzCount(_ n: Int) -> String {
        n == 1 ? "1 buzz" : "\(n) buzzes"
    }
}
