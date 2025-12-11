public typealias PlatformFilters = Set<PlatformFilter>

extension PlatformFilters {
    public static let all = Set(PlatformFilter.allCases)
}

/// Defines a set of platforms that can be used to limit where things
/// like build files, resources, and dependencies are used.
@frozen
public enum PlatformFilter: Comparable, Hashable, Codable, CaseIterable {
    case ios
    case macos
    case tvos
    case catalyst
    case driverkit
    case watchos
    case visionos
}
