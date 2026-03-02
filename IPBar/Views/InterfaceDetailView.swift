import SwiftUI

struct InterfaceDetailView: View {
    let interfaces: [NetworkInterface]
    @ObservedObject var languageManager: LanguageManager
    @State private var isExpanded = true

    private var allInterfacesWithAddress: [NetworkInterface] {
        interfaces.filter { $0.hasAddress }
    }

    var body: some View {
        if !allInterfacesWithAddress.isEmpty {
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(allInterfacesWithAddress) { iface in
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Image(systemName: iface.type.iconName)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .frame(width: 16)
                                Text(iface.name)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                Text(iface.type.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                if iface.isPrimary {
                                    Text(languageManager.text(.primary))
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(Color.accentColor)
                                        .cornerRadius(3)
                                }
                            }

                            if let v4 = iface.ipv4Address {
                                HStack(spacing: 4) {
                                    Text(languageManager.text(.v4))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(width: 18, alignment: .leading)
                                    Button {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(v4, forType: .string)
                                    } label: {
                                        Text(v4)
                                            .font(.system(.caption, design: .monospaced))
                                    }
                                    .buttonStyle(.plain)
                                    .help(languageManager.text(.clickToCopy))
                                }
                                .padding(.leading, 20)
                            }

                            if let v6 = iface.ipv6Address {
                                HStack(spacing: 4) {
                                    Text(languageManager.text(.v6))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(width: 18, alignment: .leading)
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
                                .padding(.leading, 20)
                            }
                        }
                        if iface.id != allInterfacesWithAddress.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(.top, 4)
            } label: {
                HStack(spacing: 4) {
                    Text(languageManager.text(.allInterfaces))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(allInterfacesWithAddress.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
        }
    }
}
