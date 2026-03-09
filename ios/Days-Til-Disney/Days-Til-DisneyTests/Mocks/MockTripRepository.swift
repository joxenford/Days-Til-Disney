import Foundation
@testable import Days_Til_Disney

/// In-memory TripRepository mock for ViewModel tests.
@MainActor
final class MockTripRepository: TripRepository {
    var trips: [Trip] = []

    var fetchAllTripsCallCount = 0
    var fetchPrimaryTripCallCount = 0
    var saveTripCallCount = 0
    var saveTripAsPrimaryCallCount = 0
    var updateTripCallCount = 0
    var deleteTripCallCount = 0
    var setPrimaryTripCallCount = 0

    var shouldThrowOnFetch = false
    var shouldThrowOnSave = false
    var shouldThrowOnDelete = false

    enum MockError: Error { case intentional }

    func fetchAllTrips() async throws -> [Trip] {
        fetchAllTripsCallCount += 1
        if shouldThrowOnFetch { throw MockError.intentional }
        return trips
    }

    func fetchPrimaryTrip() async throws -> Trip? {
        fetchPrimaryTripCallCount += 1
        if shouldThrowOnFetch { throw MockError.intentional }
        return trips.first { $0.isPrimary }
    }

    func fetchTrip(by id: UUID) async throws -> Trip? {
        if shouldThrowOnFetch { throw MockError.intentional }
        return trips.first { $0.id == id }
    }

    func saveTrip(_ trip: Trip) async throws {
        saveTripCallCount += 1
        if shouldThrowOnSave { throw MockError.intentional }
        trips.append(trip)
    }

    func saveTripAsPrimary(_ trip: Trip) async throws {
        saveTripAsPrimaryCallCount += 1
        if shouldThrowOnSave { throw MockError.intentional }
        for t in trips { t.isPrimary = false }
        trip.isPrimary = true
        trips.append(trip)
    }

    func updateTrip(_ trip: Trip) async throws {
        updateTripCallCount += 1
        if shouldThrowOnSave { throw MockError.intentional }
        // Trip is mutated in-place (SwiftData reference semantics via @Model)
    }

    func deleteTrip(id: UUID) async throws {
        deleteTripCallCount += 1
        if shouldThrowOnDelete { throw MockError.intentional }
        trips.removeAll { $0.id == id }
    }

    func setPrimaryTrip(id: UUID) async throws {
        setPrimaryTripCallCount += 1
        for t in trips { t.isPrimary = (t.id == id) }
    }
}
