//
//  AddNewPriorityMenu.swift
//  unblur
//
//  Created by Jose Braz on 07/01/2025.
//

import SwiftUI

struct AddNewPriorityMenu: View {
    @Binding var isAddingPriority: Bool
    @Binding var additionalPriorityText: String?
    @Binding var additionalPriorityLevel: Int?
    @Binding var priorities: [Priority] // Make priorities mutable via a Binding
    let priorityManager: PriorityManagement
    
    var body: some View {
        VStack {
            HStack {
                // TextField for entering the priority
                TextField("Enter priority", text: Binding(
                    get: { additionalPriorityText ?? "" },
                    set: { additionalPriorityText = $0 }
                ))
                .textFieldStyle(PlainTextFieldStyle())
                .padding(8)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
                
                // Menu for selecting priority level
                Menu {
                    ForEach(1...(priorities.count+1), id: \.self) { level in
                        Button(action: {
                            additionalPriorityLevel = level
                        }) {
                            Text("\(level)")
                        }
                    }
                } label: {
                    HStack {
                        Text(additionalPriorityLevel != nil ? "\(additionalPriorityLevel!)" : "Priority Level")
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                
                // Submit button
                Button(action: handlePriorityAddition) {
                    Text("Submit")
                }
            }
        }
        .padding()
    }
    
    private func handlePriorityAddition() {
        guard let additionalPriorityText = additionalPriorityText,
              let additionalPriorityLevel = additionalPriorityLevel else {
            print("Text or Level not provided")
            return
        }
        
        let incomingPriority = Priority(
            id: UUID().uuidString,
            timestamp: Date().timeIntervalSince1970,
            text: additionalPriorityText,
            priority: additionalPriorityLevel,
            isEdited: false
        )
        
        priorities.append(incomingPriority)
        priorityManager.insertPriority(incomingPriority)
        
        self.additionalPriorityText = nil
        self.additionalPriorityLevel = nil
        self.isAddingPriority = false
    }
}
