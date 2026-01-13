import Foundation

/// A file element from a glob pattern or a folder reference.
///
/// - glob: a glob pattern for files to include
/// - file: a path to single file to include
/// - folderReference: a single path to a directory
///
/// Note: For convenience, an element can be represented as a string literal
///       `"some/pattern/**"` is the equivalent of `FileElement.glob(pattern: "some/pattern/**")`
@frozen
public enum FileElement: Codable, Hashable, Equatable {
    /// A file path (or glob pattern) to include. For convenience, a string literal can be used as an alternate way to specify
    /// this option.
    case glob(pattern: FilePath)

    /// A file path to include. Globs described using `file` will not be expanded.
    case file(path: FilePath)

    /// A directory path to include as a folder reference.
    case folderReference(path: FilePath)

    private enum TypeName: String, Codable {
        case glob
        case file
        case folderReference
    }

    private var typeName: TypeName {
        switch self {
        case .glob:
            return .glob
        case .file:
            return .file
        case .folderReference:
            return .folderReference
        }
    }
}

extension FileElement: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        let filePath = try! FilePath(validating: value)
        self = .glob(pattern: filePath)
    }
}

extension [FileElement]: @retroactive ExpressibleByUnicodeScalarLiteral {
    public typealias UnicodeScalarLiteralType = String
}

extension [FileElement]: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = String
}

extension [FileElement]: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public init(stringLiteral value: String) {
        let filePath = try! FilePath(validating: value)
        self = [.glob(pattern: filePath)]
    }
}
