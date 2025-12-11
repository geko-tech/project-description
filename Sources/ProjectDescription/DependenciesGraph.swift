import Foundation

public struct DependenciesGraph: Equatable, Codable {
    public struct TreeDependency: Equatable, Codable {
        public let version: String
        public var dependencies: [String]

        public init(
            version: String,
            dependencies: [String]
        ) {
            self.version = version
            self.dependencies = dependencies
        }
    }
    /// A dictionary where the keys are the supported platforms and the values are dictionaries where the keys are the names of
    /// dependencies, and the values are the dependencies themselves.
    public let externalDependencies: [String: [TargetDependency]]

    /// A dictionary where the keys are the folder of external projects, and the values are the projects themselves.
    public let externalProjects: [AbsolutePath: Project]

    public let externalFrameworkDependencies: [AbsolutePath: [TargetDependency]]

    public let tree: [String: TreeDependency]

    /// Create an instance of `DependenciesGraph` model.
    public init(
        externalDependencies: [String: [TargetDependency]],
        externalProjects: [AbsolutePath: Project],
        externalFrameworkDependencies: [AbsolutePath: [TargetDependency]],
        tree: [String: TreeDependency]
    ) {
        self.externalDependencies = externalDependencies
        self.externalProjects = externalProjects
        self.externalFrameworkDependencies = externalFrameworkDependencies
        self.tree = tree
    }

    /// An empty `DependenciesGraph`.
    public static let none: DependenciesGraph = .init(
        externalDependencies: [:],
        externalProjects: [:],
        externalFrameworkDependencies: [:],
        tree: [:]
    )
}