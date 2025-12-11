import Foundation

/// Options for source file code generation.
@frozen
public enum FileCodeGen: String, Codable, Equatable {
    /// Public codegen
    case `public` = "codegen"
    /// Private codegen
    case `private` = "private_codegen"
    /// Project codegen
    case project = "project_codegen"
    /// Disabled codegen
    case disabled = "no_codegen"
}
