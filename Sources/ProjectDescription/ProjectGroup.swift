import Foundation

@frozen
public enum ProjectGroup: Hashable, Codable {
    case group(name: String)
    case groupReference(name: String, path: AbsolutePath)
}
