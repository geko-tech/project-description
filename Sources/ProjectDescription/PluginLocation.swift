import Foundation

/// A location to a plugin, either local or remote.
public struct PluginLocation: Codable, Equatable {
    /// The type of location `local` or `git`.
    public var type: LocationType

    /// A `Path` to a directory containing a `Plugin` manifest.
    ///
    /// Example:
    /// ```swift
    /// .local(path: "/User/local/bin")
    /// ```
    public static func local(path: FilePath, manifest: PluginConfigManifest? = nil) -> Self {
        PluginLocation(type: .local(path: path, manifest: manifest))
    }

    /// A `URL` to a `git` repository pointing at a `tag`.
    /// You can also specify a custom directory in case the plugin is not located at the root of the repository.
    /// You can also specify a custom release URL from where the plugin binary should be downloaded. If not specified,
    /// it defaults to the GitHub release URL. Note that the URL should be publicly reachable.
    ///
    /// Example:
    /// ```swift
    /// .git(url: "https://git/plugin.git", tag: "1.0.0", directory: "PluginDirectory")
    /// ```
    public static func git(url: String, tag: String, directory: String? = nil) -> Self {
        PluginLocation(type: .gitWithTag(url: url, tag: tag, directory: directory))
    }

    /// A `URL` to a `git` repository pointing at a commit `sha`.
    /// You can also specify a custom directory in case the plugin is not located at the root of the repository.
    ///
    /// Example:
    /// ```swift
    /// .git(url: "https://git/plugin.git", sha: "d06b4b3d")
    /// ```
    public static func git(url: String, sha: String, directory: String? = nil) -> Self {
        PluginLocation(type: .gitWithSha(url: url, sha: sha, directory: directory))
    }

    /// Use remote archive with the plugin.
    ///
    /// Example:
    /// ```swift
    /// .remote(url: "https://s3.example.com/bucket/GekoPlugin/1.0.2/GekoPlugin.macos.geko-plugin.zip"),
    ///
    /// .remote(
    ///     url: "https://s3.example.com/bucket/SomeArchive/2.5.0/SomeArchive.xcframework.zip",
    ///     manifest: .plugin(
    ///        name: "some_util",
    ///        executables: [
    ///            .init(name: "some_util", path: "some_util/bin"),
    ///        ]
    ///    )
    ///),
    /// ```
    public static func remote(url: String, manifest: PluginConfigManifest) -> PluginLocation {
        PluginLocation(type: .remote(urls: [.macos: url], manifest: manifest))
    }

    /// Use remote plugin archive with different operating systems support.
    ///
    /// Example:
    /// ```swift
    /// .remote(urls: [
    ///     .macos: "https://s3.example.com/bucket/GekoPlugin/1.0.2/GekoPlugin.macos.geko-plugin.zip"),
    ///     .linux("aarch64"): "https://s3.example.com/bucket/GekoPlugin/1.0.2/GekoPlugin.linux.aarch64.geko-plugin.zip"),
    ///  ]),
    ///
    /// .remote(
    ///     urls: [
    ///         .macos: "https://s3.example.com/bucket/GekoPlugin/1.0.2/GekoPlugin.macos.geko-plugin.zip"),
    ///         .linux("aarch64"): "https://s3.example.com/bucket/GekoPlugin/1.0.2/GekoPlugin.linux.aarch64.geko-plugin.zip"),
    ///     ],
    ///     manifest: .plugin(
    ///        name: "some_util",
    ///        executables: [
    ///            .init(name: "some_util", path: "some_util/bin"),
    ///        ]
    ///    )
    ///),
    /// ```
    public static func remote(urls: [PluginOS: String], manifest: PluginConfigManifest) -> PluginLocation {
        PluginLocation(type: .remote(urls: urls, manifest: manifest))
    }

    /// Use remote archive with the plugin.
    ///
    /// Example:
    /// ```swift
    /// // https://s3.example.com/bucket/GekoPlugin/1.0.2/GekoPlugin.macos.geko-plugin.zip
    /// .remote(baseUrl: "https://s3.example.com/bucket", name: "GekoPlugin", version: "1.0.2"),
    /// ```
    public static func remote(baseUrl: String, name: String, version: String, os: [PluginOS] = [.macos]) -> PluginLocation {
        let osAndUrl = os.map { os in
            switch os {
            case let .linux(arch: arch):
                (os, "\(baseUrl)/\(name)/\(version)/\(name).linux.\(arch).geko-plugin.zip")
            case .macos:
                (os, "\(baseUrl)/\(name)/\(version)/\(name).\(os).geko-plugin.zip")
            }
        }
        let urls = Dictionary(uniqueKeysWithValues: osAndUrl)
        return PluginLocation(type: .remoteGekoArchive(GekoArchive(baseUrl: baseUrl,
                                                                   name: name,
                                                                   version: version,
                                                                   urls: urls)))
    }
}

// MARK: - Codable

extension PluginLocation {
    @frozen
    public enum LocationType: Codable, Equatable {
        case local(path: FilePath, manifest: PluginConfigManifest?)
        case gitWithTag(url: String, tag: String, directory: String?)
        case gitWithSha(url: String, sha: String, directory: String?)
        case remote(urls: [PluginOS: String], manifest: PluginConfigManifest)
        case remoteGekoArchive(GekoArchive)
    }

    public struct GekoArchive: Codable, Equatable {
        public let baseUrl: String
        public let name: String
        public let version: String
        public let urls: [PluginOS: String]
    }
}

// MARK: - CustomStringConvertible

extension PluginLocation: CustomStringConvertible {
    public var description: String {
        switch self.type {
        case let .local(path, _):
            return "local path: \(path)"
        case let .gitWithTag(url, tag, directory):
            return "git url: \(url), tag: \(tag), directory: \(directory ?? "nil"))"
        case let .gitWithSha(url, sha, directory):
            return "git url: \(url), sha: \(sha), directory: \(directory ?? "nil"))"
        case let .remote(urls, _):
            return "remote url: \(urls[.current] ?? "no url for current OS")"
        case let .remoteGekoArchive(archive):
            return "archive url: \(archive.urls[.current] ?? "no url for current OS")"
        }
    }
}
