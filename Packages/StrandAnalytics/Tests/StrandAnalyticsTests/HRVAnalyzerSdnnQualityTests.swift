import XCTest
import WhoopProtocol
@testable import StrandAnalytics

final class HRVAnalyzerSdnnQualityTests: XCTestCase {
    private func sdnnQualityFixtureRows(offset: Int = 0) -> [RRInterval] {
        (0..<300).map { RRInterval(ts: offset + $0, rrMs: 1000 + ($0 % 4) * 10) }
    }

    func testCleanSegmentKeepsItsSampleSdnn() throws {
        let value = try XCTUnwrap(HRVAnalyzer.sdnnIndex(sdnnQualityFixtureRows()))
        XCTAssertEqual(value, 11.199020501841618, accuracy: 1e-12)
    }

    func testDuplicateDeliveriesCannotSupplyDailySdnn() {
        let duplicated = sdnnQualityFixtureRows().flatMap { [$0, $0] }
        XCTAssertNil(HRVAnalyzer.sdnnIndex(duplicated))
    }

    func testBankedIntervalsCannotSupplyDailySdnn() {
        let banked = sdnnQualityFixtureRows().enumerated().map {
            RRInterval(ts: ($0.offset / 6) * 6, rrMs: $0.element.rrMs)
        }
        XCTAssertNil(HRVAnalyzer.sdnnIndex(banked))
    }

    func testRefusedSegmentDoesNotDiscardCleanSegment() throws {
        let clean = sdnnQualityFixtureRows()
        let bad = sdnnQualityFixtureRows(offset: 300).flatMap { [$0, $0] }
        let value = try XCTUnwrap(HRVAnalyzer.sdnnIndex(clean + bad))
        XCTAssertEqual(value, 11.199020501841618, accuracy: 1e-12)
    }
}
