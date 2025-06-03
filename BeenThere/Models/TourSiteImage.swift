import Foundation

struct TourSiteImageResponse: Codable {
    let response: TourSiteImageInnerResponse
}
struct TourSiteImageInnerResponse: Codable {
    let header: TourAPIResponseHeader?
    let body: TourSiteImageBody
}
struct TourSiteImageBody: Codable {
    let items: TourSiteImageItems
}
struct TourSiteImageItems: Codable {
    let item: [TourSiteImage]
}
struct TourSiteImage: Codable, Hashable {
    let originimgurl: String?
    let smallimageurl: String?
}
