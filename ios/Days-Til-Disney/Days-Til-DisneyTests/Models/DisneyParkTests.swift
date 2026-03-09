import XCTest
@testable import Days_Til_Disney

@MainActor
final class DisneyParkTests: XCTestCase {

    // MARK: - CaseIterable coverage

    func test_allCases_countIs12() {
        XCTAssertEqual(DisneyPark.allCases.count, 12)
    }

    // MARK: - Display properties

    func test_displayName_allNonEmpty() {
        for park in DisneyPark.allCases {
            XCTAssertFalse(park.displayName.isEmpty, "\(park) has empty displayName")
        }
    }

    func test_emoji_allNonEmpty() {
        for park in DisneyPark.allCases {
            XCTAssertFalse(park.emoji.isEmpty, "\(park) has empty emoji")
        }
    }

    // MARK: - Resort relationship

    func test_magicKingdom_belongsToWaltDisneyWorld() {
        XCTAssertEqual(DisneyPark.magicKingdom.resort, .waltDisneyWorld)
    }

    func test_disneyland_belongsToDisneylandResort() {
        XCTAssertEqual(DisneyPark.disneyland.resort, .disneylandResort)
    }

    func test_tokyoDisneySea_belongsToTokyoDisneyResort() {
        XCTAssertEqual(DisneyPark.tokyoDisneySea.resort, .tokyoDisneyResort)
    }

    func test_allParks_resortRelationshipIsConsistent() {
        // Each park's .resort should list that park in its .parks array.
        for park in DisneyPark.allCases {
            XCTAssertTrue(
                park.resort.parks.contains(park),
                "\(park) not found in \(park.resort).parks"
            )
        }
    }

    // MARK: - colorPalette

    func test_colorPalette_allParks_noCrash() {
        for park in DisneyPark.allCases {
            _ = park.colorPalette
        }
    }

    // MARK: - castleAssetName

    func test_castleAssetName_delegatesToResort() {
        XCTAssertEqual(DisneyPark.magicKingdom.castleAssetName, DisneyResort.waltDisneyWorld.castleAssetName)
    }

    // MARK: - iconAssetName

    func test_iconAssetName_allNonEmpty() {
        for park in DisneyPark.allCases {
            XCTAssertFalse(park.iconAssetName.isEmpty, "\(park) has empty iconAssetName")
        }
    }

    // MARK: - Identifiable

    func test_id_matchesRawValue() {
        for park in DisneyPark.allCases {
            XCTAssertEqual(park.id, park.rawValue)
        }
    }

    // MARK: - Codable round-trip

    func test_codableRoundTrip() throws {
        let original = DisneyPark.tokyoDisneySea
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DisneyPark.self, from: encoded)
        XCTAssertEqual(decoded, original)
    }
}
