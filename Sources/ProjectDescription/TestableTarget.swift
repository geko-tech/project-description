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

    public init(
        target: TargetReference,
        skipped: Bool = false,
        parallelizable: Bool = false,
        randomExecutionOrdering: Bool = false
    ) {
        self.target = target
        isSkipped = skipped
        isParallelizable = parallelizable
        isRandomExecutionOrdering = randomExecutionOrdering
    }

    public init(stringLiteral value: String) {
        self.init(target: .init(projectPath: nil, target: value))
    }
}

public struct TestableTargetFilter: Equatable, Hashable, Codable {
    public var targetFilter: TargetFilter
    /// Skip test target from TestAction.
    public var isSkipped: Bool
    /// Execute tests in parallel.
    public var isParallelizable: Bool
    /// Execute tests in random order.
    public var isRandomExecutionOrdering: Bool

    public init(
        targetFilter: TargetFilter,
        skipped: Bool = false,
        parallelizable: Bool = false,
        randomExecutionOrdering: Bool = false
    ) {
        self.targetFilter = targetFilter
        isSkipped = skipped
        isParallelizable = parallelizable
        isRandomExecutionOrdering = randomExecutionOrdering
    }
}
