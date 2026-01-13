import Foundation

public typealias AbsolutePath = UNIXPath
public typealias RelativePath = UNIXPath
public typealias FilePath = UNIXPath

/// Represents an absolute or relative file system path, independently of what (or whether
/// anything at all) exists at that path in the file system at any given time.
///
/// An absolute path always starts with a `/` character, and holds a normalized
/// string representation.  This normalization is strictly syntactic, and does
/// not access the file system in any way.
/// As with AbsolutePath, the normalization for relative path is strictly 
/// syntactic, and does not access the file system in any way.
///
/// The absolute path string is normalized by:
/// - Collapsing `..` path components
/// - Removing `.` path components
/// - Removing any trailing path separator
/// - Removing any redundant path separators
///
/// The relative path string is normalized by:
/// - Collapsing `..` path components that aren't at the beginning
/// - Removing extraneous `.` path components
/// - Removing any trailing path separator
/// - Removing any redundant path separators
/// - Replacing a completely empty path with a `.`
///
/// This string manipulation may change the meaning of a path if any of the
/// path components are symbolic links on disk.  However, the file system is
/// never accessed in any way when initializing a path.
///
/// Note that `~` (home directory resolution) is *not* done as part of path
/// normalization, because it is normally the responsibility of the shell and
/// not the program being invoked (e.g. when invoking `cd ~`, it is the shell
/// that evaluates the tilde; the `cd` command receives an absolute path).
@frozen
public struct UNIXPath: Sendable, Hashable {
    @frozen
    public enum PathType {
        /// Absolute file path. Always has prefix '/'
        case absolute
        /// Relative file path. Never has prefix '/' or '@/'
        case relative
        /// Relative to root file path. Always has prefix '@/'
        case relativeToRoot
    }

    public static let relativeToRootPrefix = "@/"

    public let pathString: String

    /// Path without prefixes, such as '@/' for relativeToRoot paths
    public var clearPathString: String {
        if pathString.hasPrefix(UNIXPath.relativeToRootPrefix) {
            return String(pathString.dropFirst(UNIXPath.relativeToRootPrefix.count))
        } else {
            return pathString
        }
    }

    public static let root = Self(pathString: "/")

    /// Check if the given name is a valid individual path component.
    ///
    /// This only checks with regard to the semantics enforced by absolute path
    /// and relative path; particular file systems may have their own
    /// additional requirements.
    public static func isValidComponent(_ name: String) -> Bool {
        return name != "" && name != "." && name != ".." && !name.contains("/")
    }

    /// Directory component.  An absolute path always has a non-empty directory
    /// component (the directory component of the root path is the root itself).
    public var dirname: String {
        var tmpStr = pathString
        return tmpStr.withUTF8 { buffer -> String in
            var pos = buffer.count
            let slash: UInt8 = 47  // '/'

            while pos > 0 {
                pos -= 1

                guard buffer[pos] == slash else { continue }

                if pos == 0 {
                    return "/"
                }

                let length = pos

                return String(unsafeUninitializedCapacity: length) { newBuffer in
                    var newPos = 0
                    while newPos < length {
                        newBuffer[newPos] = buffer[newPos]
                        newPos += 1
                    }

                    return length
                }
            }

            return "."
        }
    }

    public var pathType: PathType {
        if pathString.hasPrefix("/") {
            return .absolute
        } else if pathString.hasPrefix("@/") {
            return .relativeToRoot
        } else {
            return .relative
        }
    }

    public var isAbsolute: Bool {
        return pathType == .absolute
    }

    public var isRelative: Bool {
        return pathType == .relative
    }

    public var isRelativeToRoot: Bool {
        return pathType == .relativeToRoot
    }

    /// True if the path is the root directory.
    public var isRoot: Bool {
        return self == Self.root
    }

    /// Last path component (including the suffix, if any).  It is never empty.
    public var basename: String {
        // Check for a special case of the root directory.
        if pathString.only == "/" {
            // Root directory, so the basename is a single path separator (the
            // root directory is special in this regard).
            return "/"
        }

        var tmpStr = pathString
        return tmpStr.withUTF8 { buffer -> String in
            var pos = buffer.count
            let slash: UInt8 = 47  // '/'

            while pos > 0 {
                pos -= 1

                guard buffer[pos] == slash else { continue }

                pos += 1

                if pos == buffer.count {
                    return ""
                }

                let length = buffer.count - pos

                return String(unsafeUninitializedCapacity: length) { newBuffer in
                    var newPos = 0
                    while newPos < length {
                        newBuffer[newPos] = buffer[pos]
                        pos += 1
                        newPos += 1
                    }

                    return length
                }
            }

            return pathString 
        }
    }


    /// Returns the basename without the extension.
    public var basenameWithoutExt: String {
        if let ext = self.extension {
            return String(basename.dropLast(ext.count + 1))
        }
        return basename
    }

    /// Returns an array of strings that make up the path components of the
    /// relative path.  This is the same sequence of strings as the basenames
    /// of each successive path component.  Therefore the returned array of
    /// path components is never empty; even an empty path has a single path
    /// component: the `.` string.
    public var components: [String] {
        let components = pathString.components(separatedBy: "/").filter({ !$0.isEmpty })
        //
        if pathString.hasPrefix("/") {
            return ["/"] + components
        } else {
            return components
        }
    }

    /// Absolute path of parent directory.  This always returns a path, because
    /// every directory has a parent (the parent directory of the root directory
    /// is considered to be the root directory itself).
    public var parentDirectory: Self {
        return self == .root ? self : Self(pathString: dirname)
    }

    init(pathString: String) {
        self.pathString = pathString
    }

    init(_ path: UNIXPath) {
        self.pathString = path.pathString
    }

    init(normalizingAbsolutePath path: String) {
        precondition(path.first == "/", "Failure normalizing \(path), absolute paths should start with '/'")

        assert(path.first == "/")

        let dot: UInt8 = 46  // '.'
        let slash: UInt8 = 47  // '/'

        let result = String(unsafeUninitializedCapacity: path.utf8.count + 1) { buffer in
            var pos = 0

            func removeUnnecessaryIfNeed() {
                if pos >= 4 {
                    // '/../'
                    if buffer[pos - 2] == dot, buffer[pos - 3] == dot, buffer[pos - 4] == slash {
                        pos -= 4

                        while pos > 0 && buffer[pos - 1] != slash {
                            pos -= 1
                        }

                        if pos == 0 {
                            buffer[0] = slash
                            pos += 1
                        }
                    }
                }
                if pos >= 3 {
                    // '/./'
                    if buffer[pos - 2] == dot, buffer[pos - 3] == slash {
                        pos -= 2
                    }
                }
                if pos >= 2 {
                    // '//'
                    if buffer[pos - 2] == slash {
                        pos -= 1
                    }
                }
            }

            for ch in path.utf8 {
                buffer[pos] = ch
                pos += 1

                guard ch == slash else { continue }  // '/'
                removeUnnecessaryIfNeed()
            }

            if pos > 1 && buffer[pos - 1] != slash {
                buffer[pos] = slash
                pos += 1
                removeUnnecessaryIfNeed()
            }

            if pos > 1 && buffer[pos - 1] == slash {
                pos -= 1
            }

            if pos == 0 {
                buffer[0] = slash
                pos = 1
            }

            return pos
        }

        assert(result.first == "/")

        self.pathString = result
    }

    init(normalizingRelativePath path: String) {
        precondition(path.first != "/")

        let dot: UInt8 = 46  // '.'
        let slash: UInt8 = 47  // '/'

        let result = String(unsafeUninitializedCapacity: path.utf8.count + 1) { buffer in
            var pos = 0
            var folderCount = 0
            var isCurrentComponentFolder = false

            func removeUnnecessaryIfNeed() {
                if pos >= 4 && folderCount > 0 {
                    // '/../'
                    if buffer[pos - 2] == dot, buffer[pos - 3] == dot, buffer[pos - 4] == slash {
                        pos -= 4

                        while pos > 0 && buffer[pos - 1] != slash {
                            pos -= 1
                        }

                        folderCount -= 1
                    }
                }
                if pos >= 3 {
                    // '/./'
                    if buffer[pos - 2] == dot, buffer[pos - 3] == slash {
                        pos -= 2
                    }
                }
                if pos == 2 {
                    // './'
                    if buffer[0] == dot && buffer[1] == slash {
                        pos = 1
                    }
                }
                if pos >= 2 {
                    // '//'
                    if buffer[pos - 2] == slash {
                        pos -= 1
                    }
                }
                if pos == 1 && (buffer[0] == slash || buffer[0] == dot) {
                    pos = 0
                }
            }

            for ch in path.utf8 {
                buffer[pos] = ch
                pos += 1

                if ch != dot && ch != slash {
                    isCurrentComponentFolder = true
                }

                guard ch == slash else { continue }

                if isCurrentComponentFolder {
                    folderCount += 1
                    isCurrentComponentFolder = false
                }

                removeUnnecessaryIfNeed()
            }

            if pos > 1 && buffer[pos - 1] != slash {
                buffer[pos] = slash
                pos += 1
                removeUnnecessaryIfNeed()
            }

            if pos > 1 && buffer[pos - 1] == slash {
                pos -= 1
            }

            if pos == 0 {
                buffer[0] = dot
                pos = 1
            }

            return pos
        }

        assert(result.first != "/", "result is absolute path: \(result), was normalizing: \(path)")

        self.pathString = result
    }

    /// Convenience initializer that validated the path
    public init(validating path: String) throws {
        if path.first == "/" {
            try self.init(validatingAbsolutePath: path)
        } else if path.hasPrefix(UNIXPath.relativeToRootPrefix) {
            try self.init(validatingRelativeToRootPath: path)
        } else {
            try self.init(validatingRelativePath: path)
        }
    }

    /// Initializes absolute path by concatenating a relative path to an
    /// existing absolute path, and renormalizing if necessary.
    public init(_ absPath: AbsolutePath, _ relPath: RelativePath) {
        assert(absPath.isAbsolute)
        assert(!relPath.isAbsolute)

        self.init(absPath.appending(relPath))
    }

    /// Convenience initializer that appends a string to a relative path.
    public init(_ absPath: AbsolutePath, validating relStr: String) throws {
        assert(absPath.isAbsolute)

        try self.init(absPath, RelativePath(validating: relStr))
    }

    /// Initializes an absolute path from a string that may be either absolute
    /// or relative; if relative, `basePath` is used as the anchor; if absolute,
    /// it is used as is, and in this case `basePath` is ignored.
    public init(validating str: String, relativeTo basePath: AbsolutePath) throws {
        assert(basePath.isAbsolute)

        if UNIXPath(pathString: str).isAbsolute {
            try self.init(validating: str)
        } else {
            try self.init(basePath, RelativePath(validating: str))
        }
    }

    /// Initializes absolute path from `path`, which must be an absolute
    /// path (i.e. it must begin with a path separator; this initializer does
    /// not interpret leading `~` characters as home directory specifiers).
    /// The input string will be normalized if needed, as described in the
    /// documentation for UNIXPath.
    public init(validatingAbsolutePath path: String) throws {
        switch path.first {
        case "/":
            self.init(normalizingAbsolutePath: path)
        case "~":
            throw PathValidationError.startsWithTilde(path)
        default:
            throw PathValidationError.invalidAbsolutePath(path)
        }
    }

    /// Convenience initializer that verifies that the path is relative.
    public init(validatingRelativePath path: String) throws {
        switch path.first {
        case "/":
            throw PathValidationError.invalidRelativePath(path)
        default:
            self.init(normalizingRelativePath: path)
        }
    }

    /// Convenience initializer that verifies that the path is relative to root
    public init(validatingRelativeToRootPath path: String) throws {
        guard path.hasPrefix(UNIXPath.relativeToRootPrefix) else {
            throw PathValidationError.invalidRelativePath(path)
        }

        let relativePathStr = String(path.dropFirst(UNIXPath.relativeToRootPrefix.count))
        let relativePath = try UNIXPath(validatingRelativePath: relativePathStr)

        self.init(pathString: "\(UNIXPath.relativeToRootPrefix)\(relativePath.pathString)")
    }

    /// Suffix with or without leading `.` character if any.  Note that a basename
    /// that starts with a `.` character is not considered a suffix, nor is a
    /// trailing `.` character.
    public func suffix(withDot: Bool) -> String? {
        // We use only contiguous strings. But because of bullshit string api
        // that makes `withUTF8` method mutable, we have to copy String to
        // temporary var "in case if it is modified", which is not the case.
        var tmpStr = pathString

        return tmpStr.withUTF8 { buffer -> String? in
            var pos = buffer.count
            let dot: UInt8 = 46  // '.'
            let slash: UInt8 = 47  // '/'

            while pos > 0 {
                pos -= 1

                switch buffer[pos] {
                case slash:
                    return nil
                case dot:
                    if pos > 0, buffer[pos - 1] != dot, buffer[pos - 1] != slash, pos != buffer.count - 1 {
                        if !withDot { pos += 1 }

                        let length = buffer.count - pos
                        return String(unsafeUninitializedCapacity: length) { newBuffer in
                            var j = 0
                            for i in pos..<buffer.count {
                                newBuffer[j] = buffer[i]
                                j += 1
                            }
                            return length
                        }
                    }
                default:
                    continue
                }
            }

            return nil
        }
    }

    /// Returns path with an additional literal component appended.
    ///
    /// This method accepts pseudo-path like '.' or '..', but should not contain "/".
    public func appending(component name: String) -> Self {
        assert(!name.contains("/"), "\(name) is invalid path component")

        // Handle pseudo paths.
        switch name {
        case "", ".":
            return self
        case "..":
            return self.parentDirectory
        default:
            break
        }

        if self == Self.root {
            return Self(pathString: "/" + name)
        } else {
            return Self(pathString: pathString + "/" + name)
        }
    }

    /// Returns path with additional literal components appended.
    ///
    /// This method should only be used in cases where the input is guaranteed
    /// to be a valid path component (i.e., it cannot be empty, contain a path
    /// separator, or be a pseudo-path like '.' or '..').
    public func appending(components names: [String]) -> UNIXPath {
        return names.reduce(
            self,
            { path, name in
                path.appending(component: name)
            })
    }

    /// Returns path with additional literal components appended.
    ///
    /// This method should only be used in cases where the input is guaranteed
    /// to be a valid path component (i.e., it cannot be empty, contain a path
    /// separator, or be a pseudo-path like '.' or '..').
    public func appending(components names: String...) -> UNIXPath {
        appending(components: names)
    }

    /// Returns path with the relative path applied.
    public func appending(_ relativePath: Self) -> Self {
        assert(!relativePath.isAbsolute)

        // Both paths are already normalized.  The only case in which we have
        // to renormalize their concatenation is if the relative path starts
        // with a `..` path component.
        var newPathString = pathString
        if self != .root {
            newPathString.append("/")
        }

        let relativePathString = relativePath.pathString
        newPathString.append(relativePathString)

        // If the relative string starts with `.` or `..`, we need to normalize
        // the resulting string.
        // FIXME: We can actually optimize that case, since we know that the
        // normalization of a relative path can leave `..` path components at
        // the beginning of the path only.
        if relativePathString.hasPrefix(".") {
            if newPathString.hasPrefix("/") {
                return Self(normalizingAbsolutePath: newPathString)
            } else {
                return Self(normalizingRelativePath: newPathString)
            }
        } else {
            return Self(pathString: newPathString)
        }
    }

    /// Returns a relative path that, when concatenated to `base`, yields the
    /// callee path itself.  If `base` is not an ancestor of the callee, the
    /// returned path will begin with one or more `..` path components.
    ///
    /// Because both paths are absolute, they always have a common ancestor
    /// (the root path, if nothing else).  Therefore, any path can be made
    /// relative to any other path by using a sufficient number of `..` path
    /// components.
    ///
    /// This method is strictly syntactic and does not access the file system
    /// in any way.  Therefore, it does not take symbolic links into account.
    public func relative(to base: AbsolutePath) -> RelativePath {
        assert(self.isAbsolute)
        assert(base.isAbsolute)

        var tmpFrom = base.pathString
        var tmpTo = self.pathString

        let dot: UInt8 = 46  // '/'
        let slash: UInt8 = 47  // '/'

        let result = tmpFrom.withUTF8 { fromBuffer -> RelativePath in
            return tmpTo.withUTF8 { toBuffer -> RelativePath in
                var pos = 0
                var dotPartsCount = 0

                // from - /Users/user/folder1
                // to -   /Users/user

                // /Users/user/folder
                // /Users/us

                // /Users/user
                // /Users/user/folder

                // /Users/user/folder
                // /Users/user/folder2

                // skip same parts
                while pos < fromBuffer.count, pos < toBuffer.count, fromBuffer[pos] == toBuffer[pos] {
                    pos += 1
                }

                // same strings
                if fromBuffer.count == toBuffer.count && pos == fromBuffer.count {
                    return RelativePath(pathString: ".")
                }

                // from - /Users/user
                // to   - /Users/user/folder
                let isFromAncestorOfTo = pos == fromBuffer.count && pos < toBuffer.count && toBuffer[pos] == slash
                if isFromAncestorOfTo {
                    pos += 1
                    let length = toBuffer.count - pos
                    let result = String(unsafeUninitializedCapacity: length) { newBuffer in
                        var newBufferPos = 0
                        while pos < toBuffer.count {
                            newBuffer[newBufferPos] = toBuffer[pos]
                            newBufferPos += 1
                            pos += 1
                        }
                        return length
                    }
                    return RelativePath(pathString: result)
                }

                // from - /Users/user/folder
                // to   - /Users/user
                let isFromDescendantOfTo = pos == toBuffer.count && pos < fromBuffer.count && fromBuffer[pos] == slash
                if isFromDescendantOfTo {
                    var fromPos = pos
                    while fromPos < fromBuffer.count {
                        if fromBuffer[fromPos] == slash {
                            dotPartsCount += 1
                        }
                        fromPos += 1
                    }

                    let length = dotPartsCount * 3 - 1

                    let result = String(unsafeUninitializedCapacity: length) { newBuffer in
                        var newBufferPos = 0
                        while dotPartsCount > 1 {
                            newBuffer[newBufferPos] = dot
                            newBuffer[newBufferPos + 1] = dot
                            newBuffer[newBufferPos + 2] = slash
                            dotPartsCount -= 1
                            newBufferPos += 3
                        }

                        newBuffer[newBufferPos] = dot
                        newBuffer[newBufferPos + 1] = dot

                        return length
                    }
                    return RelativePath(pathString: result)
                }

                // general case

                if pos == toBuffer.count {
                    pos -= 1
                }
                if toBuffer[pos] == slash, pos > 0 {
                    pos -= 1
                }
                while pos > 0, toBuffer[pos] != slash {
                    pos -= 1
                }
                pos += 1

                var fromPos = pos
                while fromPos < fromBuffer.count {
                    if fromBuffer[fromPos] == slash {
                        dotPartsCount += 1
                    }
                    fromPos += 1
                }
                if fromBuffer.count != 1 {
                    dotPartsCount += 1
                }

                let length = dotPartsCount * 3 + toBuffer.count - pos

                let result = String(unsafeUninitializedCapacity: length) { newBuffer in
                    var newBufferPos = 0

                    while dotPartsCount > 0 {
                        newBuffer[newBufferPos] = dot
                        newBuffer[newBufferPos + 1] = dot
                        newBuffer[newBufferPos + 2] = slash
                        dotPartsCount -= 1
                        newBufferPos += 3
                    }

                    while pos < toBuffer.count {
                        newBuffer[newBufferPos] = toBuffer[pos]
                        pos += 1
                        newBufferPos += 1
                    }

                    if newBufferPos > 2 && newBuffer[newBufferPos - 1] == slash {
                        newBufferPos -= 1
                    }

                    return newBufferPos
                }
                return RelativePath(pathString: result)
            }
        }

        return result
    }

    /// Returns true if the path is an ancestor of the given path.
    ///
    /// This method is strictly syntactic and does not access the file system
    /// in any way.
    public func isAncestor(of descendant: AbsolutePath) -> Bool {
        assert(self.isAbsolute)
        assert(descendant.isAbsolute)

        guard descendant.pathString.count > self.pathString.count else {
            return false
        }

        let nth: String.Index
        if self.isRoot {
            nth = self.pathString.startIndex
        } else {
            nth = self.pathString.endIndex
        }

        return descendant.pathString.starts(with: self.pathString) && descendant.pathString[nth] == "/"
    }

    /// Returns true if the path is an ancestor of or equal to the given path.
    ///
    /// This method is strictly syntactic and does not access the file system
    /// in any way.
    public func isAncestorOfOrEqual(to descendant: AbsolutePath) -> Bool {
        assert(self.isAbsolute)
        assert(descendant.isAbsolute)

        // return descendant.components.starts(with: self.components)
        if self.pathString.count == descendant.pathString.count {
            return self.pathString == descendant.pathString
        } else {
            return self.isAncestor(of: descendant)
        }
    }

    /// Returns true if the path is a descendant of the given path.
    ///
    /// This method is strictly syntactic and does not access the file system
    /// in any way.
    public func isDescendant(of ancestor: AbsolutePath) -> Bool {
        assert(self.isAbsolute)
        assert(ancestor.isAbsolute)

        guard self.pathString.count > ancestor.pathString.count else {
            return false
        }

        let nth: String.Index
        if ancestor.isRoot {
            nth = ancestor.pathString.startIndex
        } else {
            nth = ancestor.pathString.endIndex
        }

        return self.pathString.starts(with: ancestor.pathString) && self.pathString[nth] == "/"
    }

    /// Returns true if the path is a descendant of or equal to the given path.
    ///
    /// This method is strictly syntactic and does not access the file system
    /// in any way.
    public func isDescendantOfOrEqual(to ancestor: AbsolutePath) -> Bool {
        assert(self.isAbsolute)
        assert(ancestor.isAbsolute)

        // return self.components.starts(with: ancestor.components)
        if self.pathString.count == ancestor.pathString.count {
            return self.pathString == ancestor.pathString
        } else {
            return self.isDescendant(of: ancestor)
        }
    }

    /// Suffix (including leading `.` character) if any.  Note that a basename
    /// that starts with a `.` character is not considered a suffix, nor is a
    /// trailing `.` character.
    public var suffix: String? {
        return suffix(withDot: true)
    }

    /// Extension of the give path's basename. This follow same rules as
    /// suffix except that it doesn't include leading `.` character.
    public var `extension`: String? {
        return suffix(withDot: false)
    }
}

/// Describes the way in which a path is invalid.
@frozen
public enum PathValidationError: Error {
    case startsWithTilde(String)
    case invalidAbsolutePath(String)
    case invalidRelativePath(String)
}

extension PathValidationError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .startsWithTilde(let path):
            return "invalid absolute path '\(path)'; absolute path must begin with '/'"
        case .invalidAbsolutePath(let path):
            return "invalid absolute path '\(path)'"
        case .invalidRelativePath(let path):
            return "invalid relative path '\(path)'; relative path should not begin with '\(AbsolutePath.root.pathString)'"
        }
    }
}

extension PathValidationError: CustomNSError {
    public var errorUserInfo: [String: Any] {
        return [NSLocalizedDescriptionKey: self.description]
    }
}

extension String {
    var only: Character? {
        let index = self.index(after: self.startIndex)
        return index == self.endIndex ? self.first : nil
    }
}

extension UNIXPath: ExpressibleByStringLiteral {
    public init(_ value: StringLiteralType) {
        try! self.init(validating: value)
    }
}

extension UNIXPath: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        try! self.init(validating: value)
    }
}

extension UNIXPath: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(pathString)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(validating: container.decode(String.self))
    }
}

/// Make absolute paths Comparable.
extension UNIXPath: Comparable {
    public static func < (lhs: UNIXPath, rhs: UNIXPath) -> Bool {
        return lhs.pathString < rhs.pathString
    }
}

/// Make absolute paths CustomStringConvertible and CustomDebugStringConvertible.
extension UNIXPath: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return pathString
    }

    public var debugDescription: String {
        // FIXME: We should really be escaping backslashes and quotes here.
        return "<UNIXPath:\"\(pathString)\">"
    }
}

// MARK: - Convenience initializers

extension UNIXPath {
    public static func relativeToRoot(_ value: String) -> UNIXPath {
        return try! UNIXPath(validatingRelativeToRootPath: "\(UNIXPath.relativeToRootPrefix)\(value)")
    }

    public static func relativeToManifest(_ value: String) -> UNIXPath {
        return try! UNIXPath(validatingRelativePath: value)
    }

    public static func absolute(_ value: String) -> UNIXPath {
        return try! UNIXPath(validatingAbsolutePath: value)
    }
}
