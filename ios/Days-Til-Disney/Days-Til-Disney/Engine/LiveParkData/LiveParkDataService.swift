import Foundation

// MARK: - Protocol

/// Fetches real-time park data (wait times, show schedules) from the ThemeParks.wiki API.
/// Results are cached in memory for `cacheLifetime` to avoid hammering the API on
/// every view appear. No background polling — data is only fetched on demand.
@MainActor
protocol LiveParkDataService {
    func fetchLiveData(for park: DisneyPark) async throws -> ParkLiveData
    func clearCache(for park: DisneyPark)
}

// MARK: - Errors

enum LiveParkDataError: LocalizedError {
    case parkNotSupported(DisneyPark)
    case networkError(Error)
    case invalidResponse
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .parkNotSupported(let park):
            return "\(park.displayName) is not currently supported for live data."
        case .networkError(let underlying):
            return "Network error: \(underlying.localizedDescription)"
        case .invalidResponse:
            return "Received an unexpected response from the park data service."
        case .httpError(let code):
            return "The park data service returned an error (HTTP \(code))."
        }
    }
}

// MARK: - Implementation

@MainActor
final class DefaultLiveParkDataService: LiveParkDataService {

    // MARK: Configuration

    private static let baseURL = "https://api.themeparks.wiki/v1"
    /// Cache entries older than this are discarded on the next fetch.
    private let cacheLifetime: TimeInterval

    // MARK: Cache

    private struct CacheEntry {
        let data: ParkLiveData
        let expiry: Date
    }

    private var cache: [String: CacheEntry] = [:]

    // MARK: URLSession

    private let session: URLSession

    // MARK: Init

    init(
        cacheLifetime: TimeInterval = 5 * 60,   // 5 minutes
        session: URLSession = .shared
    ) {
        self.cacheLifetime = cacheLifetime
        self.session = session
    }

    // MARK: LiveParkDataService

    func fetchLiveData(for park: DisneyPark) async throws -> ParkLiveData {
        guard let wikiID = park.themeParkWikiID else {
            throw LiveParkDataError.parkNotSupported(park)
        }

        // Return cached entry if still fresh.
        if let entry = cache[wikiID], entry.expiry > Date() {
            return entry.data
        }

        // Build request.
        let urlString = "\(Self.baseURL)/entity/\(wikiID)/live"
        guard let url = URL(string: urlString) else {
            throw LiveParkDataError.invalidResponse
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw LiveParkDataError.networkError(error)
        }

        if let httpResponse = response as? HTTPURLResponse,
           !(200..<300).contains(httpResponse.statusCode) {
            throw LiveParkDataError.httpError(httpResponse.statusCode)
        }

        // Decode.
        let decoded: APILiveResponse
        do {
            decoded = try JSONDecoder().decode(APILiveResponse.self, from: data)
        } catch {
            throw LiveParkDataError.invalidResponse
        }

        let liveData = decoded.toDomain(park: park)

        // Store in cache.
        cache[wikiID] = CacheEntry(
            data: liveData,
            expiry: Date().addingTimeInterval(cacheLifetime)
        )

        return liveData
    }

    func clearCache(for park: DisneyPark) {
        guard let wikiID = park.themeParkWikiID else { return }
        cache.removeValue(forKey: wikiID)
    }
    // Note: cache is bounded to 12 entries max (one per supported Disney park).
}

// MARK: - API response DTOs (private, never leak outside this file)

private struct APILiveResponse: Decodable {
    let id: String
    let name: String
    let liveData: [APILiveEntity]

    enum CodingKeys: String, CodingKey {
        case id, name, liveData
    }

    func toDomain(park: DisneyPark) -> ParkLiveData {
        var attractions: [LiveAttraction] = []
        var shows: [LiveShow] = []

        for entity in liveData {
            switch entity.entityType {
            case "ATTRACTION":
                attractions.append(entity.toAttraction())
            case "SHOW":
                shows.append(entity.toShow())
            default:
                break
            }
        }

        // Sort attractions: operating first (by wait time desc), then closed/refurb alphabetically.
        attractions.sort { lhs, rhs in
            if lhs.status == .operating && rhs.status != .operating { return true }
            if lhs.status != .operating && rhs.status == .operating { return false }
            // Both same status — sort operating by wait (highest first), others by name.
            if lhs.status == .operating {
                let lWait = lhs.standbyWaitMinutes ?? -1
                let rWait = rhs.standbyWaitMinutes ?? -1
                return lWait > rWait
            }
            return lhs.name < rhs.name
        }

        // Sort shows by next showtime.
        shows.sort { lhs, rhs in
            switch (lhs.nextShowTime, rhs.nextShowTime) {
            case (let l?, let r?): return l < r
            case (.some, .none):   return true
            case (.none, .some):   return false
            case (.none, .none):   return lhs.name < rhs.name
            }
        }

        return ParkLiveData(
            park: park,
            fetchedAt: Date(),
            attractions: attractions,
            shows: shows
        )
    }
}

private struct APILiveEntity: Decodable {
    let id: String
    let name: String
    let entityType: String
    let status: String?
    let queue: APIQueue?
    let showtimes: [APIShowtime]?
    let lastUpdated: String?

    // MARK: Shared formatter (allocated once, not per call)

    private static let isoFormatter: ISO8601DateFormatter = ISO8601DateFormatter()

    // MARK: Mapping

    private var parsedStatus: AttractionStatus {
        AttractionStatus(rawValue: status ?? "") ?? .closed
    }

    private var parsedLastUpdated: Date? {
        guard let raw = lastUpdated else { return nil }
        return Self.isoFormatter.date(from: raw)
    }

    func toAttraction() -> LiveAttraction {
        let llWindow: LightningLaneWindow? = {
            guard let rt = queue?.returnTime,
                  rt.state == "AVAILABLE",
                  let start = rt.returnStart.flatMap({ Self.isoFormatter.date(from: $0) }),
                  let end   = rt.returnEnd.flatMap({   Self.isoFormatter.date(from: $0) })
            else { return nil }
            return LightningLaneWindow(returnStart: start, returnEnd: end)
        }()

        let paidLL: PaidLightningLaneInfo? = {
            guard let prt = queue?.paidReturnTime,
                  prt.state == "AVAILABLE",
                  let price = prt.price
            else { return nil }
            return PaidLightningLaneInfo(
                amountMinorUnit: price.amount,
                currencyCode: price.currency
            )
        }()

        return LiveAttraction(
            id: id,
            name: name,
            status: parsedStatus,
            standbyWaitMinutes: queue?.standby?.waitTime,
            lightningLaneReturnWindow: llWindow,
            paidLightningLanePrice: paidLL,
            lastUpdated: parsedLastUpdated
        )
    }

    func toShow() -> LiveShow {
        let now = Date()

        let times: [Date] = (showtimes ?? []).compactMap { st in
            Self.isoFormatter.date(from: st.startTime)
        }.sorted()

        let next = times.first(where: { $0 > now })

        return LiveShow(
            id: id,
            name: name,
            status: parsedStatus,
            nextShowTime: next,
            allShowTimes: times
        )
    }
}

private struct APIQueue: Decodable {
    let standby: APIStandby?
    let returnTime: APIReturnTime?
    let paidReturnTime: APIPaidReturnTime?

    enum CodingKeys: String, CodingKey {
        case standby = "STANDBY"
        case returnTime = "RETURN_TIME"
        case paidReturnTime = "PAID_RETURN_TIME"
    }
}

private struct APIStandby: Decodable {
    let waitTime: Int?
}

private struct APIReturnTime: Decodable {
    let state: String?
    let returnStart: String?
    let returnEnd: String?
}

private struct APIPaidReturnTime: Decodable {
    let state: String?
    let price: APIPrice?
    let returnStart: String?
    let returnEnd: String?
}

private struct APIPrice: Decodable {
    let amount: Int
    let currency: String
}

private struct APIShowtime: Decodable {
    let startTime: String
    let endTime: String?
    let type: String?
}
