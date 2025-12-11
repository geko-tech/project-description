import Foundation

public struct HeadersList: Codable, Equatable {
    public var list: [Headers]

    public init(list: [Headers]) {
        self.list = list
    }

    public static func headers(_ list: [Headers]) -> HeadersList {
        .init(list: list)
    }

    public static func headers(
        public: HeaderFileList? = nil,
        private: HeaderFileList? = nil,
        project: HeaderFileList? = nil,
        mappingsDir: FilePath? = nil,
        exclusionRule: Headers.AutomaticExclusionRule = .projectExcludesPrivateAndPublic,
        compilationCondition: PlatformCondition? = nil
    ) -> HeadersList {
        .init(list: [
            .headers(
                public: `public`,
                private: `private`,
                project: project,
                mappingsDir: mappingsDir,
                exclusionRule: exclusionRule,
                compilationCondition: compilationCondition
            )
        ])
    }

    /// Headers from the file list are included as:
    /// - `public`, if the header is present in the umbrella header
    /// - `private`, if the header is present in the `private` list
    /// - `project`, otherwise
    /// - Parameters:
    ///     - from: File list, which contains `public` and `project` headers
    ///     - umbrella: File path to the umbrella header
    ///     - private: File list, which contains `private` headers
    public static func allHeaders(
        from list: HeaderFileList,
        umbrella: FilePath,
        private privateHeaders: HeaderFileList? = nil,
        mappingsDir: FilePath? = nil,
        compilationCondition: PlatformCondition? = nil

    ) -> HeadersList {
        .init(list: [
            .allHeaders(
                from: list,
                umbrella: umbrella,
                private: privateHeaders,
                mappingsDir: mappingsDir,
                compilationCondition: compilationCondition
            )
        ])
    }

    /// Headers from the file list are included as:
    /// - `public`, if the header is present in the umbrella header
    /// - `private`, if the header is present in the `private` list
    /// - not included, otherwise
    /// - Parameters:
    ///     - from: File list, which contains `public` and `project` headers
    ///     - umbrella: File path to the umbrella header
    ///     - private: File list, which contains `private` headers
    public static func onlyHeaders(
        from list: HeaderFileList,
        umbrella: FilePath,
        private privateHeaders: HeaderFileList? = nil,
        mappingsDir: FilePath? = nil,
        compilationCondition: PlatformCondition? = nil
    ) -> HeadersList {
        .init(list: [
            .onlyHeaders(
                from: list,
                umbrella: umbrella,
                private: privateHeaders,
                mappingsDir: mappingsDir,
                compilationCondition: compilationCondition
            )
        ])
    }
}

/// A group of public, private and project headers.
public struct Headers: Codable, Equatable {
    /// Determine how to resolve cases, when the same files found in different header scopes
    @frozen
    public enum AutomaticExclusionRule: Int, Codable {
        /// Project headers = all found - private headers - public headers
        ///
        /// Order of geko search:
        ///  1) Public headers
        ///  2) Private headers (with auto excludes all found public headers)
        ///  3) Project headers (with excluding public/private headers)
        ///
        ///  Also geko doesn't ignore all excludes,
        ///  which had been set by `excluding` param
        case projectExcludesPrivateAndPublic

        /// Public headers = all found - private headers - project headers
        ///
        /// Order of geko search (reverse search):
        ///  1) Project headers
        ///  2) Private headers (with auto excludes all found project headers)
        ///  3) Public headers (with excluding project/private headers)
        ///
        ///  Also geko doesn't ignore all excludes,
        ///  which had been set by `excluding` param
        case publicExcludesPrivateAndProject
    }

    @frozen
    public enum ModuleMap: Codable, Equatable {
        case absent
        case file(path: FilePath)
        case generate
    }

    /// Path to an umbrella header, which will be used to get list of public headers.
    public var umbrellaHeader: FilePath?

    /// Whether to use modulemap file, generate one, or not use modulemap at all
    public var moduleMap: ModuleMap?

    /// Relative glob pattern that points to the public headers.
    public var `public`: HeaderFileList?

    /// Relative glob pattern that points to the private headers.
    public var `private`: HeaderFileList?

    /// Relative glob pattern that points to the project headers.
    public var project: HeaderFileList?

    /// A directory from where to preserve the folder structure for the headers files. If not provided the headers files are flattened.
    public var mappingsDir: FilePath?

    /// Rule, which determines how to resolve found duplicates in public/private/project scopes
    public var exclusionRule: AutomaticExclusionRule

    /// Headers condition for platform filters
    public var compilationCondition: PlatformCondition?

    public init(
        public publicHeaders: HeaderFileList? = nil,
        umbrellaHeader: FilePath? = nil,
        moduleMap: ModuleMap? = nil,
        private privateHeaders: HeaderFileList? = nil,
        project: HeaderFileList? = nil,
        mappingsDir: FilePath? = nil,
        exclusionRule: AutomaticExclusionRule = .projectExcludesPrivateAndPublic,
        compilationCondition: PlatformCondition? = nil
    ) {
        self.public = publicHeaders
        self.umbrellaHeader = umbrellaHeader
        self.moduleMap = moduleMap
        self.private = privateHeaders
        self.project = project
        self.mappingsDir = mappingsDir
        self.exclusionRule = exclusionRule
        self.compilationCondition = compilationCondition
    }

    public static func headers(
        public: HeaderFileList? = nil,
        private: HeaderFileList? = nil,
        project: HeaderFileList? = nil,
        mappingsDir: FilePath? = nil,
        exclusionRule: AutomaticExclusionRule = .projectExcludesPrivateAndPublic,
        compilationCondition: PlatformCondition? = nil
    ) -> Headers {
        .init(
            public: `public`,
            private: `private`,
            project: project,
            mappingsDir: mappingsDir,
            exclusionRule: exclusionRule,
            compilationCondition: compilationCondition
        )
    }

    private static func headers(
        from list: HeaderFileList,
        umbrella: FilePath,
        private privateHeaders: HeaderFileList? = nil,
        mappingsDir: FilePath? = nil,
        allOthersAsProject: Bool,
        compilationCondition: PlatformCondition? = nil
    ) -> Headers {
        .init(
            public: list,
            umbrellaHeader: umbrella,
            private: privateHeaders,
            project: allOthersAsProject ? list : nil,
            mappingsDir: mappingsDir,
            exclusionRule: .projectExcludesPrivateAndPublic,
            compilationCondition: compilationCondition
        )
    }

    /// Headers from the file list are included as:
    /// - `public`, if the header is present in the umbrella header
    /// - `private`, if the header is present in the `private` list
    /// - `project`, otherwise
    /// - Parameters:
    ///     - from: File list, which contains `public` and `project` headers
    ///     - umbrella: File path to the umbrella header
    ///     - private: File list, which contains `private` headers
    public static func allHeaders(
        from list: HeaderFileList,
        umbrella: FilePath,
        private privateHeaders: HeaderFileList? = nil,
        mappingsDir: FilePath? = nil,
        compilationCondition: PlatformCondition? = nil
    ) -> Headers {
        headers(
            from: list,
            umbrella: umbrella,
            private: privateHeaders,
            mappingsDir: mappingsDir,
            allOthersAsProject: true,
            compilationCondition: compilationCondition
        )
    }

    /// Headers from the file list are included as:
    /// - `public`, if the header is present in the umbrella header
    /// - `private`, if the header is present in the `private` list
    /// - not included, otherwise
    /// - Parameters:
    ///     - from: File list, which contains `public` and `project` headers
    ///     - umbrella: File path to the umbrella header
    ///     - private: File list, which contains `private` headers
    public static func onlyHeaders(
        from list: HeaderFileList,
        umbrella: FilePath,
        private privateHeaders: HeaderFileList? = nil,
        mappingsDir: FilePath? = nil,
        compilationCondition: PlatformCondition? = nil
    ) -> Headers {
        headers(
            from: list,
            umbrella: umbrella,
            private: privateHeaders,
            mappingsDir: mappingsDir,
            allOthersAsProject: false,
            compilationCondition: compilationCondition
        )
    }
}

public struct HeaderFileList: Codable, Equatable, ExpressibleByArrayLiteral, ExpressibleByStringInterpolation {
    public var files: [FilePath]
    public var excluding: [FilePath]?

    public init(
        globs: [FilePath],
        excluding: [FilePath]? = nil
    ) {
        self.files = globs
        self.excluding = excluding
    }

    public init(stringLiteral value: String) {
        self.init(globs: try! [FilePath(validating: value)])
    }

    public init(arrayLiteral elements: FilePath...) {
        self.files = elements
    }

    public static func glob(
        _ glob: FilePath,
        excluding: [FilePath]? = nil
    ) -> HeaderFileList {
        HeaderFileList(globs: [glob], excluding: excluding)
    }

    public static func list(_ globs: [FilePath], excluding: [FilePath]? = nil) -> HeaderFileList {
        HeaderFileList(globs: globs, excluding: excluding)
    }
}
