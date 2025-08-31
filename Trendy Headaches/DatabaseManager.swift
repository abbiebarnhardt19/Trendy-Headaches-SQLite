//
//  DatabaseManager.swift
//  learning_xcode
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import Foundation
import SQLite

enum DatabaseError: Error {
    case connectionFailed
}

class DatabaseManager {
    static let shared = DatabaseManager()
    private let db: Connection

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
    let email = SQLite.Expression<String>("email")
    let password = SQLite.Expression<String>("password")
    let security_question = SQLite.Expression<String>("security_question")
    let security_answer = SQLite.Expression<String>("security_answer")
    let background_color = SQLite.Expression<String>("background_color")
    let accent_color = SQLite.Expression<String>("accent_color")
    
    
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
    
    //create database
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let dbPath = "\(path)/headache_tracker.sqlite3"

        do {
            db = try Connection(dbPath) // only throws here
            db.foreignKeys = true       // does not throw
            createTables()              // does throw, catch inside createTables
        } catch {
            fatalError("Database connection failed: \(error)")
        }
    }
    
    private func createTables() {
        //create each table
        do {
            // Users
            try db.run(users.create(ifNotExists: true) { t in
                t.column(user_id, primaryKey: .autoincrement)
                t.column(email, unique: true)
                t.column(password)
                t.column(security_question)
                t.column(security_answer)
                t.column(background_color)
                t.column(accent_color)
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
                t.column(user_id)
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
    
    func addUser(
        security_question_string: String,
        security_answer_string: String,
        emailAddress: String,
        passwordHash: String,
        userBackground: String,
        userAccent: String,
        preventativeMedsCSV: String? = nil,
        emergencyMedsCSV: String? = nil,
        symptomsCSV: String? = nil,
        triggersCSV: String? = nil
    ) throws -> Int64 {
        // 1. Insert into Users
        let insertUser = users.insert(
            security_question <- security_question_string,
            security_answer <- security_answer_string,
            email <- emailAddress,
            password <- passwordHash,
            background_color <- userBackground,
            accent_color <- userAccent
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
    
    // MARK: - Database Access Helpers
        
    // Run an insert/update/delete statement and return last inserted row ID
    // For Insert statements
    func run(_ insert: SQLite.Insert) throws -> Int64 {
        try db.run(insert)
    }

    // For Update statements
    func run(_ update: SQLite.Update) throws -> Int {
        try db.run(update)
    }

    // For Delete statements
    func run(_ delete: SQLite.Delete) throws -> Int {
        try db.run(delete)
    }

    // Pluck a single row
    func pluck(_ query: SQLite.QueryType) throws -> SQLite.Row? {
        try db.pluck(query)
    }

    // Prepare a query for iteration
    func prepare(_ query: SQLite.QueryType) throws -> AnySequence<SQLite.Row> {
        try db.prepare(query)
    }

}
