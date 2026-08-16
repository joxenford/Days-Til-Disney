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

    /// The UUID used by the ThemeParks.wiki API to identify this park.
    /// Returns nil for parks that are not currently mapped (should not occur for any
    /// of the 12 supported parks, but callers must handle the optional gracefully).
    var themeParkWikiID: String? {
        switch self {
        case .magicKingdom:          return "75ea578a-adc8-4116-a54d-dccb60765ef9"
        case .epcot:                 return "47f90d2c-e191-4239-a466-5571c099571a"
        case .hollywoodStudios:      return "288747d1-8b4f-4a64-867e-ea7c9b27f573"
        case .animalKingdom:         return "1c84a229-8862-4648-9c71-378ddd2c7693"
        case .disneyland:            return "7340550b-c14d-4def-80bb-acdb51d49a66"
        case .californiaAdventure:   return "832fcd51-ea19-4e77-85c7-75d5843b127c"
        case .disneylandParkParis:   return "ca888437-ebb4-4d50-aed2-d227f7096968"
        case .waltDisneyStudiosPark: return "fc1ecaae-8af4-482b-af05-e0b9b0e7c3a6"
        case .tokyoDisneyland:       return "67b290d5-3478-4e5f-adb4-b99c42d68bfe"
        case .tokyoDisneySea:        return "8b4de4d1-b68c-431a-b83d-6f7c6fa949c2"
        case .shanghaiDisneylandPark: return "dae968d5-630d-4719-8b06-3d107e944401"
        case .hongKongDisneylandPark: return "bd0eb47b-2f02-4d4d-90fa-cb3a68988e3b"
        }
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
