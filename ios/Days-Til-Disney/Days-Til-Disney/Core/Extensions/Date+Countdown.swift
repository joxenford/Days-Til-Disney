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

    /// Hours from now until this date. Useful on the final day countdown.
    var hoursUntil: Int {
        max(0, Int(timeIntervalSinceNow / 3600))
    }

    /// Minutes from now until this date.
    var minutesUntil: Int {
        max(0, Int(timeIntervalSinceNow / 60))
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
    var countdownComponents: CountdownComponents {
        let interval = timeIntervalSinceNow
        guard interval > 0 else {
            return CountdownComponents(days: 0, hours: 0, minutes: 0, seconds: 0)
        }

        let totalSeconds = Int(interval)
        let days    = totalSeconds / 86_400
        let hours   = (totalSeconds % 86_400) / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60
        return CountdownComponents(days: days, hours: hours, minutes: minutes, seconds: seconds)
    }

    // MARK: - Display formatting

    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }

    /// e.g. "Fri, Mar 14"
    var dayMonthDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: self)
    }
}
