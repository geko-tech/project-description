import Foundation

/// A collection of file globs.
///
/// The list of files can be initialized with a string that represents the glob pattern, or an array of strings, which represents
/// a list of glob patterns.
public struct FileList: Codable, Equatable {
    /// Glob patterns to files.
    public var files: [FilePath]

    /// Glob patterns to files which will not be used.
    public var excluding: [FilePath]

    public init(files: [FilePath], excluding: [FilePath] = []) {
        self.files = files
        self.excluding = excluding
    }

    /// Creates a file list from a collection of glob patterns.
    ///
    ///   - glob: Relative glob pattern.
    ///   - excluding: Relative glob patterns for excluded files.
    public static func list(_ globs: [FilePath], excluding: [FilePath] = []) -> FileList {
        FileList(files: globs, excluding: excluding)
    }

    public static func empty() -> FileList {
        return FileList(files: [], excluding: [])
    }

    public static func glob(
        _ glob: FilePath,
        excluding: [FilePath] = []
    ) -> FileList {
        FileList(files: [glob], excluding: excluding)
    }

    /// Returns a file list glob with an optional excluding path.
    public static func glob(
        _ glob: FilePath,
        excluding: FilePath?
    ) -> FileList {
        FileList(
            files: [glob],
            excluding: excluding.flatMap { [$0] } ?? []
        )
    }
}

extension FileList: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        self.init(files: [.init(stringLiteral: value)])
    }
}

extension FileList: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: String...) {
        self.init(files: elements.map { .init(stringLiteral: $0) })
    }
}
