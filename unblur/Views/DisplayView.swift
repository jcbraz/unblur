//
//  DisplayView.swift
//  unblur
//
//  Created by Jose Braz on 05/01/2025.
//

import SwiftUI

struct DisplayView: View {
    @State var priorities: [Priority]
    @State private var selectedAction: ActionType?
    @State private var isAddingPriority: Bool = false
    @State private var isEdittingPriority: Bool = false
    @State private var isRemovingPriority: Bool = false
    @State private var additionalPriorityText: String? = nil
    @State private var additionalPriorityLevel: Int? = nil
    @Binding var showDisplayView: Bool
    @Environment(\.colorScheme) var colorScheme

    let priorityManager: PriorityManagement

    enum ActionType {
        case add, edit, rewrite, remove
    }

    var body: some View {
        ZStack {
            // Centered content
            VStack(spacing: 20) {
                Text("Your Priorities for Today")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)

                VStack(alignment: .center, spacing: 15) {
                    ForEach(priorities.sorted(by: { $0.priority < $1.priority })) { priority in
                        HStack {
                            Text("\(priority.priority).")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16, weight: .medium))
                            Text(priority.text)
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                }
                .padding()
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                HStack {
                    Spacer()
                    if isAddingPriority {
                        AddNewPriorityMenu(
                            isAddingPriority: $isAddingPriority,
                            additionalPriorityText: $additionalPriorityText,
                            additionalPriorityLevel: $additionalPriorityLevel,
                            priorities: $priorities,
                            priorityManager: priorityManager
                        )
                    } else if isRemovingPriority {
                        RemovePriorityMenu(
                            isRemovingPriority: $isRemovingPriority,
                            priorities: $priorities,
                            priorityManager: priorityManager
                        )
                    } else if isEdittingPriority {
                        EditPriorityMenu(
                            isEditingPriority: $isEdittingPriority,
                            priorities: $priorities,
                            priorityManager: priorityManager
                        )
                    } else {
                        MenuButton()
                    }
                }
                Spacer()
            }
            .padding()
        }
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

    private func MenuButton() -> some View {
        Menu {
            Button(action: { handleAction(.add) }) {
                Label("Add New Priority", systemImage: "plus")
            }

            Button(action: { handleAction(.edit) }) {
                Label("Edit Priorities", systemImage: "pencil")
            }

            Button(role: .destructive, action: { handleAction(.rewrite) }) {
                Label("Re-Write Priorities", systemImage: "arrow.triangle.2.circlepath")
            }
            
            Button(role: .destructive, action: { handleAction(.remove) }) {
                Label("Remove Priority", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .background(Color.clear)
                .contentShape(Rectangle())
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .frame(width: 44, height: 44)
    }

    private func handleAction(_ action: ActionType?) {
        guard let action = action else { return }
        switch action {
        case .add:
            isAddingPriority = true
        case .edit:
            isEdittingPriority = true
        case .rewrite:
            for element in priorities {
                priorityManager.deletePriority(element.text)
            }
            priorities = []
            showDisplayView = false
        case .remove:
            isRemovingPriority = true
        }
    }

}
