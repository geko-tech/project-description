import Foundation

public typealias SettingsDictionary = [String: SettingValue]

/// A value or a collection of values used for settings configuration.
@frozen
public enum SettingValue: ExpressibleByStringInterpolation, ExpressibleByArrayLiteral, ExpressibleByBooleanLiteral, Equatable, Codable, Hashable
{
    case string(String)
    case array([String])

    public init(stringLiteral value: String) {
        self = .string(value)
    }

    public init(arrayLiteral elements: String...) {
        self = .array(elements)
    }

    public typealias BooleanLiteralType = Bool

    public init(booleanLiteral value: Bool) {
        self = .string(value ? "YES" : "NO")
    }

    public init<T>(_ stringRawRepresentable: T) where T: RawRepresentable, T.RawValue == String {
        self = .init(stringLiteral: stringRawRepresentable.rawValue)
    }
}

public struct ConfigurationSettings: Equatable, Codable {
    public var settings: SettingsDictionary
    public var xcconfig: FilePath?

    public init(settings: SettingsDictionary = [:], xcconfig: FilePath? = nil) {
        self.settings = settings
        self.xcconfig = xcconfig
    }
}

// MARK: - Configuration

/// A the build settings and the .xcconfig file of a project or target. It is initialized with either the `.debug` or `.release`
/// static method.
public struct Configuration: Equatable, Codable {
    public var buildConfiguration: BuildConfiguration
    public var settings: ConfigurationSettings

    /// Returns a debug configuration.
    ///
    /// - Parameters:
    ///   - name: The name of the configuration to use
    ///   - settings: The base build settings to apply
    ///   - xcconfig: The xcconfig file to associate with this configuration
    /// - Returns: A debug `CustomConfiguration`
    public static func debug(
        name: ConfigurationName = .debug,
        settings: SettingsDictionary = [:],
        xcconfig: FilePath? = nil
    ) -> Configuration {
        Configuration(
            buildConfiguration: BuildConfiguration(
                name: name.rawValue,
                variant: .debug
            ),
            settings: ConfigurationSettings(
                settings: settings,
                xcconfig: xcconfig
            )
        )
    }

    /// Creates a release configuration
    ///
    /// - Parameters:
    ///   - name: The name of the configuration to use
    ///   - settings: The base build settings to apply
    ///   - xcconfig: The xcconfig file to associate with this configuration
    /// - Returns: A release `CustomConfiguration`
    public static func release(
        name: ConfigurationName = .release,
        settings: SettingsDictionary = [:],
        xcconfig: FilePath? = nil
    ) -> Configuration {
        Configuration(
            buildConfiguration: BuildConfiguration(
                name: name.rawValue,
                variant: .release
            ),
            settings: ConfigurationSettings(
                settings: settings,
                xcconfig: xcconfig
            )
        )
    }
}

// MARK: - DefaultSettings

/// Specifies the default set of settings applied to all the projects and targets.
/// The default settings can be overridden via `Settings base: SettingsDictionary`
/// and `Configuration settings: SettingsDictionary`.
@frozen
public enum DefaultSettings: Codable, Equatable {
    /// Recommended settings including warning flags to help you catch some of the bugs at the early stage of development. If you
    /// need to override certain settings in a `Configuration` it's possible to add those keys to `excluding`.
    case recommended(excluding: Set<String> = [])
    /// A minimal set of settings to make the project compile without any additional settings for example `PRODUCT_NAME` or
    /// `TARGETED_DEVICE_FAMILY`. If you need to override certain settings in a Configuration it's possible to add those keys to
    /// `excluding`.
    case essential(excluding: Set<String> = [])
    /// Geko won't generate any build settings for the target or project.
    case none
}

extension DefaultSettings {
    public static var recommended: DefaultSettings {
        .recommended(excluding: [])
    }

    public static var essential: DefaultSettings {
        .essential(excluding: [])
    }
}

// MARK: - Settings

/// A group of settings configuration.
public struct Settings: Equatable, Codable {
    public static let `default` = Settings(
        configurations: [.release: nil, .debug: nil],
        defaultSettings: .recommended
    )

    /// A dictionary with build settings that are inherited from all the configurations.
    public var base: SettingsDictionary
    /// Base settings applied only for configurations of `variant == .debug`
    public var baseDebug: SettingsDictionary
    public var configurations: [BuildConfiguration: ConfigurationSettings?]
    public var defaultSettings: DefaultSettings

    init(
        base: SettingsDictionary = [:],
        baseDebug: SettingsDictionary = [:],
        configurations: [Configuration],
        defaultSettings: DefaultSettings = .recommended
    ) {
        var configurationDict: [BuildConfiguration: ConfigurationSettings?] = [:]
        for configuration in configurations {
            configurationDict[configuration.buildConfiguration] = configuration.settings
        }

        self.init(
            base: base,
            baseDebug: baseDebug,
            configurations: configurationDict,
            defaultSettings: defaultSettings
        )
    }

    public init(
        base: SettingsDictionary = [:],
        baseDebug: SettingsDictionary = [:],
        configurations: [BuildConfiguration: ConfigurationSettings?],
        defaultSettings: DefaultSettings = .recommended
    ) {
        self.base = base
        self.baseDebug = baseDebug
        self.configurations = configurations
        self.defaultSettings = defaultSettings
    }

    /// Creates settings with default.configurations `Debug` and `Release`
    ///
    /// - Parameters:
    ///   - base: A dictionary with build settings that are inherited from all the configurations.
    ///   - debug: The debug configuration settings.
    ///   - release: The release configuration settings.
    ///   - defaultSettings: An enum specifying the set of default settings.
    ///
    /// - Note: To specify custom configurations (e.g. `Debug`, `Beta` & `Release`) or to specify xcconfigs, you can use the
    /// alternate static method
    ///         `.settings(base:configurations:defaultSettings:)`
    ///
    /// - seealso: Configuration
    /// - seealso: DefaultSettings
    public static func settings(
        base: SettingsDictionary = [:],
        debug: SettingsDictionary = [:],
        release: SettingsDictionary = [:],
        defaultSettings: DefaultSettings = .recommended
    ) -> Settings {
        Settings(
            base: base,
            baseDebug: [:],
            configurations: [
                .debug: .init(settings: debug),
                .release: .init(settings: release),
            ],
            defaultSettings: defaultSettings
        )
    }

    /// Creates settings with any number of configurations.
    ///
    /// - Parameters:
    ///   - base: A dictionary with build settings that are inherited from all the configurations.
    ///   - baseDebug: A dictionary with build settings that are inherited from all debug configurations.
    ///   - configurations: A list of configurations.
    ///   - defaultSettings: An enum specifying the set of default settings.
    ///
    /// - Note: Configurations shouldn't be empty, please use the alternate static method
    ///         `.settings(base:debug:release:defaultSettings:)` to leverage the default configurations
    ///          if you don't have any custom configurations.
    ///
    /// - seealso: Configuration
    /// - seealso: DefaultSettings
    public static func settings(
        base: SettingsDictionary = [:],
        baseDebug: SettingsDictionary = [:],
        configurations: [Configuration],
        defaultSettings: DefaultSettings = .recommended
    ) -> Settings {
        Settings(
            base: base,
            baseDebug: baseDebug,
            configurations: configurations,
            defaultSettings: defaultSettings
        )
    }

    /// Creates settings with any number of configurations.
    ///
    /// - Parameters:
    ///   - base: A dictionary with build settings that are inherited from all the configurations.
    ///   - baseDebug: A dictionary with build settings that are inherited from all debug configurations.
    ///   - configurations: A dictionary of configurations.
    ///   - defaultSettings: An enum specifying the set of default settings.
    ///
    /// - Note: Configurations shouldn't be empty, please use the alternate static method
    ///         `.settings(base:debug:release:defaultSettings:)` to leverage the default configurations
    ///          if you don't have any custom configurations.
    ///
    /// - seealso: Configuration
    /// - seealso: DefaultSettings
    public static func settings(
        base: SettingsDictionary = [:],
        baseDebug: SettingsDictionary = [:],
        configurations: [BuildConfiguration: ConfigurationSettings?],
        defaultSettings: DefaultSettings = .recommended
    ) -> Settings {
        Settings(
            base: base,
            baseDebug: baseDebug,
            configurations: configurations,
            defaultSettings: defaultSettings
        )
    }
}
