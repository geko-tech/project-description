import Foundation

/// Options for the `RunAction` action
public struct RunActionOptions: Equatable, Codable {
    /// Language to use when running the app.
    public var language: SchemeLanguage?

    /// Region to use when running the app.
    public var region: String?

    /// The path of the
    /// [StoreKit configuration
    /// file](https://developer.apple.com/documentation/xcode/setting_up_storekit_testing_in_xcode#3625700).
    public var storeKitConfigurationPath: FilePath?

    /// A simulated GPS location to use when running the app.
    public var simulatedLocation: SimulatedLocation?

    /// Configure your project to work with the Metal frame debugger.
    public var enableGPUFrameCaptureMode: GPUFrameCaptureMode

    /// Creates an `RunActionOptions` instance
    ///
    /// - Parameters:
    ///     - language: language (e.g. "pl").
    ///
    ///     - storeKitConfigurationPath: The path of the
    ///     [StoreKit configuration
    /// file](https://developer.apple.com/documentation/xcode/setting_up_storekit_testing_in_xcode#3625700).
    ///     Please note that this file is automatically added to the Project/Workpace. You should not add it manually.
    ///     The default value is `nil`, which results in no configuration defined for the scheme
    ///
    ///     - simulatedLocation: The simulated GPS location to use when running the app.
    ///     Please note that the `.custom(gpxPath:)` case must refer to a valid GPX file in your project's resources.
    ///
    ///     - enableGPUFrameCaptureMode: The Metal Frame Capture mode to use. e.g: .disabled
    ///     If your target links to the Metal framework, Xcode enables GPU Frame Capture.
    ///     You can disable it to test your app in best perfomance.
    public init(
        language: SchemeLanguage? = nil,
        region: String? = nil,
        storeKitConfigurationPath: FilePath? = nil,
        simulatedLocation: SimulatedLocation? = nil,
        enableGPUFrameCaptureMode: GPUFrameCaptureMode = GPUFrameCaptureMode.default
    ) {
        self.language = language
        self.region = region
        self.storeKitConfigurationPath = storeKitConfigurationPath
        self.simulatedLocation = simulatedLocation
        self.enableGPUFrameCaptureMode = enableGPUFrameCaptureMode
    }

    /// Creates an `RunActionOptions` instance
    ///
    /// - Parameters:
    ///     - language: language (e.g. "pl").
    ///
    ///     - storeKitConfigurationPath: The path of the
    ///     [StoreKit configuration
    /// file](https://developer.apple.com/documentation/xcode/setting_up_storekit_testing_in_xcode#3625700).
    ///     Please note that this file is automatically added to the Project/Workpace. You should not add it manually.
    ///     The default value is `nil`, which results in no configuration defined for the scheme
    ///
    ///     - simulatedLocation: The simulated GPS location to use when running the app.
    ///     Please note that the `.custom(gpxPath:)` case must refer to a valid GPX file in your project's resources.
    ///
    ///     - enableGPUFrameCaptureMode: The Metal Frame Capture mode to use. e.g: .disabled
    ///     If your target links to the Metal framework, Xcode enables GPU Frame Capture.
    ///     You can disable it to test your app in best perfomance.

    public static func options(
        language: SchemeLanguage? = nil,
        storeKitConfigurationPath: FilePath? = nil,
        simulatedLocation: SimulatedLocation? = nil,
        enableGPUFrameCaptureMode: GPUFrameCaptureMode = GPUFrameCaptureMode.default
    ) -> Self {
        self.init(
            language: language,
            storeKitConfigurationPath: storeKitConfigurationPath,
            simulatedLocation: simulatedLocation,
            enableGPUFrameCaptureMode: enableGPUFrameCaptureMode
        )
    }
}

extension RunActionOptions {
    /// Simulated location represents a GPS location that is used when running an app on the simulator.
    @frozen
    public enum SimulatedLocation: Codable, Equatable {
        /// The identifier of the location (e.g. London, England)
        case reference(String)
        /// Path to a .gpx file that indicates the location
        case gpxFile(FilePath)

        public static func custom(gpxFile: FilePath) -> SimulatedLocation {
            .gpxFile(gpxFile)
        }

        public static var london: SimulatedLocation {
            .reference("London, England")
        }

        public static var johannesburg: SimulatedLocation {
            .reference("Johannesburg, South Africa")
        }

        public static var moscow: SimulatedLocation {
            .reference("Moscow, Russia")
        }

        public static var mumbai: SimulatedLocation {
            .reference("Mumbai, India")
        }

        public static var tokyo: SimulatedLocation {
            .reference("Tokyo, Japan")
        }

        public static var sydney: SimulatedLocation {
            .reference("Sydney, Australia")
        }

        public static var hongKong: SimulatedLocation {
            .reference("Hong Kong, China")
        }

        public static var honolulu: SimulatedLocation {
            .reference("Honolulu, HI, USA")
        }

        public static var sanFrancisco: SimulatedLocation {
            .reference("San Francisco, CA, USA")
        }

        public static var mexicoCity: SimulatedLocation {
            .reference("Mexico City, Mexico")
        }

        public static var newYork: SimulatedLocation {
            .reference("New York, NY, USA")
        }

        public static var rioDeJaneiro: SimulatedLocation {
            .reference("Rio De Janeiro, Brazil")
        }
    }
}

extension RunActionOptions {
    @frozen
    public enum GPUFrameCaptureMode: String, Codable, Equatable {
        case autoEnabled
        case metal
        case openGL
        case disabled

        public static var `default`: GPUFrameCaptureMode {
            .autoEnabled
        }
    }
}
