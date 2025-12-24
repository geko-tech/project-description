import Foundation

/// A plugin representation.
///
/// Supported plugins include:
/// - [ProjectDescriptionHelpers Plugin](projectdescriptionhelpers_plugin)
/// - [Templates Plugin](templates_plugin)
/// - [Executable Plugin](executable_plugin)
/// - [Workspace Mapper Plugin](workspacemapper_plugin)
public struct Plugin: Codable, Equatable {
    /// The name of the `Plugin`.
    public let name: String
    /// Plugin executables files.
    public let executables: [ExecutablePlugin]
    /// Plugin workspace mapper.
    public let workspaceMapper: WorkspaceMapperPlugin?

    /// Creates a new plugin.
    /// - Parameters:
    ///     - name: The name of the plugin.
    ///     - executables: Plugin executables files.
    ///     - workspaceMapper: Plugin workspace mapper.
    public init(
        name: String, 
        executables: [ExecutablePlugin] = [],
        workspaceMapper: WorkspaceMapperPlugin? = nil
    ) {
        self.name = name
        self.executables = executables
        self.workspaceMapper = workspaceMapper
        dumpIfNeeded(self)
    }
}

/// `Plugin` definition in the `Config`.
public struct PluginConfigManifest: Codable, Equatable {
    /// The name of the `Plugin`
    public let name: String
    /// Plugin executables files.
    public let executables: [ExecutablePlugin]
    /// Plugin workspace mapper.
    public let workspaceMapper: WorkspaceMapperPlugin?
    
    public init(
        name: String, 
        executables: [ExecutablePlugin] = [],
        workspaceMapper: WorkspaceMapperPlugin? = nil
    ) {
        self.name = name
        self.executables = executables
        self.workspaceMapper = workspaceMapper
    }
    
    /// Creates a new plugin in `Config`.
    /// - Parameters:
    ///     - name: The name of the plugin.
    ///     - executables: Plugin executables files.
    ///     - workspaceMapper: Plugin workspace mapper.
    public static func plugin(name: String, executables: [ExecutablePlugin] = [], workspaceMapper: WorkspaceMapperPlugin? = nil) -> Self {
        Self(name: name, executables: executables, workspaceMapper: workspaceMapper)
    }
}

/// Defining the executable file.
public struct ExecutablePlugin: Codable, Equatable {
    /// The name of the executable
    public let name: String
    /// (Optional) Custom path to folder with executable file inside zip archive. By default archive root.
    public let path: String?
    
    public init(name: String, path: String? = nil) {
        self.name = name
        self.path = path
    }
}

/// Defining the workspace mapper.
public struct WorkspaceMapperPlugin: Codable, Equatable {
    /// The name of the mapper.
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}
