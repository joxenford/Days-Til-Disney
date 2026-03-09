import Foundation

extension Calendar {
    /// Days between today (start of day) and the given date (start of day).
    /// Negative means the date is in the past.
    func daysUntil(_ date: Date) -> Int {
        let today = startOfDay(for: Date())
        let target = startOfDay(for: date)
        return dateComponents([.day], from: today, to: target).day ?? 0
    }
}

extension Date {
    // MARK: - Countdown calculations

    /// Days from today until this date. Returns 0 for today, negative for past dates.
    var daysUntil: Int {
        Calendar.current.daysUntil(self)
    }

    /// True if this date falls on today's calendar day.
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// True if this date has already passed (strictly before today).
    var isPast: Bool {
        Calendar.current.startOfDay(for: self) < Calendar.current.startOfDay(for: Date())
    }

    // MARK: - Countdown components

    struct CountdownComponents {
        let days: Int
        let hours: Int
        let minutes: Int
        let seconds: Int

        /// True when the countdown is showing a sub-day display (final 24 hours).
        var isFinalDay: Bool { days == 0 }

        /// True when the countdown has reached or passed zero.
        var isArrival: Bool { days == 0 && hours == 0 && minutes == 0 }

        var accessibilityDescription: String {
            if isArrival {
                return "Today is the day! Enjoy your Disney trip!"
            } else if isFinalDay {
                return "\(hours) hours and \(minutes) minutes until your Disney trip"
            } else {
                return "\(days) days until your Disney trip"
            }
        }
    }

    /// Full countdown breakdown from now until this date.
    /// `days` uses the same calendar-day arithmetic as `Calendar.daysUntil(_:)` for
    /// consistency; hours/minutes/seconds are computed from the remaining wall-clock interval.
    var countdownComponents: CountdownComponents {
        let calendar = Calendar.current
        let calendarDays = calendar.daysUntil(self)

        guard calendarDays >= 0 else {
            return CountdownComponents(days: 0, hours: 0, minutes: 0, seconds: 0)
        }

        // Compute the remainder after stripping whole calendar days.
        // "Start of the target day" is the anchor; everything before it is the sub-day portion.
        let startOfTargetDay = calendar.startOfDay(for: self)
        let remainderInterval = max(0, startOfTargetDay.timeIntervalSinceNow)
        // On the final day (calendarDays == 0) use timeIntervalSinceNow directly.
        let subDayInterval = calendarDays == 0
            ? max(0, timeIntervalSinceNow)
            : max(0, timeIntervalSinceNow - remainderInterval)

        let totalSubSeconds = Int(calendarDays == 0 ? max(0, timeIntervalSinceNow) : subDayInterval)
        let hours   = (totalSubSeconds % 86_400) / 3_600
        let minutes = (totalSubSeconds % 3_600) / 60
        let seconds = totalSubSeconds % 60

        return CountdownComponents(days: calendarDays, hours: hours, minutes: minutes, seconds: seconds)
    }

    // MARK: - Display formatting

    // Cached formatters — created once per process, not on every property access.
    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    private static let monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()

    private static let dayMonthDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d"
        return f
    }()

    var shortDateString: String {
        Date.shortDateFormatter.string(from: self)
    }

    var monthYearString: String {
        Date.monthYearFormatter.string(from: self)
    }

    /// e.g. "Fri, Mar 14"
    var dayMonthDateString: String {
        Date.dayMonthDateFormatter.string(from: self)
    }
}
