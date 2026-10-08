import Foundation

/// A ollection of external geko registry dependencies
public struct RegistryDependencies: Codable, Equatable {
    /// Collection of geko registry repositories
    ///
    /// Repositories at the top have more priority when searching for packages.
    public var registries: [String]
    /// List of external dependencies
    public var dependencies: [Dependency]
    /// Rules that describe how resolver should select flavors for packages
    public var flavorBehavior: FlavorBehavior

    /// Creates a new `RegistryDependencies` instance.
    /// - Parameters
    ///   - registries: Collection of repositories
    ///   - dependencies: List of external dependencies
    ///   - flavorBehavior: Rules that describe how resolver should select flavors for packages
    public init(
        registries: [String],
        dependencies: [Dependency],
        flavorBehavior: FlavorBehavior = .default()
    ) {
        self.registries = registries
        self.dependencies = dependencies
        self.flavorBehavior = flavorBehavior
    }

    // MARK: - Dependency

    @frozen
    /// Dependency type of external registry package
    public enum Dependency: Codable, Hashable {
        /// Dependency from remote repository
        /// - Parameters:
        ///   - name: Name of the package
        ///   - requirement: Version requirement
        ///   - repo: Explicitly use package from repository url. If nil, package will be used from list of available top level repositories.
        ///   - flavor: Flavor to use for this package. If nil, flavor will be determined using FlavorBehavior.
        case remote(
            name: String,
            requirement: Requirement,
            repo: String? = nil,
            flavor: String? = nil
        )
        /// Dependency on a package from `.json` file.
        /// - Parameters:
        ///   - path: path to `.json` file describing a geko registry package.
        ///   - flavor: Flavor to use for this package. If nil, flavor will be determined using FlavorBehavior.
        case local(
            path: FilePath,
            flavor: String? = nil
        )
    }

    @frozen
    /// Version constraint of remote geko registry package
    public enum Requirement: Codable, Hashable {
        /// Exact version
        case exact(String)
        /// Specified version or a newer one
        case atLeast(String)
        /// Specified version or a newer one up to next major
        ///
        /// For example, `.upToNextMajor("1.2.3")` is equivalent to range `>= 1.2.3 < 2.0.0`
        case upToNextMajor(String)
        /// Specified version or a newer one up to next minor
        ///
        /// For example, `.upToNextMinor("1.2.3")` is equivalent to range `>= 1.2.3 < 1.3.0`
        case upToNextMinor(String)
    }

    // MARK: - Flavor

    /// A set of rules to describe how resolver should select flavors for packages.
    public struct FlavorBehavior: Codable, Equatable {
        /// A rule 
        public struct Rule: Codable, Equatable {
            @frozen
            public enum Severity: String, Codable, Equatable {
                case error
                case warning
            }

            public var parentFlavors: [String]
            public var dependencyFlavors: [String]
            public var severity: Severity
            public var message: String

            public init(
                parent: [String],
                cannotDependOn dependencyFlavors: [String],
                severity: Severity,
                message: String
            ) {
                self.parentFlavors = parent
                self.dependencyFlavors = dependencyFlavors
                self.severity = severity
                self.message = message
            }
        }

        /// Priority of flavors to select.
        public var priority: [String]
        public var propagate: [String]
        public var rules: [Rule]

        public init(
            priority: [String] = [],
            propagate: [String] = [],
            rules: [Rule] = []
        ) {
            self.priority = priority
            self.propagate = propagate
            self.rules = rules
        }

        public static func `default`() -> FlavorBehavior {
            return FlavorBehavior(
                priority: ["precompiled", "sources"],
                propagate: ["sources"],
                rules: [
                    Rule(
                        parent: ["precompiled"],
                        cannotDependOn: ["sources"],
                        severity: .warning,
                        message: """
                        Package "{parent_name}" with flavor "{parent_flavor}" depends on package "{dependency_name} with flavor "{dependency_flavor}" which can lead to errors during compilation.
                        """
                    )
                ]
            )
        }
    }
}
