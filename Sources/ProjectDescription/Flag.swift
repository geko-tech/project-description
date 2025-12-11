import Foundation

private let prefix = "GEKO_MANIFEST_FLAG_"

@frozen
public enum Flag {
    public static subscript(_ key: String) -> Bool {
        flag(key)
    }

    public static func flag(_ key: String) -> Bool {
        let env = "\(prefix)\(key)"
        return ProcessInfo.processInfo.environment[env] == "true"
    }

    public static func allFlags() -> Set<String> {
        var result: Set<String> = []

        for var env in ProcessInfo.processInfo.environment.keys {
            guard env.starts(with: prefix) else { continue }

            env.removeFirst(prefix.count)

            if flag(env) {
                result.insert(env)
            }
        }

        return result
    }
}
