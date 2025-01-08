//
//  EditPriorityMenu.swift
//  unblur
//
//  Created by Jose Braz on 08/01/2025.
//

import SwiftUI

struct EditPriorityMenu: View {
    @Binding var isEditingPriority: Bool
    @Binding var priorities: [Priority]
    @State var selectedPriority: Priority? = nil
    @State var newPriorityText: String? = nil
    @State var newPriorityLevel: Int? = nil
    
    let priorityManager: PriorityManagement
    
    var body: some View {
        HStack {
            Menu {
                ForEach(priorities) { priority in
                    Button(action: {
                        selectedPriority = priority
                    }) {
                        Text("\(priority.text)")
                    }
                }
            } label: {
                Text(selectedPriority != nil ? selectedPriority!.text : "Select Priority To Edit")
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            
            TextField(
                "New Property Description",
                text: Binding(
                    get: { newPriorityText ?? "" },
                    set: { newPriorityText = $0 }
                )
            )
            .textFieldStyle(PlainTextFieldStyle())
            .padding(8)
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
            
            // Menu for selecting priority level
            Menu {
                ForEach(1...(priorities.count), id: \.self) { level in
                    Button(action: {
                        newPriorityLevel = level
                    }) {
                        Text("\(level)")
                    }
                }
            } label: {
                HStack {
                    Text(
                        newPriorityLevel != nil
                        ? "\(newPriorityLevel!)" : "New Priority Level")
                }
                .padding(8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            
            VStack {
                Button(action: handlePriorityEdit) {
                    Text("Submit Edit")
                }
                
                Button(action: {
                    isEditingPriority = false
                }) {
                    Text("Cancel Edit")
                }
            }
        }
    }
    
    private func handlePriorityEdit() -> Void {
        guard let selectedPriority = selectedPriority, let newPriorityText = newPriorityText, let newPriorityLevel = newPriorityLevel  else {
            print("No Priority Selected!")
            return
        }
        
        let newPriority = Priority(
            id: selectedPriority.id,
            timestamp: Date().timeIntervalSince1970,
            text: newPriorityText,
            priority: newPriorityLevel,
            isEdited: true
        )
        
        priorities = priorities.map { priority in
            if priority.id == selectedPriority.id {
                return newPriority
            }
            return priority
        }
        
        for (index, priority) in priorities.enumerated() {
            if priority.priority >= newPriorityLevel && priority.text != newPriorityText {
                priorities[index].priority += 1
                priorityManager.updatePriority(priorities[index])
            }
        }
        
        priorities.sort { $0.priority < $1.priority }
        priorityManager.updatePriority(newPriority)
        
        self.selectedPriority = nil
        self.newPriorityText = nil
        self.newPriorityLevel = nil
        self.isEditingPriority = false
    }
}
