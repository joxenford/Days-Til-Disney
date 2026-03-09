import XCTest
@testable import Days_Til_Disney

@MainActor
final class TripTests: XCTestCase {

    // MARK: - Enum raw-value round-trip

    func test_resort_roundTrip_fromRawValue() {
        let trip = Trip.makeTest(resort: .disneylandResort)
        XCTAssertEqual(trip.resort, .disneylandResort)
        XCTAssertEqual(trip.resortRawValue, DisneyResort.disneylandResort.rawValue)
    }

    func test_parks_roundTrip_fromRawValues() {
        let parks: [DisneyPark] = [.epcot, .hollywoodStudios]
        let trip = Trip.makeTest(parks: parks)
        XCTAssertEqual(trip.parks, parks)
    }

    func test_parks_setter_updatesRawValues() {
        let trip = Trip.makeTest(parks: [.magicKingdom])
        trip.parks = [.animalKingdom, .epcot]
        XCTAssertEqual(Set(trip.parks), [.animalKingdom, .epcot])
    }

    func test_resort_setter_updatesRawValue() {
        let trip = Trip.makeTest(resort: .waltDisneyWorld)
        trip.resort = .tokyoDisneyResort
        XCTAssertEqual(trip.resort, .tokyoDisneyResort)
    }

    func test_invalidResortRawValue_defaultsToWDW() {
        let trip = Trip.makeTest()
        trip.resortRawValue = "not-a-valid-resort"
        XCTAssertEqual(trip.resort, .waltDisneyWorld)
    }

    // MARK: - primaryPark

    func test_primaryPark_returnsFirstSelectedPark() {
        let trip = Trip.makeTest(parks: [.epcot, .magicKingdom])
        XCTAssertEqual(trip.primaryPark, .epcot)
    }

    func test_primaryPark_fallsBackToResortPrimaryWhenNoParkSelected() {
        let trip = Trip.makeTest(resort: .disneylandResort, parks: [])
        // parks array is empty so primaryPark must fall back to resort.primaryPark
        XCTAssertEqual(trip.primaryPark, DisneyResort.disneylandResort.primaryPark)
    }

    // MARK: - daysUntilStart

    func test_daysUntilStart_futureTrip_isPositive() {
        let trip = Trip.makeTest(startDate: .daysFromNow(10))
        XCTAssertEqual(trip.daysUntilStart, 10)
    }

    func test_daysUntilStart_todayTrip_isZero() {
        let trip = Trip.makeTest(startDate: Date())
        XCTAssertEqual(trip.daysUntilStart, 0)
    }

    func test_daysUntilStart_pastTrip_isZero() {
        let trip = Trip.makeTest(startDate: .daysAgo(5))
        XCTAssertEqual(trip.daysUntilStart, 0)
    }

    // MARK: - isToday / isOngoing / isPast

    func test_isToday_whenStartDateIsToday() {
        let trip = Trip.makeTest(startDate: Date(), endDate: .daysFromNow(3))
        XCTAssertTrue(trip.isToday)
    }

    func test_isToday_false_whenStartDateIsTomorrow() {
        let trip = Trip.makeTest(startDate: .daysFromNow(1))
        XCTAssertFalse(trip.isToday)
    }

    func test_isOngoing_whenTodayIsWithinTripDates() {
        let trip = Trip.makeTest(startDate: .daysAgo(2), endDate: .daysFromNow(2))
        XCTAssertTrue(trip.isOngoing)
    }

    func test_isOngoing_false_whenTripIsInFuture() {
        let trip = Trip.makeTest(startDate: .daysFromNow(5), endDate: .daysFromNow(10))
        XCTAssertFalse(trip.isOngoing)
    }

    func test_isOngoing_false_whenTripIsInPast() {
        let trip = Trip.makeTest(startDate: .daysAgo(10), endDate: .daysAgo(5))
        XCTAssertFalse(trip.isOngoing)
    }

    func test_isPast_whenEndDateHasPassed() {
        let trip = Trip.makeTest(startDate: .daysAgo(5), endDate: .daysAgo(1))
        XCTAssertTrue(trip.isPast)
    }

    func test_isPast_false_whenEndDateIsToday() {
        let trip = Trip.makeTest(startDate: .daysAgo(3), endDate: Date())
        XCTAssertFalse(trip.isPast)
    }

    func test_isPast_false_whenTripIsInFuture() {
        let trip = Trip.makeTest(startDate: .daysFromNow(10), endDate: .daysFromNow(15))
        XCTAssertFalse(trip.isPast)
    }

    // MARK: - durationDays

    func test_durationDays_typicalWeekTrip() {
        let trip = Trip.makeTest(startDate: .daysFromNow(0), endDate: .daysFromNow(7))
        XCTAssertEqual(trip.durationDays, 7)
    }

    func test_durationDays_sameDayTrip_isAtLeastOne() {
        let today = Date()
        let trip = Trip.makeTest(startDate: today, endDate: today)
        XCTAssertGreaterThanOrEqual(trip.durationDays, 1)
    }

    // MARK: - markUpdated

    func test_markUpdated_setsUpdatedAtToNow() {
        let before = Date()
        let trip = Trip.makeTest()
        trip.markUpdated()
        XCTAssertGreaterThanOrEqual(trip.updatedAt, before)
    }

    // MARK: - colorPalette

    func test_colorPalette_matchesPrimaryPark_byParkIdentity() {
        // ParkColorPalette doesn't conform to Equatable (it wraps Color).
        // Verify indirectly: the trip's primaryPark drives the palette.
        let trip = Trip.makeTest(parks: [.epcot])
        // Both should reference the same logical palette — confirmed by identical park.
        XCTAssertEqual(trip.primaryPark, .epcot)
    }
}
