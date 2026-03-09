import XCTest
import UserNotifications
@testable import Days_Til_Disney

@MainActor
final class SettingsViewModelTests: XCTestCase {

    private var userPreferences: UserPreferences!
    private var notificationManager: MockMilestoneNotificationManager!
    private var tripRepo: MockTripRepository!
    private var sut: SettingsViewModel!
    private var defaults: UserDefaults!

    override func setUp() async throws {
        try await super.setUp()
        let suiteName = "com.test.SettingsVM.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        userPreferences = UserPreferences(defaults: defaults)
        notificationManager = MockMilestoneNotificationManager()
        tripRepo = MockTripRepository()
        sut = makeVM()
    }

    override func tearDown() async throws {
        sut = nil
        userPreferences = nil
        defaults = nil
        notificationManager = nil
        tripRepo = nil
        try await super.tearDown()
    }

    private func makeVM() -> SettingsViewModel {
        SettingsViewModel(
            userPreferences: userPreferences,
            notificationManager: notificationManager,
            tripRepository: tripRepo
        )
    }

    // MARK: - Proxied preference bindings

    func test_themeMode_get_returnsCurrentPreference() {
        userPreferences.themeMode = .dark
        XCTAssertEqual(sut.themeMode, .dark)
    }

    func test_themeMode_set_updatesPreference() {
        sut.themeMode = .light
        XCTAssertEqual(userPreferences.themeMode, .light)
    }

    func test_milestoneNotificationsEnabled_reflectsPreference() {
        userPreferences.milestoneNotificationsEnabled = true
        XCTAssertTrue(sut.milestoneNotificationsEnabled)
    }

    // MARK: - onAppear — notification status refresh

    func test_onAppear_deniedStatus_setsPermissionDenied() async {
        notificationManager.authStatus = .denied
        userPreferences.milestoneNotificationsEnabled = true

        await sut.onAppear()

        XCTAssertTrue(sut.notificationPermissionDenied)
        // Pref should be synced to false when denied externally.
        XCTAssertFalse(userPreferences.milestoneNotificationsEnabled)
    }

    func test_onAppear_authorizedStatus_clearsPermissionDenied() async {
        notificationManager.authStatus = .authorized

        await sut.onAppear()

        XCTAssertFalse(sut.notificationPermissionDenied)
    }

    func test_onAppear_notDeterminedStatus_clearsPermissionDenied() async {
        notificationManager.authStatus = .notDetermined

        await sut.onAppear()

        XCTAssertFalse(sut.notificationPermissionDenied)
    }

    func test_onAppear_ephemeralStatus_clearsPermissionDenied() async {
        notificationManager.authStatus = .ephemeral

        await sut.onAppear()

        XCTAssertFalse(sut.notificationPermissionDenied)
    }

    func test_onAppear_provisionalStatus_clearsPermissionDenied() async {
        notificationManager.authStatus = .provisional

        await sut.onAppear()

        XCTAssertFalse(sut.notificationPermissionDenied)
    }

    // MARK: - setMilestoneNotifications(enabled:)

    func test_setMilestoneNotifications_enabled_permissionGranted_enablesPref() async {
        notificationManager.permissionGranted = true

        await sut.setMilestoneNotifications(enabled: true)

        XCTAssertTrue(userPreferences.milestoneNotificationsEnabled)
        XCTAssertFalse(sut.notificationPermissionDenied)
    }

    func test_setMilestoneNotifications_enabled_permissionGranted_schedulesNotificationsForAllTrips() async {
        notificationManager.permissionGranted = true
        tripRepo.trips = [Trip.makeTest(), Trip.makeTest(startDate: .daysFromNow(60))]

        await sut.setMilestoneNotifications(enabled: true)

        XCTAssertEqual(notificationManager.scheduleForAllCallCount, 1)
    }

    func test_setMilestoneNotifications_enabled_permissionDenied_keepsPreferenceOff() async {
        notificationManager.permissionGranted = false

        await sut.setMilestoneNotifications(enabled: true)

        XCTAssertFalse(userPreferences.milestoneNotificationsEnabled)
        XCTAssertTrue(sut.notificationPermissionDenied)
    }

    func test_setMilestoneNotifications_disabled_turnsPrefOff() async {
        userPreferences.milestoneNotificationsEnabled = true

        await sut.setMilestoneNotifications(enabled: false)

        XCTAssertFalse(userPreferences.milestoneNotificationsEnabled)
    }

    func test_setMilestoneNotifications_disabled_cancelsAllNotifications() async {
        await sut.setMilestoneNotifications(enabled: false)

        XCTAssertEqual(notificationManager.cancelAllCallCount, 1)
    }

    func test_setMilestoneNotifications_enabled_requestsPermissionExactlyOnce() async {
        notificationManager.permissionGranted = true

        await sut.setMilestoneNotifications(enabled: true)

        XCTAssertEqual(notificationManager.requestPermissionCallCount, 1)
    }

    // MARK: - appVersion

    func test_appVersion_isNonEmpty() {
        XCTAssertFalse(sut.appVersion.isEmpty)
    }

    func test_appVersion_containsParenthesizedBuild() {
        // Expect format: "1.0 (1)" or similar.
        XCTAssertTrue(sut.appVersion.contains("("))
        XCTAssertTrue(sut.appVersion.contains(")"))
    }
}
