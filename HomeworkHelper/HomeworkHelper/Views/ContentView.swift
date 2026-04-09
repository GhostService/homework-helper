import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ChatViewModel

    private var anyProviderConfigured: Bool {
        AIProvider.allCases.contains { viewModel.hasAPIKey(for: $0) }
    }

    var body: some View {
        NavigationStack {
            if anyProviderConfigured {
                HomeView()
            } else {
                SettingsView(isInitialSetup: true)
            }
        }
        .sheet(isPresented: $viewModel.showSettings) {
            NavigationStack {
                SettingsView(isInitialSetup: false)
            }
        }
    }
}
