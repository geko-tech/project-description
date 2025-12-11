import Foundation

@frozen
public enum LaunchStyle: Codable {
    case automatically
    case waitForExecutableToBeLaunched
}
