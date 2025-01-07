import SwiftUI

@main
struct UnblurApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        .windowBackgroundDragBehavior(.automatic)
    }
}
