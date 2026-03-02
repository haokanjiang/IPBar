import SwiftUI

struct InterfaceSummaryRow: View {
    let title: String
    let icon: String
    let interfaces: [NetworkInterface]
    @ObservedObject var languageManager: LanguageManager

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 18)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }

            ForEach(interfaces) { iface in
                HStack(spacing: 4) {
                    Text(iface.name)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(width: 55, alignment: .leading)
                    if let detail = iface.ssid ?? iface.displayName {
                        Text(detail)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(iface.displayAddress, forType: .string)
                    } label: {
                        Text(iface.displayAddress)
                            .font(.system(.footnote, design: .monospaced))
                    }
                    .buttonStyle(.plain)
                    .help(languageManager.text(.clickToCopy))
                    Spacer()
                }
                .padding(.leading, 24)
            }
        }
    }
}
