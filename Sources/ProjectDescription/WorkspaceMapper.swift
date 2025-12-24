import Foundation

public struct WorkspaceMapper: Codable, Equatable {
    /// Plugin name.
    public let name: String
    /// Parameters for workspace mapper.
    public let params: [String: String]
    
    public init(
        name: String,
        params: [String: String] = [:]
    ) {
        self.name = name
        self.params = params
    }
}

/// Helper protocol for serializing and deserializing [Workspace Mapper Plugin parameters](workspacemapper_plugin#Typing-plugin-parameters).
public protocol WorkspaceMapperParameter: Codable {}

public extension WorkspaceMapperParameter {

    /// Serializes the model to a JSON string.
    func toJSONString() -> String {
        let encoder = JSONEncoder()
        guard
            let data = try? encoder.encode(self),
            let result = String(data: data, encoding: .utf8)
        else { 
            fatalError("Cannot to encode \(Self.self)")
        }
        return result
    }

    /// Deserializes the model from a JSON string.
    static func fromJSONString(_ string: String?) throws -> Self? {
        guard
            let string = string,
            let data = string.data(using: .utf8)
        else { return nil }
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}