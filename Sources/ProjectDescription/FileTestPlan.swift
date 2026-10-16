import Foundation

/// Reference an existing `.xctestplan` file on disk.
public struct FileTestPlan: Hashable, Codable {
    /// Path to the existing `.xctestplan` file.
    public var path: FilePath

    // Internal

    /// Name of the test plan.
    public var name: String
    /// Parameter testTargets is not used in Project.swift or Workspace.swift. It is filled after loading testplan and can be used in plugins.
    public var testTargets: [TestableTarget]
    /// Whether this test plan is the default plan.
    public var isDefault: Bool

    public init(path: FilePath) {
        self.name = path.basenameWithoutExt
        self.path = path

        // Internal
        self.testTargets = []
        self.isDefault = false
    }
}
