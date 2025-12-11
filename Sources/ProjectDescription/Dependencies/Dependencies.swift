import Foundation

/// A collection of external dependencies.
///
/// Learn how to get started with `Dependencies.swift` manifest with Geko documentation
///
/// ```swift
/// import ProjectDescription
///
/// let dependencies = Dependencies(
///     cocoapods: [
///         .cdn(name: "Alamofire", requirement: .exact("5.0.0"), source: "https://cdn.cocoapods.org/")
///     ]
/// )
/// ```
public struct Dependencies: Codable, Equatable {
    /// The description of dependencies that can be installed using Cocoapods
    public var cocoapods: CocoapodsDependencies?

    /// Creates a new `Dependencies` manifest instance.
    /// - Parameters:
    ///   - cocoapods: The description of dependencies that can be installed using Cocoapods. Pass `nil` if you don't have
    /// dependencies from Cocoapods.
    public init(
        cocoapods: CocoapodsDependencies? = nil
    ) {
        self.cocoapods = cocoapods
        dumpIfNeeded(self)
    }
}
