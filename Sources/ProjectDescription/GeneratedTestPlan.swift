import Foundation

/// A testable target entry used for auto-generated test plans in Geko.
///
/// Wraps a ``TestableTarget`` with optional test filtering (selected/skipped tests).
/// Conforms to `ExpressibleByStringInterpolation`, so you can use a plain string
/// wherever an `GeneratedTestPlanTestableTarget` is expected:
///
/// ```swift
/// let targets: [GeneratedTestPlanTestableTarget] = [
///     "MyFeatureTests",
///     .target("MyOtherTests", skippedTests: ["MyOtherTests/testFlaky"]),
/// ]
/// ```
public struct GeneratedTestPlanTestableTarget: Codable, Hashable, Sendable, ExpressibleByStringInterpolation {
    /// The underlying testable target reference that identifies
    /// which target should be included in the generated test plan.
    public let target: TestableTarget
    /// A list of specific tests to include in the plan.
    ///
    /// Each entry uses the Xcode test identifier format, e.g.
    /// `"MyTests/testExample"` or `"MyTests"` for an entire suite.
    /// When non-empty, only these tests will be executed for this target.
    /// An empty array means all tests are included (subject to `skippedTests`).
    public let selectedTests: [String]
    /// A list of specific tests to exclude from the plan.
    ///
    /// Each entry uses the Xcode test identifier format, e.g.
    /// `"MyTests/testExample"` or `"MyTests"` for an entire suite.
    /// These tests will be skipped even if they would otherwise run.
    /// An empty array means no tests are skipped.
    public let skippedTests: [String]
    
    public init(
        _ target: TestableTarget,
        selectedTests: [String] = [],
        skippedTests: [String] = [],
    ) {
        self.target = target
        self.selectedTests = selectedTests
        self.skippedTests = skippedTests
    }
    
    public init(stringLiteral value: String) {
        self.init(TestableTarget(stringLiteral: value))
    }
    
    /// Creates an ``GeneratedTestPlanTestableTarget`` with optional test filtering.
    ///
    /// This factory method provides a more readable call-site syntax:
    /// ```swift
    /// .target("MyTests", selectedTests: ["MyTests/testImportant"])
    /// ```
    ///
    /// - Parameters:
    ///   - target: The testable target to include.
    ///   - selectedTests: Tests to run exclusively. Empty means run all.
    ///   - skippedTests: Tests to skip. Empty means skip none.
    /// - Returns: A configured ``GeneratedTestPlanTestableTarget``.
    public static func target(
        _ target: TestableTarget,
        selectedTests: [String] = [],
        skippedTests: [String] = [],
    ) -> Self {
        .init(target, selectedTests: selectedTests, skippedTests: skippedTests)
    }
}

/// A test plan that Geko generates during project generation.
///
/// Unlike a ``TestPlan`` that references an existing `.xctestplan` file on disk, a generated test
/// plan is described declaratively and its `.xctestplan` file is produced by Geko. Test targets can
/// be listed explicitly via ``testTargets`` or resolved automatically from ``targetSelection`` scopes.
public struct GeneratedTestPlan: Codable, Hashable, Sendable {
    /// Options applied to the generated test plan.
    public struct Options: Codable, Hashable, Sendable {
        /// Arguments Passed On Launch
        public struct CommandLineArgumentEntry: Codable, Hashable, Sendable {
            public let argument: String
            public let enabled: Bool?

            public init(argument: String, enabled: Bool?) {
                self.argument = argument
                self.enabled = enabled
            }

            public static func argument(argument: String, enabled: Bool? = nil) -> Self {
                Self(argument: argument, enabled: enabled)
            }
        }

        /// Environment Variables
        public struct VariableEntity: Codable, Hashable, Sendable {
            public let enabled: Bool?
            public let key: String
            public let value: String

            public init(key: String, value: String, enabled: Bool?) {
                self.key = key
                self.value = value
                self.enabled = enabled
            }

            public static func variable(key: String, value: String, enabled: Bool? = nil) -> Self {
                Self(key: key, value: value, enabled: enabled)
            }
        }

        /// Simulated Location
        public struct LocationScenario: Codable, Hashable, Sendable {
            public let identifier: String
            public let referenceType: String

            public init(identifier: String, referenceType: String) {
                self.identifier = identifier
                self.referenceType = referenceType
            }
        }        
        /// Automatic Screen Capture
        public enum UITestingScreenshotsLifetime: String, Codable, Hashable, Sendable {
            /// On, and keep all
            case keepAlways
            /// On, and delete if test succeeds (default)
            case deleteOnSuccess
            /// Off
            case keepNever
        }
        
        /// Preferred Capture Format
        public enum PreferredScreenCaptureFormat: String, Codable, Hashable, Sendable {
            /// Video (default)
            case video
            /// Screenshot
            case screenshot
        }
        
        /// Distribution
        public enum Distributor: String, Codable, Hashable, Sendable {
            case appStore = "com.apple.AppStore"
            case testFlight = "com.apple.TestFlight"
        }
        
        /// Attachments
        public enum UserAttachmentLifetime: String, Codable, Hashable, Sendable {
            /// On, and keep all
            case keepAlways
            /// On, and delete if test succeeds (default)
            case deleteOnSuccess
            /// Off
            case keepNever
        }
        
        /// Collect Test Diagnostics on Failure
        public enum DiagnosticCollectionPolicy: String, Codable, Hashable, Sendable {
            /// Never
            case never = "Never"
            /// When testing with xcodebuild (default)
            case xcodebuild
            /// Always
            case always = "Always"
        }
        
        /// XCTest Execution Order
        public enum TestExecutionOrdering: String, Codable, Hashable, Sendable {
            /// Alphabetical (default)
            case alphabetical
            /// Random
            case random
        }
        
        /// Test Repetition Mode
        public enum TestRepetitionMode: String, Codable, Hashable, Sendable {
            /// Until Failure
            case untilFailure
            /// Retry On Failure
            case retryOnFailure
            /// Up Until Maximum Repetitions
            case fixedIterations
            /// None (default)
            case none
        }

        /// Code coverage
        @frozen
        public enum Coverage: Codable, Hashable, Sendable {
            /// Off
            case disabled
            /// On (default)
            case all
            /// List of targets with code coverage enabled
            case selected([TargetReference])
        }

        /// Address Sanitizer
        public struct AddressSanitizer: Codable, Hashable, Sendable {
            public let detectStackUseAfterReturn: Bool?
            public let enabled: Bool

            public init(detectStackUseAfterReturn: Bool? = nil, enabled: Bool = true) {
                self.detectStackUseAfterReturn = detectStackUseAfterReturn
                self.enabled = enabled
            }

            /// On
            public static func on() -> Self { Self(enabled: true) }
            /// On, and detect stack use after return
            public static func onAndDetectStackUseAfterReturn() -> Self { Self(detectStackUseAfterReturn: true, enabled: true) }
        }

        public struct RuntimeApiChecking: Codable, Hashable, Sendable {
            public enum Severity: String, Codable, Sendable {
                case warning
                case failure
            }

            public let severity: Severity?
            public let enabled: Bool?

            public init(severity: Severity?, enabled: Bool?) {
                self.severity = severity
                self.enabled = enabled
            }

            /// On (as Warning) (default)
            public static func onAsWarning() -> Self { Self(severity: .warning, enabled: nil) }
            /// On (as Failure)
            public static func onAsFailure() -> Self { Self(severity: .failure, enabled: nil) }
            /// Off
            public static func off() -> Self { Self(severity: nil, enabled: false) }
        }

        /// Hardware Memory Tagging
        public struct CheckedAllocations: Codable, Hashable, Sendable {
            public let enabled: Bool
            public let requiresHardwareAcceleration: Bool

            public init(enabled: Bool = true, requiresHardwareAcceleration: Bool) {
                self.enabled = enabled
                self.requiresHardwareAcceleration = requiresHardwareAcceleration
            }

            /// Off
            public static func off() -> Self { Self(enabled: false, requiresHardwareAcceleration: true) }
            /// On (when supported)
            public static func onWhenSupported() -> Self { Self(enabled: true, requiresHardwareAcceleration: true) }
            /// On (when supported), fall back to Guard Malloc otherwise
            public static func onWhenSupportedFallBackToGuardMalloc() -> Self { Self(enabled: true, requiresHardwareAcceleration: false) }
        }        
        /// Malloc Stack Logging
        @frozen
        public enum MallocStackLoggingOptions: Codable, Hashable, Sendable {
            /// On
            case on
            /// Off (default)
            case off
        }
        
        /// Arguments Passed On Launch
        public let commandLineArgumentEntries: [CommandLineArgumentEntry]?
        /// Environment Variables
        public let environmentVariableEntries: [VariableEntity]?
        /// Target for Variable Expansion
        public let targetForVariableExpansion: TargetReference?
        /// Application Language
        public let language: String?
        /// Application Region
        public let region: String?
        /// Simulated Location
        public let locationScenario: LocationScenario?
        /// Automatic Screen Capture
        public let uiTestingScreenshotsLifetime: UITestingScreenshotsLifetime?
        /// Preferred Capture Format
        public let preferredScreenCaptureFormat: PreferredScreenCaptureFormat?
        /// Localization Screenshots
        public let areLocalizationScreenshotsEnabled: Bool?
        /// Distribution
        public let distributor: Distributor?
        /// Attachments
        public let userAttachmentLifetime: UserAttachmentLifetime?
        /// Collect Test Diagnostics on Failure
        public let diagnosticCollectionPolicy: DiagnosticCollectionPolicy?
        /// XCTest Execution Order
        public let testExecutionOrdering: TestExecutionOrdering?
        /// Test Timeouts
        public let testTimeoutsEnabled: Bool?
        /// Default Test Execution Time Allowance (s) (default: 600)
        public let defaultTestExecutionTimeAllowance: Int?
        /// Maximum Test Execution Time Allowance (s) (default: None)
        public let maximumTestExecutionTimeAllowance: Int?
        /// Test Repetition Mode
        public let testRepetitionMode: TestRepetitionMode?
        /// Maximum Test Repetitions (default: 3)
        public let maximumTestRepetitions: Int?
        /// Relaunch Tests for Each Repetition
        public let repeatInNewRunnerProcess: Bool?
        /// Code Coverage
        public let codeCoverage: Coverage?
        /// Address Sanitizer
        public let addressSanitizer: AddressSanitizer?
        /// Thread Sanitizer
        public let threadSanitizerEnabled: Bool?
        /// Undefined Behavior Sanitizer
        public let undefinedBehaviorSanitizerEnabled: Bool?
        /// Main Thread Checker
        public let mainThreadCheckerDetectionPolicy: RuntimeApiChecking?
        /// Thread Performance Checker
        public let threadPerformanceCheckerRuntimeIssueDetection: RuntimeApiChecking?
        /// Other Runtime Issues
        public let runtimeIssueDetection: RuntimeApiChecking?
        /// Hardware Memory Tagging
        public let checkedAllocations: CheckedAllocations?
        /// Malloc Scribble
        public let mallocScribbleEnabled: Bool?
        /// Malloc Guard Edges
        public let mallocGuardEdgesEnabled: Bool?
        /// Zombie Objects
        public let nsZombieEnabled: Bool?
        /// Malloc Stack Logging
        public let mallocStackLoggingOptions: MallocStackLoggingOptions?
        
        public init(
            commandLineArgumentEntries: [CommandLineArgumentEntry]?,
            environmentVariableEntries: [VariableEntity]?,
            targetForVariableExpansion: TargetReference?,
            language: String?,
            region: String?,
            locationScenario: LocationScenario?,
            uiTestingScreenshotsLifetime: UITestingScreenshotsLifetime?,
            preferredScreenCaptureFormat: PreferredScreenCaptureFormat?,
            areLocalizationScreenshotsEnabled: Bool?,
            distributor: Distributor?,
            userAttachmentLifetime: UserAttachmentLifetime?,
            diagnosticCollectionPolicy: DiagnosticCollectionPolicy?,
            testExecutionOrdering: TestExecutionOrdering?,
            testTimeoutsEnabled: Bool?,
            defaultTestExecutionTimeAllowance: Int?,
            maximumTestExecutionTimeAllowance: Int?,
            testRepetitionMode: TestRepetitionMode?,
            maximumTestRepetitions: Int?,
            repeatInNewRunnerProcess: Bool?,
            codeCoverage: Coverage?,
            addressSanitizer: AddressSanitizer?,
            threadSanitizerEnabled: Bool?,
            undefinedBehaviorSanitizerEnabled: Bool?,
            mainThreadCheckerDetectionPolicy: RuntimeApiChecking?,
            threadPerformanceCheckerRuntimeIssueDetection: RuntimeApiChecking?,
            runtimeIssueDetection: RuntimeApiChecking?,
            checkedAllocations: CheckedAllocations?,
            mallocScribbleEnabled: Bool?,
            mallocGuardEdgesEnabled: Bool?,
            nsZombieEnabled: Bool?,
            mallocStackLoggingOptions: MallocStackLoggingOptions?,
        ) {
            self.commandLineArgumentEntries = commandLineArgumentEntries
            self.environmentVariableEntries = environmentVariableEntries
            self.targetForVariableExpansion = targetForVariableExpansion
            self.language = language
            self.region = region
            self.locationScenario = locationScenario
            self.uiTestingScreenshotsLifetime = uiTestingScreenshotsLifetime
            self.preferredScreenCaptureFormat = preferredScreenCaptureFormat
            self.areLocalizationScreenshotsEnabled = areLocalizationScreenshotsEnabled
            self.distributor = distributor
            self.userAttachmentLifetime = userAttachmentLifetime
            self.diagnosticCollectionPolicy = diagnosticCollectionPolicy
            self.testExecutionOrdering = testExecutionOrdering
            self.testTimeoutsEnabled = testTimeoutsEnabled
            self.defaultTestExecutionTimeAllowance = defaultTestExecutionTimeAllowance
            self.maximumTestExecutionTimeAllowance = maximumTestExecutionTimeAllowance
            self.testRepetitionMode = testRepetitionMode
            self.maximumTestRepetitions = maximumTestRepetitions
            self.repeatInNewRunnerProcess = repeatInNewRunnerProcess
            self.codeCoverage = codeCoverage
            self.addressSanitizer = addressSanitizer
            self.threadSanitizerEnabled = threadSanitizerEnabled
            self.undefinedBehaviorSanitizerEnabled = undefinedBehaviorSanitizerEnabled
            self.mainThreadCheckerDetectionPolicy = mainThreadCheckerDetectionPolicy
            self.threadPerformanceCheckerRuntimeIssueDetection = threadPerformanceCheckerRuntimeIssueDetection
            self.runtimeIssueDetection = runtimeIssueDetection
            self.checkedAllocations = checkedAllocations
            self.mallocScribbleEnabled = mallocScribbleEnabled
            self.mallocGuardEdgesEnabled = mallocGuardEdgesEnabled
            self.nsZombieEnabled = nsZombieEnabled
            self.mallocStackLoggingOptions = mallocStackLoggingOptions
        }
        
        public static func options(
            commandLineArgumentEntries: [CommandLineArgumentEntry]? = nil,
            environmentVariableEntries: [VariableEntity]? = nil,
            targetForVariableExpansion: TargetReference? = nil,
            language: String? = nil,
            region: String? = nil,
            locationScenario: LocationScenario? = nil,
            uiTestingScreenshotsLifetime: UITestingScreenshotsLifetime? = nil,
            preferredScreenCaptureFormat: PreferredScreenCaptureFormat? = nil,
            areLocalizationScreenshotsEnabled: Bool? = nil,
            distributor: Distributor? = nil,
            userAttachmentLifetime: UserAttachmentLifetime? = nil,
            diagnosticCollectionPolicy: DiagnosticCollectionPolicy? = nil,
            testExecutionOrdering: TestExecutionOrdering? = nil,
            testTimeoutsEnabled: Bool? = nil,
            defaultTestExecutionTimeAllowance: Int? = nil,
            maximumTestExecutionTimeAllowance: Int? = nil,
            testRepetitionMode: TestRepetitionMode? = nil,
            maximumTestRepetitions: Int? = nil,
            repeatInNewRunnerProcess: Bool? = nil,
            codeCoverage: Coverage? = nil,
            addressSanitizer: AddressSanitizer? = nil,
            threadSanitizerEnabled: Bool? = nil,
            undefinedBehaviorSanitizerEnabled: Bool? = nil,
            mainThreadCheckerDetectionPolicy: RuntimeApiChecking? = nil,
            threadPerformanceCheckerRuntimeIssueDetection: RuntimeApiChecking? = nil,
            runtimeIssueDetection: RuntimeApiChecking? = nil,
            checkedAllocations: CheckedAllocations? = nil,
            mallocScribbleEnabled: Bool? = nil,
            mallocGuardEdgesEnabled: Bool? = nil,
            nsZombieEnabled: Bool? = nil,
            mallocStackLoggingOptions: MallocStackLoggingOptions? = nil,
        ) -> Self {
            Self(
                commandLineArgumentEntries: commandLineArgumentEntries,
                environmentVariableEntries: environmentVariableEntries,
                targetForVariableExpansion: targetForVariableExpansion,
                language: language,
                region: region,
                locationScenario: locationScenario,
                uiTestingScreenshotsLifetime: uiTestingScreenshotsLifetime,
                preferredScreenCaptureFormat: preferredScreenCaptureFormat,
                areLocalizationScreenshotsEnabled: areLocalizationScreenshotsEnabled,
                distributor: distributor,
                userAttachmentLifetime: userAttachmentLifetime,
                diagnosticCollectionPolicy: diagnosticCollectionPolicy,
                testExecutionOrdering: testExecutionOrdering,
                testTimeoutsEnabled: testTimeoutsEnabled,
                defaultTestExecutionTimeAllowance: defaultTestExecutionTimeAllowance,
                maximumTestExecutionTimeAllowance: maximumTestRepetitions,
                testRepetitionMode: testRepetitionMode,
                maximumTestRepetitions: maximumTestRepetitions,
                repeatInNewRunnerProcess: repeatInNewRunnerProcess,
                codeCoverage: codeCoverage,
                addressSanitizer: addressSanitizer,
                threadSanitizerEnabled: threadSanitizerEnabled,
                undefinedBehaviorSanitizerEnabled: undefinedBehaviorSanitizerEnabled,
                mainThreadCheckerDetectionPolicy: mainThreadCheckerDetectionPolicy,
                threadPerformanceCheckerRuntimeIssueDetection: threadPerformanceCheckerRuntimeIssueDetection,
                runtimeIssueDetection: runtimeIssueDetection,
                checkedAllocations: checkedAllocations,
                mallocScribbleEnabled: mallocScribbleEnabled,
                mallocGuardEdgesEnabled: mallocGuardEdgesEnabled,
                nsZombieEnabled: nsZombieEnabled,
                mallocStackLoggingOptions: mallocStackLoggingOptions
            )
        }
    }

    /// A build configuration of the generated test plan.
    public struct Configuration: Codable, Hashable {
        /// The name of the configuration.
        public let name: String
        /// The options applied to this configuration.
        public let options: Options?

        public init(name: String, options: Options?) {
            self.name = name
            self.options = options
        }

        public static func configuration(name: String, options: Options? = nil) -> Self {
            Self(name: name, options: options)
        }
    }

    @frozen
    public enum MissingTargetPolicy: Codable, Hashable, Sendable {
        @frozen
        public enum Notification: Codable, Equatable, Sendable {
            /// Silently ignore — no output, no warnings.
            case silent
            /// Emit a warning to inform the user.
            case warning
        }
        
        /// Do not generate the test plan at all.
        ///
        /// - Parameter notification: Whether to silently skip or emit a warning.
        ///
        /// Use when a missing target makes the whole test plan meaningless.
        case skipTestPlan(Notification = .warning)
        
        /// Skip only the missing target from the test plan.
        ///
        /// - Parameter notification: Whether to silently skip or emit a warning.
        ///
        /// Other valid targets in the plan will still be included.
        case skipTarget(Notification = .warning)
        
        /// Fail the entire generation with an error.
        ///
        /// Use when all specified targets are strictly required.
        case fail
    }
    
    /// Name of the test plan
    public let name: String
    /// The path to the folder where the test plan will be generated. If the path is `nil`, it will be written to `Derived/TestPlans/<name>.xctestplan`
    public var directory: FilePath?
    /// Configurations
    public var configurations: [Configuration]
    /// Default options
    public var defaultOptions: Options?
    /// Explicit test targets to include in the generated test plan.
    public var testTargets: [GeneratedTestPlanTestableTarget]
    /// Scopes that resolve which test targets to include in the generated test plan.
    public var targetSelection: [TestableTargetSelectionScope]
    /// Policy for handling missing targets.
    public var missingTargetPolicy: MissingTargetPolicy

    // Internal

    /// The path where the generated test plan is written.
    public var path: FilePath
    /// Whether this test plan is the default plan.
    public var isDefault: Bool

    // MARK: - Init

    public init(
        name: String,
        directory: FilePath?,
        configurations: [Configuration],
        defaultOptions: Options?,
        testTargets: [GeneratedTestPlanTestableTarget],
        targetSelection: [TestableTargetSelectionScope],
        missingTargetPolicy: MissingTargetPolicy
    ) {
        self.name = name.split(separator: ".").first.map(String.init) ?? name
        self.directory = directory
        self.configurations = configurations
        self.defaultOptions = defaultOptions
        self.testTargets = testTargets
        self.targetSelection = targetSelection
        self.missingTargetPolicy = missingTargetPolicy
        
        // Internal
        self.path = "/"
        self.isDefault = false
    }
}
