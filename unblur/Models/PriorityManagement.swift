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

    func getTodayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    func getYesterdayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        return formatter.string(from: yesterday!)
    }
    
    private func getDatabase() {
        let fileURL = try! FileManager.default
            .url(
                for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
                create: true
            )
            .appendingPathComponent("unblurv1.sqlite")

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

    func insertPriority(_ priority: Priority) -> Void {
        
        let insertSQL = """
                INSERT OR REPLACE INTO priorities (id, date, text, priority, is_edited)
                VALUES (?, ?, ?, ?, ?);
            """
        var insertStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, insertSQL, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (priority.id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (priority.date as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (priority.text as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 4, Int32(priority.priority))
            sqlite3_bind_int(insertStatement, 5, priority.isEdited ? 1 : 0)

            if sqlite3_step(insertStatement) != SQLITE_DONE {
                print("Error saving priority")
            }
        }

        sqlite3_finalize(insertStatement)
    }
    
    func upsertPriorities(_ priorities: [Priority]) -> Void {
        let currentDate = getTodayDateString()
        
        let deleteDailyPrioritiesCheckSQL = """
            DELETE FROM priorities WHERE date = ?;
        """
        var deleteStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteDailyPrioritiesCheckSQL, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, (currentDate as NSString).utf8String, -1, nil)
            
            if sqlite3_step(deleteStatement) != SQLITE_DONE {
                print("Error deleting daily priorities")
                if let errmsg = sqlite3_errmsg(db) {
                    print("SQLite error: \(String(cString: errmsg))")
                }
            }
        }
        
        sqlite3_finalize(deleteStatement)
        
        for priority in priorities {
            insertPriority(priority)
        }
    }

    func getPreviousDayPriorties() -> [Priority] {
        var priorities: [Priority] = []

        let yesterdayString = getYesterdayDateString()
        let defaultTaskNumber = getDefaultTaskNumber() ?? 3;

        let querySQL = """
                SELECT id, date, text, priority, is_edited
                FROM priorities
                WHERE date = ?
                ORDER BY priority ASC
                LIMIT ?;
            """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (yesterdayString as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(defaultTaskNumber))

            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let date = String(cString: sqlite3_column_text(statement, 1))
                let text = String(cString: sqlite3_column_text(statement, 2))
                let priority = Int(sqlite3_column_int(statement, 3))
                let isEdited = sqlite3_column_int(statement, 4) != 0

                priorities.append(
                    Priority(
                        id: id,
                        date: date,
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

        let todayString = getTodayDateString()
        let defaultTaskNumber = getDefaultTaskNumber() ?? 3;

        let querySQL = """
                SELECT
                    *
                FROM priorities
                WHERE date = ?
                ORDER BY priority ASC
                LIMIT ?;
            """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (todayString as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(defaultTaskNumber))

            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let date = String(cString: sqlite3_column_text(statement, 1))
                let text = String(cString: sqlite3_column_text(statement, 2))
                let priority = Int(sqlite3_column_int(statement, 3))
                let isEdited = sqlite3_column_int(statement, 4) != 0

                priorities.append(
                    Priority(
                        id: id,
                        date: date,
                        text: text,
                        priority: priority,
                        isEdited: isEdited
                    ))
            }
        }

        sqlite3_finalize(statement)
        return priorities
    }

    func updatePriority(_ priority: Priority) -> Void {
        let updateSQL = """
                UPDATE priorities SET date = ?, text = ?, priority = ?, is_edited = 1
                WHERE id = ?;
            """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (priority.date as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (priority.text as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(priority.priority))
            sqlite3_bind_int(statement, 4, priority.isEdited ? 1 : 0)
            sqlite3_bind_text(statement, 5, (priority.id as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error saving priority")
            }
        }

        sqlite3_finalize(statement)
    }

    func deletePriority(_ priorityText: String) -> Void {
        let deleteSQL = """
                DELETE FROM priorities 
                WHERE text = ? AND date LIKE ?;
            """

        var statement: OpaquePointer?

        let todayString = getTodayDateString()
        print(todayString)

        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (priorityText as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (todayString as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error deleting priority")
            }
        }

        sqlite3_finalize(statement)
    }
}
