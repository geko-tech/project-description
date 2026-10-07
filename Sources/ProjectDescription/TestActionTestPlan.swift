import Foundation

/// A test plan passed to a test action.
///
/// A test plan can either reference an existing `.xctestplan` file on disk or describe a
/// generated test plan that Geko creates during generation.
@frozen
public enum TestActionTestPlan: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    /// Reference an existing `.xctestplan` file on disk.
    ///
    /// - Parameter path: Path to the existing `.xctestplan` file.
    case file(FilePath)

    /// Describe a test plan that Geko generates during generation.
    ///
    /// - Parameters:
    ///   - name: Name of the generated test plan.
    ///   - directory: Directory the test plan is written to. If `nil`, it's written to the derived directory.
    ///   - configurations: Configurations of the generated test plan.
    ///   - defaultOptions: Default options applied to the generated test plan.
    ///   - testTargets: Explicit test targets to include in the generated test plan.
    ///   - targetSelection: Scopes that resolve which test targets to include in the generated test plan.
    ///   - missingTargetPolicy: Policy applied when a target referenced by the generated test plan is missing.
    case generated(
        name: String,
        directory: FilePath? = nil,
        configurations: [GeneratedTestPlan.Configuration] = [],
        defaultOptions: GeneratedTestPlan.Options? = nil,
        testTargets: [GeneratedTestPlanTestableTarget] = [],
        targetSelection: [TestableTargetSelectionScope] = [],
        missingTargetPolicy: GeneratedTestPlan.MissingTargetPolicy = .skipTestPlan()
    )

    public init(_ value: StringLiteralType) {
        self = .file(FilePath(value))
    }

    public init(stringLiteral value: String) {
        self = .file(FilePath(stringLiteral: value))
    }
}