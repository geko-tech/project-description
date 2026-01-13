import Foundation

/// Class for descripting geko plugins
///
/// To create a plugin, write a function using following template.
/// ```swift
/// @_cdecl("loadGekoPlugin") func loadGekoPlugin() -> UnsafeMutableRawPointer {
///     return GekoPlugin(workspaceMapper: { _ in }).toPointer()
/// }
/// ```
///
/// It is important to keep name of `cdecl`, otherwise geko will not be able to load plugin.
///
/// It is important to convert plugin to a pointer using `toPointer` method, to
/// keep instance of `GekoPlugin` retained.
public class GekoPlugin {
    /// Magic number to identify Geko plugin during loading.
    public let magicNumber = 3716326

    /// Parameters that were passed when declaring WorkspaceMapper ``WorkspaceMapper/params`` in ``Workspace/workspaceMappers``.
    public typealias Parameters = [String: String]

    /// Closure which is called when workspace is finished loading. Workspace contains unresolved globs, such as ``**/*.swift``.
    public let workspaceMapperWithGlobs: ((inout WorkspaceWithProjects, Parameters, DependenciesGraph) throws -> ([SideEffectDescriptor], [LintingIssue]))?
    /// Closure which is called when workspace is finished resolving globs.
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
