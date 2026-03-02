import SwiftUI

struct MenuBarPanel: View {
    @ObservedObject var viewModel: NetworkViewModel
    @ObservedObject var languageManager: LanguageManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let primary = viewModel.primaryInterface {
                ActiveInterfaceCard(
                    interface: primary,
                    isLocationAuthorized: viewModel.isLocationAuthorized,
                    languageManager: languageManager
                )
                Divider().padding(.horizontal, 12)
            } else {
                noNetworkView
                Divider().padding(.horizontal, 12)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !viewModel.wifiInterfaces.isEmpty {
                        InterfaceSummaryRow(
                            title: "Wi-Fi",
                            icon: "wifi",
                            interfaces: viewModel.wifiInterfaces,
                            languageManager: languageManager
                        )
                        .padding(.vertical, 8)
                        Divider()
                    }
                    if !viewModel.ethernetInterfaces.isEmpty {
                        InterfaceSummaryRow(
                            title: "Ethernet",
                            icon: "cable.connector",
                            interfaces: viewModel.ethernetInterfaces,
                            languageManager: languageManager
                        )
                        .padding(.vertical, 8)
                        Divider()
                    }
                    InterfaceDetailView(
                        interfaces: viewModel.interfaces,
                        languageManager: languageManager
                    )
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 12)
            }
            .frame(maxHeight: 300)

            Divider().padding(.horizontal, 12)

            ActionButtonsBar(viewModel: viewModel, languageManager: languageManager)
        }
        .frame(width: 320)
        .onAppear {
            viewModel.start()
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "," {
                    SettingsWindowController.shared.showSettings()
                    return nil
                }
                return event
            }
        }
        .onDisappear { viewModel.stop() }
    }

    private var noNetworkView: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .font(.title2)
                .foregroundColor(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(languageManager.text(.noNetwork))
                    .font(.headline)
                Text(languageManager.text(.noActiveConnection))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
    }
}
