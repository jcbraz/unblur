//
//  unblurApp.swift
//  unblur
//
//  Created by Jose Braz on 08/01/2025.
//

import SwiftUI
import LaunchAtLogin

@main
struct UnblurApp: App {
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    @State private var launchAtLoginEnabled: Bool = true
    
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
        
        MenuBarExtra {
            QuickLookMenu()
        } label: {
            Label("unblur", systemImage: "rectangle.stack")
        }
        
        Settings {
            Form {
                LaunchAtLogin.Toggle()
            }
        }
    }
}
