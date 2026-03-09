import XCTest
import SwiftUI
@testable import Days_Til_Disney

@MainActor
final class UserPreferencesTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!
    private var prefs: UserPreferences!

    override func setUp() async throws {
        try await super.setUp()
        suiteName = "com.test.UserPreferencesTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        prefs = UserPreferences(defaults: defaults)
    }

    override func tearDown() async throws {
        prefs = nil
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        try await super.tearDown()
    }

    // MARK: - Default values

    func test_defaultThemeMode_isAuto() {
        XCTAssertEqual(prefs.themeMode, .auto)
    }

    func test_defaultHasCompletedOnboarding_isFalse() {
        XCTAssertFalse(prefs.hasCompletedOnboarding)
    }

    func test_defaultMilestoneNotificationsEnabled_isFalse() {
        XCTAssertFalse(prefs.milestoneNotificationsEnabled)
    }

    func test_defaultPrimaryTripID_isNil() {
        XCTAssertNil(prefs.primaryTripID)
    }

    // MARK: - Persistence

    func test_themeMode_persistsToUserDefaults() {
        prefs.themeMode = .dark
        XCTAssertEqual(defaults.string(forKey: "userPrefs.themeMode"), "dark")
    }

    func test_hasCompletedOnboarding_persistsToUserDefaults() {
        prefs.hasCompletedOnboarding = true
        XCTAssertTrue(defaults.bool(forKey: "userPrefs.hasCompletedOnboarding"))
    }

    func test_milestoneNotificationsEnabled_persistsToUserDefaults() {
        prefs.milestoneNotificationsEnabled = true
        XCTAssertTrue(defaults.bool(forKey: "userPrefs.milestoneNotificationsEnabled"))
    }

    func test_primaryTripID_persistsToUserDefaults() {
        let id = UUID()
        prefs.primaryTripID = id
        XCTAssertEqual(defaults.string(forKey: "userPrefs.primaryTripID"), id.uuidString)
    }

    func test_primaryTripID_clearsWhenSetToNil() {
        prefs.primaryTripID = UUID()
        prefs.primaryTripID = nil
        XCTAssertNil(defaults.string(forKey: "userPrefs.primaryTripID"))
    }

    // MARK: - colorScheme computed property

    func test_colorScheme_isNilForAutoMode() {
        prefs.themeMode = .auto
        XCTAssertNil(prefs.colorScheme)
    }

    func test_colorScheme_isLightForLightMode() {
        prefs.themeMode = .light
        XCTAssertEqual(prefs.colorScheme, .light)
    }

    func test_colorScheme_isDarkForDarkMode() {
        prefs.themeMode = .dark
        XCTAssertEqual(prefs.colorScheme, .dark)
    }

    // MARK: - ThemeMode

    func test_themeMode_allCasesHaveDisplayName() {
        for mode in UserPreferences.ThemeMode.allCases {
            XCTAssertFalse(mode.displayName.isEmpty)
        }
    }

    func test_themeMode_allCasesHaveSystemImageName() {
        for mode in UserPreferences.ThemeMode.allCases {
            XCTAssertFalse(mode.systemImageName.isEmpty)
        }
    }

    func test_themeMode_idMatchesRawValue() {
        for mode in UserPreferences.ThemeMode.allCases {
            XCTAssertEqual(mode.id, mode.rawValue)
        }
    }
}
