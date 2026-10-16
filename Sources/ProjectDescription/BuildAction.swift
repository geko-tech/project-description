import Foundation

/// An action that builds products.
///
/// It's initialized with the `.buildAction` static method.
public struct BuildAction: Equatable, Codable {
    /// A list of targets to build, which are defined in the project.
    public var targets: [TargetReference]
    /// A list of target selection scopes that determine which targets to build.
    ///
    /// Each scope describes a group of targets (e.g. all targets or a filtered subset) that
    /// should be resolved into the `targets` list during generation.
    public var targetSelection: [TargetSelectionScope]
    /// A list of actions that are executed before starting the build process.
    public var preActions: [ExecutionAction]
    /// A list of actions that are executed after the build process.
    public var postActions: [ExecutionAction]
    /// Whether to build a list of implicit dependencies
    public var buildImplicitDependencies: Bool
    /// Whether the post actions should be run in the case of a failure
    public var runPostActionsOnFailure: Bool

    public init(
        targets: [TargetReference] = [],
        targetSelection: [TargetSelectionScope] = [],
        preActions: [ExecutionAction] = [],
        postActions: [ExecutionAction] = [],
        buildImplicitDependencies: Bool = true,
        runPostActionsOnFailure: Bool = false
    ) {
        self.targets = targets
        self.targetSelection = targetSelection
        self.preActions = preActions
        self.postActions = postActions
        self.buildImplicitDependencies = buildImplicitDependencies
        self.runPostActionsOnFailure = runPostActionsOnFailure
    }

    /// Returns a build action.
    /// - Parameters:
    ///   - targets: A list of targets to build, which are defined in the project.
    ///   - targetSelection: A list of target selection scopes that determine which targets to build.
    ///   - preActions: A list of actions that are executed before starting the build process.
    ///   - postActions: A list of actions that are executed after the build process.
    ///   - runPostActionsOnFailure: Whether the post actions should be run in the case of a failure
    /// - Returns: Initialized build action.
    public static func buildAction(
        targets: [TargetReference],
        targetSelection: [TargetSelectionScope] = [],
        preActions: [ExecutionAction] = [],
        postActions: [ExecutionAction] = [],
        buildImplicitDependencies: Bool = true,
        runPostActionsOnFailure: Bool = false
    ) -> BuildAction {
        BuildAction(
            targets: targets,
            targetSelection: targetSelection,
            preActions: preActions,
            postActions: postActions,
            buildImplicitDependencies: buildImplicitDependencies,
            runPostActionsOnFailure: runPostActionsOnFailure
        )
    }
}
