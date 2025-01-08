//
//  PriorityInputView.swift
//  unblur
//
//  Created by Jose Braz on 08/01/2025.
//

import SwiftUI

struct PriorityInputView: View {
    @Binding var priorities: [String]
    @FocusState private var focusedField: Int?
    @Environment(\.colorScheme) var colorScheme
    let onSave: () -> Void
    
    private func handleReturnKey(index: Int) {
        if index < priorities.count - 1 {
            focusedField = index + 1
        } else {
            focusedField = nil
            onSave()
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 13) {
            ForEach(priorities.indices, id: \.self) { index in
                HStack {
                    Text("\(index + 1).")
                        .foregroundColor(.secondary)
                        .frame(width: 14, alignment: .leading)
                    TextField("Priority \(index + 1)", text: $priorities[index])
                        .textFieldStyle(PlainTextFieldStyle())
                        .focused($focusedField, equals: index)
                        .onSubmit {
                            handleReturnKey(index: index)
                        }
                        .padding(8)
                        .background(
                            colorScheme == .dark
                                ? Color.black.opacity(0.3)
                                : Color.white.opacity(0.3)
                        )
                        .cornerRadius(8)
                }
            }
        }
        .onAppear {
            focusedField = 0
        }
    }
}
