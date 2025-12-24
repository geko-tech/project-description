import Foundation

public class GekoPlugin {
    /// Magic number to identify Geko plugin during loading.
    public let magicNumber = 3716326

    /// Parameters that were passed when declaring the WorkspaceMapper ``WorkspaceMapper/params`` in ``Workspace/workspaceMappers``.
    public typealias Parameters = [String: String]

    /// Hook for workspace mapper with globs.
    public let workspaceMapperWithGlobs: ((inout WorkspaceWithProjects, Parameters, DependenciesGraph) throws -> ([SideEffectDescriptor], [LintingIssue]))?
    /// Hook for workspace mapper.
    public let workspaceMapper: ((inout WorkspaceWithProjects, Parameters, DependenciesGraph) throws -> ([SideEffectDescriptor], [LintingIssue]))?

    public init(
        workspaceMapperWithGlobs: ((inout WorkspaceWithProjects, Parameters, DependenciesGraph) throws -> ([SideEffectDescriptor], [LintingIssue]))? = nil,
        workspaceMapper: ((inout WorkspaceWithProjects, Parameters, DependenciesGraph) throws -> ([SideEffectDescriptor], [LintingIssue]))? = nil
    ) {
        self.workspaceMapperWithGlobs = workspaceMapperWithGlobs
        self.workspaceMapper = workspaceMapper
    }

    /// Helper method for converting an object to a pointer.
    public func toPointer() -> UnsafeMutableRawPointer {
        Unmanaged.passRetained(self).toOpaque()
    }
}
