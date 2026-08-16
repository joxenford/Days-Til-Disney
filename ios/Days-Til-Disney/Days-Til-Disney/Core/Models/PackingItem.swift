import Foundation
import SwiftData

/// A single item on a trip's packing checklist.
///
/// Enum-typed properties (`category`) are stored as raw String values
/// following the same pattern as `Trip` to avoid SwiftData limitations
/// with Codable enums.
@Model
final class PackingItem {
    var id: UUID = UUID()
    var name: String = ""
    /// Backing store for `category` — stored as its rawValue String.
    var categoryRawValue: String = PackingCategory.custom.rawValue
    var isChecked: Bool = false
    /// True when this item was generated from the park-specific defaults.
    var isParkDefault: Bool = false
    var createdAt: Date = Date()
    /// Inverse of the Trip.packingItems relationship.
    var trip: Trip?

    init(
        id: UUID = UUID(),
        name: String,
        category: PackingCategory,
        isChecked: Bool = false,
        isParkDefault: Bool = false,
        createdAt: Date = Date(),
        trip: Trip? = nil
    ) {
        self.id = id
        self.name = name
        self.categoryRawValue = category.rawValue
        self.isChecked = isChecked
        self.isParkDefault = isParkDefault
        self.createdAt = createdAt
        self.trip = trip
    }

    // MARK: - Typed computed property

    var category: PackingCategory {
        get { PackingCategory(rawValue: categoryRawValue) ?? .custom }
        set { categoryRawValue = newValue.rawValue }
    }
}
