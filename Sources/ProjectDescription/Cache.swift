import Foundation

/// A cache configuration.
public struct Cache: Codable, Hashable {
    // Warning ⚠️
    //
    // If new property is added to a caching profile,
    // it must be added to `CacheProfileContentHasher` too.
    /// A cache profile.
    public struct Profile: Codable, Hashable, CustomStringConvertible {
        /// A cache profile scripts
        public struct RunScript: Codable, Hashable, CustomStringConvertible {
            /// The unique name of script
            public let name: String

            /// The environment variables keys necessary to execute the script. They will be resolved relative to the project
            /// settings
            public let envKeys: [String]

            public init(
                name: String,
                envKeys: [String]
            ) {
                self.name = name
                self.envKeys = envKeys
            }

            public static func script(
                name: String,
                envKeys: [String]
            ) -> RunScript {
                RunScript(
                    name: name,
                    envKeys: envKeys
                )
            }

            public var description: String {
                "ScriptName: \(name), EnvKeys: \(envKeys.joined(separator: ","))"
            }
        }

        public struct PlatformOptions: Codable, Hashable, CustomStringConvertible {

            /// The target architecture for cache warmup, e.g. iOS:arm64, watchOS:arm6432 etc.
            public var arch: BinaryArchitecture

            /// The version of the OS to be used when building the project during a caching warmup
            public var os: Version?

            /// The device to be used when building the project during a caching warmup
            public var device: String?

            public init(
                arch: BinaryArchitecture,
                os: Version? = nil,
                device: String? = nil
            ) {
                self.arch = arch
                self.os = os
                self.device = device
            }

            public static func options(
                arch: BinaryArchitecture,
                os: Version? = nil,
                device: String? = nil
            ) -> PlatformOptions {
                PlatformOptions(
                    arch: arch,
                    os: os,
                    device: device
                )
            }

            public var description: String {
                var params = ["Arch: \(arch)"]
                if let os {
                    params.append("os: \(os)")
                }
                if let device {
                    params.append("device: \(device)")
                }
                return params.joined(separator: ",")
            }
        }

        /// Additional options for cache profile
        public struct Options: Codable, Hashable, CustomStringConvertible {

            /// Sets `ENABLE_ONLY_ACTIVE_RESOURCES` build setting for bundle targets
            public var onlyActiveResourcesInBundles: Bool

            /// Sets additional swiftc and clang flags for coverage profile generation
            public var exportCoverageProfiles: Bool

            /// Enable additional cache for xcframeworks swiftmodules files.
            /// Option can be overridden using the env variable `GEKO_SWIFTMODULE_CACHE_ENABLED`
            public var swiftModuleCacheEnabled: Bool

            /// Static init
            /// - Parameters:
            ///   - onlyActiveResourcesInBundles: Sets `ENABLE_ONLY_ACTIVE_RESOURCES` build setting for bundle targets
            ///   - exportCoverageProfiles: Sets additional swiftc and clang flags for coverage profile generation
            /// - Returns: Options object
            public static func options(
                onlyActiveResourcesInBundles: Bool = true,
                exportCoverageProfiles: Bool = false,
                swiftModuleCacheEnabled: Bool = false
            ) -> Self {
                Options(
                    onlyActiveResourcesInBundles: onlyActiveResourcesInBundles,
                    exportCoverageProfiles: exportCoverageProfiles,
                    swiftModuleCacheEnabled: swiftModuleCacheEnabled
                )
            }

            public var description: String {
                ([onlyActiveResourcesInBundles, exportCoverageProfiles, swiftModuleCacheEnabled] as! [CustomStringConvertible])
                    .map(\.description)
                    .joined(separator: ",")
            }
        }

        /// The unique name of a profile
        public var name: String

        /// The configuration to be used when building the project during a caching warmup
        public var configuration: String

        /// The platforms this target support and target platform options
        public var platforms: [Platform: PlatformOptions]

        /// Scripts to run before warming up the cache
        public var scripts: [RunScript]

        /// Additional options for cache profile
        public var options: Options

        public init(
            name: String,
            configuration: String,
            platforms: [Platform: PlatformOptions],
            scripts: [RunScript] = [],
            options: Options = .options()
        ) {
            self.name = name
            self.configuration = configuration
            self.platforms = platforms
            self.scripts = scripts
            self.options = options
        }

        /// Returns a `Cache.Profile` instance.
        ///
        /// - Parameters:
        ///     - name: The unique name of the cache profile
        ///     - configuration: The configuration to be used when building the project during a caching warmup
        ///     - platforms: Dictionary of platforms with platform options: e.g. arch, device, os
        ///     - scripts: Scripts to run before warming up the cache
        ///     - options: Additional options for cache profile
        /// - Returns: The `Cache.Profile` instance
        public static func profile(
            name: String,
            configuration: String,
            platforms: [Platform: PlatformOptions],
            scripts: [RunScript] = [],
            options: Options = .options()
        ) -> Profile {
            Profile(
                name: name,
                configuration: configuration,
                platforms: platforms,
                scripts: scripts,
                options: options
            )
        }

        public var description: String {
            name
        }
    }

    /// A list of the cache profiles.
    public var profiles: [Profile]
    /// The path where the cache will be stored, if `nil` it will be a default location in a shared directory.
    public var path: FilePath?

    /// Unique identifier of cached artifacts. Can be used to invalidate cache if needed.
    public var version: String?

    public init(profiles: [Profile], path: AbsolutePath?, version: String? = nil) {
        self.profiles = profiles
        self.path = path
        self.version = version
    }

    /// Returns a `Cache` instance containing the given profiles.
    /// If no profile list is provided, geko's default profile will be taken as the default.
    /// If no profile is provided in `geko cache --profile` command, the first profile from the profiles list will be taken as
    /// the default.
    /// - Parameters:
    ///   - profiles: Profiles to be chosen from
    ///   - path: The path where the cache will be stored, if `nil` it will be a default location in a shared directory.
    ///   - version: Unique identifier of cached artifacts. Can be used to invalidate cache if needed.
    /// - Returns: The `Cache` instance
    public static func cache(profiles: [Profile] = [], path: FilePath? = nil, version: String? = nil) -> Cache {
        Cache(profiles: profiles, path: path, version: version)
    }
}
