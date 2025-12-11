import Foundation

public struct WorkspaceWithProjects: Codable, Equatable {
    public var workspace: Workspace
    public var projects: [Project]
    public init(workspace: Workspace, projects: [Project]) {
        self.workspace = workspace
        self.projects = projects
    }
}