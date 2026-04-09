import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ChatViewModel

    var body: some View {
        NavigationStack {
            if viewModel.apiKeyConfigured {
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
