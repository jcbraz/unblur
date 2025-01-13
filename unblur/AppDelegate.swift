//
//  AppDelegate.swift
//  unblur
//
//  Created by Jose Braz on 08/01/2025.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    let priorityManager = PriorityManagement()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
      let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
      if let button = statusBarItem.button {
        button.image = NSImage(named: NSImage.Name("rectangle.stack"))
        button.title = "unblur"
        button.action = #selector(statusBarButtonClicked(_:))
        button.target = self
        button.title = "Open Window"
      }
    }
    
    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
      print("Menu item clicked")
      // We'll implement the window handling logic here
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            let contentView = ContentView()
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 500),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.center()
            window.contentView = NSHostingView(rootView: contentView)
            window.makeKeyAndOrderFront(nil)
        }
        return true
    }
}
