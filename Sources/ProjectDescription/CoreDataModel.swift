import Foundation

/// A Core Data model.
public struct CoreDataModel: Codable, Equatable {
    /// Path to the model.
    public var path: FilePath

    /// Paths to the versions.
    public var versions: [FilePath]

    /// Optional Current version (with or without extension)
    public var currentVersion: String?

    /// Creates a Core Data model from a path.
    ///
    /// - Parameters:
    ///   - path: path to the Core Data model.
    ///   - versions: optional array of paths to each versioned .xcdatamodel file. Will be filled automatically by default.
    ///   - currentVersion: optional current version name (with or without the extension)
    ///   By providing nil, it will try to read it from the .xccurrentversion file.
    public init(
        _ path: FilePath,
        versions: [FilePath] = [],
        currentVersion: String? = nil
    ) {
        self.path = path
        self.versions = versions
        self.currentVersion = currentVersion
    }
}
