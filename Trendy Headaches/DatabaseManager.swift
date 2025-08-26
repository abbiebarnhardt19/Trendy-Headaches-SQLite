import Foundation
import SQLite

enum DatabaseError: Error {
    case connectionFailed
}

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection!
    
    // tables
    let users = Table("Users")
    let painTypes = Table("Pain_Types")
    let medications = Table("Medications")
    let triggers = Table("Triggers")
    let logs = Table("Logs")
    let logTriggers = Table("Log_Triggers")
    
    // columns
    // users columns
    let user_id = SQLite.Expression<Int64>("user_id")
    let first_name = SQLite.Expression<String>("first_name")
    let email = SQLite.Expression<String>("email")
    let phone_number = SQLite.Expression<String>("phone_number")
    let birthday = SQLite.Expression<Date>("birthday")
    let password = SQLite.Expression<String>("password")
    
    // pain types
    let pain_type_id = SQLite.Expression<Int64>("pain_type_id")
    let pain_type_name = SQLite.Expression<String>("pain_type_name")
    
    // medications
    let med_id = SQLite.Expression<Int64>("med_id")
    let med_category = SQLite.Expression<String>("med_category")
    let med_name = SQLite.Expression<String>("med_name")
    let current_prescription = SQLite.Expression<String>("current_prescription")
    let start_date = SQLite.Expression<Date>("start_date")
    let end_date = SQLite.Expression<Date?>("end_date")
    
    // triggers
    let trigger_id = SQLite.Expression<Int64>("trigger_id")
    let trigger_name = SQLite.Expression<String>("trigger_name")
    
    // logs
    let log_id = SQLite.Expression<Int64>("log_id")
    let date = SQLite.Expression<Date>("date")
    let time = SQLite.Expression<String>("time")
    let pain_level = SQLite.Expression<Int>("pain_level")
    let med_taken = SQLite.Expression<Bool>("med_taken")
    let med_worked = SQLite.Expression<Bool>("med_worked")
    let pain_description = SQLite.Expression<String>("pain_description")
    let notes = SQLite.Expression<String>("notes")
    
    // log triggers
    // no unique ID, composite primary key of log_id and trigger_id
    
    // initialize
    private init() {
        connect()
        createTables()
    }
    
    private func connect() {
        do {
            // get file path for the database
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let dbPath = "\(documentsDirectory)/headache_tracker.sqlite3"
            
            // create database
            db = try Connection(dbPath)
            
            // enable foreign keys
            db.foreignKeys = true
            
            // print the **full path to the DB file**
            print("Database full path: \(dbPath)")
        } catch {
            print("Database connection error: \(error)")
        }
    }
    
    private func createTables() {
        //create each table
        do {
            // Users
            try db.run(users.create(ifNotExists: true) { t in
                t.column(user_id, primaryKey: .autoincrement)
                t.column(first_name)
                t.column(email, unique: true)
                t.column(phone_number)
                t.column(birthday)
                t.column(password)
            })
            
            // Pain_Types
            try db.run(painTypes.create(ifNotExists: true) { t in
                t.column(pain_type_id, primaryKey: .autoincrement)
                t.column(user_id)
                t.column(pain_type_name)
                t.foreignKey(user_id, references: users, user_id, delete: .cascade)
            })
            
            // Medications
            try db.run(medications.create(ifNotExists: true) { t in
                t.column(med_id, primaryKey: .autoincrement)
                t.column(pain_type_id)
                t.column(med_category)
                t.column(med_name)
                t.column(current_prescription)
                t.column(start_date)
                t.column(end_date)
                t.foreignKey(pain_type_id, references: painTypes, pain_type_id, delete: .cascade)
            })
            
            // Triggers
            try db.run(triggers.create(ifNotExists: true) { t in
                t.column(trigger_id, primaryKey: .autoincrement)
                t.column(user_id)
                t.column(trigger_name)
                t.foreignKey(user_id, references: users, user_id, delete: .cascade)
            })
            
            // Logs
            try db.run(logs.create(ifNotExists: true) { t in
                t.column(log_id, primaryKey: .autoincrement)
                t.column(user_id)
                t.column(date)
                t.column(time)
                t.column(pain_level)
                t.column(pain_type_id)
                t.column(med_taken)
                t.column(med_worked)
                t.column(pain_description)
                t.column(notes)
                t.foreignKey(user_id, references: users, user_id, delete: .cascade)
                t.foreignKey(pain_type_id, references: painTypes, pain_type_id, delete: .setNull)
            })
            
            // Log_Triggers
            try db.run(logTriggers.create(ifNotExists: true) { t in
                t.column(log_id)
                t.column(trigger_id)
                t.foreignKey(log_id, references: logs, log_id, delete: .cascade)
                t.foreignKey(trigger_id, references: triggers, trigger_id, delete: .cascade)
                t.primaryKey(log_id, trigger_id)
            })
            
        } catch {
            print("Table creation error: \(error)")
        }
    }
    // functions to add something to a tablr
    
    func addUser(firstName: String, emailAddress: String, phone: String, birthDate: Date, passwordHash: String) throws -> Int64 {
        let insert = users.insert(
            first_name <- firstName,
            email <- emailAddress,
            phone_number <- phone,
            birthday <- birthDate,
            password <- passwordHash
        )
        let rowId = try db.run(insert)
        return rowId
    }
    
    func addPainType(userId: Int64, painTypeName: String) throws -> Int64 {
        let insert = painTypes.insert(
            user_id <- userId,
            pain_type_name <- painTypeName
        )
        let rowId = try db.run(insert)
        return rowId
    }
    
    func addMedication(painTypeId: Int64, category: String, medName: String, prescription: String, start: Date, end: Date?) throws -> Int64 {
        let insert = medications.insert(
            pain_type_id <- painTypeId,
            med_category <- category,
            med_name <- medName,
            current_prescription <- prescription,
            start_date <- start,
            end_date <- end
        )
        let rowId = try db.run(insert)
        return rowId
    }
    
    func addTrigger(userId: Int64, triggerName: String) throws -> Int64 {
        let insert = triggers.insert(
            user_id <- userId,
            trigger_name <- triggerName
        )
        let rowId = try db.run(insert)
        return rowId
    }
    
    func addLog(userId: Int64, dateVal: Date, timeVal: String, painLvl: Int, painTypeId: Int64, medTaken: Bool, medWorked: Bool, painDesc: String, note: String) throws -> Int64 {
        let insert = logs.insert(
            user_id <- userId,
            date <- dateVal,
            time <- timeVal,
            pain_level <- painLvl,
            pain_type_id <- painTypeId,
            med_taken <- medTaken,
            med_worked <- medWorked,
            pain_description <- painDesc,
            notes <- note
        )
        let rowId = try db.run(insert)
        return rowId
    }
    
    func addLogTrigger(logIdVal: Int64, triggerIdVal: Int64) throws {
        let insert = logTriggers.insert(
            log_id <- logIdVal,
            trigger_id <- triggerIdVal
        )
        try db.run(insert)
    }
    
    
    
    
    //login function, returns row of the user
    func loginUser(emailAddress: String, passwordInput: String) throws -> Int64? {
        guard db != nil else {
            throw DatabaseError.connectionFailed
        }

        // use the class-level `users` table and columns
        if let user = try db.pluck(users.filter(email == emailAddress && password == passwordInput)) {
            return user[user_id] // return the correct user_id
        } else {
            return nil
        }
    }
    
    func getFirstName(for userId: Int64) throws -> String? {
        if let user = try db.pluck(users.filter(user_id == userId)) {
            return user[first_name]
        }
        return nil
    }
    
    func emailExists(_ email: String) throws -> Bool {
        let users = Table("users")
        let emailColumn = SQLite.Expression<String>("email")

        let query = users.filter(emailColumn == email)
        return try db.pluck(query) != nil
    }


}



//
//  DatabaseManager.swift
//  learning_xcode
//
//  Created by Abigail Barnhardt on 8/24/25.
//

