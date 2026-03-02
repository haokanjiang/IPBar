import Foundation

enum InterfaceType: String, CaseIterable, Sendable {
    case wifi = "Wi-Fi"
    case ethernet = "Ethernet"
    case vpn = "VPN"
    case loopback = "Loopback"
    case cellular = "Cellular"
    case other = "Other"

    var iconName: String {
        switch self {
        case .wifi: return "wifi"
        case .ethernet: return "cable.connector"
        case .vpn: return "lock.shield"
        case .loopback: return "arrow.triangle.2.circlepath"
        case .cellular: return "antenna.radiowaves.left.and.right"
        case .other: return "network"
        }
    }

    var sortOrder: Int {
        switch self {
        case .wifi: return 0
        case .ethernet: return 1
        case .vpn: return 2
        case .cellular: return 3
        case .loopback: return 4
        case .other: return 5
        }
    }
}

struct NetworkInterface: Identifiable, Sendable {
    let id: String
    let name: String
    let type: InterfaceType
    let ipv4Address: String?
    let ipv6Address: String?
    let isPrimary: Bool
    let ssid: String?
    let displayName: String?

    var displayAddress: String {
        ipv4Address ?? ipv6Address ?? "N/A"
    }

    var hasAddress: Bool {
        ipv4Address != nil || ipv6Address != nil
    }
}
