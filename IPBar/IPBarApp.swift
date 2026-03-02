import SwiftUI

@main
struct IPBarApp: App {
    @StateObject private var viewModel = NetworkViewModel()
    @StateObject private var languageManager = LanguageManager.shared

    var body: some Scene {
        MenuBarExtra(viewModel.menuBarTitle, systemImage: "network") {
            MenuBarPanel(viewModel: viewModel, languageManager: languageManager)
        }
        .menuBarExtraStyle(.window)
    }
}
