import Foundation

/// A collection of external cocoapods dependencies
public struct CocoapodsDependencies: Codable, Equatable {
    /// Collection of cocoapods CDN specs repositories
    ///
    /// Repositories at the top have more priority when searching podspecs.
    /// CDN specs repositories are always have more priority than Git specs repositories.
    public var repos: [String]
    /// Collection of cocoapods Git specs repositories
    ///
    /// Repositories at the top have more priority when searching podspecs.
    /// CDN specs repositories are always have more priority than Git specs repositories.
    public var gitRepos: [String]
    /// List of external dependencies
    public var dependencies: [Dependency]
    /// List of local podspecs, that need to participate in dependency resolution.
    ///
    /// This may be the case when external module depends on local one.
    /// Key is source_root path, value is an array of globs to podspec files.
    public var localPodspecs: [FilePath: [FilePath]]?
    /// Default linkage type for all cocoapods dependencies
    ///
    /// When specified, changes linkage type for all cocoapods dependencies,
    /// unless specified in `forceLinking`
    public var defaultForceLinking: Linking?
    /// Linkage type for specific cocoapods dependencies
    ///
    /// Key - name of dependency, value - linkage
    public var forceLinking: [String: Linking]?

    /// Creates a new `CocoapodsDependencies` instance.
    /// - Parameters
    ///   - repos: Collection of CDN repositories
    ///   - gitRepos: Collection of Git repositories
    ///   - dependencies: External dependencies
    ///   - localPodspecs: List of local podspecs that need to participate in dependency resolution. This may be the case when external module depends on local one.
    ///   - defaultForceLinking: Default linkage type for all cocoapods dependencies
    ///   - forceLinking: Linkage type for specific cocoapods dependencies
    public init(
        repos: [String],
        gitRepos: [String] = [],
        dependencies: [Dependency],
        localPodspecs: [FilePath: [FilePath]]? = nil,
        defaultForceLinking: Linking? = nil,
        forceLinking: [String: Linking]? = nil
    ) {
        self.repos = repos
        self.gitRepos = gitRepos
        self.dependencies = dependencies
        self.localPodspecs = localPodspecs
        self.defaultForceLinking = defaultForceLinking
        self.forceLinking = forceLinking
    }

    public static func == (lhs: CocoapodsDependencies, rhs: CocoapodsDependencies) -> Bool {
        lhs.dependencies.sorted() == rhs.dependencies.sorted() && lhs.repos.sorted() == rhs.repos.sorted()
    }
}

extension CocoapodsDependencies {
    @frozen
    /// Linkage type of cocoapods dependencies
    public enum Linking: Equatable, Codable {
        case `static`
        case dynamic
    }

    @frozen
    /// Dependency type of external cocoapods module
    public enum Dependency: Codable, Hashable, Comparable {
        /// Dependency from CDN repository.
        /// - Parameters:
        ///   - name: Name of the pod
        ///   - requirement: Version requirment
        ///   - source: Repo name. If `nil`, then searches the repositories in the order specified in `repos`.
        case cdn(name: String, requirement: Requirement, source: String? = nil)
        /// Dependency from Git repository.
        /// - Parameters:
        ///   - name: Name of the pod
        ///   - source: Url to git repository
        ///   - ref: Git reference (branch, tag or commit)
        case git(name: String, _ source: String, ref: GitRef)
        /// Local Dependency.
        /// - Parameters:
        ///   - name: Name of the pod
        ///   - path: Absolute or relative path to the pod
        case path(name: String, path: FilePath)
        /// Dependency from Git Specs repository.
        /// - Parameters:
        ///   - name: Name of the pod
        ///   - requirement: Version requirment
        ///   - source: Repo name. If `nil`, then searches the repositories in the order specified in `gitRepos`.
        case gitRepo(name: String, requirement: Requirement, source: String? = nil)

        public var name: String {
            switch self {
            case let .cdn(name, _, _):
                return name
            case let .git(name, _, _):
                return name
            case let .path(name: name, path: _):
                return name
            case let .gitRepo(name, _, _):
                return name
            }
        }

        public static func < (lhs: Dependency, rhs: Dependency) -> Bool {
            lhs.name < rhs.name
        }
    }

    @frozen
    /// Git ref of external repository
    public enum GitRef: Codable, Equatable, Hashable, Comparable, CustomStringConvertible {
        /// Branch name of external repository
        case branch(String)
        /// Tag name of external repository
        case tag(String)
        /// Commit sha of external repository
        case commit(String)

        public var description: String {
            switch self {
            case let .branch(branch):
                return "branch \(branch)"
            case let .tag(tag):
                return "tag \(tag)"
            case let .commit(commit):
                return "commit \(commit)"
            }
        }
    }

    @frozen
    /// Version constraint of external cocoapods dependency
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
}
