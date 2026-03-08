import Foundation

/// Injectable clock abstraction. Enables deterministic time-of-day theming in tests and previews.
protocol TimeOfDayProviding {
    /// The current hour of the day in 24-hour format (0–23).
    var currentHour: Int { get }

    /// The full current time for any callers that need it.
    var now: Date { get }
}

extension TimeOfDayProviding {
    var currentTimeOfDay: TimeOfDay {
        TimeOfDay.current(hour: currentHour)
    }
}

// MARK: - Live implementation

/// Uses the system clock. Used in production.
final class LiveTimeOfDayProvider: TimeOfDayProviding {
    var now: Date { Date() }

    var currentHour: Int {
        Calendar.current.component(.hour, from: now)
    }
}

// MARK: - Test / Preview implementation

/// Injects a fixed time so previews and unit tests get deterministic theming.
final class FixedTimeOfDayProvider: TimeOfDayProviding {
    private let fixedHour: Int

    init(hour: Int) {
        self.fixedHour = hour
    }

    var now: Date {
        Calendar.current.date(
            bySettingHour: fixedHour, minute: 0, second: 0, of: Date()
        ) ?? Date()
    }

    var currentHour: Int { fixedHour }

    // Convenience factories for common preview states.
    static let dawn  = FixedTimeOfDayProvider(hour: 6)
    static let day   = FixedTimeOfDayProvider(hour: 12)
    static let dusk  = FixedTimeOfDayProvider(hour: 18)
    static let night = FixedTimeOfDayProvider(hour: 22)
}
