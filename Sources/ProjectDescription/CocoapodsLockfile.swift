import Foundation

public struct CocoapodsLockfile: Codable, Equatable {
    public typealias Lockfile = [String: SourceData]

    public struct PodData: Codable, Equatable {
        // do no forget update comparePods(to:) when you add new fields!
        public var hash: String?
        public var version: PackageVersion
        public var subspecs: [String]?

        public init(hash: String? = nil, version: PackageVersion, subspecs: [String]? = nil) {
            self.hash = hash
            self.version = version
            self.subspecs = subspecs
        }
    }

    @frozen
    public enum SourceType: String, Codable {
        case git
        case cdn
        case path
        case gitRepo
    }

    public struct SourceData: Codable, Equatable {
        public var type: SourceType
        public var ref: String?
        public var pods: [String: PodData]

        public init(type: SourceType, ref: String? = nil, pods: [String : PodData]) {
            self.type = type
            self.ref = ref
            self.pods = pods
        }
    }

    public var podsBySource: Lockfile

    public init(podsBySource: Lockfile) {
        self.podsBySource = podsBySource
    }
}
