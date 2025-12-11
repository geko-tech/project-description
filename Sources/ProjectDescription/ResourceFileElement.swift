import Foundation

/// A resource file element from a glob pattern or a folder reference.
///
/// - glob: a glob pattern for files to include
/// - folderReference: a single path to a directory
///
/// Note: For convenience, an element can be represented as a string literal
///       `"some/pattern/**"` is the equivalent of `ResourceFileElement.glob(pattern: "some/pattern/**")`
@frozen
public enum ResourceFileElement: Codable, Hashable, Equatable {
    /// A glob pattern of files to include and ODR tags
    case glob(pattern: FilePath, excluding: [FilePath] = [], tags: [String] = [], inclusionCondition: PlatformCondition? = nil)

    /// A file path to a single file to include, ODR tags list and inclusion
    /// condition.
    /// For convenience, a string literal can be used as an alternate way to specify this option.
    case file(path: FilePath, tags: [String] = [], inclusionCondition: PlatformCondition? = nil)

    /// Relative path to a directory to include as a folder reference and ODR tags
    case folderReference(path: FilePath, tags: [String] = [], inclusionCondition: PlatformCondition? = nil)

    private enum TypeName: String, Codable {
        case glob
        case folderReference
        case file
    }

    private var typeName: TypeName {
        switch self {
        case .glob:
            return .glob
        case .folderReference:
            return .folderReference
        case .file:
            return .file
        }
    }
}

extension ResourceFileElement: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        self = .glob(pattern: FilePath(value))
    }
}

extension ResourceFileElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .glob(pattern, excluding, tags, inclusionCondition):
            var result = "ResourceFileElement.glob(\n"

            result += "  \(pattern.debugDescription)\n"

            if !excluding.isEmpty {
                result += "  excluding("
                for excluded in excluding {
                    result += "    \(excluded.debugDescription)\n"
                }
                result += "  )\n"
            }

            if !tags.isEmpty {
                result += "  tags(\(tags.debugDescription))"
            }

            if let inclusionCondition {
                result += "  inclusionCondition(\(inclusionCondition))"
            }

            result += ")"
            return result
        case let .folderReference(path, tags, inclusionCondition),
            let .file(path, tags, inclusionCondition):
            var result = "ResourceFileElement.file(\n"

            result += "  \(path.debugDescription)\n"

            if !tags.isEmpty {
                result += "  tags(\(tags.debugDescription))"
            }

            if let inclusionCondition {
                result += "  inclusionCondition(\(inclusionCondition))"
            }

            result += ")"

            return result
        }
    }
}

// MARK: - ResourceFileElements

/// A collection of resource file.
public struct ResourceFileElements: ExpressibleByStringInterpolation, ExpressibleByArrayLiteral {
    /// List of resource file elements
    public var resources: [ResourceFileElement]

    public init(resources: [ResourceFileElement]) {
        self.resources = resources
    }

    public init(stringLiteral value: String) {
        self.init(resources: [.glob(pattern: FilePath(value))])
    }

    public init(arrayLiteral elements: ResourceFileElement...) {
        self.init(resources: elements)
    }
}
