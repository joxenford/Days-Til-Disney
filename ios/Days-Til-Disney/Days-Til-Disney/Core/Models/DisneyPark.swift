import Foundation

/// All 12 Disney theme parks across the six global resorts.
enum DisneyPark: String, Codable, CaseIterable, Identifiable {
    case magicKingdom
    case epcot
    case hollywoodStudios
    case animalKingdom
    case disneyland
    case californiaAdventure
    case tokyoDisneyland
    case tokyoDisneySea
    case disneylandParkParis
    case waltDisneyStudiosPark
    case hongKongDisneylandPark
    case shanghaiDisneylandPark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .magicKingdom:          return "Magic Kingdom"
        case .epcot:                 return "EPCOT"
        case .hollywoodStudios:      return "Hollywood Studios"
        case .animalKingdom:         return "Animal Kingdom"
        case .disneyland:            return "Disneyland"
        case .californiaAdventure:   return "Disney California Adventure"
        case .tokyoDisneyland:       return "Tokyo Disneyland"
        case .tokyoDisneySea:        return "Tokyo DisneySea"
        case .disneylandParkParis:   return "Disneyland Park Paris"
        case .waltDisneyStudiosPark: return "Walt Disney Studios Park"
        case .hongKongDisneylandPark: return "Hong Kong Disneyland"
        case .shanghaiDisneylandPark: return "Shanghai Disneyland"
        }
    }

    var resort: DisneyResort {
        switch self {
        case .magicKingdom, .epcot, .hollywoodStudios, .animalKingdom:
            return .waltDisneyWorld
        case .disneyland, .californiaAdventure:
            return .disneylandResort
        case .tokyoDisneyland, .tokyoDisneySea:
            return .tokyoDisneyResort
        case .disneylandParkParis, .waltDisneyStudiosPark:
            return .disneylandParis
        case .hongKongDisneylandPark:
            return .hongKongDisneyland
        case .shanghaiDisneylandPark:
            return .shanghaiDisneyland
        }
    }

    var colorPalette: ParkColorPalette {
        switch self {
        case .magicKingdom:          return .magicKingdom
        case .epcot:                 return .epcot
        case .hollywoodStudios:      return .hollywoodStudios
        case .animalKingdom:         return .animalKingdom
        case .disneyland:            return .disneyland
        case .californiaAdventure:   return .californiaAdventure
        case .tokyoDisneyland:       return .tokyoDisneyland
        case .tokyoDisneySea:        return .tokyoDisneySea
        case .disneylandParkParis:   return .disneylandParkParis
        case .waltDisneyStudiosPark: return .waltDisneyStudiosPark
        case .hongKongDisneylandPark: return .hongKongDisneylandPark
        case .shanghaiDisneylandPark: return .shanghaiDisneylandPark
        }
    }

    var iconAssetName: String {
        switch self {
        case .magicKingdom:          return "icon-magic-kingdom"
        case .epcot:                 return "icon-epcot"
        case .hollywoodStudios:      return "icon-hollywood-studios"
        case .animalKingdom:         return "icon-animal-kingdom"
        case .disneyland:            return "icon-disneyland"
        case .californiaAdventure:   return "icon-california-adventure"
        case .tokyoDisneyland:       return "icon-tokyo-disneyland"
        case .tokyoDisneySea:        return "icon-tokyo-disneysea"
        case .disneylandParkParis:   return "icon-paris-disneyland"
        case .waltDisneyStudiosPark: return "icon-paris-studios"
        case .hongKongDisneylandPark: return "icon-hong-kong"
        case .shanghaiDisneylandPark: return "icon-shanghai"
        }
    }

    var castleAssetName: String {
        resort.castleAssetName
    }

    var emoji: String {
        switch self {
        case .magicKingdom:          return "🏰"
        case .epcot:                 return "🌍"
        case .hollywoodStudios:      return "🎬"
        case .animalKingdom:         return "🦁"
        case .disneyland:            return "🏰"
        case .californiaAdventure:   return "🌊"
        case .tokyoDisneyland:       return "🌸"
        case .tokyoDisneySea:        return "⛵"
        case .disneylandParkParis:   return "🗼"
        case .waltDisneyStudiosPark: return "🎥"
        case .hongKongDisneylandPark: return "✨"
        case .shanghaiDisneylandPark: return "🌟"
        }
    }
}
