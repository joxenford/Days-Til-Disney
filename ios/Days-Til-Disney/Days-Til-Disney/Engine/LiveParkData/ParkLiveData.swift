import Foundation

// MARK: - Domain models

/// Aggregated live data snapshot for a single park.
struct ParkLiveData {
    let park: DisneyPark
    let fetchedAt: Date
    let attractions: [LiveAttraction]
    let shows: [LiveShow]

    // MARK: Derived helpers

    /// Attractions currently showing an operating status.
    var operatingAttractions: [LiveAttraction] {
        attractions.filter { $0.status == .operating }
    }

    /// Average standby wait across operating attractions that have a reported wait time.
    var averageWaitMinutes: Int? {
        let waits = operatingAttractions.compactMap(\.standbyWaitMinutes)
        guard !waits.isEmpty else { return nil }
        return waits.reduce(0, +) / waits.count
    }
}

// MARK: - Attraction

struct LiveAttraction: Identifiable {
    let id: String
    let name: String
    let status: AttractionStatus
    /// Standby queue wait time in minutes. nil when the attraction is not operating
    /// or the park has not reported a wait (e.g. low-capacity dark rides).
    let standbyWaitMinutes: Int?
    /// Lightning Lane return window, if a free LL is currently available.
    let lightningLaneReturnWindow: LightningLaneWindow?
    /// Paid Lightning Lane price in the park's local currency, if applicable.
    let paidLightningLanePrice: PaidLightningLaneInfo?
    let lastUpdated: Date?
}

// MARK: - Show

struct LiveShow: Identifiable {
    let id: String
    let name: String
    let status: AttractionStatus
    /// The soonest upcoming showtime from now, if any.
    let nextShowTime: Date?
    /// All scheduled showtimes for today.
    let allShowTimes: [Date]
}

// MARK: - Supporting types

enum AttractionStatus: String {
    case operating    = "OPERATING"
    case closed       = "CLOSED"
    case refurbishment = "REFURBISHMENT"
    case down         = "DOWN"

    /// Display label shown in UI badges.
    var displayLabel: String {
        switch self {
        case .operating:     return "Open"
        case .closed:        return "Closed"
        case .refurbishment: return "Refurb"
        case .down:          return "Down"
        }
    }
}

struct LightningLaneWindow {
    let returnStart: Date
    let returnEnd: Date

    /// Human-readable return window, e.g. "2:30 – 3:30 PM".
    var displayString: String {
        let fmt = DateFormatter()
        fmt.timeStyle = .short
        fmt.dateStyle = .none
        return "\(fmt.string(from: returnStart)) – \(fmt.string(from: returnEnd))"
    }
}

struct PaidLightningLaneInfo {
    /// Raw price in the smallest currency unit (e.g. cents for USD).
    let amountMinorUnit: Int
    let currencyCode: String

    /// Formatted price string using the device locale, e.g. "$21.00".
    var displayPrice: String {
        let amount = Double(amountMinorUnit) / 100.0
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = currencyCode
        return fmt.string(from: NSNumber(value: amount)) ?? "\(currencyCode) \(amount)"
    }
}
