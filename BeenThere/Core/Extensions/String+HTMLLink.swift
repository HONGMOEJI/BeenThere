import Foundation

extension String {
    /// HTML <a href="URL">TEXT</a> 태그에서 URL/텍스트 추출
    func htmlLinkToUrlAndTitle() -> (url: String, title: String)? {
        guard let regex = try? NSRegularExpression(pattern: "<a[^>]+href\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>(.*?)</a>", options: []) else { return nil }
        guard let match = regex.firstMatch(in: self, options: [], range: NSRange(self.startIndex..., in: self)) else { return nil }
        let urlRange = match.range(at: 1)
        let titleRange = match.range(at: 2)
        if let url = Range(urlRange, in: self), let title = Range(titleRange, in: self) {
            return (String(self[url]), String(self[title]))
        }
        return nil
    }
}
