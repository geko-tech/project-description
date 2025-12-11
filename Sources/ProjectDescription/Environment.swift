import Foundation

@frozen
public enum Env {
    private static let trueValues: Set<String> = ["1", "true", "TRUE", "yes", "YES"]
    private static let falseValues: Set<String> = ["0", "false", "FALSE", "no", "NO"]

    public static subscript(_ key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }

    public static subscript(bool key: String) -> Bool? {
        bool(key)
    }

    public static func string(_ key: String) -> String? {
        Self[key]
    }

    public static func bool(_ key: String) -> Bool? {
        guard let value = Self[key] else { return nil }

        if trueValues.contains(value) {
            return true
        } else if falseValues.contains(value) {
            return false
        }

        return nil
    }

    public static func int(_ key: String) -> Int? {
        guard let value = Self[key] else { return nil }

        return Int(value)
    }
}
