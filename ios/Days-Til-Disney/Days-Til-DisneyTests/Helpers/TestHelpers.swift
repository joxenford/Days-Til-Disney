import Foundation
import SwiftData
@testable import Days_Til_Disney

// MARK: - Date helpers for tests

extension Date {
    /// Returns a date `days` calendar days from today at midnight.
    static func daysFromNow(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Calendar.current.startOfDay(for: Date()))!
    }

    static func daysAgo(_ days: Int) -> Date {
        daysFromNow(-days)
    }
}

// MARK: - Trip factory

extension Trip {
    /// Convenience factory for test trips. Avoids SwiftData's @Model requirement
    /// when creating lightweight value objects for seeding mock repositories.
    static func makeTest(
        name: String = "Test Trip",
        resort: DisneyResort = .waltDisneyWorld,
        parks: [DisneyPark] = [.magicKingdom],
        startDate: Date = .daysFromNow(30),
        endDate: Date = .daysFromNow(37),
        isPrimary: Bool = false
    ) -> Trip {
        Trip(
            name: name,
            resort: resort,
            parks: parks,
            startDate: startDate,
            endDate: endDate,
            isPrimary: isPrimary
        )
    }
}

// MARK: - DailyContent factory

extension DailyContent {
    static func makeTest(
        type: ContentType = .funFact,
        title: String = "Test Fact",
        body: String = "Test body text.",
        park: DisneyPark? = nil,
        resort: DisneyResort? = nil,
        daysOutRange: DaysOutRange = .universal
    ) -> DailyContent {
        DailyContent(
            type: type,
            title: title,
            body: body,
            park: park,
            resort: resort,
            daysOutRange: daysOutRange
        )
    }
}

// MARK: - In-memory SwiftData container

enum TestContainer {
    static func make() throws -> ModelContainer {
        let schema = Schema([Trip.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
