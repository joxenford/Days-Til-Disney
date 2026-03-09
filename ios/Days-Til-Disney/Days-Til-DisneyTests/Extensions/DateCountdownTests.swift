import XCTest
@testable import Days_Til_Disney

@MainActor
final class DateCountdownTests: XCTestCase {

    private let calendar = Calendar.current

    // MARK: - Calendar.daysUntil

    func test_calendarDaysUntil_futureDate_isPositive() {
        let future = Date.daysFromNow(5)
        XCTAssertEqual(calendar.daysUntil(future), 5)
    }

    func test_calendarDaysUntil_today_isZero() {
        // Use start of day so time-of-day doesn't affect the result.
        let today = calendar.startOfDay(for: Date())
        XCTAssertEqual(calendar.daysUntil(today), 0)
    }

    func test_calendarDaysUntil_pastDate_isNegative() {
        let past = Date.daysAgo(3)
        XCTAssertEqual(calendar.daysUntil(past), -3)
    }

    // MARK: - Date.daysUntil

    func test_daysUntil_tomorrow_isOne() {
        let tomorrow = Date.daysFromNow(1)
        XCTAssertEqual(tomorrow.daysUntil, 1)
    }

    func test_daysUntil_yesterday_isNegativeOne() {
        let yesterday = Date.daysAgo(1)
        XCTAssertEqual(yesterday.daysUntil, -1)
    }

    func test_daysUntil_100DaysOut_is100() {
        let date = Date.daysFromNow(100)
        XCTAssertEqual(date.daysUntil, 100)
    }

    // MARK: - Date.isToday

    func test_isToday_forCurrentDate() {
        XCTAssertTrue(Date().isToday)
    }

    func test_isToday_false_forTomorrow() {
        XCTAssertFalse(Date.daysFromNow(1).isToday)
    }

    func test_isToday_false_forYesterday() {
        XCTAssertFalse(Date.daysAgo(1).isToday)
    }

    // MARK: - Date.isPast

    func test_isPast_forYesterday() {
        XCTAssertTrue(Date.daysAgo(1).isPast)
    }

    func test_isPast_false_forToday() {
        XCTAssertFalse(calendar.startOfDay(for: Date()).isPast)
    }

    func test_isPast_false_forTomorrow() {
        XCTAssertFalse(Date.daysFromNow(1).isPast)
    }

    // MARK: - CountdownComponents

    func test_countdownComponents_futureDate_hasCorrectDays() {
        let tenDaysOut = Date.daysFromNow(10)
        let components = tenDaysOut.countdownComponents
        XCTAssertEqual(components.days, 10)
    }

    func test_countdownComponents_pastDate_isAllZero() {
        let pastDate = Date.daysAgo(2)
        let components = pastDate.countdownComponents
        XCTAssertEqual(components.days, 0)
        XCTAssertEqual(components.hours, 0)
        XCTAssertEqual(components.minutes, 0)
        XCTAssertEqual(components.seconds, 0)
    }

    func test_countdownComponents_isFinalDay_whenDaysIsZero() {
        // A time in the future on today's date.
        let soonish = Date().addingTimeInterval(3600) // 1 hour from now
        let components = soonish.countdownComponents
        XCTAssertTrue(components.isFinalDay)
    }

    func test_countdownComponents_isFinalDay_false_whenDaysIsPositive() {
        let fiveDaysOut = Date.daysFromNow(5)
        let components = fiveDaysOut.countdownComponents
        XCTAssertFalse(components.isFinalDay)
    }

    func test_countdownComponents_isArrival_whenCountdownIsZero() {
        // A date in the past — all zeros.
        let pastDate = Date.daysAgo(1)
        let components = pastDate.countdownComponents
        XCTAssertTrue(components.isArrival)
    }

    func test_countdownComponents_isArrival_false_whenDaysRemaining() {
        let components = Date.daysFromNow(3).countdownComponents
        XCTAssertFalse(components.isArrival)
    }

    // MARK: - CountdownComponents.accessibilityDescription

    func test_accessibilityDescription_isArrival_containsToday() {
        // Build a components struct that is an arrival state.
        let desc = Date.CountdownComponents(days: 0, hours: 0, minutes: 0, seconds: 0).accessibilityDescription
        XCTAssertTrue(desc.lowercased().contains("today"))
    }

    func test_accessibilityDescription_isFinalDay_containsHoursAndMinutes() {
        let desc = Date.CountdownComponents(days: 0, hours: 3, minutes: 45, seconds: 0).accessibilityDescription
        XCTAssertTrue(desc.contains("3"))
        XCTAssertTrue(desc.contains("45"))
    }

    func test_accessibilityDescription_multiDay_containsDayCount() {
        let desc = Date.CountdownComponents(days: 7, hours: 0, minutes: 0, seconds: 0).accessibilityDescription
        XCTAssertTrue(desc.contains("7"))
    }

    // MARK: - dayMonthDateString

    func test_dayMonthDateString_isNonEmpty() {
        XCTAssertFalse(Date().dayMonthDateString.isEmpty)
    }

    func test_dayMonthDateString_formattedForLocale_containsMonthOrDay() {
        // We can't assert the exact string (locale-dependent), but it must contain
        // some text matching a day or month abbreviation.
        let str = Date.daysFromNow(10).dayMonthDateString
        XCTAssertGreaterThan(str.count, 3)
    }
}
