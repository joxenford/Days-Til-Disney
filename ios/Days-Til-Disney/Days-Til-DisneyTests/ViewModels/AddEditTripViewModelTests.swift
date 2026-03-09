import XCTest
@testable import Days_Til_Disney

@MainActor
final class AddEditTripViewModelTests: XCTestCase {

    private var tripRepo: MockTripRepository!
    private var notificationManager: MockMilestoneNotificationManager!
    private var userPreferences: UserPreferences!
    private var defaults: UserDefaults!
    private var sut: AddEditTripViewModel!

    override func setUp() async throws {
        try await super.setUp()
        tripRepo = MockTripRepository()
        notificationManager = MockMilestoneNotificationManager()
        let suiteName = "com.test.AddEditVM.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        userPreferences = UserPreferences(defaults: defaults)
    }

    override func tearDown() async throws {
        sut = nil
        userPreferences = nil
        defaults = nil
        notificationManager = nil
        tripRepo = nil
        try await super.tearDown()
    }

    private func makeAddVM() -> AddEditTripViewModel {
        AddEditTripViewModel(
            mode: .add,
            tripRepository: tripRepo,
            notificationManager: notificationManager,
            userPreferences: userPreferences
        )
    }

    private func makeEditVM(tripID: UUID) -> AddEditTripViewModel {
        AddEditTripViewModel(
            mode: .edit(tripID: tripID),
            tripRepository: tripRepo,
            notificationManager: notificationManager,
            userPreferences: userPreferences
        )
    }

    // MARK: - AddEditTripMode

    func test_mode_add_isNotEditing() {
        XCTAssertFalse(AddEditTripMode.add.isEditing)
    }

    func test_mode_edit_isEditing() {
        XCTAssertTrue(AddEditTripMode.edit(tripID: UUID()).isEditing)
    }

    func test_mode_add_navigationTitle() {
        XCTAssertEqual(AddEditTripMode.add.navigationTitle, "New Trip")
    }

    func test_mode_edit_navigationTitle() {
        XCTAssertEqual(AddEditTripMode.edit(tripID: UUID()).navigationTitle, "Edit Trip")
    }

    // MARK: - TripFormState validation

    func test_formState_validWithAllFieldsSet() {
        var form = TripFormState()
        form.name = "My Trip"
        form.selectedParks = [.magicKingdom]
        form.endDate = form.startDate.addingTimeInterval(86400 * 7)
        XCTAssertTrue(form.isValid)
        XCTAssertNil(form.validationError)
    }

    func test_formState_invalid_whenNameIsEmpty() {
        var form = TripFormState()
        form.name = ""
        form.selectedParks = [.magicKingdom]
        XCTAssertFalse(form.isValid)
        XCTAssertNotNil(form.validationError)
    }

    func test_formState_invalid_whenNameIsWhitespaceOnly() {
        var form = TripFormState()
        form.name = "   "
        form.selectedParks = [.magicKingdom]
        XCTAssertFalse(form.isValid)
    }

    func test_formState_invalid_whenNoParksSelected() {
        var form = TripFormState()
        form.name = "Trip"
        form.selectedParks = []
        XCTAssertFalse(form.isValid)
        XCTAssertNotNil(form.validationError)
    }

    func test_formState_invalid_whenEndDateBeforeStartDate() {
        var form = TripFormState()
        form.name = "Trip"
        form.selectedParks = [.magicKingdom]
        form.startDate = .daysFromNow(10)
        form.endDate = .daysFromNow(5)
        XCTAssertFalse(form.isValid)
        XCTAssertNotNil(form.validationError)
    }

    func test_formState_valid_whenEndDateEqualsStartDate() {
        var form = TripFormState()
        form.name = "Trip"
        form.selectedParks = [.magicKingdom]
        let date = Date.daysFromNow(10)
        form.startDate = date
        form.endDate = date
        XCTAssertTrue(form.isValid)
    }

    // MARK: - resortDidChange

    func test_resortDidChange_resetsParkSelectionToResortPrimaryPark() {
        sut = makeAddVM()
        sut.resortDidChange(to: .disneylandResort)
        XCTAssertEqual(sut.form.selectedParks, [DisneyResort.disneylandResort.primaryPark])
        XCTAssertEqual(sut.form.selectedResort, .disneylandResort)
    }

    // MARK: - togglePark

    func test_togglePark_addsParkWhenNotSelected() {
        sut = makeAddVM()
        sut.form.selectedParks = [.magicKingdom]
        sut.togglePark(.epcot)
        XCTAssertTrue(sut.form.selectedParks.contains(.epcot))
    }

    func test_togglePark_removesParkWhenSelected_ifOtherParksExist() {
        sut = makeAddVM()
        sut.form.selectedParks = [.magicKingdom, .epcot]
        sut.togglePark(.epcot)
        XCTAssertFalse(sut.form.selectedParks.contains(.epcot))
    }

    func test_togglePark_doesNotRemoveLastPark() {
        sut = makeAddVM()
        sut.form.selectedParks = [.magicKingdom]
        sut.togglePark(.magicKingdom)
        XCTAssertTrue(sut.form.selectedParks.contains(.magicKingdom))
    }

    // MARK: - save (add mode)

    func test_save_add_withInvalidForm_setsError() async {
        let sut = makeAddVM()
        sut.form.name = ""

        await sut.save()

        XCTAssertNotNil(sut.saveError)
        XCTAssertFalse(sut.didSaveSuccessfully)
    }

    func test_save_add_withValidForm_callsSaveOnRepository() async {
        let sut = makeAddVM()
        sut.form.name = "New Trip"
        sut.form.selectedParks = [.magicKingdom]
        sut.form.startDate = .daysFromNow(30)
        sut.form.endDate = .daysFromNow(37)

        await sut.save()

        XCTAssertTrue(sut.didSaveSuccessfully)
        XCTAssertNil(sut.saveError)
    }

    func test_save_add_firstTrip_savesTripAsPrimary() async {
        let sut = makeAddVM()
        sut.form.name = "First Trip"
        sut.form.selectedParks = [.magicKingdom]

        await sut.save()

        // First trip should be saved via saveTripAsPrimary.
        XCTAssertEqual(tripRepo.saveTripAsPrimaryCallCount, 1)
        XCTAssertEqual(tripRepo.saveTripCallCount, 0)
    }

    func test_save_add_subsequentTrip_nonPrimary_usesSaveTrip() async {
        // Add an existing trip so this is NOT the first.
        tripRepo.trips = [Trip.makeTest(isPrimary: true)]

        let sut = makeAddVM()
        sut.form.name = "Second Trip"
        sut.form.selectedParks = [.magicKingdom]
        sut.form.isPrimary = false

        await sut.save()

        XCTAssertEqual(tripRepo.saveTripCallCount, 1)
        XCTAssertEqual(tripRepo.saveTripAsPrimaryCallCount, 0)
    }

    func test_save_add_subsequentTrip_markedAsPrimary_savesTripAsPrimary() async {
        tripRepo.trips = [Trip.makeTest(isPrimary: true)]

        let sut = makeAddVM()
        sut.form.name = "New Primary"
        sut.form.selectedParks = [.magicKingdom]
        sut.form.isPrimary = true

        await sut.save()

        XCTAssertEqual(tripRepo.saveTripAsPrimaryCallCount, 1)
    }

    func test_save_add_repositoryThrows_setsError() async {
        tripRepo.shouldThrowOnSave = true

        let sut = makeAddVM()
        sut.form.name = "Trip"
        sut.form.selectedParks = [.magicKingdom]

        await sut.save()

        XCTAssertNotNil(sut.saveError)
        XCTAssertFalse(sut.didSaveSuccessfully)
    }

    func test_save_add_isSaving_clearsAfterSave() async {
        let sut = makeAddVM()
        sut.form.name = "Trip"
        sut.form.selectedParks = [.magicKingdom]

        await sut.save()

        XCTAssertFalse(sut.isSaving)
    }

    // MARK: - save (edit mode)

    func test_save_edit_withValidData_callsUpdateTrip() async {
        let original = Trip.makeTest(name: "Original")
        tripRepo.trips = [original]

        let sut = makeEditVM(tripID: original.id)
        await sut.onAppear()

        sut.form.name = "Updated"
        await sut.save()

        XCTAssertTrue(sut.didSaveSuccessfully)
        XCTAssertEqual(tripRepo.updateTripCallCount, 1)
    }

    func test_save_edit_whenTripNotFound_setsError() async {
        // No trips in repo; edit will fail to find the trip.
        let sut = makeEditVM(tripID: UUID())
        sut.form.name = "Any Name"
        sut.form.selectedParks = [.magicKingdom]

        await sut.save()

        XCTAssertNotNil(sut.saveError)
        XCTAssertFalse(sut.didSaveSuccessfully)
    }

    func test_save_edit_withPrimary_callsSetPrimaryTripFirst() async {
        let original = Trip.makeTest(name: "Original", isPrimary: false)
        tripRepo.trips = [original]

        let sut = makeEditVM(tripID: original.id)
        await sut.onAppear()
        sut.form.isPrimary = true

        await sut.save()

        XCTAssertEqual(tripRepo.setPrimaryTripCallCount, 1)
        XCTAssertEqual(tripRepo.updateTripCallCount, 1)
    }

    // MARK: - onAppear (edit mode)

    func test_onAppear_editMode_populatesFormFromTrip() async {
        let trip = Trip.makeTest(
            name: "Loaded Trip",
            resort: .disneylandResort,
            parks: [.disneyland],
            isPrimary: true
        )
        tripRepo.trips = [trip]

        let sut = makeEditVM(tripID: trip.id)
        await sut.onAppear()

        XCTAssertEqual(sut.form.name, "Loaded Trip")
        XCTAssertEqual(sut.form.selectedResort, .disneylandResort)
        XCTAssertTrue(sut.form.selectedParks.contains(.disneyland))
        XCTAssertTrue(sut.form.isPrimary)
    }

    func test_onAppear_editMode_tripNotFound_setsError() async {
        let sut = makeEditVM(tripID: UUID()) // not in repo
        await sut.onAppear()

        XCTAssertNotNil(sut.saveError)
    }

    func test_onAppear_addMode_doesNotPopulateForm() async {
        let sut = makeAddVM()
        // Repos have no trips — this must not crash or set any error.
        await sut.onAppear()

        XCTAssertNil(sut.saveError)
        // Default form name should still be empty.
        XCTAssertTrue(sut.form.name.isEmpty)
    }

    // MARK: - Park ordering in save

    func test_save_add_parksAreOrderedByResortDefinedOrder() async {
        let sut = makeAddVM()
        sut.form.name = "Trip"
        sut.form.selectedResort = .waltDisneyWorld
        // Select parks in reverse resort order.
        sut.form.selectedParks = [.animalKingdom, .epcot, .magicKingdom]

        await sut.save()

        let saved = tripRepo.trips.first
        // Resort order: magicKingdom, epcot, hollywoodStudios, animalKingdom
        // Expected filtered order: magicKingdom, epcot, animalKingdom
        XCTAssertEqual(saved?.parks.first, .magicKingdom)
    }

    // MARK: - Notification scheduling (first trip)

    func test_save_add_firstTrip_requestsNotificationPermission() async {
        let sut = makeAddVM()
        sut.form.name = "First Trip"
        sut.form.selectedParks = [.magicKingdom]
        notificationManager.authStatus = .notDetermined
        notificationManager.permissionGranted = true

        await sut.save()

        XCTAssertEqual(notificationManager.requestPermissionCallCount, 1)
    }

    func test_save_add_firstTrip_permissionGranted_schedulesNotifications() async {
        let sut = makeAddVM()
        sut.form.name = "First Trip"
        sut.form.selectedParks = [.magicKingdom]
        notificationManager.authStatus = .notDetermined
        notificationManager.permissionGranted = true

        await sut.save()

        XCTAssertEqual(notificationManager.scheduleForTripCallCount, 1)
    }

    func test_save_add_firstTrip_permissionDenied_doesNotScheduleNotifications() async {
        let sut = makeAddVM()
        sut.form.name = "First Trip"
        sut.form.selectedParks = [.magicKingdom]
        notificationManager.authStatus = .notDetermined
        notificationManager.permissionGranted = false

        await sut.save()

        XCTAssertEqual(notificationManager.scheduleForTripCallCount, 0)
    }
}
