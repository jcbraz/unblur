//
//  StatusBarController.swift
//  unblur
//
//  Created by Jose Braz on 08/01/2025.
//

import SwiftUI
import AppKit

class StatusBarController {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var priorityManager: PriorityManagement
    
    init(priorityManager: PriorityManagement) {
        self.priorityManager = priorityManager
        
        // Initialize popover first
        self.popover = NSPopover()
        self.popover.behavior = .transient
        self.popover.animates = true
        
        // Initialize status item
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Configure status item after initialization
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "Priorities")
            button.image?.size = NSSize(width: 18, height: 18)
            button.target = self
            button.action = #selector(togglePopover(_:))
        }
        
        // Update popover content after all properties are initialized
        updatePopoverContent()
        
        // Add notification observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePriorityUpdate),
            name: NSNotification.Name("PrioritiesDidUpdate"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handlePriorityUpdate() {
        updatePopoverContent()
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                updatePopoverContent()
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
    
    private func updatePopoverContent() {
        let priorities = priorityManager.getCurrentDayPriorities()
        let contentView = StatusBarPrioritiesView(
            priorities: priorities,
            priorityManager: priorityManager
        )
        popover.contentViewController = NSHostingController(rootView: contentView)
    }
}
