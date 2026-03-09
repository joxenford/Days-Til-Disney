import XCTest
@testable import Days_Til_Disney

@MainActor
final class DisneyResortTests: XCTestCase {

    // MARK: - CaseIterable coverage

    func test_allCases_countIs6() {
        XCTAssertEqual(DisneyResort.allCases.count, 6)
    }

    // MARK: - Display properties

    func test_displayName_waltDisneyWorld() {
        XCTAssertEqual(DisneyResort.waltDisneyWorld.displayName, "Walt Disney World")
    }

    func test_shortName_allNonEmpty() {
        for resort in DisneyResort.allCases {
            XCTAssertFalse(resort.shortName.isEmpty, "\(resort) has empty shortName")
        }
    }

    func test_location_allNonEmpty() {
        for resort in DisneyResort.allCases {
            XCTAssertFalse(resort.location.isEmpty, "\(resort) has empty location")
        }
    }

    // MARK: - Parks

    func test_waltDisneyWorld_hasFourParks() {
        XCTAssertEqual(DisneyResort.waltDisneyWorld.parks.count, 4)
    }

    func test_disneylandResort_hasTwoParks() {
        XCTAssertEqual(DisneyResort.disneylandResort.parks.count, 2)
    }

    func test_tokyoDisneyResort_hasTwoParks() {
        XCTAssertEqual(DisneyResort.tokyoDisneyResort.parks.count, 2)
    }

    func test_hongKongDisneyland_hasOnePark() {
        XCTAssertEqual(DisneyResort.hongKongDisneyland.parks.count, 1)
    }

    func test_shanghaiDisneyland_hasOnePark() {
        XCTAssertEqual(DisneyResort.shanghaiDisneyland.parks.count, 1)
    }

    func test_allResorts_haveAtLeastOnePark() {
        for resort in DisneyResort.allCases {
            XCTAssertFalse(resort.parks.isEmpty, "\(resort) has no parks")
        }
    }

    // MARK: - primaryPark

    func test_primaryPark_isFirstPark() {
        for resort in DisneyResort.allCases {
            XCTAssertEqual(resort.primaryPark, resort.parks.first)
        }
    }

    // MARK: - castleAssetName

    func test_castleAssetName_allNonEmpty() {
        for resort in DisneyResort.allCases {
            XCTAssertFalse(resort.castleAssetName.isEmpty)
        }
    }

    func test_waltDisneyWorld_castleIsCinderella() {
        XCTAssertEqual(DisneyResort.waltDisneyWorld.castleAssetName, "castle-cinderella")
    }

    // MARK: - Identifiable

    func test_id_matchesRawValue() {
        for resort in DisneyResort.allCases {
            XCTAssertEqual(resort.id, resort.rawValue)
        }
    }

    // MARK: - Codable round-trip

    func test_codableRoundTrip() throws {
        let original = DisneyResort.disneylandParis
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DisneyResort.self, from: encoded)
        XCTAssertEqual(decoded, original)
    }
}
