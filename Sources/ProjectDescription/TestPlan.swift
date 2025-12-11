import Foundation

public struct TestPlan: Hashable, Codable {
    public let name: String
    public let path: FilePath
    public var testTargets: [TestableTarget]
    public var isDefault: Bool

    public init(path: FilePath, testTargets: [TestableTarget], isDefault: Bool) {
        name = path.basenameWithoutExt
        self.path = path
        self.testTargets = testTargets
        self.isDefault = isDefault
    }
}
