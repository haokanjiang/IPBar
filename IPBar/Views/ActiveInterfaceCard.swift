import SwiftUI

struct ActiveInterfaceCard: View {
    let interface: NetworkInterface
    var isLocationAuthorized: Bool = true
    @ObservedObject var languageManager: LanguageManager

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: interface.type.iconName)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(interface.name)
                        .font(.headline)
                    Text("(\(interface.type.rawValue))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if let detail = interface.ssid ?? (interface.type != .wifi ? interface.displayName : nil) {
                        Text("·")
                            .foregroundColor(.secondary)
                        Text(detail)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }

                if interface.type == .wifi && interface.ssid == nil && !isLocationAuthorized {
                    Button {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "location.slash")
                                .font(.caption2)
                            Text(languageManager.text(.enableLocationServices))
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                    }
                    .buttonStyle(.plain)
                }

                if let v4 = interface.ipv4Address {
                    HStack(spacing: 4) {
                        Text(languageManager.text(.ipv4))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 30, alignment: .leading)
                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(v4, forType: .string)
                        } label: {
                            Text(v4)
                                .font(.system(.body, design: .monospaced))
                        }
                        .buttonStyle(.plain)
                        .help(languageManager.text(.clickToCopy))
                    }
                }

                if let v6 = interface.ipv6Address {
                    HStack(spacing: 4) {
                        Text(languageManager.text(.ipv6))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 30, alignment: .leading)
                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(v6, forType: .string)
                        } label: {
                            Text(v6)
                                .font(.system(.caption, design: .monospaced))
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        .buttonStyle(.plain)
                        .help(languageManager.text(.clickToCopy))
                    }
                }
            }
        }
        .padding(12)
    }
}
