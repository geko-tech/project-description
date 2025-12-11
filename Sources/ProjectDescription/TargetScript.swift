import Foundation

/// A build phase action used to run a script.
///
/// Target scripts, represented as target script build phases in the generated Xcode projects, are useful to define actions to be
/// executed before of after the build process of a target.
public struct TargetScript: Codable, Equatable { // swiftlint:disable:this type_body_length
    /// Order when the script gets executed.
    ///
    /// - pre: Before the sources and resources build phase.
    /// - post: After the sources and resources build phase.
    @frozen
    public enum Order: String, Codable, Equatable {
        case pre
        case post
    }

    /// Specifies how to execute the target script
    ///
    /// - tool: Executes the tool with the given arguments. Geko will look up the tool on the environment's PATH.
    /// - scriptPath: Executes the file at the path with the given arguments.
    /// - text: Executes the embedded script. This should be a short command.
    @frozen
    public enum Script: Equatable, Codable {
        case tool(path: String, args: [String] = [])
        case scriptPath(path: FilePath, args: [String] = [])
        case embedded(String)
    }

    /// Name of the build phase when the project gets generated.
    public var name: String

    /// The script that is to be executed
    public var script: Script

    /// Target script order.
    public var order: Order

    /// List of input file paths
    public var inputPaths: FileList

    /// List of input filelist paths
    public var inputFileListPaths: [FilePath]

    /// List of output file paths
    public var outputPaths: FileList

    /// List of output filelist paths
    public var outputFileListPaths: [FilePath]

    /// Show environment variables in the logs
    public var showEnvVarsInLog: Bool

    /// Whether to skip running this script in incremental builds, if nothing has changed
    public var basedOnDependencyAnalysis: Bool?

    /// Whether this script only runs on install builds (default is false)
    public var runForInstallBuildsOnly: Bool

    /// The path to the shell which shall execute this script.
    public var shellPath: String

    /// The path to the dependency file
    public var dependencyFile: FilePath?

    /// Creates the target script with its attributes.
    ///
    /// - Parameters:
    ///   - name: Name of the build phase when the project gets generated.
    ///   - script: The script to be executed.
    ///   - order: Target script order
    ///   - inputPaths: Glob pattern to the files.
    ///   - inputFileListPaths: List of input filelist paths.
    ///   - outputPaths: List of output file paths.
    ///   - outputFileListPaths: List of output filelist paths.
    ///   - showEnvVarsInLog: Show environment variables in the logs
    ///   - basedOnDependencyAnalysis: Whether to skip running this script in incremental builds
    ///   - runForInstallBuildsOnly: Whether this script only runs on install builds (default is false)
    ///   - shellPath: The path to the shell which shall execute this script. Default is `/bin/sh`.
    ///   - dependencyFile: The path to the dependency file. Default is `nil`.
    public init(
        name: String,
        order: Order,
        script: Script = .embedded(""),
        inputPaths: FileList = [],
        inputFileListPaths: [FilePath] = [],
        outputPaths: FileList = [],
        outputFileListPaths: [FilePath] = [],
        showEnvVarsInLog: Bool = true,
        basedOnDependencyAnalysis: Bool? = nil,
        runForInstallBuildsOnly: Bool = false,
        shellPath: String = "/bin/sh",
        dependencyFile: FilePath? = nil
    ) {
        self.name = name
        self.script = script
        self.order = order
        self.inputPaths = inputPaths
        self.inputFileListPaths = inputFileListPaths
        self.outputPaths = outputPaths
        self.outputFileListPaths = outputFileListPaths
        self.showEnvVarsInLog = showEnvVarsInLog
        self.basedOnDependencyAnalysis = basedOnDependencyAnalysis
        self.runForInstallBuildsOnly = runForInstallBuildsOnly
        self.shellPath = shellPath
        self.dependencyFile = dependencyFile
    }

    // MARK: - FilePath init

    /// Returns a target script that gets executed before the sources and resources build phase.
    ///
    /// - Parameters:
    ///   - path: FilePath to the script to execute.
    ///   - arguments: Arguments that to be passed.
    ///   - name: Name of the build phase when the project gets generated.
    ///   - inputPaths: Glob pattern to the files.
    ///   - inputFileListPaths: List of input filelist paths.
    ///   - outputPaths: List of output file paths.
    ///   - outputFileListPaths: List of output filelist paths.
    ///   - basedOnDependencyAnalysis: Whether to skip running this script in incremental builds
    ///   - runForInstallBuildsOnly: Whether this script only runs on install builds (default is false)
    ///   - shellPath: The path to the shell which shall execute this script. Default is `/bin/sh`.
    ///   - dependencyFile: The path to the dependency file. Default is `nil`.
    /// - Returns: Target script.
    public static func pre(
        path: FilePath,
        arguments: String...,
        name: String,
        inputPaths: FileList = [],
        inputFileListPaths: [FilePath] = [],
        outputPaths: FileList = [],
        outputFileListPaths: [FilePath] = [],
        showEnvVarsInLog: Bool = true,
        basedOnDependencyAnalysis: Bool? = nil,
        runForInstallBuildsOnly: Bool = false,
        shellPath: String = "/bin/sh",
        dependencyFile: FilePath? = nil
    ) -> TargetScript {
        TargetScript(
            name: name,
            order: .pre,
            script: .scriptPath(path: path, args: arguments),
            inputPaths: inputPaths,
            inputFileListPaths: inputFileListPaths,
            outputPaths: outputPaths,
            outputFileListPaths: outputFileListPaths,
            showEnvVarsInLog: showEnvVarsInLog,
            basedOnDependencyAnalysis: basedOnDependencyAnalysis,
            runForInstallBuildsOnly: runForInstallBuildsOnly,
            shellPath: shellPath,
            dependencyFile: dependencyFile
        )
    }

    /// Returns a target script that gets executed before the sources and resources build phase.
    ///
    /// - Parameters:
    ///   - path: FilePath to the script to execute.
    ///   - arguments: Arguments that to be passed.
    ///   - name: Name of the build phase when the project gets generated.
    ///   - inputPaths: Glob pattern to the files.
    ///   - inputFileListPaths: List of input filelist paths.
    ///   - outputPaths: List of output file paths.
    ///   - outputFileListPaths: List of output filelist paths.
    ///   - basedOnDependencyAnalysis: Whether to skip running this script in incremental builds
    ///   - runForInstallBuildsOnly: Whether this script only runs on install builds (default is false)
    ///   - shellPath: The path to the shell which shall execute this script. Default is `/bin/sh`.
    ///   - dependencyFile: The path to the dependency file. Default is `nil`.
    /// - Returns: Target script.
    public static func pre(
        path: FilePath,
        arguments: [String],
        name: String,
        inputPaths: FileList = [],
        inputFileListPaths: [FilePath] = [],
        outputPaths: FileList = [],
        outputFileListPaths: [FilePath] = [],
        showEnvVarsInLog: Bool = true,
        basedOnDependencyAnalysis: Bool? = nil,
        runForInstallBuildsOnly: Bool = false,
        shellPath: String = "/bin/sh",
        dependencyFile: FilePath? = nil
    ) -> TargetScript {
        TargetScript(
            name: name,
            order: .pre,
            script: .scriptPath(path: path, args: arguments),
            inputPaths: inputPaths,
            inputFileListPaths: inputFileListPaths,
            outputPaths: outputPaths,
            outputFileListPaths: outputFileListPaths,
            showEnvVarsInLog: showEnvVarsInLog,
            basedOnDependencyAnalysis: basedOnDependencyAnalysis,
            runForInstallBuildsOnly: runForInstallBuildsOnly,
            shellPath: shellPath,
            dependencyFile: dependencyFile
        )
    }

    /// Returns a target script that gets executed after the sources and resources build phase.
    ///
    /// - Parameters:
    ///   - path: FilePath to the script to execute.
    ///   - arguments: Arguments that to be passed.
    ///   - name: Name of the build phase when the project gets generated.
    ///   - inputPaths: Glob pattern to the files.
    ///   - inputFileListPaths: List of input filelist paths.
    ///   - outputPaths: List of output file paths.
    ///   - outputFileListPaths: List of output filelist paths.
    ///   - basedOnDependencyAnalysis: Whether to skip running this script in incremental builds
    ///   - runForInstallBuildsOnly: Whether this script only runs on install builds (default is false)
    ///   - shellPath: The path to the shell which shall execute this script. Default is `/bin/sh`.
    ///   - dependencyFile: The path to the dependency file. Default is `nil`.
    /// - Returns: Target script.
    public static func post(
        path: FilePath,
        arguments: String...,
        name: String,
        inputPaths: FileList = [],
        inputFileListPaths: [FilePath] = [],
        outputPaths: FileList = [],
        outputFileListPaths: [FilePath] = [],
        showEnvVarsInLog: Bool = true,
        basedOnDependencyAnalysis: Bool? = nil,
        runForInstallBuildsOnly: Bool = false,
        shellPath: String = "/bin/sh",
        dependencyFile: FilePath? = nil
    ) -> TargetScript {
        TargetScript(
            name: name,
            order: .post,
            script: .scriptPath(path: path, args: arguments),
            inputPaths: inputPaths,
            inputFileListPaths: inputFileListPaths,
            outputPaths: outputPaths,
            outputFileListPaths: outputFileListPaths,
            showEnvVarsInLog: showEnvVarsInLog,
            basedOnDependencyAnalysis: basedOnDependencyAnalysis,
            runForInstallBuildsOnly: runForInstallBuildsOnly,
            shellPath: shellPath,
            dependencyFile: dependencyFile
        )
    }

    /// Returns a target script that gets executed after the sources and resources build phase.
    ///
    /// - Parameters:
    ///   - path: FilePath to the script to execute.
    ///   - arguments: Arguments that to be passed.
    ///   - name: Name of the build phase when the project gets generated.
    ///   - inputPaths: Glob pattern to the files.
    ///   - inputFileListPaths: List of input filelist paths.
    ///   - outputPaths: List of output file paths.
    ///   - outputFileListPaths: List of output filelist paths.
    ///   - basedOnDependencyAnalysis: Whether to skip running this script in incremental builds
    ///   - runForInstallBuildsOnly: Whether this script only runs on install builds (default is false)
    ///   - shellPath: The path to the shell which shall execute this script. Default is `/bin/sh`.
    ///   - dependencyFile: The path to the dependency file. Default is `nil`.
    /// - Returns: Target script.
    public static func post(
        path: FilePath,
        arguments: [String],
        name: String,
        inputPaths: FileList = [],
        inputFileListPaths: [FilePath] = [],
        outputPaths: FileList = [],
        outputFileListPaths: [FilePath] = [],
        showEnvVarsInLog: Bool = true,
        basedOnDependencyAnalysis: Bool? = nil,
        runForInstallBuildsOnly: Bool = false,
        shellPath: String = "/bin/sh",
        dependencyFile: FilePath? = nil
    ) -> TargetScript {
        TargetScript(
            name: name,
            order: .post,
            script: .scriptPath(path: path, args: arguments),
            inputPaths: inputPaths,
            inputFileListPaths: inputFileListPaths,
            outputPaths: outputPaths,
            outputFileListPaths: outputFileListPaths,
            showEnvVarsInLog: showEnvVarsInLog,
            basedOnDependencyAnalysis: basedOnDependencyAnalysis,
            runForInstallBuildsOnly: runForInstallBuildsOnly,
            shellPath: shellPath,
            dependencyFile: dependencyFile
        )
    }

    // MARK: - Tools init

    /// Returns a target script that gets executed before the sources and resources build phase.
    ///
    /// - Parameters:
    ///   - tool: Name of the tool to execute. Geko will look up the tool on the environment's PATH.
    ///   - arguments: Arguments that to be passed.
    ///   - name: Name of the build phase when the project gets generated.
    ///   - inputPaths: Glob pattern to the files.
    ///   - inputFileListPaths: List of input filelist paths.
    ///   - outputPaths: List of output file paths.
    ///   - outputFileListPaths: List of output filelist paths.
    ///   - basedOnDependencyAnalysis: Whether to skip running this script in incremental builds
    ///   - runForInstallBuildsOnly: Whether this script only runs on install builds (default is false)
    ///   - shellPath: The path to the shell which shall execute this script. Default is `/bin/sh`.
    ///   - dependencyFile: The path to the dependency file. Default is `nil`.
    /// - Returns: Target script.
    public static func pre(
        tool: String,
        arguments: String...,
        name: String,
        inputPaths: FileList = [],
        inputFileListPaths: [FilePath] = [],
        outputPaths: FileList = [],
        outputFileListPaths: [FilePath] = [],
        showEnvVarsInLog: Bool = true,
        basedOnDependencyAnalysis: Bool? = nil,
        runForInstallBuildsOnly: Bool = false,
        shellPath: String = "/bin/sh",
        dependencyFile: FilePath? = nil
    ) -> TargetScript {
        TargetScript(
            name: name,
            order: .pre,
            script: .tool(path: tool, args: arguments),
            inputPaths: inputPaths,
            inputFileListPaths: inputFileListPaths,
            outputPaths: outputPaths,
            outputFileListPaths: outputFileListPaths,
            showEnvVarsInLog: showEnvVarsInLog,
            basedOnDependencyAnalysis: basedOnDependencyAnalysis,
            runForInstallBuildsOnly: runForInstallBuildsOnly,
            shellPath: shellPath,
            dependencyFile: dependencyFile
        )
    }

    /// Returns a target script that gets executed before the sources and resources build phase.
    ///
    /// - Parameters:
    ///   - tool: Name of the tool to execute. Geko will look up the tool on the environment's PATH.
    ///   - arguments: Arguments that to be passed.
    ///   - name: Name of the build phase when the project gets generated.
    ///   - inputPaths: Glob pattern to the files.
    ///   - inputFileListPaths: List of input filelist paths.
    ///   - outputPaths: List of output file paths.
    ///   - outputFileListPaths: List of output filelist paths.
    ///   - basedOnDependencyAnalysis: Whether to skip running this script in incremental builds
    ///   - runForInstallBuildsOnly: Whether this script only runs on install builds (default is false)
    ///   - shellPath: The path to the shell which shall execute this script. Default is `/bin/sh`.
    ///   - dependencyFile: The path to the dependency file. Default is `nil`.
    /// - Returns: Target script.
    public static func pre(
        tool: String,
        arguments: [String],
        name: String,
        inputPaths: FileList = [],
        inputFileListPaths: [FilePath] = [],
        outputPaths: FileList = [],
        outputFileListPaths: [FilePath] = [],
        showEnvVarsInLog: Bool = true,
        basedOnDependencyAnalysis: Bool? = nil,
        runForInstallBuildsOnly: Bool = false,
        shellPath: String = "/bin/sh",
        dependencyFile: FilePath? = nil
    ) -> TargetScript {
        TargetScript(
            name: name,
            order: .pre,
            script: .tool(path: tool, args: arguments),
            inputPaths: inputPaths,
            inputFileListPaths: inputFileListPaths,
            outputPaths: outputPaths,
            outputFileListPaths: outputFileListPaths,
            showEnvVarsInLog: showEnvVarsInLog,
            basedOnDependencyAnalysis: basedOnDependencyAnalysis,
            runForInstallBuildsOnly: runForInstallBuildsOnly,
            shellPath: shellPath,
            dependencyFile: dependencyFile
        )
    }

    /// Returns a target script that gets executed after the sources and resources build phase.
    ///
    /// - Parameters:
    ///   - tool: Name of the tool to execute. Geko will look up the tool on the environment's PATH.
    ///   - arguments: Arguments that to be passed.
    ///   - name: Name of the build phase when the project gets generated.
    ///   - inputPaths: Glob pattern to the files.
    ///   - inputFileListPaths: List of input filelist paths.
    ///   - outputPaths: List of output file paths.
    ///   - outputFileListPaths: List of output filelist paths.
    ///   - basedOnDependencyAnalysis: Whether to skip running this script in incremental builds
    ///   - runForInstallBuildsOnly: Whether this script only runs on install builds (default is false)
    ///   - shellPath: The path to the shell which shall execute this script. Default is `/bin/sh`.
    ///   - dependencyFile: The path to the dependency file. Default is `nil`.
    /// - Returns: Target script.
    public static func post(
        tool: String,
        arguments: String...,
        name: String,
        inputPaths: FileList = [],
        inputFileListPaths: [FilePath] = [],
        outputPaths: FileList = [],
        outputFileListPaths: [FilePath] = [],
        showEnvVarsInLog: Bool = true,
        basedOnDependencyAnalysis: Bool? = nil,
        runForInstallBuildsOnly: Bool = false,
        shellPath: String = "/bin/sh",
        dependencyFile: FilePath? = nil
    ) -> TargetScript {
        TargetScript(
            name: name,
            order: .post,
            script: .tool(path: tool, args: arguments),
            inputPaths: inputPaths,
            inputFileListPaths: inputFileListPaths,
            outputPaths: outputPaths,
            outputFileListPaths: outputFileListPaths,
            showEnvVarsInLog: showEnvVarsInLog,
            basedOnDependencyAnalysis: basedOnDependencyAnalysis,
            runForInstallBuildsOnly: runForInstallBuildsOnly,
            shellPath: shellPath,
            dependencyFile: dependencyFile
        )
    }

    /// Returns a target script that gets executed after the sources and resources build phase.
    ///
    /// - Parameters:
    ///   - tool: Name of the tool to execute. Geko will look up the tool on the environment's PATH.
    ///   - arguments: Arguments that to be passed.
    ///   - name: Name of the build phase when the project gets generated.
    ///   - inputPaths: Glob pattern to the files.
    ///   - inputFileListPaths: List of input filelist paths.
    ///   - outputPaths: List of output file paths.
    ///   - outputFileListPaths: List of output filelist paths.
    ///   - basedOnDependencyAnalysis: Whether to skip running this script in incremental builds
    ///   - runForInstallBuildsOnly: Whether this script only runs on install builds (default is false)
    ///   - shellPath: The path to the shell which shall execute this script. Default is `/bin/sh`.
    ///   - dependencyFile: The path to the dependency file. Default is `nil`.
    /// - Returns: Target script.
    public static func post(
        tool: String,
        arguments: [String],
        name: String,
        inputPaths: FileList = [],
        inputFileListPaths: [FilePath] = [],
        outputPaths: FileList = [],
        outputFileListPaths: [FilePath] = [],
        showEnvVarsInLog: Bool = true,
        basedOnDependencyAnalysis: Bool? = nil,
        runForInstallBuildsOnly: Bool = false,
        shellPath: String = "/bin/sh",
        dependencyFile: FilePath? = nil
    ) -> TargetScript {
        TargetScript(
            name: name,
            order: .post,
            script: .tool(path: tool, args: arguments),
            inputPaths: inputPaths,
            inputFileListPaths: inputFileListPaths,
            outputPaths: outputPaths,
            outputFileListPaths: outputFileListPaths,
            showEnvVarsInLog: showEnvVarsInLog,
            basedOnDependencyAnalysis: basedOnDependencyAnalysis,
            runForInstallBuildsOnly: runForInstallBuildsOnly,
            shellPath: shellPath,
            dependencyFile: dependencyFile
        )
    }

    // MARK: Embedded script init

    /// Returns a target script that gets executed before the sources and resources build phase.
    ///
    /// - Parameters:
    ///   - script: The text of the script to run. This should be kept small.
    ///   - arguments: Arguments that to be passed.
    ///   - name: Name of the build phase when the project gets generated.
    ///   - inputPaths: Glob pattern to the files.
    ///   - inputFileListPaths: List of input filelist paths.
    ///   - outputPaths: List of output file paths.
    ///   - outputFileListPaths: List of output filelist paths.
    ///   - basedOnDependencyAnalysis: Whether to skip running this script in incremental builds
    ///   - runForInstallBuildsOnly: Whether this script only runs on install builds (default is false)
    ///   - shellPath: The path to the shell which shall execute this script. Default is `/bin/sh`.
    ///   - dependencyFile: The path to the dependency file. Default is `nil`.
    /// - Returns: Target script.
    public static func pre(
        script: String,
        name: String,
        inputPaths: FileList = [],
        inputFileListPaths: [FilePath] = [],
        outputPaths: FileList = [],
        outputFileListPaths: [FilePath] = [],
        showEnvVarsInLog: Bool = true,
        basedOnDependencyAnalysis: Bool? = nil,
        runForInstallBuildsOnly: Bool = false,
        shellPath: String = "/bin/sh",
        dependencyFile: FilePath? = nil
    ) -> TargetScript {
        TargetScript(
            name: name,
            order: .pre,
            script: .embedded(script),
            inputPaths: inputPaths,
            inputFileListPaths: inputFileListPaths,
            outputPaths: outputPaths,
            outputFileListPaths: outputFileListPaths,
            showEnvVarsInLog: showEnvVarsInLog,
            basedOnDependencyAnalysis: basedOnDependencyAnalysis,
            runForInstallBuildsOnly: runForInstallBuildsOnly,
            shellPath: shellPath,
            dependencyFile: dependencyFile
        )
    }

    /// Returns a target script that gets executed after the sources and resources build phase.
    ///
    /// - Parameters:
    ///   - script: The script to be executed.
    ///   - name: Name of the build phase when the project gets generated.
    ///   - inputPaths: Glob pattern to the files.
    ///   - inputFileListPaths: List of input filelist paths.
    ///   - outputPaths: List of output file paths.
    ///   - outputFileListPaths: List of output filelist paths.
    ///   - basedOnDependencyAnalysis: Whether to skip running this script in incremental builds
    ///   - runForInstallBuildsOnly: Whether this script only runs on install builds (default is false)
    ///   - shellPath: The path to the shell which shall execute this script. Default is `/bin/sh`.
    ///   - dependencyFile: The path to the dependency file. Default is `nil`.
    /// - Returns: Target script.
    public static func post(
        script: String,
        name: String,
        inputPaths: FileList = [],
        inputFileListPaths: [FilePath] = [],
        outputPaths: FileList = [],
        outputFileListPaths: [FilePath] = [],
        showEnvVarsInLog: Bool = true,
        basedOnDependencyAnalysis: Bool? = nil,
        runForInstallBuildsOnly: Bool = false,
        shellPath: String = "/bin/sh",
        dependencyFile: FilePath? = nil
    ) -> TargetScript {
        TargetScript(
            name: name,
            order: .post,
            script: .embedded(script),
            inputPaths: inputPaths,
            inputFileListPaths: inputFileListPaths,
            outputPaths: outputPaths,
            outputFileListPaths: outputFileListPaths,
            showEnvVarsInLog: showEnvVarsInLog,
            basedOnDependencyAnalysis: basedOnDependencyAnalysis,
            runForInstallBuildsOnly: runForInstallBuildsOnly,
            shellPath: shellPath,
            dependencyFile: dependencyFile
        )
    }
}
