import Foundation

/// All six Disney resort destinations worldwide.
enum DisneyResort: String, Codable, CaseIterable, Identifiable {
    case waltDisneyWorld
    case disneylandResort
    case tokyoDisneyResort
    case disneylandParis
    case hongKongDisneyland
    case shanghaiDisneyland

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .waltDisneyWorld:    return "Walt Disney World"
        case .disneylandResort:   return "Disneyland Resort"
        case .tokyoDisneyResort:  return "Tokyo Disney Resort"
        case .disneylandParis:    return "Disneyland Paris"
        case .hongKongDisneyland: return "Hong Kong Disneyland"
        case .shanghaiDisneyland: return "Shanghai Disneyland"
        }
    }

    var shortName: String {
        switch self {
        case .waltDisneyWorld:    return "WDW"
        case .disneylandResort:   return "DLR"
        case .tokyoDisneyResort:  return "TDR"
        case .disneylandParis:    return "DLP"
        case .hongKongDisneyland: return "HKDL"
        case .shanghaiDisneyland: return "SHDL"
        }
    }

    var location: String {
        switch self {
        case .waltDisneyWorld:    return "Orlando, Florida, USA"
        case .disneylandResort:   return "Anaheim, California, USA"
        case .tokyoDisneyResort:  return "Urayasu, Chiba, Japan"
        case .disneylandParis:    return "Chessy, Île-de-France, France"
        case .hongKongDisneyland: return "Lantau Island, Hong Kong"
        case .shanghaiDisneyland: return "Pudong, Shanghai, China"
        }
    }

    var parks: [DisneyPark] {
        switch self {
        case .waltDisneyWorld:
            return [.magicKingdom, .epcot, .hollywoodStudios, .animalKingdom]
        case .disneylandResort:
            return [.disneyland, .californiaAdventure]
        case .tokyoDisneyResort:
            return [.tokyoDisneyland, .tokyoDisneySea]
        case .disneylandParis:
            return [.disneylandParkParis, .waltDisneyStudiosPark]
        case .hongKongDisneyland:
            return [.hongKongDisneylandPark]
        case .shanghaiDisneyland:
            return [.shanghaiDisneylandPark]
        }
    }

    /// The "flagship" park used for theming when no specific park is selected.
    var primaryPark: DisneyPark {
        parks.first ?? .magicKingdom
    }

    var castleAssetName: String {
        switch self {
        case .waltDisneyWorld:    return "castle-cinderella"
        case .disneylandResort:   return "castle-sleeping-beauty"
        case .tokyoDisneyResort:  return "castle-tokyo"
        case .disneylandParis:    return "castle-paris"
        case .hongKongDisneyland: return "castle-magical-dreams"
        case .shanghaiDisneyland: return "castle-enchanted-storybook"
        }
    }
}
