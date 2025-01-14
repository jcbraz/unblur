//
//  PriorityStore.swift
//  unblur
//
//  Created by Jose Braz on 14/01/2025.
//

import SwiftUI

class PriorityStore: ObservableObject {
    @Published var dailyPriorities: [Priority] = []
    private let priorityManager = PriorityManagement()
    
    func refreshPriorities() {
        dailyPriorities = priorityManager.getCurrentDayPriorities()
    }
    
    init() {
        refreshPriorities()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePrioritiesUpdate),
            name: .prioritiesDidUpdate,
            object: nil
        )
    }
    
    @objc private func handlePrioritiesUpdate() {
        refreshPriorities()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
