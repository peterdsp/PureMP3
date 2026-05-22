import SwiftUI

@main
struct PureMP3App: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: AppViewModel())
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 940, height: 620)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
