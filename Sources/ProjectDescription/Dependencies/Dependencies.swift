import Foundation

/// A collection of external dependencies.
///
/// Learn how to get started with `Dependencies.swift` manifest with Geko documentation
///
/// ```swift
/// import ProjectDescription
///
/// let dependencies = Dependencies(
///     registry: .init(
///         registries: ["https://geko-registry.company.com"],
///         dependencies: [
///             .remote(name: "Alamofire", requirement: .exact("1.0.0")),
///             .local(path: .relativeToRoot("../LocalProject/.geko/Registry/LocalPackage.json"))
///         ]
///     ),
///     cocoapods: .init(
///         dependencies: [
///             .cdn(name: "Alamofire", requirement: .exact("5.0.0"), source: "https://cdn.cocoapods.org/")
///         ]
///     )
/// )
/// ```
public struct Dependencies: Codable, Equatable {
    /// The description of dependencies that can be installed using Geko registry
    public var registry: RegistryDependencies?
    /// The description of dependencies that can be installed using Cocoapods
    public var cocoapods: CocoapodsDependencies?

    /// Creates a new `Dependencies` manifest instance.
    /// - Parameters:
    ///   - registry: The description of dependencies that can be installed using Geko. Pass `nil` if you don't have
    /// dependencies from Geko registry.
    ///   - cocoapods: The description of dependencies that can be installed using Cocoapods. Pass `nil` if you don't have
    /// dependencies from Cocoapods.
    public init(
        registry: RegistryDependencies? = nil,
        cocoapods: CocoapodsDependencies? = nil
    ) {
        self.registry = registry
        self.cocoapods = cocoapods
        dumpIfNeeded(self)
    }
}
