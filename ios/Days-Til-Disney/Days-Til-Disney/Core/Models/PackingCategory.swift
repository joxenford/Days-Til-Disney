import Foundation

/// Categories for organizing packing list items.
enum PackingCategory: String, Codable, CaseIterable, Identifiable {
    case essentials
    case clothing
    case parkDay
    case electronics
    case documents
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .essentials:  return "Essentials"
        case .clothing:    return "Clothing"
        case .parkDay:     return "Park Day"
        case .electronics: return "Electronics"
        case .documents:   return "Documents"
        case .custom:      return "Custom"
        }
    }

    var systemImageName: String {
        switch self {
        case .essentials:  return "star.fill"
        case .clothing:    return "tshirt.fill"
        case .parkDay:     return "map.fill"
        case .electronics: return "bolt.fill"
        case .documents:   return "doc.fill"
        case .custom:      return "plus.circle.fill"
        }
    }

    /// Display order for category sections.
    var sortOrder: Int {
        switch self {
        case .essentials:  return 0
        case .clothing:    return 1
        case .parkDay:     return 2
        case .electronics: return 3
        case .documents:   return 4
        case .custom:      return 5
        }
    }
}
