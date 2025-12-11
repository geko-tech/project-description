import Foundation

public class GekoPlugin {
    public let magicNumber = 3716326

    public let workspaceMapperWithGlobs: ((inout WorkspaceWithProjects, [String: String], DependenciesGraph) throws -> ([SideEffectDescriptor], [LintingIssue]))?
    public let workspaceMapper: ((inout WorkspaceWithProjects, [String: String], DependenciesGraph) throws -> ([SideEffectDescriptor], [LintingIssue]))?

    public init(
        workspaceMapperWithGlobs: ((inout WorkspaceWithProjects, [String: String], DependenciesGraph) throws -> ([SideEffectDescriptor], [LintingIssue]))? = nil,
        workspaceMapper: ((inout WorkspaceWithProjects, [String: String], DependenciesGraph) throws -> ([SideEffectDescriptor], [LintingIssue]))? = nil
    ) {
        self.workspaceMapperWithGlobs = workspaceMapperWithGlobs
        self.workspaceMapper = workspaceMapper
    }

    public func toPointer() -> UnsafeMutableRawPointer {
        Unmanaged.passRetained(self).toOpaque()
    }
}
