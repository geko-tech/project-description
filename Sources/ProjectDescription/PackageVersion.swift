import Foundation

@frozen
public struct PackageVersion: CustomStringConvertible, Codable, Comparable, Equatable, Hashable {

    public static let maxSegmentCount = 5
    public let major: Int
    public let minor: Int
    public let patch: Int
    public let segment4: Int
    public let segment5: Int
    public let preReleaseSegments: [String]

    public let preRelease: String?
    public let buildMetadata: String?

    public let value: String

    public var description: String {
        let majorMinor = "\(major).\(minor)"

        let lowerSegment: String
        switch (patch, segment4, segment5) {
        case (0, 0, 0):
            lowerSegment = ""
        case (_, 0, 0):
            lowerSegment = ".\(patch)"
        case (_, _, 0):
            lowerSegment = ".\(patch).\(segment4)"
        default:
            lowerSegment = ".\(patch).\(segment4).\(segment5)"
        }

        let preReleaseStr: String = if let preRelease, !preRelease.isEmpty {
            "-\(preRelease)"
        } else {
            ""
        }

        let metadataStr = buildMetadata.map { "+\($0)" } ?? ""

        return "\(majorMinor)\(lowerSegment)\(preReleaseStr)\(metadataStr)"
    }

    // possible version 1.0.0-alpha+001
    public static let versionCharset: CharacterSet = {
        var charset = CharacterSet.decimalDigits
        charset.insert(charactersIn: ".-+")
        charset.insert(charactersIn: "a"..."z")
        charset.insert(charactersIn: "A"..."Z")
        return charset
    }()

    public init(from str: CustomStringConvertible) {
        guard let parsed = Self.parse(from: str) else {
            fatalError("Invalid package version: \"\(str)\"")
        }

        self = parsed
    }

    public static func parse(from str: CustomStringConvertible) -> PackageVersion? {
        var components = str.description.split(separator: "+", maxSplits: 1)

        guard components.count > 0 else {
            return nil
        }

        let buildMetadata = components.count > 1 ? String(components[1]) : nil

        components = components[0].split(separator: "-", maxSplits: 1)
        let preRelease = components.count > 1 ? String(components[1]) : nil

        let segments = Self.versionSegments(String(components[0]))

        guard
            let majorSegment = segments.first,
            let majorInt = Int(majorSegment)
        else {
            return nil
        }

        assert(PackageVersion.maxSegmentCount == 5)
        let major = majorInt
        // -1 means that this segment is pre-release and
        // its actual value stored in preReleaseSegments
        let minor = Int(segments[safe: 1] ?? "0") ?? -1
        let patch = Int(segments[safe: 2] ?? "0") ?? -1
        let segment4 = Int(segments[safe: 3] ?? "0") ?? -1
        let segment5 = Int(segments[safe: 4] ?? "0") ?? -1
        let noPreRelease = major >= 0
            && minor >= 0
            && patch >= 0
            && segment4 >= 0
            && segment5 >= 0
        // https://www.rubydoc.info/github/CocoaPods/Core/Pod/Version
        let preReleaseSegments = noPreRelease ? [] : segments

        return PackageVersion(
            major,
            minor,
            patch,
            segment4,
            segment5,
            preRelease: preRelease,
            buildMetadata: buildMetadata,
            preReleaseSegments: preReleaseSegments,
            value: str.description
        )
    }

    public init(
        _ major: Int,
        _ minor: Int = 0,
        _ patch: Int = 0,
        _ segment4: Int = 0,
        _ segment5: Int = 0,
        preRelease: String? = nil,
        buildMetadata: String? = nil,
        preReleaseSegments: [String] = [],
        value: String? = nil
    ) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.segment4 = segment4
        self.segment5 = segment5
        self.preRelease = preRelease
        self.buildMetadata = buildMetadata
        self.preReleaseSegments = preReleaseSegments
        let preReleaseStr = preRelease.map { "-\($0)" } ?? ""
        let metadataStr = buildMetadata.map { "+\($0)" } ?? ""

        if let value {
            self.value = value
        } else {
            self.value = "\(major).\(minor).\(patch).\(segment4).\(segment5)\(preReleaseStr)\(metadataStr)"
        }
    }

    // MARK: PubGrub.Version

    public static let lowest: PackageVersion = .init(0, 0, 0, 0, 1)

    public func bump() -> Self {
        .init(major, minor, patch, segment4, segment5 + 1)
    }

    public func bumpMinor() -> Self {
        .init(major, minor + 1)
    }

    public func bumpMajor() -> Self {
        .init(major + 1)
    }

    // MARK: Equatable

    public static func == (lhs: Self, rhs: Self) -> Bool {
        assert(PackageVersion.maxSegmentCount == 5)
        return lhs.major == rhs.major
            && lhs.minor == rhs.minor
            && lhs.patch == rhs.patch
            && lhs.segment4 == rhs.segment4
            && lhs.segment5 == rhs.segment5
            && lhs.preRelease == rhs.preRelease
            && lhs.buildMetadata == rhs.buildMetadata
            && lhs.preReleaseSegments == rhs.preReleaseSegments
    }

    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {
        assert(PackageVersion.maxSegmentCount == 5)
        hasher.combine(major)
        hasher.combine(minor)
        hasher.combine(patch)
        hasher.combine(segment4)
        hasher.combine(segment5)
        hasher.combine(preRelease)
        hasher.combine(buildMetadata)
    }

    // MARK: Comparable

    public static func < (lhs: Self, rhs: Self) -> Bool {
        assert(PackageVersion.maxSegmentCount == 5)
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        if lhs.patch != rhs.patch {
            return lhs.patch < rhs.patch
        }
        if lhs.segment4 != rhs.segment4 {
            return lhs.segment4 < rhs.segment4
        }
        if lhs.segment5 != rhs.segment5 {
            return lhs.segment5 < rhs.segment5
        }
        if lhs.preReleaseSegments != rhs.preReleaseSegments {
            for (l, r) in zip(lhs.preReleaseSegments, rhs.preReleaseSegments) {
                if l != r {
                    return l < r
                }
            }
            return lhs.preReleaseSegments.count < rhs.preReleaseSegments.count
        }
        if lhs.preRelease != rhs.preRelease {
            guard let lPre = lhs.preRelease else { return false }
            guard let rPre = rhs.preRelease else { return true }
            return lPre < rPre
        }
        if lhs.buildMetadata != rhs.buildMetadata {
            guard let lb = lhs.buildMetadata else { return false }
            guard let rb = rhs.buildMetadata else { return true }
            return lb < rb
        }
        // lhs == rhs
        return false
    }
}

extension PackageVersion {
    public static func versionSegments(_ version: String) -> [String] {
        var result: [String] = []
        var currentSegment = ""

        var iter = version.makeIterator()
        var char: Character? = iter.next()
        while let ch = char {
            switch ch {
            case "a"..."z", "A"..."Z":
                while let ch = char, ("a"..."z").contains(ch) || ("A"..."Z").contains(ch) {
                    currentSegment.append(ch)
                    char = iter.next()
                }
                result.append(currentSegment)
                currentSegment.removeAll()
            case "0"..."9":
                while let ch = char, ("0"..."9").contains(ch) {
                    currentSegment.append(ch)
                    char = iter.next()
                }
                result.append(currentSegment)
                currentSegment.removeAll()
            default:
                char = iter.next()
            }
        }

        if result.count > Self.maxSegmentCount {
            fatalError("Unsupported version: \(version). Versions with segment count more than \(Self.maxSegmentCount) are not supported")
        }

        return result
    }
}

extension PackageVersion {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension PackageVersion {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        self.init(from: value)
    }
}

extension Array {
    fileprivate subscript(safe idx: Int) -> Element? {
        if indices.contains(idx) {
            return self[idx]
        }
        return nil
    }
}
