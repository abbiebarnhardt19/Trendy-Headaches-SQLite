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
    let symptoms = Table("Symptoms")
    let medications = Table("Medications")
    let triggers = Table("Triggers")
    let logs = Table("Logs")
    let logTriggers = Table("Log_Triggers")
    
    // columns
    // users columns
    let user_id = SQLite.Expression<Int64>("user_id")
    let first_name = SQLite.Expression<String>("first_name")
    let email = SQLite.Expression<String>("email")
    let password = SQLite.Expression<String>("password")
    
    // symptom types
    let symptom_id = SQLite.Expression<Int64>("symptom_id")
    let symptom_name = SQLite.Expression<String>("symptom_name")
    
    // medications
    let med_id = SQLite.Expression<Int64>("med_id")
    let med_category = SQLite.Expression<String>("med_category")
    let med_name = SQLite.Expression<String>("med_name")
    let med_start = SQLite.Expression<Date>("med_start")
    let med_end = SQLite.Expression<Date?>("med_end")
    
    // triggers
    let trigger_id = SQLite.Expression<Int64>("trigger_id")
    let trigger_name = SQLite.Expression<String>("trigger_name")
    
    // logs
    let log_id = SQLite.Expression<Int64>("log_id")
    let date = SQLite.Expression<Date>("date")
    let time = SQLite.Expression<String>("time")
    let severity = SQLite.Expression<Int>("severity_level")
    let med_taken = SQLite.Expression<Bool>("med_taken")
    let med_worked = SQLite.Expression<Bool>("med_worked")
    let symptom_description = SQLite.Expression<String>("symptom_description")
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
                t.column(password)
            })
            
            // Symptom_Types
            try db.run(symptoms.create(ifNotExists: true) { t in
                t.column(symptom_id, primaryKey: .autoincrement)
                t.column(user_id)
                t.column(symptom_name)
                t.foreignKey(user_id, references: users, user_id, delete: .cascade)
            })
            
            // Medications
            try db.run(medications.create(ifNotExists: true) { t in
                t.column(med_id, primaryKey: .autoincrement)
                t.column(med_category)
                t.column(med_name)
                t.column(med_start)
                t.column(med_end)
                t.foreignKey(user_id, references: users, user_id, delete: .cascade)
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
                t.column(severity)
                t.column(symptom_id)
                t.column(med_taken)
                t.column(med_worked)
                t.column(symptom_description)
                t.column(notes)
                t.foreignKey(user_id, references: users, user_id, delete: .cascade)
                t.foreignKey(symptom_id, references: symptoms, symptom_id, delete: .setNull)
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
    
    
    func addUser(
        firstName: String,
        emailAddress: String,
        passwordHash: String,
        preventativeMedsCSV: String? = nil,
        emergencyMedsCSV: String? = nil,
        symptomsCSV: String? = nil,
        triggersCSV: String? = nil
    ) throws -> Int64 {
        // 1. Insert into Users
        let insertUser = users.insert(
            first_name <- firstName,
            email <- emailAddress,
            password <- passwordHash
        )
        let userId = try db.run(insertUser)
        
        // 2. Insert Preventative Medications
        if let preventative = preventativeMedsCSV, !preventative.isEmpty {
            let medsArray = preventative.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for med in medsArray where !med.isEmpty {
                let insertMed = medications.insert(
                    user_id <- userId,
                    med_category <- "Preventative",
                    med_name <- med,
                    med_start <- Date(),
                    med_end <- nil
                )
                try db.run(insertMed)
            }
        }
        
        // 3. Insert Emergency Medications
        if let emergency = emergencyMedsCSV, !emergency.isEmpty {
            let medsArray = emergency.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for med in medsArray where !med.isEmpty {
                let insertMed = medications.insert(
                    user_id <- userId,
                    med_category <- "Emergency",
                    med_name <- med,
                    med_start <- Date(),
                    med_end <- nil
                )
                try db.run(insertMed)
            }
        }
        
        // 4. Insert Triggers
        if let triggersList = triggersCSV, !triggersList.isEmpty {
            let array = triggersList.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for trig in array where !trig.isEmpty {
                let insertTrig = triggers.insert(
                    user_id <- userId,
                    trigger_name <- trig
                )
                try db.run(insertTrig)
            }
        }
        
        // 5. Insert Symptoms
        if let symptomsList = symptomsCSV, !symptomsList.isEmpty {
            let array = symptomsList.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for symptom in array where !symptom.isEmpty {
                let insertSymptom = symptoms.insert(
                    user_id <- userId,
                    symptom_name <- symptom
                )
                try db.run(insertSymptom)
            }
        }
        
        return userId
    }

    
    func addSymptom(userId: Int64, symptomName: String) throws -> Int64 {
        let insert = symptoms.insert(
            user_id <- userId,
            symptom_name <- symptomName
        )
        let rowId = try db.run(insert)
        return rowId
    }
    
    func addMedication(category: String, medName: String, prescription: String, start: Date, end: Date?) throws -> Int64 {
        let insert = medications.insert(
            med_category <- category,
            med_name <- medName,
            med_start <- start,
            med_end <- end
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
    
    func addLog(userId: Int64, dateVal: Date, timeVal: String, severityLvl: Int, symptomId: Int64, medTaken: Bool, medWorked: Bool, symptomDesc: String, note: String) throws -> Int64 {
        let insert = logs.insert(
            user_id <- userId,
            date <- dateVal,
            time <- timeVal,
            severity <- severityLvl,
            symptom_id <- symptomId,
            med_taken <- medTaken,
            med_worked <- medWorked,
            symptom_description <- symptomDesc,
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

