import Foundation
import Network
import SystemConfiguration
import CoreWLAN
import CoreLocation

@MainActor
final class NetworkMonitorService: NSObject, CLLocationManagerDelegate {
    private var pathMonitor: NWPathMonitor?
    private var monitorQueue: DispatchQueue?
    private var pollingTimer: Timer?
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    var onUpdate: (([NetworkInterface]) -> Void)?
    private(set) var isLocationAuthorized: Bool = false

    func startMonitoring() {
        updateLocationStatus()
        requestLocationAuthorizationIfNeeded()
        refresh()

        let queue = DispatchQueue(label: "com.ipbar.networkmonitor")
        monitorQueue = queue
        let monitor = NWPathMonitor()
        pathMonitor = monitor
        monitor.pathUpdateHandler = { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
        monitor.start(queue: queue)

        pollingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func stopMonitoring() {
        pathMonitor?.cancel()
        pathMonitor = nil
        monitorQueue = nil
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    // MARK: - Location Authorization

    private func updateLocationStatus() {
        let status = locationManager.authorizationStatus
        let authorized = CLLocationManager.locationServicesEnabled()
            && status != .notDetermined
            && status != .denied
            && status != .restricted
        isLocationAuthorized = authorized
    }

    private func requestLocationAuthorizationIfNeeded() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.updateLocationStatus()
            self.refresh()
        }
    }

    func refresh() {
        let interfaces = fetchNetworkState()
        onUpdate?(interfaces)
    }

    // MARK: - Core Data Fetching

    nonisolated func fetchNetworkState() -> [NetworkInterface] {
        let primaryName = fetchPrimaryInterfaceName()
        let addresses = fetchAllAddresses()
        let classification = buildInterfaceClassification()
        let wifiSSID = fetchWiFiSSID()
        let displayNames = buildDisplayNameMap()

        var interfaceMap: [String: (ipv4: String?, ipv6: String?)] = [:]
        for (name, addr, isIPv4) in addresses {
            var current = interfaceMap[name] ?? (nil, nil)
            if isIPv4 {
                current.ipv4 = addr
            } else {
                current.ipv6 = addr
            }
            interfaceMap[name] = current
        }

        var results: [NetworkInterface] = []
        for (name, addrs) in interfaceMap {
            let type = classification[name] ?? classifyByName(name)
            let iface = NetworkInterface(
                id: name,
                name: name,
                type: type,
                ipv4Address: addrs.ipv4,
                ipv6Address: addrs.ipv6,
                isPrimary: name == primaryName,
                ssid: type == .wifi ? wifiSSID : nil,
                displayName: displayNames[name]
            )
            results.append(iface)
        }

        results.sort { lhs, rhs in
            if lhs.isPrimary != rhs.isPrimary { return lhs.isPrimary }
            if lhs.type.sortOrder != rhs.type.sortOrder { return lhs.type.sortOrder < rhs.type.sortOrder }
            return lhs.name < rhs.name
        }

        return results
    }

    // MARK: - Primary Interface via SCDynamicStore

    nonisolated func fetchPrimaryInterfaceName() -> String? {
        guard let store = SCDynamicStoreCreate(nil, "IPBar" as CFString, nil, nil) else {
            return nil
        }
        let key = "State:/Network/Global/IPv4" as CFString
        guard let dict = SCDynamicStoreCopyValue(store, key) as? [String: Any] else {
            return nil
        }
        return dict["PrimaryInterface"] as? String
    }

    // MARK: - All Addresses via getifaddrs

    nonisolated func fetchAllAddresses() -> [(name: String, address: String, isIPv4: Bool)] {
        var results: [(String, String, Bool)] = []
        var ifaddrPtr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddrPtr) == 0, let firstAddr = ifaddrPtr else {
            return results
        }
        defer { freeifaddrs(ifaddrPtr) }

        var current: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let addr = current {
            defer { current = addr.pointee.ifa_next }

            guard let sa = addr.pointee.ifa_addr else { continue }
            let family = sa.pointee.sa_family

            guard family == UInt8(AF_INET) || family == UInt8(AF_INET6) else { continue }

            let name = String(cString: addr.pointee.ifa_name)
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let saLen: socklen_t
            if family == UInt8(AF_INET) {
                saLen = socklen_t(MemoryLayout<sockaddr_in>.size)
            } else {
                saLen = socklen_t(MemoryLayout<sockaddr_in6>.size)
            }

            let result = getnameinfo(
                sa, saLen,
                &hostname, socklen_t(hostname.count),
                nil, 0,
                NI_NUMERICHOST
            )
            guard result == 0 else { continue }

            let addressString = String(cString: hostname)

            // Skip link-local IPv6 (fe80::)
            if family == UInt8(AF_INET6) && addressString.hasPrefix("fe80:") {
                continue
            }

            results.append((name, addressString, family == UInt8(AF_INET)))
        }

        return results
    }

    // MARK: - Interface Classification via SystemConfiguration

    nonisolated func buildInterfaceClassification() -> [String: InterfaceType] {
        var map: [String: InterfaceType] = [:]

        guard let scInterfaces = SCNetworkInterfaceCopyAll() as? [SCNetworkInterface] else {
            return map
        }

        for iface in scInterfaces {
            guard let bsdName = SCNetworkInterfaceGetBSDName(iface) as? String else { continue }
            let ifType = SCNetworkInterfaceGetInterfaceType(iface) as? String

            switch ifType {
            case "IEEE80211":
                map[bsdName] = .wifi
            case "Ethernet":
                map[bsdName] = .ethernet
            default:
                break
            }
        }

        return map
    }

    // MARK: - Display Names via SCNetworkService

    nonisolated func buildDisplayNameMap() -> [String: String] {
        var map: [String: String] = [:]

        // First, get hardware display names from SCNetworkInterface
        if let scInterfaces = SCNetworkInterfaceCopyAll() as? [SCNetworkInterface] {
            for iface in scInterfaces {
                guard let bsdName = SCNetworkInterfaceGetBSDName(iface) as? String,
                      let displayName = SCNetworkInterfaceGetLocalizedDisplayName(iface) as? String else { continue }
                map[bsdName] = displayName
            }
        }

        // Then, override with user-configured service names (more descriptive, e.g. "iPhone USB")
        guard let prefs = SCPreferencesCreate(nil, "IPBar" as CFString, nil),
              let services = SCNetworkServiceCopyAll(prefs) as? [SCNetworkService] else {
            return map
        }

        for svc in services {
            guard SCNetworkServiceGetEnabled(svc),
                  let iface = SCNetworkServiceGetInterface(svc),
                  let bsdName = SCNetworkInterfaceGetBSDName(iface) as? String,
                  let serviceName = SCNetworkServiceGetName(svc) as? String else { continue }
            map[bsdName] = serviceName
        }

        return map
    }

    // MARK: - Wi-Fi SSID

    nonisolated func fetchWiFiSSID() -> String? {
        CWWiFiClient.shared().interface()?.ssid()
    }

    // MARK: - Name-based Classification Fallback

    nonisolated func classifyByName(_ name: String) -> InterfaceType {
        if name.hasPrefix("utun") || name.hasPrefix("ipsec") || name.hasPrefix("ppp") {
            return .vpn
        }
        if name == "lo0" {
            return .loopback
        }
        if name.hasPrefix("pdp_ip") {
            return .cellular
        }
        return .other
    }
}
