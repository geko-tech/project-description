import Foundation

/// A scope that describes a group of targets to include in a build action.
///
/// Used to express which targets of a project (or workspace) should be built when the
/// manifest cannot list them explicitly (for example, when targets are added or removed over time).
@frozen
public enum TargetSelectionScope: Equatable, Codable {
    /// Include all buildable targets.
    case all

    /// Include only targets matching the given filters.
    ///
    /// - Parameters:
    ///   - platform: When set, only targets of this platform are included.
    ///   - products: When set, only targets whose product type is in this list are included.
    ///   - regexp: When set, only targets whose name matches any of these regular expressions are included.
    ///   - exclude: When set, targets whose name matches any of these regular expressions are excluded.
    case scope(
        platform: Platform? = nil,
        products: [Product]? = nil,
        regexp: [String]? = nil,
        exclude: [String]? = nil
    )
}