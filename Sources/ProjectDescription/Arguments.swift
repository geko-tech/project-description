import Foundation

/// A collection of arguments and environment variables.
public struct Arguments: Equatable, Codable {
    public var environmentVariables: [String: EnvironmentVariable]
    public var launchArguments: [LaunchArgument]

    public init(
        environmentVariables: [String: EnvironmentVariable] = [:],
        launchArguments: [LaunchArgument] = []
    ) {
        self.environmentVariables = environmentVariables
        self.launchArguments = launchArguments
    }

    public init(launchArguments: [LaunchArgument]) {
        environmentVariables = [:]
        self.launchArguments = launchArguments
    }

    // Implement `Equatable` manually so order of arguments doesn't matter.
    public static func == (lhs: Arguments, rhs: Arguments) -> Bool {
        lhs.environmentVariables == rhs.environmentVariables
            && lhs.launchArguments.sorted { $0.name < $1.name }
            == rhs.launchArguments.sorted { $0.name < $1.name }
    }
}
