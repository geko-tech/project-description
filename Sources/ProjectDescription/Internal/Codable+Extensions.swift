import Foundation

extension KeyedEncodingContainer {
    @inlinable
    mutating func encodeIfNotEmpty<T: Collection & Encodable>(
        _ value: T,
        forKey key: KeyedEncodingContainer<K>.Key
    ) throws {
        guard !value.isEmpty else { return }
        try encode(value, forKey: key)
    }

    @inlinable
    mutating func encodeIfNotNil<T: Encodable>(
        _ value: Optional<T>,
        forKey key: KeyedEncodingContainer<K>.Key
    ) throws {
        guard let value else { return }
        try encode(value, forKey: key)
    }
}
