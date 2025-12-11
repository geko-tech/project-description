import Foundation

// MARK: - Platform

/// A supported platform representation.
@frozen
public enum Platform: String, Codable, Equatable, CaseIterable, Comparable {
    /// The iOS platform
    case iOS = "ios"
    /// The macOS platform
    case macOS = "macos"
    /// The tvOS platform
    case tvOS = "tvos"
    /// The watchOS platform
    case watchOS = "watchos"
    /// The visionOS platform
    case visionOS = "visionos"

    public var caseValue: String {
        switch self {
        case .iOS: return "iOS"
        case .macOS: return "macOS"
        case .tvOS: return "tvOS"
        case .watchOS: return "watchOS"
        case .visionOS: return "visionOS"
        }
    }

    public static func < (lhs: Platform, rhs: Platform) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// A supported Swift Package Manager platform representation.
@frozen
public enum PackagePlatform: String, Codable, Equatable, CaseIterable, Comparable {
    /// The iOS platform
    case iOS = "ios"
    /// The Mac Catalyst platform
    case macCatalyst = "maccatalyst"
    /// The macOS platform
    case macOS = "macos"
    /// The tvOS platform
    case tvOS = "tvos"
    /// The watchOS platform
    case watchOS = "watchos"
    /// The visionOS platform
    case visionOS = "visionos"

    public var caseValue: String {
        switch self {
        case .iOS: return "iOS"
        case .macCatalyst: return "macCatalyst"
        case .macOS: return "macOS"
        case .tvOS: return "tvOS"
        case .watchOS: return "watchOS"
        case .visionOS: return "visionOS"
        }
    }

    public static func < (lhs: PackagePlatform, rhs: PackagePlatform) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
