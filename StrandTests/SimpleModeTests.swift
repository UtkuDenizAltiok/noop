import XCTest
@testable import Strand

/// Pins Simple mode's rules: the switch's key and default, which tabs exist, that a swipe can never land on
/// a tab that is not there, that the Simple Today shows each full-view section once or leaves it out on
/// purpose, and that every entry of the plain-language guide is complete.
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

    // MARK: - Today

    func testSimpleTodayLeadsWithTheScoresAndEndsWithTheGuide() {
        let order = SimpleTodaySection.allCases
        XCTAssertEqual(order.first, .scores)
        XCTAssertEqual(order.last, .guide)
        XCTAssertEqual(order.prefix(3), [.scores, .summary, .behindCharge],
                       "The scores, what they mean today, then why: the order a wearer reads them in.")
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
