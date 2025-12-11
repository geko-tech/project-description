import Foundation

/// A cloud configuration, used for remote caching.
public struct Cloud: Codable, Hashable {
    /// The base URL that points to the s3 server.
    public let url: String

    /// The bucket unique identifier.
    public let bucket: String

    /// Returns a generic cloud configuration.
    /// - Parameters:
    ///   - projectId: Project unique identifier.
    ///   - url: Base URL to the Cloud server.
    /// - Returns: A Cloud instance.
    public static func cloud(bucket: String, url: String) -> Cloud {
        Cloud(url: url, bucket: bucket)
    }
}
