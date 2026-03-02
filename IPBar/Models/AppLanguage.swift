import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case chinese = "zh"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
        }
    }
}

enum LocalizedKey {
    case refresh
    case copyIP
    case copyAll
    case quit
    case settings
    case noIP
    case noNetwork
    case noActiveConnection
    case enableLocationServices
    case clickToCopy
    case ipv4
    case ipv6
    case allInterfaces
    case primary
    case v4
    case v6
    case language
}

private let localizedStrings: [LocalizedKey: [AppLanguage: String]] = [
    .refresh: [.english: "Refresh", .chinese: "刷新"],
    .copyIP: [.english: "Copy IP", .chinese: "复制 IP"],
    .copyAll: [.english: "Copy All", .chinese: "复制全部"],
    .quit: [.english: "Quit", .chinese: "退出"],
    .settings: [.english: "Settings", .chinese: "设置"],
    .noIP: [.english: "No IP", .chinese: "无 IP"],
    .noNetwork: [.english: "No Network", .chinese: "无网络"],
    .noActiveConnection: [.english: "No active network connection detected", .chinese: "未检测到活跃的网络连接"],
    .enableLocationServices: [.english: "Enable Location Services for Wi-Fi name", .chinese: "启用定位服务以显示 Wi-Fi 名称"],
    .clickToCopy: [.english: "Click to copy", .chinese: "点击复制"],
    .ipv4: [.english: "IPv4", .chinese: "IPv4"],
    .ipv6: [.english: "IPv6", .chinese: "IPv6"],
    .allInterfaces: [.english: "All Interfaces", .chinese: "所有接口"],
    .primary: [.english: "Primary", .chinese: "主要"],
    .v4: [.english: "v4", .chinese: "v4"],
    .v6: [.english: "v6", .chinese: "v6"],
    .language: [.english: "Language", .chinese: "语言"],
]

@MainActor
final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    private static let storageKey = "app_language"

    @Published var current: AppLanguage {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: Self.storageKey)
        }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: Self.storageKey) ?? ""
        self.current = AppLanguage(rawValue: saved) ?? .english
    }

    func text(_ key: LocalizedKey) -> String {
        localizedStrings[key]?[current] ?? ""
    }
}
