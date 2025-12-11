import Foundation

// MARK: - InfoPlist

/// A info plist from a file, a custom dictonary or a extended defaults.
@frozen
public enum InfoPlist: Codable, Equatable {
    /// The path to an existing Info.plist file.
    case file(path: FilePath)

    // Path to a generated info.plist file (may not exist on disk at the time of project generation).
    // Data of the generated file
    case generatedFile(path: FilePath, data: Data)

    /// A dictionary with the Info.plist content. Geko generates the Info.plist file at the generation time.
    case dictionary([String: Plist.Value])

    /// Generate an Info.plist file with the default content for the target product extended with the values in the given
    /// dictionary.
    case extendingDefault(with: [String: Plist.Value])

    /// Generate the default content for the target the InfoPlist belongs to.
    public static var `default`: InfoPlist {
        .extendingDefault(with: [:])
    }

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

// MARK: - InfoPlist - ExpressibleByStringInterpolation

extension InfoPlist: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        self = .file(path: try! FilePath(validating: value))
    }
}
