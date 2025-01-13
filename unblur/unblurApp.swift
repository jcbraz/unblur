//
//  unblurApp.swift
//  unblur
//
//  Created by Jose Braz on 08/01/2025.
//

import SwiftUI

@main
struct UnblurApp: App {
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        .windowBackgroundDragBehavior(.automatic)
        .commands {
            CommandGroup(replacing: .appTermination) {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
        MenuBarExtra("unblur", systemImage: "rectangle.stack", isInserted: $showMenuBarExtra) {
            QuickLookMenu()
        }
    }
}
