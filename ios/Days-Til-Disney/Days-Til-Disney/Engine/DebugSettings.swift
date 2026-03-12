#if DEBUG
import Foundation

/// Debug-only overrides for testing features that depend on trip timing.
/// These settings are compiled out of release builds entirely.
enum DebugSettings {
    static let forceOngoingTripKey = "debug_forceOngoingTrip"

    static var forceOngoingTrip: Bool {
        get { UserDefaults.standard.bool(forKey: forceOngoingTripKey) }
        set { UserDefaults.standard.set(newValue, forKey: forceOngoingTripKey) }
    }
}
#endif
