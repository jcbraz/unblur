//
//  Priority.swift
//  unblur
//
//  Created by Jose Braz on 05/01/2025.
//

import Foundation

struct PriorityContext {
    var defaultTaskNumber: Int
    var previousDayTaskView: Bool
}

struct Priority: Identifiable {
    let id: String
    var timestamp: TimeInterval
    var text: String
    var priority: Int
    var isEdited: Bool
}
