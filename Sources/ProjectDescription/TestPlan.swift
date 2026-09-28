import Foundation

public struct TestPlan: Hashable, Codable {
    public struct TestableTarget: Codable, Equatable, Sendable {
        /// The target name and its project path.
        public var target: TargetReference
        /// Execute tests in parallel.
        public var parallelizable: Bool?
        public var skipped: Bool?
        public var selectedTests: [String]
        public var skippedTests: [String]

        public init(
            target: TargetReference,
            isParallelizable: Bool? = nil,
            isSkipped: Bool? = nil,
            selectedTests: [String] = [],
            skippedTests: [String] = []
        ) {
            self.target = target
            self.parallelizable = isParallelizable
            self.skipped = isSkipped
            self.selectedTests = selectedTests
            self.skippedTests = skippedTests
        }
    }

    public struct TestableTargetFilter: Codable, Equatable, Sendable {
        public var targetFilter: TargetFilter
        /// Execute tests in parallel.
        public var isParallelizable: Bool?
        public var isSkipped: Bool?
        public var selectedTests: [String]
        public var skippedTests: [String]

        public init(
            targetFilter: TargetFilter,
            isParallelizable: Bool? = nil,
            isSkipped: Bool? = nil,
            selectedTests: [String] = [],
            skippedTests: [String] = []
        ) {
            self.targetFilter = targetFilter
            self.isParallelizable = isParallelizable
            self.isSkipped = isSkipped
            self.selectedTests = selectedTests
            self.skippedTests = skippedTests
        }
    }

    public struct Options: Codable, Equatable, Sendable {
        /// Arguments Passed On Launch
        public struct CommandLineArgumentEntry: Codable, Equatable, Sendable {
            public let argument: String
            public let enabled: Bool?

            public init(argument: String, enabled: Bool? = nil) {
                self.argument = argument
                self.enabled = enabled
            }
        }

        /// Environment Variables
        public struct VariableEntity: Codable, Equatable, Sendable {
            public let enabled: Bool?
            public let key: String
            public let value: String

            public init(key: String, value: String, enabled: Bool? = nil) {
                self.key = key
                self.value = value
                self.enabled = enabled
            }
        }

        /// Simulated Location
        public struct LocationScenario: Codable, Equatable, Sendable {
            public let identifier: String
            public let referenceType: String

            public init(identifier: String, referenceType: String) {
                self.identifier = identifier
                self.referenceType = referenceType
            }
        }

        /// Automatic Screen Capture
        public enum UITestingScreenshotsLifetime: String, Codable, Equatable, Sendable {
            /// On, and keep all
            case keepAlways
            /// On, and delete if test succeeds (default)
            case deleteOnSuccess
            /// Off
            case keepNever
        }

        /// Preferred Capture Format
        public enum PreferredScreenCaptureFormat: String, Codable, Equatable, Sendable {
            /// Video (default)
            case video
            /// Screenshot
            case screenshot
        }

        /// Distribution
        public enum Distributor: String, Codable, Equatable, Sendable {
            case appStore = "com.apple.AppStore"
            case testFlight = "com.apple.TestFlight"
        }

        /// Attachments
        public enum UserAttachmentLifetime: String, Codable, Equatable, Sendable {
            /// On, and keep all
            case keepAlways
            /// On, and delete if test succeeds (default)
            case deleteOnSuccess
            /// Off
            case keepNever
        }

        /// Collect Test Diagnostics on Failure
        public enum DiagnosticCollectionPolicy: String, Codable, Equatable, Sendable {
            /// Never
            case never = "Never"
            /// When testing with xcodebuild (default)
            case xcodebuild
            /// Always
            case always = "Always"
        }

        /// XCTest Execution Order
        public enum TestExecutionOrdering: String, Codable, Equatable, Sendable {
            /// Alphabetical (default)
            case alphabetical
            /// Random
            case random
        }

        /// Test Repetition Mode
        public enum TestRepetitionMode: String, Codable, Equatable, Sendable {
            /// Until Failure
            case untilFailure
            /// Retry On Failure
            case retryOnFailure
            /// Up Until Maximum Repetitions
            case fixedIterations
            /// None (default)
            case none
        }

        /// Address Sanitizer
        public struct AddressSanitizer: Codable, Equatable, Sendable {
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

        public struct RuntimeApiChecking: Codable, Equatable, Sendable {
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
        public struct CheckedAllocations: Codable, Equatable, Sendable {
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
        public enum MallocStackLoggingOptions: Codable, Equatable, Sendable {
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
        public let targetForVariableExpansion: String?
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
        public let codeCoverage: Bool?
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
            commandLineArgumentEntries: [CommandLineArgumentEntry]? = nil,
            environmentVariableEntries: [VariableEntity]? = nil,
            targetForVariableExpansion: String? = nil,
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
            codeCoverage: Bool? = nil,
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
    }

    public let name: String

    public var path: FilePath?

    public var configurationOptions: Options?
    public var defaultOptions: Options?

    public var testTargets: [TestableTarget]
    public var testTargetFilters: [TestableTargetFilter]

    public var isDefault: Bool
    public var isGenerated: Bool

    @available(*, deprecated)
    public init(path: FilePath, testTargets: [TestableTarget], isDefault: Bool) {
        name = path.basenameWithoutExt
        self.path = path
        self.configurationOptions = nil
        self.defaultOptions = nil
        self.testTargets = testTargets
        self.testTargetFilters = []
        self.isDefault = isDefault
        self.isGenerated = false
    }

    private init(
        name: String,
        path: FilePath?,
        configurationOptions: Options?,
        defaultOptions: Options?,
        testTargets: [TestableTarget],
        testTargetFilters: [TestableTargetFilter],
        isDefault: Bool,
        isGenerated: Bool
    ) {
        self.name = name
        self.path = path
        self.configurationOptions = configurationOptions
        self.defaultOptions = defaultOptions
        self.testTargets = testTargets
        self.testTargetFilters = testTargetFilters
        self.isDefault = isDefault
        self.isGenerated = isGenerated
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(path)
    }

    public static func file(
        path: FilePath,
        isDefault: Bool = false
    ) -> Self {
        return Self(
            name: path.basenameWithoutExt,
            path: path,
            configurationOptions: nil,
            defaultOptions: nil,
            testTargets: [],
            testTargetFilters: [],
            isDefault: isDefault,
            isGenerated: false
        )
    }

    public static func generate(
        name: String,
        directory: FilePath? = nil,
        configurationOptions: Options? = nil,
        defaultOptions: Options? = nil,
        testTargets: [TestableTarget] = [],
        testTargetFilters: [TestableTargetFilter] = [],
        isDefault: Bool = false
    ) -> Self {
        return Self(
            name: name,
            path: directory.map { $0.appending(component: name) },
            configurationOptions: configurationOptions,
            defaultOptions: defaultOptions,
            testTargets: testTargets,
            testTargetFilters: testTargetFilters,
            isDefault: isDefault,
            isGenerated: false
        )
    }
}
