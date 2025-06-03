import Foundation

struct DetailInfoResponse: Codable {
    let response: DetailInfoResponseInner
}
struct DetailInfoResponseInner: Codable {
    let header: TourAPIResponseHeader?
    let body: DetailInfoBody
}
struct DetailInfoBody: Codable {
    let items: DetailInfoItems
}
struct DetailInfoItems: Codable {
    let item: [DetailInfo]
}
struct DetailInfo: Codable, Hashable {
    let infoname: String?
    let infotext: String?
}
