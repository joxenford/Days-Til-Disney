import Foundation

/// A milestone celebration triggered when the countdown reaches a key threshold.
struct Milestone: Identifiable, Hashable {
    let daysOut: Int
    let title: String
    let subtitle: String
    let celebrationType: CelebrationType

    var id: Int { daysOut }

    // MARK: - All defined milestones

    static let all: [Milestone] = [
        Milestone(
            daysOut: 100,
            title: "100 Days of Magic!",
            subtitle: "The countdown begins. Start dreaming big!",
            celebrationType: .confetti
        ),
        Milestone(
            daysOut: 50,
            title: "Halfway There!",
            subtitle: "50 days to go. Now is a great time to start planning.",
            celebrationType: .sparkle
        ),
        Milestone(
            daysOut: 30,
            title: "One Month to Go!",
            subtitle: "30 days! Time to start packing lists and dining plans.",
            celebrationType: .confetti
        ),
        Milestone(
            daysOut: 14,
            title: "Two Weeks Away!",
            subtitle: "The excitement is building. Two weeks!",
            celebrationType: .sparkle
        ),
        Milestone(
            daysOut: 7,
            title: "One Week to Go!",
            subtitle: "Seven sleeps until the magic! Start packing.",
            celebrationType: .fireworks
        ),
        Milestone(
            daysOut: 3,
            title: "Almost There!",
            subtitle: "Just 3 days! Finish those last-minute preparations.",
            celebrationType: .sparkle
        ),
        Milestone(
            daysOut: 1,
            title: "Tomorrow's the Day!",
            subtitle: "One sleep until Disney magic. Rest up, adventurer!",
            celebrationType: .fireworks
        ),
        Milestone(
            daysOut: 0,
            title: "TODAY IS THE DAY!",
            subtitle: "The wait is over. Welcome to the magic!",
            celebrationType: .fireworks
        )
    ]

    /// Returns the milestone matching exactly the given days out, if any.
    static func matching(daysOut: Int) -> Milestone? {
        all.first { $0.daysOut == daysOut }
    }
}

// MARK: - CelebrationType

extension Milestone {
    enum CelebrationType: String, Hashable {
        case confetti
        case fireworks
        case sparkle

        var particleSystemName: String {
            switch self {
            case .confetti:  return "confetti-particle"
            case .fireworks: return "firework-particle"
            case .sparkle:   return "sparkle-particle"
            }
        }

        /// Haptic intensity hint for the celebration.
        var isHeavyHaptic: Bool {
            self == .fireworks
        }
    }
}
