import XCTest
import SwiftUI
@testable import Days_Til_Disney

/// Covers the one path Trip Detail and the milestone screen now share:
/// `ShareCountdownCard.rendered(trip:scheme:)`. A silent nil or a dropped
/// `scale` would ship a missing or blurry share image from both callers.
@MainActor
final class ShareCountdownCardTests: XCTestCase {

    /// 360×450pt at 3x — the 1080×1350 (4:5) social crop the card is sized for.
    private let expectedPixelSize = CGSize(width: 1080, height: 1350)

    func test_rendered_producesImageAtSocialCropSize() {
        let trip = Trip.makeTest(startDate: .daysFromNow(100), endDate: .daysFromNow(107))

        let image = ShareCountdownCard.rendered(trip: trip, scheme: .light)

        XCTAssertEqual(image?.size.width, ShareCountdownCard.width)
        XCTAssertEqual(image?.size.height, ShareCountdownCard.height)
        XCTAssertEqual(image?.scale, 3.0, "Dropping the 3x scale ships a blurry share card.")
        XCTAssertEqual(image?.cgImage?.width, Int(expectedPixelSize.width))
        XCTAssertEqual(image?.cgImage?.height, Int(expectedPixelSize.height))
    }

    /// The card branches on isToday / isPast, so render every branch — a crash or
    /// nil in one of them only shows up for trips in that state.
    func test_rendered_succeedsForEveryHeroBranch() {
        let cases: [(String, Trip)] = [
            ("future", .makeTest(startDate: .daysFromNow(100), endDate: .daysFromNow(107))),
            ("today", .makeTest(startDate: .daysFromNow(0), endDate: .daysFromNow(7))),
            ("past", .makeTest(startDate: .daysAgo(14), endDate: .daysAgo(7)))
        ]

        for (label, trip) in cases {
            for scheme in [ColorScheme.light, .dark] {
                XCTAssertNotNil(ShareCountdownCard.rendered(trip: trip, scheme: scheme),
                                "\(label) trip failed to render in \(scheme)")
            }
        }
    }
}
