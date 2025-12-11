/// The configuration of your environment.
///
/// Geko can be configured through a shared `Config.swift` manifest.
/// When Geko is executed, it traverses up the directories to find a `Geko` directory containing a `Config.swift` file.
/// Defining a configuration manifest is not required, but recommended to ensure a consistent behaviour across all the projects
/// that are part of the repository.
///
/// The example below shows a project that has a global `Config.swift` file that will be used when Geko is run from any of the
/// subdirectories:
///
/// ```bash
/// /Workspace.swift
/// /Geko/Config.swift # Configuration manifest
/// /Framework/Project.swift
/// /App/Project.swift
/// ```
///
/// That way, when executing Geko in any of the subdirectories, it will use the shared configuration.
///
/// The snippet below shows an example configuration manifest:
///
/// ```swift
/// import ProjectDescription
///
/// let config = Config(
///     compatibleXcodeVersions: ["14.2"],
///     swiftVersion: "5.7.0"
/// )
/// ```
public struct Config: Codable, Equatable {
    /// Generation options.
    public var generationOptions: GenerationOptions
    
    /// List of options to use when running `geko fetch`.
    public let installOptions: InstallOptions

    /// Set the versions of Xcode that the project is compatible with.
    public var compatibleXcodeVersions: CompatibleXcodeVersions

    /// List of `Plugin`s used to extend Geko.
    public var plugins: [PluginLocation]

    /// Cloud configuration.
    public var cloud: Cloud?

    /// Cache configuration.
    public var cache: Cache?

    /// The Swift tools versions that will be used by Geko to fetch external dependencies.
    /// If `nil` is passed then Geko will use the environment’s version.
    /// - Note: This **does not** control the `SWIFT_VERSION` build setting in regular generated projects, for this please use
    /// `Project.settings`
    /// or `Target.settings` as needed.
    public var swiftVersion: Version?

    /// Scripts that are executed before fetch phase. Executed in the same order as declared.
    public var preFetchScripts: [Script]

    /// Scripts that are executed before generation phase. Executed in the same order as declared.
    public var preGenerateScripts: [Script]

    /// Scripts that are executed after generation phase. Executed in the same order as declared.
    public var postGenerateScripts: [Script]
    
    /// if passed then will use bundler to work with Cocoapods
    public var cocoapodsUseBundler: Bool

    /// Creates a geko configuration.
    ///
    /// - Parameters:
    ///   - compatibleXcodeVersions: List of Xcode versions the project is compatible with.
    ///   - cloud: Cloud configuration.
    ///   - cache: Cache configuration.
    ///   - swiftVersion: The version of Swift that will be used by Geko.
    ///   - plugins: A list of plugins to extend Geko.
    ///   - generationOptions: List of options to use when generating the project.
    ///   - preFetchScripts: Scripts that are executed before fetch phase. Executed in the same order as declared.
    ///   - preGenerateScripts: Scripts that are executed before generation phase. Executed in the same order as declared.
    ///   - postGenerateScripts: Scripts that are executed after generation phase. Executed in the same order as declared.
    ///   - cocoapodsUseBundler: if passed then will use bundler to work with Cocoapods
    public init(
        compatibleXcodeVersions: CompatibleXcodeVersions = .all,
        cloud: Cloud? = nil,
        cache: Cache? = nil,
        swiftVersion: Version? = nil,
        plugins: [PluginLocation] = [],
        generationOptions: GenerationOptions = .options(),
        installOptions: InstallOptions = .options(),
        preFetchScripts: [Script] = [],
        preGenerateScripts: [Script] = [],
        postGenerateScripts: [Script] = [],
        cocoapodsUseBundler: Bool = false
    ) {
        self.compatibleXcodeVersions = compatibleXcodeVersions
        self.plugins = plugins
        self.generationOptions = generationOptions
        self.installOptions = installOptions
        self.cloud = cloud
        self.cache = cache
        self.swiftVersion = swiftVersion
        self.preFetchScripts = preFetchScripts
        self.preGenerateScripts = preGenerateScripts
        self.postGenerateScripts = postGenerateScripts
        self.cocoapodsUseBundler = cocoapodsUseBundler
        dumpIfNeeded(self)
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(generationOptions)
        hasher.combine(installOptions)
        hasher.combine(cloud)
        hasher.combine(cache)
        hasher.combine(swiftVersion)
        hasher.combine(compatibleXcodeVersions)
        hasher.combine(cocoapodsUseBundler)
    }
}
