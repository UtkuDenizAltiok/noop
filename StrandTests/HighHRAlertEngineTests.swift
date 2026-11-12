import XCTest
@testable import Strand

/// The high heart rate warning judges the AVERAGE heart rate over the wearer's duration, so one wrong reading can
/// neither start nor stop it; it buzzes at once and then every 5 s, and stops a few seconds after the heart rate
/// really drops. Readings once a second, limit 110 bpm, window 90 s unless a test says otherwise.
final class HighHRAlertEngineTests: XCTestCase {
    private let hrWarnLimit110For90 = HighHRAlertEngine.Config(thresholdBpm: 110, windowSec: 90)

    /// Feeds one reading a second for every whole second in `seconds` and returns each decision by its second.
    private func hrWarnFeedEverySecond(_ engine: inout HighHRAlertEngine, _ seconds: ClosedRange<Int>,
                                       config: HighHRAlertEngine.Config,
                                       bpm: (Int) -> Int) -> [Int: HighHRAlertEngine.Decision] {
        var decisions: [Int: HighHRAlertEngine.Decision] = [:]
        for second in seconds {
            decisions[second] = engine.ingest(bpm: bpm(second), at: TimeInterval(second), config: config)
        }
        return decisions
    }

    /// The seconds at which a buzz was asked for, in order.
    private func hrWarnBuzzSeconds(_ decisions: [Int: HighHRAlertEngine.Decision]) -> [Int] {
        decisions.filter { $0.value.buzz }.keys.sorted()
    }

    func testSteadyAboveTheLimitBuzzesAfterTheWindowThenEveryFiveSeconds() {
        var engine = HighHRAlertEngine()
        let d = hrWarnFeedEverySecond(&engine, 0...100, config: hrWarnLimit110For90) { _ in 120 }
        for second in 0...89 {
            XCTAssertFalse(d[second]!.buzz, "no buzz at \(second)")
            XCTAssertEqual(d[second]!.phase, .measuring, "still measuring at \(second)")
        }
        XCTAssertEqual(d[90]!.phase, .alerting)
        XCTAssertEqual(hrWarnBuzzSeconds(d), [90, 95, 100])
        for second in 91...94 { XCTAssertEqual(d[second]!.phase, .alerting) }
    }

    func testOneSpikeCannotStartIt() {
        var engine = HighHRAlertEngine()
        let d = hrWarnFeedEverySecond(&engine, 0...200, config: hrWarnLimit110For90) { $0 == 50 ? 200 : 100 }
        XCTAssertEqual(d[90]!.averageBpm!, 9_100.0 / 90.0, accuracy: 0.0001)   // 101.1
        XCTAssertEqual(d[90]!.phase, .below)
        XCTAssertTrue(hrWarnBuzzSeconds(d).isEmpty)
        XCTAssertFalse(d.values.contains { $0.phase == .alerting })
    }

    func testScatteredMisreadsCannotStopIt() {
        let misreads: Set<Int> = [10, 17, 24, 31, 38, 45, 52, 59, 66, 73]
        var engine = HighHRAlertEngine()
        let d = hrWarnFeedEverySecond(&engine, 0...90, config: hrWarnLimit110For90) { misreads.contains($0) ? 60 : 120 }
        XCTAssertEqual(d[90]!.averageBpm!, 10_200.0 / 90.0, accuracy: 0.0001)   // 113.3
        XCTAssertEqual(d[90]!.phase, .alerting)
        XCTAssertTrue(d[90]!.buzz)
    }

    func testAlternatingAboveAndBelowAlertsOnTheAverage() {
        var engine = HighHRAlertEngine()
        let d = hrWarnFeedEverySecond(&engine, 0...90, config: hrWarnLimit110For90) { $0.isMultiple(of: 2) ? 105 : 125 }
        XCTAssertEqual(d[90]!.averageBpm!, 115, accuracy: 0.0001)
        XCTAssertEqual(d[90]!.phase, .alerting)
        XCTAssertTrue(d[90]!.buzz)
    }

    /// The heart rate right now is above the limit (the 10-s median is 120), but an average of exactly 110 is not.
    func testAnAverageExactlyAtTheLimitDoesNotAlert() {
        var engine = HighHRAlertEngine()
        let d = hrWarnFeedEverySecond(&engine, 0...150, config: hrWarnLimit110For90) { $0.isMultiple(of: 2) ? 100 : 120 }
        XCTAssertEqual(d[90]!.averageBpm!, 110, accuracy: 0.0001)
        XCTAssertEqual(d[90]!.recentBpm, 120)
        XCTAssertEqual(d[90]!.phase, .below)
        XCTAssertTrue(hrWarnBuzzSeconds(d).isEmpty)
    }

    func testItStopsSoonAfterARealDropWhileTheAverageIsStillHigh() {
        var engine = HighHRAlertEngine()
        let d = hrWarnFeedEverySecond(&engine, 0...230, config: hrWarnLimit110For90) { $0 <= 200 ? 120 : 95 }
        XCTAssertEqual(d[205]!.phase, .alerting)
        XCTAssertEqual(d[206]!.phase, .below)
        XCTAssertGreaterThan(d[206]!.averageBpm!, 110)
        XCTAssertEqual(hrWarnBuzzSeconds(d).last, 205)
    }

    func testItReturnsAtOnceWhenTheHeartRateClimbsBack() {
        var engine = HighHRAlertEngine()
        let d = hrWarnFeedEverySecond(&engine, 0...230, config: hrWarnLimit110For90) { second in
            second <= 200 || second >= 220 ? 120 : 95
        }
        XCTAssertEqual(d[206]!.phase, .below)
        XCTAssertEqual(d[223]!.phase, .below)
        XCTAssertEqual(d[224]!.phase, .alerting)
        XCTAssertTrue(d[224]!.buzz)
        let buzzes = hrWarnBuzzSeconds(d)
        let previous = buzzes[buzzes.firstIndex(of: 224)! - 1]
        XCTAssertGreaterThanOrEqual(224 - previous, 5)   // at least 4.5 s; whole seconds here
    }

    /// A 40-s silence leaves readings covering 52 of the 90 s, too few to judge, until coverage is back to 72 s.
    func testAfterAGapItWaitsUntilTheReadingsCoverEnoughOfTheWindow() {
        var engine = HighHRAlertEngine()
        var d = hrWarnFeedEverySecond(&engine, 0...60, config: hrWarnLimit110For90) { _ in 120 }
        d.merge(hrWarnFeedEverySecond(&engine, 101...180, config: hrWarnLimit110For90) { _ in 120 }) { $1 }
        XCTAssertEqual(d[101]!.phase, .measuring)
        for second in 101...171 { XCTAssertFalse(d[second]!.buzz, "no buzz at \(second)") }
        XCTAssertEqual(d[171]!.phase, .measuring)
        XCTAssertEqual(d[172]!.phase, .alerting)
        XCTAssertEqual(hrWarnBuzzSeconds(d).first, 172)
    }

    /// Ten low readings in the last 10 s are a real drop (the recent median is then 60), unlike ten scattered ones.
    func testTenLowReadingsInTheLastTenSecondsStopIt() {
        var engine = HighHRAlertEngine()
        let d = hrWarnFeedEverySecond(&engine, 0...160, config: hrWarnLimit110For90) { $0 <= 150 ? 120 : 60 }
        XCTAssertEqual(d[150]!.phase, .alerting)
        XCTAssertEqual(d[160]!.recentBpm, 60)
        XCTAssertEqual(d[160]!.phase, .below)
        XCTAssertGreaterThan(d[160]!.averageBpm!, 110)
    }

    func testAfterALongSilenceItWaitsAFullWindowAgain() {
        var engine = HighHRAlertEngine()
        var d = hrWarnFeedEverySecond(&engine, 0...100, config: hrWarnLimit110For90) { _ in 120 }
        XCTAssertEqual(d[100]!.phase, .alerting)
        d = hrWarnFeedEverySecond(&engine, 300...400, config: hrWarnLimit110For90) { _ in 120 }
        for second in 300...389 {
            XCTAssertEqual(d[second]!.phase, .measuring, "measuring at \(second)")
            XCTAssertFalse(d[second]!.buzz, "no buzz at \(second)")
        }
        XCTAssertEqual(d[390]!.phase, .alerting)
        XCTAssertEqual(hrWarnBuzzSeconds(d).first, 390)
    }

    func testReadingsOutsideThePlausibleRangeChangeNothing() {
        var engine = HighHRAlertEngine()
        let first = engine.ingest(bpm: 0, at: 0, config: hrWarnLimit110For90)
        XCTAssertEqual(first, HighHRAlertEngine.Decision(phase: .measuring, averageBpm: nil, recentBpm: nil, buzz: false))

        let d = hrWarnFeedEverySecond(&engine, 0...90, config: hrWarnLimit110For90) { _ in 120 }
        XCTAssertTrue(d[90]!.buzz)
        let unchanged = HighHRAlertEngine.Decision(phase: d[90]!.phase, averageBpm: d[90]!.averageBpm,
                                                   recentBpm: d[90]!.recentBpm, buzz: false)
        XCTAssertEqual(engine.ingest(bpm: 0, at: 90.5, config: hrWarnLimit110For90), unchanged)
        XCTAssertEqual(engine.ingest(bpm: 250, at: 91.5, config: hrWarnLimit110For90), unchanged)
        // The rhythm is untouched: the next buzz is still at 95.
        let after = hrWarnFeedEverySecond(&engine, 91...95, config: hrWarnLimit110For90) { _ in 120 }
        XCTAssertEqual(hrWarnBuzzSeconds(after), [95])
    }

    func testAReadingFromEarlierThanTheLastResetsTheWarning() {
        var engine = HighHRAlertEngine()
        let d = hrWarnFeedEverySecond(&engine, 0...100, config: hrWarnLimit110For90) { _ in 120 }
        XCTAssertEqual(d[100]!.phase, .alerting)
        let back = engine.ingest(bpm: 120, at: 50, config: hrWarnLimit110For90)
        XCTAssertEqual(back.phase, .measuring)
        XCTAssertEqual(back.averageBpm, 120)
        XCTAssertFalse(back.buzz)
    }

    /// Both the standard profile and the realtime stream reporting: a reading every half second.
    func testTwoReadingsASecondGiveTheSameAverageAndFirstBuzzAsOne() {
        let bpm: (Int) -> Int = { (40...44).contains($0) ? 60 : 120 }
        var once = HighHRAlertEngine()
        let onceDecisions = hrWarnFeedEverySecond(&once, 0...100, config: hrWarnLimit110For90, bpm: bpm)

        var twice = HighHRAlertEngine()
        var twiceDecisions: [Double: HighHRAlertEngine.Decision] = [:]
        for halfSecond in 0...200 {
            let t = Double(halfSecond) / 2
            twiceDecisions[t] = twice.ingest(bpm: bpm(Int(t)), at: t, config: hrWarnLimit110For90)
        }
        XCTAssertEqual(twiceDecisions[90]!.averageBpm!, onceDecisions[90]!.averageBpm!, accuracy: 0.05)
        XCTAssertEqual(twiceDecisions[100]!.averageBpm!, onceDecisions[100]!.averageBpm!, accuracy: 0.05)
        XCTAssertEqual(hrWarnBuzzSeconds(onceDecisions).first, 90)
        XCTAssertEqual(twiceDecisions.filter { $0.value.buzz }.keys.min(), 90)
    }

    func testTheShortestAndLongestWindowsAlertAtTheRightSecond() {
        let short = HighHRAlertEngine.Config(thresholdBpm: 110, windowSec: 10)
        var engine = HighHRAlertEngine()
        let d10 = hrWarnFeedEverySecond(&engine, 0...20, config: short) { _ in 120 }
        XCTAssertEqual(d10[9]!.phase, .measuring)
        XCTAssertEqual(d10[10]!.phase, .alerting)
        XCTAssertEqual(hrWarnBuzzSeconds(d10).first, 10)

        let long = HighHRAlertEngine.Config(thresholdBpm: 110, windowSec: 600)
        engine = HighHRAlertEngine()
        let d600 = hrWarnFeedEverySecond(&engine, 0...610, config: long) { _ in 120 }
        XCTAssertEqual(d600[599]!.phase, .measuring)
        XCTAssertEqual(d600[600]!.phase, .alerting)
        XCTAssertEqual(hrWarnBuzzSeconds(d600).first, 600)
    }
}

/// The warning needs EVERY readable reading, including the ones `noteReadableHeartRate` returns early on (its
/// silence-timer throttle) and the steady ones `heartRate` never republishes.
@MainActor
final class HighHRAlertHookTests: XCTestCase {
    func testEveryReadableReadingReachesTheHook() {
        let live = LiveState()
        var hrWarnSeen: [Int] = []
        live.onReadableHeartRate = { hrWarnSeen.append($0) }
        for _ in 0..<5 { live.noteReadableHeartRate(bpm: 72) }
        live.noteReadableHeartRate(bpm: 73)
        XCTAssertEqual(hrWarnSeen, [72, 72, 72, 72, 72, 73])
    }
}

/// The settings are clamped before they reach the engine, and a duration is put into words in one place.
final class HighHRAlertPrefsTests: XCTestCase {
    private var hrWarnSuiteName = ""
    private var hrWarnDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        hrWarnSuiteName = "HighHRAlertPrefsTests-\(UUID().uuidString)"
        hrWarnDefaults = UserDefaults(suiteName: hrWarnSuiteName)
    }

    override func tearDown() {
        hrWarnDefaults.removePersistentDomain(forName: hrWarnSuiteName)
        super.tearDown()
    }

    func testDefaultsAreOff110For90Seconds() {
        let prefs = HighHRAlertPrefs.current(hrWarnDefaults)
        XCTAssertFalse(prefs.enabled)
        XCTAssertEqual(prefs.config, HighHRAlertEngine.Config(thresholdBpm: 110, windowSec: 90))
    }

    func testStoredValuesAreClamped() {
        hrWarnDefaults.set(true, forKey: HighHRAlertPrefs.enabledKey)
        hrWarnDefaults.set(10, forKey: HighHRAlertPrefs.thresholdKey)
        hrWarnDefaults.set(3, forKey: HighHRAlertPrefs.windowKey)
        XCTAssertEqual(HighHRAlertPrefs.current(hrWarnDefaults).config,
                       HighHRAlertEngine.Config(thresholdBpm: 40, windowSec: 10))
        hrWarnDefaults.set(300, forKey: HighHRAlertPrefs.thresholdKey)
        hrWarnDefaults.set(5_000, forKey: HighHRAlertPrefs.windowKey)
        XCTAssertEqual(HighHRAlertPrefs.current(hrWarnDefaults).config,
                       HighHRAlertEngine.Config(thresholdBpm: 220, windowSec: 600))
        hrWarnDefaults.set(92, forKey: HighHRAlertPrefs.windowKey)
        XCTAssertEqual(HighHRAlertPrefs.current(hrWarnDefaults).config.windowSec, 90)
        XCTAssertTrue(HighHRAlertPrefs.current(hrWarnDefaults).enabled)
    }

    /// Simple mode's More lists the warning under Daily tools, right after Alarms.
    func testSimpleMoreListsTheWarningAfterAlarms() {
        let tools = SimpleModePrefs.moreEntries(showsCoachRow: true).filter { $0.group == .dailyTools }
        XCTAssertEqual(tools, [.alarms, .heartRateWarning, .breathe, .coach])
    }

    func testDurationsInWords() {
        XCTAssertEqual(HighHRAlertPrefs.durationText(45), "45 s")
        XCTAssertEqual(HighHRAlertPrefs.durationText(90), "1 min 30 s")
        XCTAssertEqual(HighHRAlertPrefs.durationText(120), "2 min")
        XCTAssertEqual(HighHRAlertPrefs.durationText(600), "10 min")
    }
}

/// What the running warning does with the engine's decisions: buzz, report, and log only changes.
@MainActor
final class HighHRAlertMonitorTests: XCTestCase {
    private var hrWarnSuiteName = ""
    private var hrWarnDefaults: UserDefaults!
    private var hrWarnLog: [String] = []
    private var hrWarnBuzzAttempts = 0
    private var hrWarnStrapReachable = true

    override func setUp() {
        super.setUp()
        hrWarnSuiteName = "HighHRAlertMonitorTests-\(UUID().uuidString)"
        hrWarnDefaults = UserDefaults(suiteName: hrWarnSuiteName)
        hrWarnLog = []
        hrWarnBuzzAttempts = 0
        hrWarnStrapReachable = true
    }

    override func tearDown() {
        hrWarnDefaults.removePersistentDomain(forName: hrWarnSuiteName)
        super.tearDown()
    }

    private func hrWarnMonitorFixture(enabled: Bool) -> HighHRAlertMonitor {
        hrWarnDefaults.set(enabled, forKey: HighHRAlertPrefs.enabledKey)
        return HighHRAlertMonitor(defaults: hrWarnDefaults,
                                  log: { [unowned self] in self.hrWarnLog.append($0) },
                                  sendBuzz: { [unowned self] in
                                      self.hrWarnBuzzAttempts += 1
                                      return self.hrWarnStrapReachable
                                  })
    }

    private func hrWarnFeedMonitor(_ monitor: HighHRAlertMonitor, _ seconds: ClosedRange<Int>, bpm: Int) {
        for second in seconds {
            monitor.ingest(bpm: bpm, now: Date(timeIntervalSince1970: 1_000_000 + TimeInterval(second)))
        }
    }

    func testOffDoesNothing() {
        let monitor = hrWarnMonitorFixture(enabled: false)
        XCTAssertEqual(monitor.status, .off)
        hrWarnFeedMonitor(monitor, 0...200, bpm: 150)
        XCTAssertEqual(monitor.status, .off)
        XCTAssertEqual(hrWarnBuzzAttempts, 0)
        XCTAssertTrue(hrWarnLog.isEmpty)
    }

    func testOverTheLimitBuzzesAndLogsOnceThenBackUnder() {
        let monitor = hrWarnMonitorFixture(enabled: true)
        XCTAssertEqual(monitor.status, .waiting)
        hrWarnFeedMonitor(monitor, 0...50, bpm: 120)
        XCTAssertEqual(monitor.status, .measuring)
        hrWarnFeedMonitor(monitor, 51...120, bpm: 120)
        XCTAssertEqual(monitor.status, .alerting(average: 120, buzzDelivered: true))
        XCTAssertEqual(hrWarnBuzzAttempts, 7)   // 90, 95, …, 120
        XCTAssertEqual(hrWarnLog, ["High HR warning: over the limit (90-s average 120, now 120); buzzing every 5 s"])

        // The 10-s median turns at 126 (six readings of 95), after one more buzz at 125.
        hrWarnFeedMonitor(monitor, 121...140, bpm: 95)
        XCTAssertEqual(monitor.status, .below(average: 114))   // (70 × 120 + 20 × 95) / 90 at 140
        XCTAssertEqual(hrWarnBuzzAttempts, 8)
        XCTAssertEqual(hrWarnLog.count, 2)
        XCTAssertEqual(hrWarnLog.last, "High HR warning: back under the limit (now 95, 90-s average 118) after 8 buzzes")
    }

    func testAStrapThatCannotBeReachedIsReportedNotClaimed() {
        hrWarnStrapReachable = false
        let monitor = hrWarnMonitorFixture(enabled: true)
        hrWarnFeedMonitor(monitor, 0...120, bpm: 120)
        XCTAssertEqual(monitor.status, .alerting(average: 120, buzzDelivered: false))
        XCTAssertEqual(hrWarnLog, ["High HR warning: over the limit but no buzz was sent (strap not connected or not fully paired)"])

        hrWarnStrapReachable = true
        hrWarnFeedMonitor(monitor, 121...125, bpm: 120)
        XCTAssertEqual(monitor.status, .alerting(average: 120, buzzDelivered: true))
        XCTAssertEqual(hrWarnLog.count, 1)
    }

    func testLosingTheHeartRatePausesIt() {
        let monitor = hrWarnMonitorFixture(enabled: true)
        hrWarnFeedMonitor(monitor, 0...95, bpm: 120)
        monitor.heartRateCleared()
        XCTAssertEqual(monitor.status, .waiting)
        XCTAssertEqual(hrWarnLog.last, "High HR warning: paused, no live heart rate")
        monitor.heartRateCleared()
        XCTAssertEqual(hrWarnLog.filter { $0.contains("paused") }.count, 1)
    }

    func testTheSwitchAndValuesLogOnlyChanges() {
        let monitor = hrWarnMonitorFixture(enabled: false)
        hrWarnDefaults.set(true, forKey: HighHRAlertPrefs.enabledKey)
        monitor.settingsChanged()
        XCTAssertEqual(monitor.status, .waiting)
        monitor.settingsChanged()
        hrWarnDefaults.set(120, forKey: HighHRAlertPrefs.thresholdKey)
        monitor.settingsChanged()
        hrWarnFeedMonitor(monitor, 0...10, bpm: 130)
        hrWarnDefaults.set(false, forKey: HighHRAlertPrefs.enabledKey)
        monitor.settingsChanged()
        monitor.settingsChanged()
        XCTAssertEqual(monitor.status, .off)
        XCTAssertEqual(hrWarnLog, ["High HR warning: on (above 110 bpm for 90 s)",
                                   "High HR warning: on (above 120 bpm for 90 s)",
                                   "High HR warning: off"])
    }
}
