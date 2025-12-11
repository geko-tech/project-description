import Foundation

@resultBuilder
public struct DictionaryBuilder<Key: Hashable, Value> {
    public static func buildBlock(_ dictionaries: Dictionary<Key, Value>...) -> Dictionary<Key, Value> {
        dictionaries.reduce(into: [:]) {
            $0.merge($1) { _, new in new }
        }
    }

    public static func buildOptional(_ dictionary: Dictionary<Key, Value>?) -> Dictionary<Key, Value> {
        dictionary ?? [:]
    }

    public static func buildExpression(_ dictionary: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        dictionary
    }

    public static func buildEither(first dictionary: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        dictionary
    }

    public static func buildEither(second dictionary: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        dictionary
    }
}

public extension Dictionary {
    init(@DictionaryBuilder<Key, Value> build: () -> Self) {
        self = build()
    }
}
