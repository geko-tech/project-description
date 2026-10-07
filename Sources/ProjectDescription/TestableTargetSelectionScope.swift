import Foundation

/// A scope that describes a group of test targets to include in a test action.
///
/// Used to express which test targets of a project (or workspace) should be tested when the
/// manifest cannot list them explicitly (for example, when targets are added or removed over time).
@frozen
public enum TestableTargetSelectionScope: Hashable, Codable {
    /// Include all testable targets.
    ///
    /// - Parameter options: Options applied to every selected testable target.
    case all(options: TestingOptions? = nil)

    /// Include only testable targets matching the given filters.
    ///
    /// - Parameters:
    ///   - platform: When set, only targets of this platform are included.
    ///   - products: When set, only targets whose product type is in this list are included.
    ///   - regexp: When set, only targets whose name matches any of these regular expressions are included.
    ///   - exclude: When set, targets whose name matches any of these regular expressions are excluded.
    ///   - options: Options applied to every selected testable target.
    case scope(
        platform: Platform? = nil,
        products: [Product]? = nil,
        regexp: [String]? = nil,
        exclude: [String]? = nil,
        options: TestingOptions? = nil
    )
}