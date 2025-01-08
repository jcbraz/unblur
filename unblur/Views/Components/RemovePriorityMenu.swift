//
//  RemovePriorityMenu.swift
//  unblur
//
//  Created by Jose Braz on 07/01/2025.
//

import SwiftUI

struct RemovePriorityMenu: View {
    @State var selectedPriority: Priority? = nil
    @Binding var isRemovingPriority: Bool
    @Binding var priorities: [Priority]
    
    let priorityManager: PriorityManagement
    
    var body: some View {
        VStack {
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
                    Text(selectedPriority != nil ? selectedPriority!.text : "Select Priority")
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                VStack {
                    Button(action: handlePriorityRemoval) {
                        Text("Submit Removal")
                    }
                    
                    Button(action: {
                        isRemovingPriority = false
                    }) {
                        Text("Cancel Removal")
                    }
                }
            }
        }
        .padding()
    }
    
    private func handlePriorityRemoval() {
        guard let selectedPriority else {
            print("No Priority Selected!")
            return
        }
        
        priorities.removeAll(where: { $0.id == selectedPriority.id })
        for (index, priority) in priorities.enumerated() {
            if priority.priority >= selectedPriority.priority {
                priorities[index].priority -= 1
                priorityManager.updatePriority(priorities[index])
            }
        }
        
        priorityManager.deletePriority(selectedPriority.text)
        
        self.selectedPriority = nil
        self.isRemovingPriority = false
    }
}
