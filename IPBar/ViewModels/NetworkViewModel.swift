import Foundation
import SwiftUI
import Combine

@MainActor
final class NetworkViewModel: ObservableObject {
    @Published private(set) var interfaces: [NetworkInterface] = []
    @Published private(set) var lastUpdated: Date = Date()
    @Published private(set) var isLocationAuthorized: Bool = false
    private let service = NetworkMonitorService()
    private var languageCancellable: AnyCancellable?

    var menuBarTitle: String {
        if let primary = primaryInterface {
            return primary.displayAddress
        }
        return LanguageManager.shared.text(.noIP)
    }

    var primaryInterface: NetworkInterface? {
        interfaces.first(where: { $0.isPrimary && $0.hasAddress })
    }

    var wifiInterfaces: [NetworkInterface] {
        interfaces.filter { $0.type == .wifi && $0.hasAddress && !$0.isPrimary }
    }

    var ethernetInterfaces: [NetworkInterface] {
        interfaces.filter { $0.type == .ethernet && $0.hasAddress && !$0.isPrimary }
    }

    var vpnInterfaces: [NetworkInterface] {
        interfaces.filter { $0.type == .vpn && $0.hasAddress }
    }

    var otherInterfaces: [NetworkInterface] {
        interfaces.filter {
            $0.type != .wifi && $0.type != .ethernet && $0.type != .vpn && $0.hasAddress
        }
    }

    func start() {
        service.onUpdate = { [weak self] interfaces in
            guard let self else { return }
            self.interfaces = interfaces
            self.lastUpdated = Date()
            self.isLocationAuthorized = self.service.isLocationAuthorized
        }
        service.startMonitoring()

        languageCancellable = LanguageManager.shared.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }

    func stop() {
        service.stopMonitoring()
    }

    func refresh() {
        service.refresh()
    }

    func copyCurrentIP() {
        guard let ip = primaryInterface?.displayAddress else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(ip, forType: .string)
    }

    func copyAllSummary() {
        let summary = interfaces
            .filter { $0.hasAddress }
            .map { iface -> String in
                var line = "\(iface.name) (\(iface.type.rawValue))"
                if iface.isPrimary { line += " *" }
                if let v4 = iface.ipv4Address { line += "\n  IPv4: \(v4)" }
                if let v6 = iface.ipv6Address { line += "\n  IPv6: \(v6)" }
                return line
            }
            .joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(summary, forType: .string)
    }
}
