import Foundation

public struct WorkspaceMapper: Codable, Equatable {
    /// Plugin name.
    public let name: String
    /// Params for mapper.
    public let params: [String: String]
    
    public init(
        name: String,
        params: [String: String] = [:]
    ) {
        self.name = name
        self.params = params
    }
}

public protocol WorkspaceMapperParameter: Codable {}

public extension WorkspaceMapperParameter {

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

    static func fromJSONString(_ string: String?) throws -> Self? {
        guard
            let string = string,
            let data = string.data(using: .utf8)
        else { return nil }
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}