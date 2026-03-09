import XCTest
@testable import Days_Til_Disney

@MainActor
final class MilestoneTests: XCTestCase {

    // MARK: - Milestone.all

    func test_all_containsEightMilestones() {
        XCTAssertEqual(Milestone.all.count, 8)
    }

    func test_all_containsExpectedDaysOut() {
        let expected = Set([0, 1, 3, 7, 14, 30, 50, 100])
        let actual = Set(Milestone.all.map(\.daysOut))
        XCTAssertEqual(actual, expected)
    }

    func test_all_noTitlesAreEmpty() {
        for milestone in Milestone.all {
            XCTAssertFalse(milestone.title.isEmpty, "daysOut=\(milestone.daysOut) has empty title")
        }
    }

    func test_all_noSubtitlesAreEmpty() {
        for milestone in Milestone.all {
            XCTAssertFalse(milestone.subtitle.isEmpty, "daysOut=\(milestone.daysOut) has empty subtitle")
        }
    }

    // MARK: - matching(daysOut:)

    func test_matching_returnsCorrectMilestone() {
        let m = Milestone.matching(daysOut: 100)
        XCTAssertNotNil(m)
        XCTAssertEqual(m?.daysOut, 100)
    }

    func test_matching_returnsNilForNonMilestoneDay() {
        XCTAssertNil(Milestone.matching(daysOut: 42))
        XCTAssertNil(Milestone.matching(daysOut: -1))
        XCTAssertNil(Milestone.matching(daysOut: 200))
    }

    func test_matching_zero_isValidMilestone() {
        XCTAssertNotNil(Milestone.matching(daysOut: 0))
    }

    // MARK: - Identifiable

    func test_id_matchesDaysOut() {
        for milestone in Milestone.all {
            XCTAssertEqual(milestone.id, milestone.daysOut)
        }
    }

    // MARK: - CelebrationType

    func test_fireworks_isHeavyHaptic() {
        XCTAssertTrue(Milestone.CelebrationType.fireworks.isHeavyHaptic)
    }

    func test_confetti_isNotHeavyHaptic() {
        XCTAssertFalse(Milestone.CelebrationType.confetti.isHeavyHaptic)
    }

    func test_sparkle_isNotHeavyHaptic() {
        XCTAssertFalse(Milestone.CelebrationType.sparkle.isHeavyHaptic)
    }

    func test_particleSystemName_allNonEmpty() {
        for type_ in [Milestone.CelebrationType.confetti, .fireworks, .sparkle] {
            XCTAssertFalse(type_.particleSystemName.isEmpty)
        }
    }

    // MARK: - Day-7 fires fireworks (per product spec)

    func test_milestone7_isCelebratedWithFireworks() {
        let m = Milestone.matching(daysOut: 7)
        XCTAssertEqual(m?.celebrationType, .fireworks)
    }

    // MARK: - Hashable

    func test_milestoneHashable_viaSet() {
        let set: Set<Milestone> = [Milestone.all[0], Milestone.all[0], Milestone.all[1]]
        XCTAssertEqual(set.count, 2)
    }
}
