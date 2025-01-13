//
//  PriorityStore.swift
//  unblur
//
//  Created by Jose Braz on 05/01/2025.
//

import Foundation
import SQLite3

class PriorityManagement {
    private var db: OpaquePointer?

    init() {
        getDatabase()
    }

    private func getDatabase() {
        let fileURL = try! FileManager.default
            .url(
                for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
                create: true
            )
            .appendingPathComponent("priorities.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            return
        }
    }
    
    private func getDefaultTaskNumber() -> Int? {
        var taskNumber: Int = 0
        
        let querySQL = """
            SELECT
                default_task_number
            FROM settings
            LIMIT 1;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                taskNumber = Int(sqlite3_column_int(statement, 0))
            }
        } else {
            print("Error getting default task number")
            return nil
        }
        
        sqlite3_finalize(statement)
        
        return taskNumber
    }

    func insertPriority(_ priority: Priority) {
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

    func getPreviousDayPriorties() -> [Priority] {
        var priorities: [Priority] = []

        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
        let endOfYesterday = startOfToday.addingTimeInterval(-1)

        let startTimestamp = startOfYesterday.timeIntervalSince1970
        let endTimestamp = endOfYesterday.timeIntervalSince1970
        
        let defaultTaskNumber = getDefaultTaskNumber() ?? 3;

        let querySQL = """
                SELECT id, timestamp, text, priority, is_edited
                FROM priorities
                WHERE timestamp >= ? AND timestamp <= ?
                ORDER BY priority ASC
                LIMIT ?;
            """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_double(statement, 1, startTimestamp)
            sqlite3_bind_double(statement, 2, endTimestamp)
            sqlite3_bind_int(statement, 3, Int32(defaultTaskNumber))

            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let timestamp = sqlite3_column_double(statement, 1)
                let text = String(cString: sqlite3_column_text(statement, 2))
                let priority = Int(sqlite3_column_int(statement, 3))
                let isEdited = sqlite3_column_int(statement, 4) != 0

                priorities.append(
                    Priority(
                        id: id,
                        timestamp: timestamp,
                        text: text,
                        priority: priority,
                        isEdited: isEdited
                    ))
            }
        }

        sqlite3_finalize(statement)
        return priorities
    }
    
    func getCurrentDayPriorities() -> [Priority] {
        var priorities: [Priority] = []

        let calendar = Calendar.current
        let startOfTodayTimestamp = calendar.startOfDay(for: .now).timeIntervalSince1970
        let defaultTaskNumber = getDefaultTaskNumber() ?? 3;

        let querySQL = """
                SELECT *
                FROM (
                    SELECT id, timestamp, text, priority, is_edited
                    FROM priorities
                    ORDER BY timestamp DESC
                    LIMIT ?
                )
                ORDER BY priority ASC
            """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_double(statement, 1, startOfTodayTimestamp)
            sqlite3_bind_int(statement, 3, Int32(defaultTaskNumber))

            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let timestamp = sqlite3_column_double(statement, 1)
                let text = String(cString: sqlite3_column_text(statement, 2))
                let priority = Int(sqlite3_column_int(statement, 3))
                let isEdited = sqlite3_column_int(statement, 4) != 0

                priorities.append(
                    Priority(
                        id: id,
                        timestamp: timestamp,
                        text: text,
                        priority: priority,
                        isEdited: isEdited
                    ))
            }
        }

        sqlite3_finalize(statement)
        return priorities
    }

    func updatePriority(_ priority: Priority) {
        let updateSQL = """
                UPDATE priority SET timestamp = ?, text = ?, priority = ?, is_edited = 1
                WHERE id = ?;
            """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_double(statement, 1, priority.timestamp)
            sqlite3_bind_text(statement, 2, (priority.text as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(priority.priority))
            sqlite3_bind_int(statement, 4, priority.isEdited ? 1 : 0)
            sqlite3_bind_text(statement, 5, (priority.id as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error saving priority")
            }
        }

        sqlite3_finalize(statement)
        
        print("Updated priority \(priority.text), \(priority.priority)")
    }

    func deletePriority(_ priorityText: String) {
        let deleteSQL = """
                DELETE FROM priority 
                WHERE text = ? AND timestamp >= ?;
            """

        var statement: OpaquePointer?

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startTimestamp = startOfToday.timeIntervalSince1970

        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (priorityText as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 2, startTimestamp)
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error deleting priority")
            }
        }

        sqlite3_finalize(statement)
        print("DELETED PRIORITY WITH TEXT", priorityText)
    }
}
