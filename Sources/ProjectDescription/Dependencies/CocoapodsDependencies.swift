import Foundation

public struct CocoapodsDependencies: Codable, Equatable {
    public var repos: [String]
    public var gitRepos: [String]
    public var dependencies: [Dependency]
    public var localPodspecs: [FilePath: [FilePath]]?
    public var defaultForceLinking: Linking?
    public var forceLinking: [String: Linking]?

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
    public enum Linking: Equatable, Codable {
        case `static`
        case dynamic
    }

    @frozen
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
    public enum GitRef: Codable, Equatable, Hashable, Comparable, CustomStringConvertible {
        case branch(String)
        case tag(String)
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
    public enum Requirement: Codable, Hashable {
        case exact(String)
        case atLeast(String)
        case upToNextMajor(String)
        case upToNextMinor(String)
    }
}
