extension Config {
    @frozen
    public enum Script: Codable, Equatable {
        case script(_ script: ShellScript)
        case plugin(_ plugin: ExecutablePlugin)

        public static func script(
            _ script: String,
            isErrorIgnored: Bool = false,
            shellPath: String? = nil
        ) -> Script {
            .script(
                ShellScript(script, isErrorIgnored: isErrorIgnored, shellPath: shellPath)
            )
        }

        /// Calling the executable plugin.
        public static func plugin(
            name: String,
            executable: String? = nil,
            args: [String] = []
        ) -> Script {
            .plugin(
                ExecutablePlugin(name: name, executable: executable, args: args)
            )
        }
    }
    
    public struct ShellScript: Codable, Equatable {
        /// The script to be executed with parameters.
        public let script: String
        /// An error in the execution of the script will not interrupt the phase.
        public let isErrorIgnored: Bool
        /// The path to the shell which shall execute this script. Default is current shell.
        public let shellPath: String?

        public init(
            _ script: String,
            isErrorIgnored: Bool,
            shellPath: String?
        ) {
            self.script = script
            self.isErrorIgnored = isErrorIgnored
            self.shellPath = shellPath
        }
    }

    public struct ExecutablePlugin: Codable, Equatable {
        /// Name of the plugin
        public let name: String
        /// Name of the executable file
        public let executable: String?
        /// Arguments for the executable file
        public let args: [String]

        public init(
            name: String,
            executable: String?,
            args: [String]
        ) {
            self.name = name
            self.executable = executable
            self.args = args
        }
    }
}
