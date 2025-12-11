import Foundation

@frozen
public enum BinaryArchitecture: String, Codable, Equatable, CaseIterable {
    case x8664 = "x86_64"
    case i386
    case armv7
    case armv7s
    case arm64
    case armv7k
    case arm6432 = "arm64_32"
    case arm64e
}
