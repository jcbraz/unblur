//
//  ContextStore.swift
//  unblur
//
//  Created by Jose Braz on 05/01/2025.
//

import Foundation
import SQLite3

class ContextManagement {
    private var db: OpaquePointer?

    init() {
        setupDatabase()
    }

    private func setupDatabase() {
        let fileURL = try! FileManager.default
            .url(
                for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
                create: true
            )
            .appendingPathComponent("unblur.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            return
        }

        // Create tables
        let createTable = """
                CREATE TABLE IF NOT EXISTS priorities (
                    id TEXT PRIMARY KEY,
                    timestamp DOUBLE,
                    text TEXT,
                    priority INTEGER,
                    is_edited INTEGER
                );
                CREATE TABLE IF NOT EXISTS settings (
                    default_task_number INTEGER,
                    previous_day_task_view INTEGER
                );
            """

        if sqlite3_exec(db, createTable, nil, nil, nil) != SQLITE_OK {
            print("Error creating table")
            return
        }
    }

    func checkDatabaseExistence() -> Bool {
        let fileURL = try! FileManager.default
            .url(
                for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
                create: true
            )
            .appendingPathComponent("unblur.sqlite")

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return false
        }

        // Open database connection if not already open
        if db == nil {
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("Error opening database")
                return false
            }
        }

        // Check if the settings table has data
        let querySQL = "SELECT COUNT(*) FROM settings;"
        var statement: OpaquePointer?
        var rowCount = 0

        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                rowCount = Int(sqlite3_column_int(statement, 0))
            }
        }

        sqlite3_finalize(statement)
        return rowCount > 0
    }

    func savePriority(_ priority: Priority) {
        let insertSQL = """
                INSERT OR REPLACE INTO priorities (id, timestamp, text, priority, is_edited)
                VALUES (?, ?, ?, ?, ?);
            """
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (priority.id as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 2, priority.timestamp)
            sqlite3_bind_text(statement, 3, (priority.text as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 4, Int32(priority.priority))
            sqlite3_bind_int(statement, 5, priority.isEdited ? 1 : 0)

            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error saving priority")
            }
        }

        sqlite3_finalize(statement)
    }

    func saveSettings(_ context: PriorityContext) {
        let insertSQL = """
                INSERT OR REPLACE INTO settings (default_task_number, previous_day_task_view)
                VALUES (?, ?);
            """
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(context.defaultTaskNumber))
            sqlite3_bind_int(statement, 2, context.previousDayTaskView ? 1 : 0)

            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error saving settings")
            }
        }

        sqlite3_finalize(statement)
    }

    func loadSettings() -> PriorityContext {
        let querySQL = "SELECT default_task_number, previous_day_task_view FROM settings LIMIT 1;"
        var statement: OpaquePointer?
        var context = PriorityContext(defaultTaskNumber: 3, previousDayTaskView: true)

        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                context.defaultTaskNumber = Int(sqlite3_column_int(statement, 0))
                context.previousDayTaskView = sqlite3_column_int(statement, 1) != 0
            }
        }

        sqlite3_finalize(statement)
        return context
    }
    
    func getDefaultTaskNumber() -> Int {
        let querySQL = "SELECT default_task_number FROM settings LIMIT 1;"
        var statement: OpaquePointer?
        var defaultTaskNumber: Int = 0
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                defaultTaskNumber = Int(sqlite3_column_int(statement, 0))
            }
        }
        
        if defaultTaskNumber == 0 {
            defaultTaskNumber = 3
        }
        
        sqlite3_finalize(statement)
        return defaultTaskNumber
    }
    
    func updateDefaultTaskNumber(_ oldValue: Int, _ newValue: Int) -> Void {
        let updateSQL = "UPDATE settings SET default_task_number = ? WHERE default_task_number = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(newValue))
            sqlite3_bind_int(statement, 2, Int32(oldValue))
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error updating default task number")
        }
        
        sqlite3_finalize(statement)
    }
}
