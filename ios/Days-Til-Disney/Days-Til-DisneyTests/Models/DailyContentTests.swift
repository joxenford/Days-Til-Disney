import XCTest
@testable import Days_Til_Disney

@MainActor
final class DailyContentTests: XCTestCase {

    // MARK: - DaysOutRange.contains

    func test_daysOutRange_contains_insideRange() {
        let range = DaysOutRange(min: 10, max: 50)
        XCTAssertTrue(range.contains(10))
        XCTAssertTrue(range.contains(50))
        XCTAssertTrue(range.contains(30))
    }

    func test_daysOutRange_contains_outsideRange() {
        let range = DaysOutRange(min: 10, max: 50)
        XCTAssertFalse(range.contains(9))
        XCTAssertFalse(range.contains(51))
        XCTAssertFalse(range.contains(-1))
    }

    func test_staticRanges_generalFacts_minIs90() {
        XCTAssertEqual(DaysOutRange.generalFacts.min, 90)
    }

    func test_staticRanges_planningTips_range30to89() {
        XCTAssertTrue(DaysOutRange.planningTips.contains(30))
        XCTAssertTrue(DaysOutRange.planningTips.contains(89))
        XCTAssertFalse(DaysOutRange.planningTips.contains(90))
        XCTAssertFalse(DaysOutRange.planningTips.contains(29))
    }

    func test_staticRanges_packingAndPrep_range7to29() {
        XCTAssertTrue(DaysOutRange.packingAndPrep.contains(7))
        XCTAssertTrue(DaysOutRange.packingAndPrep.contains(29))
        XCTAssertFalse(DaysOutRange.packingAndPrep.contains(6))
        XCTAssertFalse(DaysOutRange.packingAndPrep.contains(30))
    }

    func test_staticRanges_dayOfTips_range0to6() {
        XCTAssertTrue(DaysOutRange.dayOfTips.contains(0))
        XCTAssertTrue(DaysOutRange.dayOfTips.contains(6))
        XCTAssertFalse(DaysOutRange.dayOfTips.contains(7))
        XCTAssertFalse(DaysOutRange.dayOfTips.contains(-1))
    }

    func test_staticRanges_universal_containsEverythingNonNegative() {
        XCTAssertTrue(DaysOutRange.universal.contains(0))
        XCTAssertTrue(DaysOutRange.universal.contains(9999))
    }

    // MARK: - isRelevant(for:daysOut:)

    func test_isRelevant_universalContent_isAlwaysRelevant() {
        let content = DailyContent.makeTest(daysOutRange: .universal)
        let trip = Trip.makeTest()
        XCTAssertTrue(content.isRelevant(for: trip, daysOut: 0))
        XCTAssertTrue(content.isRelevant(for: trip, daysOut: 100))
    }

    func test_isRelevant_outsideDaysOutRange_isFalse() {
        let content = DailyContent.makeTest(daysOutRange: DaysOutRange(min: 30, max: 60))
        let trip = Trip.makeTest()
        XCTAssertFalse(content.isRelevant(for: trip, daysOut: 10))
        XCTAssertFalse(content.isRelevant(for: trip, daysOut: 61))
    }

    func test_isRelevant_parkFilter_matchingPark_isTrue() {
        let content = DailyContent.makeTest(park: .magicKingdom, daysOutRange: .universal)
        let trip = Trip.makeTest(parks: [.magicKingdom, .epcot])
        XCTAssertTrue(content.isRelevant(for: trip, daysOut: 10))
    }

    func test_isRelevant_parkFilter_nonMatchingPark_isFalse() {
        let content = DailyContent.makeTest(park: .animalKingdom, daysOutRange: .universal)
        let trip = Trip.makeTest(parks: [.magicKingdom])
        XCTAssertFalse(content.isRelevant(for: trip, daysOut: 10))
    }

    func test_isRelevant_resortFilter_matchingResort_isTrue() {
        let content = DailyContent.makeTest(resort: .waltDisneyWorld, daysOutRange: .universal)
        let trip = Trip.makeTest(resort: .waltDisneyWorld)
        XCTAssertTrue(content.isRelevant(for: trip, daysOut: 10))
    }

    func test_isRelevant_resortFilter_nonMatchingResort_isFalse() {
        let content = DailyContent.makeTest(resort: .disneylandParis, daysOutRange: .universal)
        let trip = Trip.makeTest(resort: .waltDisneyWorld)
        XCTAssertFalse(content.isRelevant(for: trip, daysOut: 10))
    }

    // MARK: - ContentType

    func test_contentType_displayName_allNonEmpty() {
        for type_ in DailyContent.ContentType.allCases {
            XCTAssertFalse(type_.displayName.isEmpty)
        }
    }

    func test_contentType_systemImageName_allNonEmpty() {
        for type_ in DailyContent.ContentType.allCases {
            XCTAssertFalse(type_.systemImageName.isEmpty)
        }
    }

    func test_contentType_accessibilityLabel_allNonEmpty() {
        for type_ in DailyContent.ContentType.allCases {
            XCTAssertFalse(type_.accessibilityLabel.isEmpty)
        }
    }

    // MARK: - Codable

    func test_codableRoundTrip_universalContent() throws {
        let original = DailyContent.makeTest(title: "Round-trip Test", body: "Some body")
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DailyContent.self, from: encoded)
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.body, original.body)
        XCTAssertEqual(decoded.daysOutRange.min, original.daysOutRange.min)
        XCTAssertEqual(decoded.daysOutRange.max, original.daysOutRange.max)
    }

    func test_codableRoundTrip_withParkAndResort() throws {
        let original = DailyContent.makeTest(
            park: .epcot,
            resort: .waltDisneyWorld,
            daysOutRange: DaysOutRange(min: 30, max: 60)
        )
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DailyContent.self, from: encoded)
        XCTAssertEqual(decoded.park, .epcot)
        XCTAssertEqual(decoded.resort, .waltDisneyWorld)
    }
}
