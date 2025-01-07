//
//  StorageService.swift
//  unblur
//
//  Created by Jose Braz on 05/01/2025.
//

import CoreData

class StorageService {
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "unblur")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func loadPreviousDayTasks() {
        
    }
    
    func saveTasks(tasks: [Priority]) {
        let context = container.viewContext
        // Save logic here
        try? context.save()
    }
}
