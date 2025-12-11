import Foundation

/// Dependency status used by dependencies
@frozen
public enum LinkingStatus: String, Codable, Hashable {
    /// Required dependency
    case required

    /// Optional dependency (weakly linked)
    case optional

    /// Skip linking
    case none
}

/// Dependency type used by `.sdk` target dependencies
@frozen
public enum SDKType: String, Codable, Hashable {
    /// Library SDK dependency
    case library

    /// Framework SDK dependency
    case framework
}

/// A target dependency.
@frozen
public enum TargetDependency: Codable, Hashable {
    /// Dependency on another target within the same project
    ///
    /// - Parameters:
    ///   - name: Name of the target to depend on
    ///   - status: The dependency status (optional dependencies are weakly linked)
    ///   - condition: condition under which to use this dependency, `nil` if this should always be used
    case target(name: String, status: LinkingStatus = .required, condition: PlatformCondition? = nil)

    /// Dependency on a local target from another project
    ///
    /// - Parameters:
    ///   - name: Name of the target to depend on
    ///   - condition: condition under which to use this dependency, `nil` if this should always be used
    case local(name: String, status: LinkingStatus = .required, condition: PlatformCondition? = nil)

    /// Dependency on a target within another project
    ///
    /// - Parameters:
    ///   - target: Name of the target to depend on
    ///   - path: Relative path to the other project directory
    ///   - status: The dependency status (optional dependencies are weakly linked)
    ///   - condition: condition under which to use this dependency, `nil` if this should always be used
    case project(target: String, path: FilePath, status: LinkingStatus = .required, condition: PlatformCondition? = nil)

    /// Dependency on a prebuilt framework
    ///
    /// - Parameters:
    ///   - path: Relative path to the prebuilt framework
    ///   - status: The dependency status (optional dependencies are weakly linked)
    ///   - condition: condition under which to use this dependency, `nil` if this should always be used
    case framework(path: FilePath, status: LinkingStatus = .required, condition: PlatformCondition? = nil)

    /// Dependency on prebuilt library
    ///
    /// - Parameters:
    ///   - path: Relative path to the prebuilt library
    ///   - publicHeaders: Relative path to the library's public headers directory
    ///   - swiftModuleMap: Relative path to the library's swift module map file
    ///   - condition: condition under which to use this dependency, `nil` if this should always be used
    case library(path: FilePath, publicHeaders: FilePath, swiftModuleMap: FilePath?, condition: PlatformCondition? = nil)

    /// Dependency on system library or framework
    ///
    /// - Parameters:
    ///   - name: Name of the system library or framework (not including extension)
    ///            e.g. `ARKit`, `c++`
    ///   - type: The dependency type
    ///   - status: The dependency status (optional dependencies are weakly linked)
    ///   - condition: condition under which to use this dependency, `nil` if this should always be used
    case sdk(name: String, type: SDKType, status: LinkingStatus, condition: PlatformCondition? = nil)

    /// Dependency on a xcframework
    ///
    /// - Parameters:
    ///   - path: Relative path to the xcframework
    ///   - status: The dependency status (optional dependencies are weakly linked)
    ///   - condition: condition under which to use this dependency, `nil` if this should always be used
    case xcframework(path: FilePath, status: LinkingStatus = .required, condition: PlatformCondition? = nil)

    case bundle(path: FilePath, condition: PlatformCondition? = nil)

    /// Dependency on XCTest.
    case xctest

    /// Dependency on an external dependency imported through `Dependencies.swift`.
    ///
    /// - Parameters:
    ///   - name: Name of the external dependency
    ///   - condition: condition under which to use this dependency, `nil` if this should always be used
    case external(name: String, condition: PlatformCondition? = nil)

    /// Dependency on system library or framework
    ///
    /// - Parameters:
    ///   - name: Name of the system library or framework (including extension)
    ///            e.g. `ARKit.framework`, `libc++.tbd`
    ///   - type: Whether or not this dependecy is required. Defaults to `.required`
    ///   - condition: condition under which to use this dependency, `nil` if this should always be used
    public static func sdk(name: String, type: SDKType, condition: PlatformCondition? = nil) -> TargetDependency {
        .sdk(name: name, type: type, status: .required, condition: condition)
    }

    /// Dependency on another target within the same project. This is just syntactic sugar for `.target(name: target.name)`.
    ///
    /// - Parameters:
    ///   - target: Instance of the target to depend on
    ///   - condition: condition under which to use this dependency, `nil` if this should always be used
    public static func target(_ target: Target, condition: PlatformCondition? = nil) -> TargetDependency {
        .target(name: target.name, condition: condition)
    }

    public var typeName: String {
        switch self {
        case .target:
            return "target"
        case .local:
            return "local"
        case .project:
            return "project"
        case .framework:
            return "framework"
        case .library:
            return "library"
        case .sdk:
            return "sdk"
        case .xcframework:
            return "xcframework"
        case .bundle:
            return "bundle"
        case .xctest:
            return "xctest"
        case .external:
            return "external"
        }
    }
}
