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
    @Binding var priorities: [Priority]
    let priorityManager: PriorityManagement

    var body: some View {
        VStack {
            HStack {
                TextField(
                    "Enter priority",
                    text: Binding(
                        get: { additionalPriorityText ?? "" },
                        set: { additionalPriorityText = $0 }
                    )
                )
                .textFieldStyle(PlainTextFieldStyle())
                .padding(8)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)

                // Menu for selecting priority level
                Menu {
                    ForEach(1...(priorities.count + 1), id: \.self) { level in
                        Button(action: {
                            additionalPriorityLevel = level
                        }) {
                            Text("\(level)")
                        }
                    }
                } label: {
                    HStack {
                        Text(
                            additionalPriorityLevel != nil
                                ? "\(additionalPriorityLevel!)" : "Priority Level")
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }

                VStack {
                    Button(action: handlePriorityAddition) {
                        Text("Submit Addition")
                    }
                    
                    Button(action: {
                        isAddingPriority = false
                    }) {
                        Text("Cancel Addition")
                    }
                }
            }
        }
        .padding()
    }

    private func handlePriorityAddition() {
        guard let additionalPriorityText = additionalPriorityText,
            let additionalPriorityLevel = additionalPriorityLevel
        else {
            print("Text or Level not provided")
            return
        }

        let incomingPriority = Priority(
            id: UUID().uuidString,
            date: priorityManager.getTodayDateString(),
            text: additionalPriorityText,
            priority: additionalPriorityLevel,
            isEdited: false
        )

        for (index, priority) in priorities.enumerated() {
            if priority.priority >= additionalPriorityLevel {
                priorities[index].priority += 1
                priorityManager.updatePriority(priorities[index])
            }
        }
        priorities.append(incomingPriority)
        priorities.sort { $0.priority < $1.priority }

        priorityManager.insertPriority(incomingPriority)

        self.additionalPriorityText = nil
        self.additionalPriorityLevel = nil
        self.isAddingPriority = false
    }
}
