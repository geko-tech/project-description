import Foundation

/// A collection of source file globs.
public struct SourceFilesList: ExpressibleByStringInterpolation, ExpressibleByArrayLiteral {
    /// List glob patterns.
    public var sourceFiles: [SourceFiles]

    public init(globs: [SourceFiles]) {
        self.sourceFiles = globs
    }

    public init(sourceFiles: [SourceFiles]) {
        self.sourceFiles = sourceFiles
    }

    /// Creates the source files list with the glob patterns as strings.
    ///
    /// - Parameter globs: Glob patterns.
    public init(sourceFiles: [String]) {
        self.sourceFiles = sourceFiles.map(SourceFiles.init)
    }

    /// Returns a sources list from a list of paths.
    /// - Parameter paths: Source paths.
    public static func paths(_ paths: [FilePath]) -> SourceFilesList {
        SourceFilesList(sourceFiles: paths.map { .glob($0) })
    }

    public init(stringLiteral value: String) {
        self.init(sourceFiles: [value])
    }

    public init(arrayLiteral elements: SourceFiles...) {
        self.init(sourceFiles: elements)
    }
}

/// A type that represents source files.
public struct SourceFiles: Equatable, Codable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    /// Source file paths.
    public var paths: [FilePath]

    /// Glob patterns for source files that will be excluded.
    public var excluding: [FilePath]

    /// Compiler flags
    /// When source files are added to a target, they can contain compiler flags that Xcode's build system
    /// passes to the compiler when compiling those files. By default none is passed.
    public var compilerFlags: String?

    /// Source file code generation attribute
    public let codeGen: FileCodeGen?

    /// Source file condition for platform filters
    public let compilationCondition: PlatformCondition?

    /// This is intended to be used by the mappers that generate files through side effects.
    /// This attribute is used by the content hasher used by the caching functionality.
    public var contentHash: String? = nil

    public init(
        glob: FilePath,
        excluding: [FilePath] = [],
        compilerFlags: String? = nil,
        contentHash: String? = nil,
        codeGen: FileCodeGen? = nil,
        compilationCondition: PlatformCondition? = nil
    ) {
        self.paths = [glob]
        self.excluding = excluding
        self.compilerFlags = compilerFlags
        self.contentHash = contentHash
        self.codeGen = codeGen
        self.compilationCondition = compilationCondition
    }

    public init(
        paths: [FilePath],
        excluding: [FilePath] = [],
        compilerFlags: String? = nil,
        contentHash: String? = nil,
        codeGen: FileCodeGen? = nil,
        compilationCondition: PlatformCondition? = nil
    ) {
        self.paths = paths
        self.excluding = excluding
        self.compilerFlags = compilerFlags
        self.contentHash = contentHash
        self.codeGen = codeGen
        self.compilationCondition = compilationCondition
    }

    // MARK: - ExpressibleByStringLiteral

    public init(stringLiteral value: String) {
        let filePath = try! FilePath(validating: value)
        self.init(glob: filePath)
    }

    /// Returns a source glob pattern configuration.
    ///
    /// - Parameters:
    ///   - glob: Glob pattern to the source files.
    ///   - excluding: Glob patterns for source files that will be excluded.
    ///   - compilerFlags: The compiler flags to be set to the source files in the sources build phase.
    ///   - codeGen: The source file attribute to be set in the build phase.
    ///   - compilationCondition: Condition for file compilation.
    public static func glob(
        _ glob: FilePath,
        excluding: [FilePath] = [],
        compilerFlags: String? = nil,
        codeGen: FileCodeGen? = nil,
        compilationCondition: PlatformCondition? = nil
    ) -> Self {
        .init(
            glob: glob,
            excluding: excluding,
            compilerFlags: compilerFlags,
            codeGen: codeGen,
            compilationCondition: compilationCondition
        )
    }

    public static func glob(
        _ glob: FilePath,
        excluding: FilePath?,
        compilerFlags: String? = nil,
        codeGen: FileCodeGen? = nil,
        compilationCondition: PlatformCondition? = nil
    ) -> Self {
        let paths: [FilePath] = excluding.flatMap { [$0] } ?? []
        return .init(
            glob: glob,
            excluding: paths,
            compilerFlags: compilerFlags,
            codeGen: codeGen,
            compilationCondition: compilationCondition
        )
    }
}

extension SourceFiles: CustomDebugStringConvertible {
    public var debugDescription: String {
        var result = "SourceFiles(\n  "
        result += paths.debugDescription

        if !excluding.isEmpty {
            result += "\n  excluding ("

            for exclude in excluding {
                result += "\n    \(exclude.debugDescription)"
            }
        }

        result += "\n)"

        return result
    }
}
