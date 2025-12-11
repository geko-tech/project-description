import Foundation

/// A plugin representation.
///
/// Supported plugins include:
/// - ProjectDescriptionHelpers
///     - These are plugins designed to be usable by any other manifest excluding `Config` and `Plugin`.
///     - The source files for these helpers must live under a ProjectDescriptionHelpers directory in the location where `Plugin`
/// manifest lives.
///
public struct Plugin: Codable, Equatable {
    /// The name of the `Plugin`.
    public let name: String
    /// Plugin executables files.
    public let executables: [PluginExecutable]
    /// Plugin workspace mapper.
    public let workspaceMapper: WorkspaceMapperPlugin?

    /// Creates a new plugin.
    /// - Parameters:
    ///     - name: The name of the plugin.
    ///     - executables: Plugin executables files.
    ///     - workspaceMapper: Plugin workspace mapper.
    public init(
        name: String, 
        executables: [PluginExecutable] = [],
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
    public let executables: [PluginExecutable]
    
    public init(name: String, executables: [PluginExecutable] = []) {
        self.name = name
        self.executables = executables
    }
    
    /// Creates a new plugin in `Config`.
    /// - Parameters:
    ///     - name: The name of the plugin.
    ///     - executables: Plugin executables files.
    public static func plugin(name: String, executables: [PluginExecutable] = []) -> Self {
        Self(name: name, executables: executables)
    }
}

/// Defining the executable file.
public struct PluginExecutable: Codable, Equatable {
    /// The name of the executable
    public let name: String
    /// Path to executable in archive
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
