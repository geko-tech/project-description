import Foundation

// MARK: - Entitlements

@frozen
public enum Entitlements: Codable, Equatable {
    /// The path to an existing .entitlements file.
    case file(path: FilePath)

    // Path to a generated .entitlements file (may not exist on disk at the time of project generation).
    // Data of the generated file
    case generatedFile(path: FilePath, data: Data)

    /// A dictionary with the entitlements content. Geko generates the .entitlements file at the generation time.
    case dictionary([String: Plist.Value])

    // MARK: - Error

    @frozen
    public enum CodingError: Error {
        case invalidType(String)
    }

    // MARK: - Internal

    public var path: FilePath? {
        switch self {
        case let .file(path), let .generatedFile(path, _):
            return path
        default:
            return nil
        }
    }
}

// MARK: - Entitlements - ExpressibleByStringInterpolation

extension Entitlements: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        self = .file(path: try! FilePath(validating: value))
    }
}
