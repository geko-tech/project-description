import Foundation

func dumpIfNeeded(_ entity: some Encodable) {
    guard CommandLine.argc > 0,
          CommandLine.arguments.contains("--geko-dump")
    else { return }
    let encoder = JSONEncoder()
    // swiftlint:disable:next force_try
    let data = try! encoder.encode(entity)
    let manifest = String(data: data, encoding: .utf8)!
    print("GEKO_MANIFEST_START")
    print(manifest)
    print("GEKO_MANIFEST_END")
}
