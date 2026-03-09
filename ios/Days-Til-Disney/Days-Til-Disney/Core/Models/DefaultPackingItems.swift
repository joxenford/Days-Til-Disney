import Foundation

/// Seed data for the packing checklist.
///
/// Items are split into two groups:
/// - `universal`: shown for every trip regardless of resort.
/// - Resort-specific extras: appended based on `DisneyResort`.
enum DefaultPackingItems {

    // MARK: - Template

    /// A lightweight value type used to define default items before they are
    /// turned into `PackingItem` models.
    struct Template {
        let name: String
        let category: PackingCategory
    }

    // MARK: - Universal items (all resorts)

    static let universal: [Template] = [
        // Essentials
        Template(name: "Sunscreen (SPF 50+)", category: .essentials),
        Template(name: "Comfortable walking shoes", category: .essentials),
        Template(name: "Portable phone charger / power bank", category: .essentials),
        Template(name: "Reusable water bottle", category: .essentials),
        Template(name: "Hand sanitizer", category: .essentials),
        Template(name: "Pain reliever / basic medications", category: .essentials),
        Template(name: "Blister prevention / moleskin", category: .essentials),
        Template(name: "Snacks (granola bars, etc.)", category: .essentials),

        // Clothing
        Template(name: "Comfortable shorts or pants", category: .clothing),
        Template(name: "Breathable t-shirts", category: .clothing),
        Template(name: "Extra socks (at least 2 pairs per day)", category: .clothing),
        Template(name: "Underwear", category: .clothing),
        Template(name: "Comfortable sneakers (broken in)", category: .clothing),
        Template(name: "Light jacket or hoodie for evening", category: .clothing),

        // Park Day
        Template(name: "Park bag / day pack", category: .parkDay),
        Template(name: "Autograph book and pens", category: .parkDay),
        Template(name: "Poncho or compact rain jacket", category: .parkDay),
        Template(name: "Sunglasses", category: .parkDay),
        Template(name: "Hat or sun visor", category: .parkDay),
        Template(name: "Mickey ears / Disney ears", category: .parkDay),
        Template(name: "Lanyard for park tickets", category: .parkDay),

        // Electronics
        Template(name: "Phone + charging cable", category: .electronics),
        Template(name: "Portable charger charged up", category: .electronics),
        Template(name: "Camera or camera equipment", category: .electronics),
        Template(name: "Earbuds or headphones", category: .electronics),

        // Documents
        Template(name: "Park tickets (printed or digital)", category: .documents),
        Template(name: "Photo ID / passport", category: .documents),
        Template(name: "Hotel / resort confirmation", category: .documents),
        Template(name: "Travel insurance details", category: .documents),
        Template(name: "Emergency contact list", category: .documents),
    ]

    // MARK: - Resort-specific extras

    /// Walt Disney World — Florida heat + humidity, multi-day park hopping.
    static let waltDisneyWorld: [Template] = [
        Template(name: "Rain poncho (Florida afternoon storms)", category: .parkDay),
        Template(name: "Bug spray (for Animal Kingdom evenings)", category: .essentials),
        Template(name: "Cooling towel or misting fan", category: .essentials),
        Template(name: "Lightning Lane / Genie+ strategy notes", category: .parkDay),
        Template(name: "Dining reservation confirmations", category: .documents),
        Template(name: "MagicBand+ (if purchased)", category: .electronics),
        Template(name: "Park-hopper strategy printed", category: .parkDay),
        Template(name: "Swimwear (for hotel pool or water parks)", category: .clothing),
    ]

    /// Disneyland Resort — more compact, California climate.
    static let disneylandResort: [Template] = [
        Template(name: "Light layers (cool California mornings)", category: .clothing),
        Template(name: "Comfortable flats / walking shoes", category: .clothing),
        Template(name: "Genie+ or Lightning Lane notes", category: .parkDay),
        Template(name: "DCA walking map / strategy", category: .parkDay),
    ]

    /// Tokyo Disney Resort — cultural considerations, Japanese climate.
    static let tokyoDisneyResort: [Template] = [
        Template(name: "Warm layers (cooler Japanese climate)", category: .clothing),
        Template(name: "Umbrella (Japan rainy season)", category: .parkDay),
        Template(name: "Pocket wifi or data SIM", category: .electronics),
        Template(name: "Yen / local currency", category: .documents),
        Template(name: "Translation app downloaded offline", category: .electronics),
        Template(name: "Passport (international travel)", category: .documents),
        Template(name: "IC card (Suica) for transit", category: .documents),
        Template(name: "Japan travel adapter / plug converter", category: .electronics),
    ]

    /// Disneyland Paris — European climate, fashion-forward crowd.
    static let disneylandParis: [Template] = [
        Template(name: "Warm coat (Paris can be cold year-round)", category: .clothing),
        Template(name: "Waterproof boots or shoes", category: .clothing),
        Template(name: "Umbrella", category: .parkDay),
        Template(name: "Euros / local currency", category: .documents),
        Template(name: "Passport (international travel)", category: .documents),
        Template(name: "European travel adapter", category: .electronics),
        Template(name: "EU roaming data plan or SIM", category: .electronics),
    ]

    /// Hong Kong Disneyland — subtropical, humid.
    static let hongKongDisneyland: [Template] = [
        Template(name: "Rain poncho (subtropical climate)", category: .parkDay),
        Template(name: "Cooling towel / misting fan", category: .essentials),
        Template(name: "Hong Kong dollars / Octopus card", category: .documents),
        Template(name: "Passport (international travel)", category: .documents),
        Template(name: "Hong Kong travel adapter", category: .electronics),
        Template(name: "Data SIM or pocket wifi", category: .electronics),
    ]

    /// Shanghai Disneyland — large park, hot summers.
    static let shanghaiDisneyland: [Template] = [
        Template(name: "Cooling towel / handheld fan (hot summers)", category: .essentials),
        Template(name: "Rain poncho", category: .parkDay),
        Template(name: "WeChat Pay / Alipay set up", category: .documents),
        Template(name: "Chinese yuan / RMB", category: .documents),
        Template(name: "Passport (international travel)", category: .documents),
        Template(name: "VPN app (configured before arrival)", category: .electronics),
        Template(name: "Data SIM for China", category: .electronics),
    ]

    // MARK: - Lookup

    /// Returns all default templates for the given resort —
    /// universal items first, then resort-specific extras.
    static func templates(for resort: DisneyResort) -> [Template] {
        let extras: [Template]
        switch resort {
        case .waltDisneyWorld:    extras = waltDisneyWorld
        case .disneylandResort:   extras = disneylandResort
        case .tokyoDisneyResort:  extras = tokyoDisneyResort
        case .disneylandParis:    extras = disneylandParis
        case .hongKongDisneyland: extras = hongKongDisneyland
        case .shanghaiDisneyland: extras = shanghaiDisneyland
        }
        return universal + extras
    }

    /// Converts templates to live `PackingItem` models attached to a trip.
    static func makeItems(for trip: Trip) -> [PackingItem] {
        templates(for: trip.resort).map { template in
            PackingItem(
                name: template.name,
                category: template.category,
                isParkDefault: true,
                trip: trip
            )
        }
    }
}
