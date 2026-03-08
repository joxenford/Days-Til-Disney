import Foundation

/// A single piece of daily Disney content surfaced to the user during their countdown.
struct DailyContent: Codable, Identifiable, Hashable {
    let id: UUID
    let type: ContentType
    let title: String
    let body: String
    let park: DisneyPark?
    let resort: DisneyResort?
    let daysOutRange: DaysOutRange
    let source: String?

    init(
        id: UUID = UUID(),
        type: ContentType,
        title: String,
        body: String,
        park: DisneyPark? = nil,
        resort: DisneyResort? = nil,
        daysOutRange: DaysOutRange,
        source: String? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.body = body
        self.park = park
        self.resort = resort
        self.daysOutRange = daysOutRange
        self.source = source
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, type, title, body, park, resort
        case daysOutMin = "days_out_min"
        case daysOutMax = "days_out_max"
        case source
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(ContentType.self, forKey: .type)
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)
        park = try container.decodeIfPresent(DisneyPark.self, forKey: .park)
        resort = try container.decodeIfPresent(DisneyResort.self, forKey: .resort)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        let min = try container.decode(Int.self, forKey: .daysOutMin)
        let max = try container.decode(Int.self, forKey: .daysOutMax)
        daysOutRange = DaysOutRange(min: min, max: max)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encodeIfPresent(park, forKey: .park)
        try container.encodeIfPresent(resort, forKey: .resort)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encode(daysOutRange.min, forKey: .daysOutMin)
        try container.encode(daysOutRange.max, forKey: .daysOutMax)
    }

    // MARK: - Filtering helpers

    func isRelevant(for trip: Trip, daysOut: Int) -> Bool {
        guard daysOutRange.contains(daysOut) else { return false }

        // Content with a specific park filter must match one of the trip's parks.
        if let contentPark = park {
            return trip.parks.contains(contentPark)
        }

        // Content with a resort filter must match the trip's resort.
        if let contentResort = resort {
            return contentResort == trip.resort
        }

        // No filter — universal content, always relevant.
        return true
    }
}

// MARK: - ContentType

extension DailyContent {
    enum ContentType: String, Codable, CaseIterable {
        case funFact       = "fun_fact"
        case planningTip   = "planning_tip"
        case trivia        = "trivia"
        case rideSpotlight = "ride_spotlight"

        var displayName: String {
            switch self {
            case .funFact:       return "Fun Fact"
            case .planningTip:   return "Planning Tip"
            case .trivia:        return "Trivia"
            case .rideSpotlight: return "Ride Spotlight"
            }
        }

        var systemImageName: String {
            switch self {
            case .funFact:       return "lightbulb.fill"
            case .planningTip:   return "calendar.badge.checkmark"
            case .trivia:        return "questionmark.circle.fill"
            case .rideSpotlight: return "star.fill"
            }
        }

        var accessibilityLabel: String {
            switch self {
            case .funFact:       return "Fun fact"
            case .planningTip:   return "Planning tip"
            case .trivia:        return "Trivia question"
            case .rideSpotlight: return "Ride spotlight"
            }
        }
    }
}

// MARK: - DaysOutRange

/// A codable closed range replacement (ClosedRange isn't directly Codable).
struct DaysOutRange: Codable, Hashable {
    let min: Int
    let max: Int

    func contains(_ value: Int) -> Bool {
        value >= min && value <= max
    }

    /// Canonical ranges from the product brief.
    static let generalFacts    = DaysOutRange(min: 90, max: Int.max)
    static let planningTips    = DaysOutRange(min: 30, max: 89)
    static let packingAndPrep  = DaysOutRange(min: 7,  max: 29)
    static let dayOfTips       = DaysOutRange(min: 0,  max: 6)
    static let universal       = DaysOutRange(min: 0,  max: Int.max)
}

// MARK: - Sample data

extension DailyContent {
    static var preview: DailyContent {
        DailyContent(
            type: .funFact,
            title: "Walt's Original Dream",
            body: "Walt Disney purchased the land for Walt Disney World in 1964 under a secret alias so prices wouldn't skyrocket. He paid roughly $5 million for 27,000 acres — about $185 per acre.",
            daysOutRange: .generalFacts
        )
    }
}
