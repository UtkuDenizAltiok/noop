import XCTest
@testable import Strand

/// Pins Simple mode's rules: the switch's key and default, which tabs exist, that a swipe can never land on
/// a tab that is not there, that "Show everything on this screen" brings back the full layout, that the
/// Simple More list keeps the Lift Log, that the Simple Today shows each full-view section once or leaves it
/// out on purpose, and that every entry of the plain-language guide is complete.
final class SimpleModeTests: XCTestCase {

    // MARK: - The switch

    func testSwitchKeyAndDefault() {
        XCTAssertEqual(SimpleModePrefs.storageKey, "noop.simpleMode")
        XCTAssertTrue(SimpleModePrefs.defaultEnabled, "Simple mode ships on: a first launch opens the calm view.")
    }

    // MARK: - Tabs

    func testFullViewKeepsTheCoachMasterSwitchRule() {
        for configured in [false, true] {
            XCTAssertTrue(SimpleModePrefs.showsCoachTab(simpleMode: false, coachEnabled: true, coachConfigured: configured))
            XCTAssertFalse(SimpleModePrefs.showsCoachTab(simpleMode: false, coachEnabled: false, coachConfigured: configured))
        }
    }

    func testSimpleModeShowsCoachOnlyOnceItIsSetUp() {
        XCTAssertFalse(SimpleModePrefs.showsCoachTab(simpleMode: true, coachEnabled: true, coachConfigured: false))
        XCTAssertTrue(SimpleModePrefs.showsCoachTab(simpleMode: true, coachEnabled: true, coachConfigured: true))
        XCTAssertFalse(SimpleModePrefs.showsCoachTab(simpleMode: true, coachEnabled: false, coachConfigured: true),
                       "Coach switched off means no Coach tab in either view.")
    }

    func testVisibleTagsKeepMoreAtFour() {
        XCTAssertEqual(SimpleModePrefs.visibleTabTags(showsCoach: true), [0, 1, 2, 3, 4])
        XCTAssertEqual(SimpleModePrefs.visibleTabTags(showsCoach: false), [0, 1, 2, 4])
    }

    /// The blank-tab bug: with Coach hidden, a swipe forward from Sleep (2) must reach More (4), and a swipe
    /// back from More must reach Sleep, never the unclaimed tag 3.
    func testSwipeSkipsAHiddenCoachTab() {
        let visible = SimpleModePrefs.visibleTabTags(showsCoach: false)
        XCTAssertEqual(SimpleModePrefs.swipeTarget(from: 2, forward: true, visible: visible), 4)
        XCTAssertEqual(SimpleModePrefs.swipeTarget(from: 4, forward: false, visible: visible), 2)
    }

    func testSwipeAlwaysLandsOnAVisibleTabAndStopsAtTheEnds() {
        for showsCoach in [false, true] {
            let visible = SimpleModePrefs.visibleTabTags(showsCoach: showsCoach)
            for current in visible {
                for forward in [false, true] {
                    let landed = SimpleModePrefs.swipeTarget(from: current, forward: forward, visible: visible)
                    XCTAssertTrue(visible.contains(landed), "Swipe from \(current) landed on hidden tag \(landed).")
                }
            }
            XCTAssertEqual(SimpleModePrefs.swipeTarget(from: 4, forward: true, visible: visible), 4)
            XCTAssertEqual(SimpleModePrefs.swipeTarget(from: 0, forward: false, visible: visible), 0)
        }
        // A tag that is not visible (Coach just hidden while selected) recovers to the first tab.
        XCTAssertEqual(SimpleModePrefs.swipeTarget(from: 3, forward: true, visible: [0, 1, 2, 4]), 0)
    }

    // MARK: - Show everything on this screen

    /// The one funnel every simplified screen reads: simple only while the switch is on and the wearer has
    /// not asked for everything on that screen. With the switch off, the row is absent and the full view shows.
    func testIsSimpleTruthTable() {
        XCTAssertTrue(SimpleModePrefs.isSimple(stored: true, showingAll: false))
        XCTAssertFalse(SimpleModePrefs.isSimple(stored: true, showingAll: true),
                       "\"Show everything on this screen\" must bring back the full layout.")
        XCTAssertFalse(SimpleModePrefs.isSimple(stored: false, showingAll: false),
                       "Simple mode off is the full view.")
        XCTAssertFalse(SimpleModePrefs.isSimple(stored: false, showingAll: true))
    }

    // MARK: - More

    /// Utku's rule: Simple mode never hides the Lift Log. It is listed in Training whether or not Coach is.
    func testSimpleMoreListKeepsTheLiftLogInTraining() {
        for showsCoach in [false, true] {
            let entries = SimpleModePrefs.moreEntries(showsCoachRow: showsCoach)
            XCTAssertTrue(entries.contains(.liftLog), "The Lift Log must stay in Simple mode's More list.")
        }
        XCTAssertEqual(SimpleMoreEntry.liftLog.group, .training)
    }

    func testSimpleMoreListHasNoDuplicatesAndKeepsItsGroupsTogether() {
        for showsCoach in [false, true] {
            let entries = SimpleModePrefs.moreEntries(showsCoachRow: showsCoach)
            XCTAssertEqual(Set(entries).count, entries.count, "A row is listed twice.")
            // The groups render in `SimpleMoreGroup` order, each with its own rows, so the list must already
            // be in that order or a row would move on screen.
            let groupOrder = entries.map(\.group)
            XCTAssertEqual(groupOrder, groupOrder.sorted { lhs, rhs in
                SimpleMoreGroup.allCases.firstIndex(of: lhs)! < SimpleMoreGroup.allCases.firstIndex(of: rhs)!
            })
            for group in SimpleMoreGroup.allCases {
                XCTAssertTrue(groupOrder.contains(group), "\(group) has no rows.")
            }
        }
    }

    /// Every entry reaches the screen: with Coach listed, the list is every case; without it, every case but
    /// Coach. The exhaustive switch in `SimpleMoreIndex` gives each one its row.
    func testEverySimpleMoreEntryIsListedAndCoachOnlyWithoutATab() {
        XCTAssertEqual(SimpleModePrefs.moreEntries(showsCoachRow: true), SimpleMoreEntry.allCases)
        XCTAssertEqual(SimpleModePrefs.moreEntries(showsCoachRow: false),
                       SimpleMoreEntry.allCases.filter { $0 != .coach })
    }

    /// "Report a problem" (the Test Centre, where the strap log lives) sits in Help between the guide and
    /// Settings.
    func testReportAProblemSitsBetweenTheGuideAndSettings() {
        let help = SimpleModePrefs.moreEntries(showsCoachRow: false).filter { $0.group == .help }
        XCTAssertEqual(help, [.plainGuide, .reportProblem, .settings])
    }

    // MARK: - Today

    func testSimpleTodayLeadsWithTheScoresAndEndsWithTheGuide() {
        let order = SimpleTodaySection.allCases
        XCTAssertEqual(order.first, .scores)
        XCTAssertEqual(order.last, .guide)
        XCTAssertEqual(order.prefix(4), [.scores, .summary, .sleepLine, .behindCharge],
                       "How ready, what to do today, how the night went, then why: the order a wearer asks.")
        XCTAssertEqual(Set(order).count, order.count)
    }

    /// Every full-view Today section is either shown once in Simple mode or left out on purpose. The switch is
    /// exhaustive, so a new `TodaySection` cannot be added without deciding where Simple mode puts it.
    func testEveryFullSectionIsShownOnceOrOmittedOnPurpose() {
        func simpleCounterpart(of full: TodaySection) -> SimpleTodaySection? {
            switch full {
            case .hero:           return .scores
            case .synthesis:      return .summary
            case .recoveryVitals: return .behindCharge
            case .heartRate:      return .heartRate
            case .workouts:       return .workouts
            case .menstrualCycle: return .menstrualCycle
            case .journal:        return .journal
            case .addedCards:     return .addedCards
            case .liveSession, .keyMetrics, .yourCards: return nil
            }
        }
        for full in TodaySection.allCases {
            let omitted = SimpleTodaySection.omittedFullSections.contains(full)
            let counterpart = simpleCounterpart(of: full)
            XCTAssertNotEqual(omitted, counterpart != nil,
                              "\(full) must be either shown in Simple mode or listed as omitted, not both or neither.")
            if let counterpart {
                XCTAssertTrue(SimpleTodaySection.allCases.contains(counterpart))
            }
        }
        XCTAssertFalse(SimpleTodaySection.omittedFullSections.contains(.hero), "The scores are never omitted.")
    }

    // MARK: - Sleep

    /// The Simple Sleep tab leads with the night and shows sleep debt once: the metric tiles, which repeat
    /// the score and carry a second debt figure, stay in the full view.
    func testSimpleSleepLeadsWithTheNightAndShowsDebtOnce() {
        XCTAssertEqual(SimpleModePrefs.sleepSections.first, .stages)
        XCTAssertTrue(SimpleModePrefs.sleepSections.contains(.sleepDebt))
        XCTAssertFalse(SimpleModePrefs.sleepSections.contains(.nightDetail))
        XCTAssertEqual(Set(SimpleModePrefs.sleepSections).count, SimpleModePrefs.sleepSections.count)
    }

    // MARK: - The plain guide

    func testEveryGuideEntryIsCompleteAndBelongsToOneGroup() {
        let grouped = PlainGuideGroup.allCases.flatMap(\.terms)
        XCTAssertEqual(grouped.count, PlainGuideTerm.allCases.count, "An entry is missing from, or repeated in, the groups.")
        XCTAssertEqual(Set(grouped), Set(PlainGuideTerm.allCases))
        for group in PlainGuideGroup.allCases {
            XCTAssertFalse(group.terms.isEmpty, "\(group) has no entries.")
            XCTAssertFalse(group.title.isEmpty)
        }
        for term in PlainGuideTerm.allCases {
            XCTAssertFalse(term.title.isEmpty, "\(term) has no title.")
            XCTAssertFalse(term.summary.isEmpty, "\(term) has no one-line meaning.")
            XCTAssertGreaterThan(term.detail.count, term.summary.count, "\(term)'s paragraph should say more than its one line.")
            XCTAssertFalse(term.icon.isEmpty)
        }
    }

    func testOnlyTheThreeScoresLinkToTheTechnicalGuide() {
        XCTAssertEqual(PlainGuideTerm.charge.scoringSection, .charge)
        XCTAssertEqual(PlainGuideTerm.effort.scoringSection, .effort)
        XCTAssertEqual(PlainGuideTerm.rest.scoringSection, .rest)
        let linked = PlainGuideTerm.allCases.filter { $0.scoringSection != nil }
        XCTAssertEqual(linked, [.charge, .effort, .rest])
    }

    /// The scores' familiar other names must match the captions the Simple Today prints under each ring.
    func testScoresNameTheirFamiliarOtherNames() {
        XCTAssertEqual(PlainGuideTerm.charge.alsoCalled, String(localized: "Recovery"))
        XCTAssertEqual(PlainGuideTerm.effort.alsoCalled, String(localized: "Strain"))
        XCTAssertNotNil(PlainGuideTerm.rest.alsoCalled)
        XCTAssertEqual(PlainGuideTerm.allCases.first, .charge)
    }
}
