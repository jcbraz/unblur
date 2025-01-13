//
//  StatusBarPrioritiesView.swift
//  unblur
//
//  Created by Jose Braz on 08/01/2025.
//
import SwiftUI

struct StatusBarPrioritiesView: View {
    @State var priorities: [Priority]
    let priorityManager: PriorityManagement
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Priorities")
                .font(.system(size: 14, weight: .bold))
                .padding(.bottom, 4)
            
            if priorities.isEmpty {
                Text("No priorities set for today")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            } else {
                ForEach(priorities.sorted(by: { $0.priority < $1.priority })) { priority in
                    HStack(spacing: 8) {
                        Text("\(priority.priority).")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                        Text(priority.text)
                            .font(.system(size: 12))
                    }
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            HStack {
                Button("Open App") {
                    NSApp.activate(ignoringOtherApps: true)
                    if let window = NSApp.windows.first {
                        window.makeKeyAndOrderFront(nil)
                    } else {
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
                }
                .font(.system(size: 12))
                
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .font(.system(size: 12))
            }
        }
        .padding(12)
        .frame(width: 300)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(colorScheme == .dark ? .darkGray : .white).opacity(0.1),
                    Color(colorScheme == .dark ? .black : .gray).opacity(0.2),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
