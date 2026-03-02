import SwiftUI

struct ActionButtonsBar: View {
    @ObservedObject var viewModel: NetworkViewModel
    @ObservedObject var languageManager: LanguageManager

    var body: some View {
        HStack(spacing: 0) {
            Button {
                viewModel.refresh()
            } label: {
                Label(languageManager.text(.refresh), systemImage: "arrow.clockwise")
                    .font(.caption)
            }
            .buttonStyle(.borderless)

            Spacer()

            Button {
                viewModel.copyCurrentIP()
            } label: {
                Label(languageManager.text(.copyIP), systemImage: "doc.on.doc")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .disabled(viewModel.primaryInterface == nil)

            Spacer()

            Button {
                viewModel.copyAllSummary()
            } label: {
                Label(languageManager.text(.copyAll), systemImage: "doc.on.clipboard")
                    .font(.caption)
            }
            .buttonStyle(.borderless)

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label(languageManager.text(.quit), systemImage: "power")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
