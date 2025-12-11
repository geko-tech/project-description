import Foundation

@frozen
public enum PluginOS: Codable, Hashable {
    case macos
    case linux(arch: String)

    public static var current: PluginOS {
        #if os(macOS)
            .macos
        #else
            var sysinfo = utsname()
            uname(&sysinfo)
            let data = Data(bytes: &sysinfo.machine, count: Int(SYS_NMLN))
            let arch = String(bytes: data, encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
            return .linux(arch: arch)
        #endif
    }
}
