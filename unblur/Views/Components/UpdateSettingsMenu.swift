//
//  UpdateSettingsMenu.swift
//  unblur
//
//  Created by Jose Braz on 09/01/2025.
//

import SwiftUI

struct UpdateSettingsMenu: View {
    @Binding var isUpdatingSettings: Bool
    @State var selectedDefaultTaskValue: Int? = nil
    
    
    let contextManager: ContextManagement
    
    var body: some View {
        HStack {
            Menu {
                ForEach(1...10, id: \.self) { number in
                    Button(action: {
                        selectedDefaultTaskValue = number
                    }) {
                        Text("\(number)")
                    }
                }
            } label: {
                Text(selectedDefaultTaskValue != nil ? selectedDefaultTaskValue!.description : "Select New Default Task Value")
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            VStack {
                Button(action: handleDefaultTaskValueUpdate) {
                    Text("Submit Update")
                }
                
                Button(action: {
                    isUpdatingSettings = false
                }) {
                    Text("Cancel Update")
                }
            }
        }
    }
    
    private func handleDefaultTaskValueUpdate() {
        guard let selectedDefaultTaskValue = selectedDefaultTaskValue else {
                print("No value selected")
                return
        }
        
        let currentDefaultTaskNumber = contextManager.getDefaultTaskNumber()
        contextManager.updateDefaultTaskNumber(currentDefaultTaskNumber, selectedDefaultTaskValue)
        
        self.selectedDefaultTaskValue = nil
        self.isUpdatingSettings = false
        
    }
}
