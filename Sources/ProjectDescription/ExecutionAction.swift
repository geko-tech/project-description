import Foundation

/// An action that can be executed as part of another action for pre or post execution.
public struct ExecutionAction: Equatable, Codable {
    /// Name of a script.
    public var title: String
    /// An inline shell script.
    public var scriptText: String
    /// Name of the build or test target that will provide the action's build settings.
    public var target: TargetReference?

    /// The path to the shell which shall execute this script. if it is nil, Xcode will use default value.
    public var shellPath: String?

    public let showEnvVarsInLog: Bool

    // MARK: - Init

    public init(
        title: String = "Run Script",
        scriptText: String,
        target: TargetReference? = nil,
        shellPath: String? = nil,
        showEnvVarsInLog: Bool = true
    ) {
        self.title = title
        self.scriptText = scriptText
        self.target = target
        self.shellPath = shellPath
        self.showEnvVarsInLog = showEnvVarsInLog
    }
}
