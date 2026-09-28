import Foundation

public struct TargetFilter: Equatable, Codable, Hashable {
    var platform: Platform
    var products: [Product]
    var nameRegexp: String
    var onlyFocusedTargets: Bool
}
