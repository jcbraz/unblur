//
//  QuickLookMenu.swift
//  unblur
//
//  Created by Jose Braz on 13/01/2025.
//

import SwiftUI

struct QuickLookMenu: View {
    @StateObject private var store = PriorityStore()
    
    var body: some View {
        if store.dailyPriorities.isEmpty {
            Text("No priorities yet!")
        } else {
            VStack(alignment: .center, spacing: 15) {
                ForEach(store.dailyPriorities.sorted(by: { $0.priority < $1.priority })) { priority in
                    HStack {
                        Text(priority.text)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .padding()
        }
    }
}
