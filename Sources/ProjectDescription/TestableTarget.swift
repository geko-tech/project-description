import Foundation

/// Testable target describe target and tests information.
public struct TestableTarget: Equatable, Hashable, Codable, ExpressibleByStringInterpolation {
    /// The target name and its project path.
    public var target: TargetReference
    /// Skip test target from TestAction.
    public var isSkipped: Bool
    /// Execute tests in parallel.
    public var isParallelizable: Bool
    /// Execute tests in random order.
    public var isRandomExecutionOrdering: Bool
    /// Enables test coverage
    public var isCoverageEnabled: Bool

    public init(
        target: TargetReference,
        skipped: Bool = false,
        parallelizable: Bool = false,
        randomExecutionOrdering: Bool = false,
        coverage: Bool = false
    ) {
        self.target = target
        isSkipped = skipped
        isParallelizable = parallelizable
        isRandomExecutionOrdering = randomExecutionOrdering
        isCoverageEnabled = coverage
    }

    public init(
        target: TargetReference,
        skipped: Bool = false,
        options: TestingOptions = TestingOptions()
    ) {
        self.target = target
        isSkipped = skipped
        isParallelizable = options.contains(.parallelizable)
        isRandomExecutionOrdering = options.contains(.randomExecutionOrdering)
        isCoverageEnabled = options.contains(.coverage)
    }

    public init(stringLiteral value: String) {
        self.init(target: .init(projectPath: nil, target: value))
    }
}
