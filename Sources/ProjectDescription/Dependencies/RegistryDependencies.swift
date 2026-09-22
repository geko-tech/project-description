import Foundation

public struct Registry: Codable, Equatable {
    public var registries: [String]
    public var dependencies: [Dependency]
    public var defaultFlavor: String?

    public init(
        registries: [String],
        dependencies: [Dependency],
        defaultFlavor: String? = nil
    ) {
        self.registries = registries
        self.dependencies = dependencies
        self.defaultFlavor = defaultFlavor
    }

    public enum Dependency: Codable, Hashable {
        case remote(
            name: String,
            requirement: Requirement,
            source: String? = nil,
            flavor: String? = nil
        )
        case local(
            path: FilePath,
            flavor: String? = nil
        )
    }

    public enum Requirement: Codable, Hashable {
        case exact(String)
        case atLeast(String)
        case upToNextMajor(String)
        case upToNextMinor(String)
    }
}
