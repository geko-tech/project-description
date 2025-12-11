import Foundation

/// Options to configure scheme diagnostics for run and test actions.
public struct SchemeDiagnosticsOptions: Equatable, Codable {
    /// Enable the address sanitizer
    public var addressSanitizerEnabled: Bool

    /// Enable the detect use of stack after return of address sanitizer
    public var detectStackUseAfterReturnEnabled: Bool

    /// Enable the thread sanitizer
    public var threadSanitizerEnabled: Bool

    /// Enable the undefined behavior sanitizer
    public var undefinedBehaviorSanitizerEnabled: Bool

    /// Enable the main thread cheker
    public var mainThreadCheckerEnabled: Bool

    /// Enable thread performance checker
    public var performanceAntipatternCheckerEnabled: Bool

    /// Enable gpu validation mode
    public var gpuValidationModeEnabled: Bool

    public init(
        addressSanitizerEnabled: Bool = false,
        detectStackUseAfterReturnEnabled: Bool = false,
        threadSanitizerEnabled: Bool = false,
        undefinedBehaviorSanitizerEnabled: Bool = false,
        mainThreadCheckerEnabled: Bool = true,
        performanceAntipatternCheckerEnabled: Bool = true,
        gpuValidationModeEnabled: Bool = true
    ) {
        self.addressSanitizerEnabled = addressSanitizerEnabled
        self.detectStackUseAfterReturnEnabled = detectStackUseAfterReturnEnabled
        self.threadSanitizerEnabled = threadSanitizerEnabled
        self.undefinedBehaviorSanitizerEnabled = undefinedBehaviorSanitizerEnabled
        self.mainThreadCheckerEnabled = mainThreadCheckerEnabled
        self.performanceAntipatternCheckerEnabled = performanceAntipatternCheckerEnabled
        self.gpuValidationModeEnabled = gpuValidationModeEnabled
    }

    public static func options(
        addressSanitizerEnabled: Bool = false,
        detectStackUseAfterReturnEnabled: Bool = false,
        threadSanitizerEnabled: Bool = false,
        undefinedBehaviorSanitizerEnabled: Bool = false,
        ubSanitizerEnabled: Bool = false,
        mainThreadCheckerEnabled: Bool = true,
        performanceAntipatternCheckerEnabled: Bool = true,
        gpuValidationModeEnabled: Bool = true
    ) -> SchemeDiagnosticsOptions {
        return .init(
            addressSanitizerEnabled: addressSanitizerEnabled,
            detectStackUseAfterReturnEnabled: detectStackUseAfterReturnEnabled,
            threadSanitizerEnabled: threadSanitizerEnabled,
            undefinedBehaviorSanitizerEnabled: undefinedBehaviorSanitizerEnabled,
            mainThreadCheckerEnabled: mainThreadCheckerEnabled,
            performanceAntipatternCheckerEnabled: performanceAntipatternCheckerEnabled,
            gpuValidationModeEnabled: gpuValidationModeEnabled
        )
    }
}
