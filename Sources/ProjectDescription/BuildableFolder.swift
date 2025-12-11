import Foundation

public struct BuildableFolder: Codable, Equatable, Hashable {
    public var path: FilePath
    public var exceptions: [FilePath]

    public init(
        _ path: FilePath,
        exceptions: [FilePath]
    ) {
        self.path = path
        self.exceptions = exceptions
    }
}

extension BuildableFolder: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        self.init(FilePath(value), exceptions: [])
    }
}
