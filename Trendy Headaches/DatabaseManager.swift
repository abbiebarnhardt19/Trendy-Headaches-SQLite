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
    
    // columns
    // users columns
    let user_id = SQLite.Expression<Int64>("user_id")
    let email = SQLite.Expression<String>("email")
    let password = SQLite.Expression<String>("password")
    let security_question = SQLite.Expression<String>("security_question")
    let security_answer = SQLite.Expression<String>("security_answer")
    let background_color = SQLite.Expression<String>("background_color")
    let accent_color = SQLite.Expression<String>("accent_color")
    
    // symptoms columns
    let symptom_id = SQLite.Expression<Int64>("symptom_id")
    let symptom_name = SQLite.Expression<String>("symptom_name")
    let symptom_start = SQLite.Expression<Date>("symptom_start")
    let symptom_end = SQLite.Expression<Date?>("symptom_end")
    
    // medications columns
    let medication_id = SQLite.Expression<Int64>("medication_id")
    let medication_category = SQLite.Expression<String>("medication_category")
    let medication_name = SQLite.Expression<String>("medication_name")
    let medication_start = SQLite.Expression<Date>("medication_start")
    let medication_end = SQLite.Expression<Date?>("medication_end")
    
    // triggers columns
    let trigger_id = SQLite.Expression<Int64>("trigger_id")
    let trigger_name = SQLite.Expression<String>("trigger_name")
    let trigger_start = SQLite.Expression<Date>("trigger_start")
    let trigger_end = SQLite.Expression<Date?>("trigger_end")
    
    // log columns
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
        // Get path to documents directory
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let dbPath = "\(path)/headache_tracker.sqlite3"
        
        // Delete old database if it exists (for testing)
//        let fileManager = FileManager.default
//        if fileManager.fileExists(atPath: dbPath) {
//            do {
//                try fileManager.removeItem(atPath: dbPath)
//                print("Old database deleted successfully")
//            } catch {
//                print("Failed to delete old database: \(error)")
//           }
//        }
        //make the database
        do {
            db = try Connection(dbPath)
            db.foreignKeys = true
            createTables()
        } catch {
            fatalError("Database connection failed: \(error)")
        }
    }

    //create each tabke with the predefined columns
    private func createTables() {
        do {
            // create users columns
            try db.run(users.create(ifNotExists: true) { t in
                t.column(user_id, primaryKey: .autoincrement)
                t.column(email, unique: true)
                t.column(password)
                t.column(security_question)
                t.column(security_answer)
                t.column(background_color)
                t.column(accent_color)
            })
            
            // create symptoms columns
            try db.run(symptoms.create(ifNotExists: true) { t in
                t.column(symptom_id, primaryKey: .autoincrement)
                t.column(user_id)
                t.column(symptom_name)
                t.column(symptom_start)
                t.column(symptom_end)
                t.foreignKey(user_id, references: users, user_id, delete: .cascade)
            })
            
            // create medications columns
            try db.run(medications.create(ifNotExists: true) { t in
                t.column(medication_id, primaryKey: .autoincrement)
                t.column(medication_category)
                t.column(medication_name)
                t.column(medication_start)
                t.column(medication_end)
                t.column(user_id)
                t.foreignKey(user_id, references: users, user_id, delete: .cascade)
            })
            
            // create triggers columns
            try db.run(triggers.create(ifNotExists: true) { t in
                t.column(trigger_id, primaryKey: .autoincrement)
                t.column(user_id)
                t.column(trigger_name)
                t.column(trigger_start)
                t.column(trigger_end)
                t.foreignKey(user_id, references: users, user_id, delete: .cascade)
            })
            
            // create logs columns
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
            
        } catch {
            print("Table creation error: \(error)")
        }
    }
    
    
    //add a user to the database
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
        
        var userId: Int64 = 0
        
        // add the user data to the user table
        do {
            let insertUser = users.insert(
                security_question <- security_question_string,
                security_answer <- security_answer_string,
                email <- emailAddress,
                password <- passwordHash,
                background_color <- userBackground,
                accent_color <- userAccent
            )
            //save the user id to use as a foriegn key in the other tables
            userId = try db.run(insertUser)
        } catch {
            throw NSError(domain: "Database Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Oops! Something went wrong. Please try again later."])
        }
        
        //add preventative meds to the medications table
        //seperate on commas and remove whitespace
        if let preventative = preventativeMedsCSV, !preventative.isEmpty {
            let medsArray = preventative.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for med in medsArray where !med.isEmpty {
                do {
                    let insertMed = medications.insert(
                        user_id <- userId,
                        medication_category <- "preventative",
                        medication_name <- med,
                        medication_start <- Date(),
                        medication_end <- nil
                    )
                    try db.run(insertMed)
                } catch {
                    throw NSError(domain: "Database Error", code: 2, userInfo: [NSLocalizedDescriptionKey: "Oops! Something went wrong. Please try again later."])
                }
            }
        }
        
        //add emergency meds to the medications table
        //seperate on commas and remove whitespace
        if let emergency = emergencyMedsCSV, !emergency.isEmpty {
            let medsArray = emergency.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for med in medsArray where !med.isEmpty {
                do {
                    let insertMed = medications.insert(
                        user_id <- userId,
                        medication_category <- "emergency",
                        medication_name <- med,
                        medication_start <- Date(),
                        medication_end <- nil
                    )
                    try db.run(insertMed)
                } catch {
                    throw NSError(domain: "Database Error", code: 3, userInfo: [NSLocalizedDescriptionKey: "Oops! Something went wrong. Please try again later."])
                }
            }
        }
        
        //add triggers to the triggers table
        //seperate on commas and remove whitespace
        if let triggersList = triggersCSV, !triggersList.isEmpty {
            let array = triggersList.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for trig in array where !trig.isEmpty {
                do {
                    let insertTrig = triggers.insert(
                        user_id <- userId,
                        trigger_name <- trig,
                        trigger_start <- Date(),
                        trigger_end <- nil
                    )
                    try db.run(insertTrig)
                } catch {
                    throw NSError(domain: "Database Error", code: 4, userInfo: [NSLocalizedDescriptionKey: "Oops! Something went wrong. Please try again later."])
                }
            }
        }
        
        //add symptoms to the symptoms table
        //seperate on commas and remove whitespace
        if let symptomsList = symptomsCSV, !symptomsList.isEmpty {
            let array = symptomsList.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for symptom in array where !symptom.isEmpty {
                do {
                    let insertSymptom = symptoms.insert(
                        user_id <- userId,
                        symptom_name <- symptom,
                        symptom_start <- Date(),
                        symptom_end <- nil
                    )
                    try db.run(insertSymptom)
                } catch {
                    throw NSError(domain: "Database Error", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to insert symptom '\(symptom)'. Error: \(error)"])
                }
            }
        }
        //return the user ID
        return userId
    }

    
    //database access helpers
        
    //insert helper
    func run(_ insert: SQLite.Insert) throws -> Int64 {
        try db.run(insert)
    }

    //update helper
    func run(_ update: SQLite.Update) throws -> Int {
        try db.run(update)
    }

    //delete helper
    func run(_ delete: SQLite.Delete) throws -> Int {
        try db.run(delete)
    }

    //select helped
    func pluck(_ query: SQLite.QueryType) throws -> SQLite.Row? {
        try db.pluck(query)
    }

    //prepare helper
    func prepare(_ query: SQLite.QueryType) throws -> AnySequence<SQLite.Row> {
        try db.prepare(query)
    }

}
