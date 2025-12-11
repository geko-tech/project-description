extension Config {
    /// Options for project generation.
    public struct GenerationOptions: Codable, Hashable {
        /**
         This enum represents the targets against which Geko will run the check for potential side effects
         caused by static transitive dependencies.
         */
        @frozen
        public enum StaticSideEffectsWarningTargets: Codable, Hashable {
            case all
            case none
            case excluding([String])
        }

        /// When passed, Xcode will resolve its Package Manager dependencies using the system-defined
        /// accounts (for example, git) instead of the Xcode-defined accounts
        public var resolveDependenciesWithSystemScm: Bool

        /// Disables locking Swift packages. This can speed up generation but does increase risk if packages are not locked
        /// in their declarations.
        public var disablePackageVersionLocking: Bool

        /// Allows setting a custom directory to be used when resolving package dependencies
        /// This path is passed to `xcodebuild` via the `-clonedSourcePackagesDirPath` argument
        public var clonedSourcePackagesDirPath: FilePath?

        /// Allows configuring which targets Geko checks for potential side effects due multiple branches of the graph
        /// including the same static library of framework as a transitive dependency.
        public var staticSideEffectsWarningTargets: StaticSideEffectsWarningTargets

        /// The generated project has build settings and build paths modified in such a way that projects with implicit
        /// dependencies won't build until all dependencies are declared explicitly.
        public let enforceExplicitDependencies: Bool

        /// Whether to convert paths in podspecs to buildable folders.
        /// Conversion is available only for paths that have exactly one globstar at the end of the path
        /// For example `Sources/**` will be converted, while `Sources/**/Mocks/**` will not.
        public let convertPathsInPodspecsToBuildableFolders: Bool

        /// Whether to use old linkable dependencies search logic.
        /// See documentation for more info.
        public let useOldLinkableDependencies: Bool

        /// Options to add `-add_ast_path` with paths to swiftmodules of specified modules to `OTHER_LDFLAGS`
        public let addAstPathsToLinker: LinkerAstPaths

        public static func options(
            resolveDependenciesWithSystemScm: Bool = false,
            disablePackageVersionLocking: Bool = false,
            clonedSourcePackagesDirPath: FilePath? = nil,
            staticSideEffectsWarningTargets: StaticSideEffectsWarningTargets = .all,
            enforceExplicitDependencies: Bool = false,
            convertPathsInPodspecsToBuildableFolders: Bool = false,
            useOldLinkableDependencies: Bool = false,
            addAstPathsToLinker: LinkerAstPaths = .disabled
        ) -> Self {
            self.init(
                resolveDependenciesWithSystemScm: resolveDependenciesWithSystemScm,
                disablePackageVersionLocking: disablePackageVersionLocking,
                clonedSourcePackagesDirPath: clonedSourcePackagesDirPath,
                staticSideEffectsWarningTargets: staticSideEffectsWarningTargets,
                enforceExplicitDependencies: enforceExplicitDependencies,
                convertPathsInPodspecsToBuildableFolders: convertPathsInPodspecsToBuildableFolders,
                useOldLinkableDependencies: useOldLinkableDependencies,
                addAstPathsToLinker: addAstPathsToLinker
            )
        }
    }
}

extension Config.GenerationOptions {
    /// Enum of available options of adding `-add_ast_path` parameters to linker
    @frozen
    public enum LinkerAstPaths: Codable, Hashable {
        /// Do not add any parameters at all
        case disabled
        /// Add only for all direct dependencies of each runnable target
        case forAllDirectDependencies
        /// Add only for all direct and transitive dependencies of each runnable target
        case forAllDependencies
        /// Add only for direct and focused targets for each runnable target
        case forFocusedTargetsOnly
    }
}
