//
//  CustomFunctions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/30/25.
//

import SQLite
import Foundation
import CryptoKit

extension DatabaseManager {
    
    // MARK: - User Functions
    
    func addSymptom(userId: Int64, symptomName: String) throws -> Int64 {
        let insert = symptoms.insert(user_id <- userId, symptom_name <- symptomName)
        return try run(insert)
    }
    
    func addMedication(category: String, medName: String, prescription: String, start: Date, end: Date?) throws -> Int64 {
        let insert = medications.insert(med_category <- category, med_name <- medName, med_start <- start, med_end <- end)
        return try run(insert)
    }
    
    func addTrigger(userId: Int64, triggerName: String) throws -> Int64 {
        let insert = triggers.insert(user_id <- userId, trigger_name <- triggerName)
        return try run(insert)
    }
    
    func addLog(userId: Int64, dateVal: Date, timeVal: String, severityLvl: Int, symptomId: Int64, medTaken: Bool, medWorked: Bool, symptomDesc: String, note: String) throws -> Int64 {
        let insert = logs.insert(user_id <- userId, date <- dateVal, time <- timeVal, severity <- severityLvl, symptom_id <- symptomId, med_taken <- medTaken, med_worked <- medWorked, symptom_description <- symptomDesc, notes <- note)
        return try run(insert)
    }
    
    func addLogTrigger(logIdVal: Int64, triggerIdVal: Int64) throws {
        let insert = logTriggers.insert(log_id <- logIdVal, trigger_id <- triggerIdVal)
        try _ = run(insert)
    }
    
    func loginUser(emailAddress: String, passwordInput: String) throws -> Int64? {
        if let user = try pluck(users.filter(email == emailAddress && password == passwordInput)) {
            return user[user_id]
        } else {
            return nil
        }
    }
    
    func getUserFromEmail(email: String) -> Int64? {
        do {
            let emailColumn = SQLite.Expression<String>("email")
            let targetColumn = SQLite.Expression<Int64>("user_id")
            if let row = try pluck(users.filter(emailColumn == email)) {
                return row[targetColumn]
            }
        } catch {
            print("DB error: \(error)")
        }
        return nil
    }
    
    func getSingleColumnValue(userId: Int64, columnName: String) -> String? {
        do {
            let idColumn = SQLite.Expression<Int64>("user_id")
            let targetColumn = SQLite.Expression<String>(columnName)
            if let row = try pluck(users.filter(idColumn == userId)) {
                return row[targetColumn]
            }
        } catch {
            print("DB error: \(error)")
        }
        return nil
    }
    
    func getForeignKeyColumnValues(userId: Int64, tableName: String, columnName: String) -> [String] {
        do {
            let idColumn = SQLite.Expression<Int64>("user_id")
            let targetColumn = SQLite.Expression<String>(columnName)
            let table = Table(tableName)
            return try prepare(table.filter(idColumn == userId)).map { row in
                row[targetColumn]
            }
        } catch {
            print("DB error in getForeignKeyColumnValues:", error)
            return []
        }
    }
    
    func emailExists(_ emailAddress: String) throws -> Bool {
        let cleaned = normalizedValue(emailAddress)
        let query = users.filter(email == cleaned)
        return try pluck(query) != nil
    }
    
    func normalizedValue(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    // MARK: - User Helper Functions (directly in DatabaseManager)
    
    static func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    static func doesEmailExist(_ email: String) -> Bool {
        let cleaned = DatabaseManager.shared.normalizedValue(email)
        do {
            return try DatabaseManager.shared.emailExists(cleaned)
        } catch {
            print("Database error checking email: \(error)")
            return false
        }
    }
    
    static func getCurrentPassword(forEmail email: String) -> (userId: Int64?, currentPassword: String) {
        guard let id = DatabaseManager.shared.getUserFromEmail(email: email) else {
            return (nil, "")
        }
        let currentPassword = DatabaseManager.shared.getSingleColumnValue(userId: id, columnName: "password") ?? ""
        return (id, currentPassword)
    }
    
    static func getSecurityQuestionAndAnswer(forEmail email: String) -> (userId: Int64?, question: String, hashedAnswer: String) {
        guard let id = DatabaseManager.shared.getUserFromEmail(email: email) else {
            return (nil, "", "")
        }
        let question = DatabaseManager.shared.getSingleColumnValue(userId: id, columnName: "security_question") ?? ""
        let hashedAnswer = DatabaseManager.shared.getSingleColumnValue(userId: id, columnName: "security_answer") ?? ""
        return (id, question, hashedAnswer)
    }
    
    static func createUser(
        email: String,
        password: String,
        securityQuestion: String,
        securityAnswer: String,
        symptoms: String,
        preventativeMeds: String,
        emergencyMeds: String,
        triggers: String
    ) throws {
        let normalizedEmail = DatabaseManager.shared.normalizedValue(email)
        let hashedPassword = DatabaseManager.hashString(password)
        let hashedSecurityAnswer = DatabaseManager.hashString(DatabaseManager.shared.normalizedValue(securityAnswer))
        
        let userId = try DatabaseManager.shared.addUser(
            security_question_string: securityQuestion,
            security_answer_string: hashedSecurityAnswer,
            emailAddress: normalizedEmail,
            passwordHash: hashedPassword,
            userColor: "green",
            preventativeMedsCSV: preventativeMeds,
            emergencyMedsCSV: emergencyMeds,
            symptomsCSV: symptoms,
            triggersCSV: triggers
        )
        
        symptoms.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.forEach { symptom in
            if !symptom.isEmpty {
                _ = try? DatabaseManager.shared.addSymptom(userId: userId, symptomName: symptom)
            }
        }
        
        triggers.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.forEach { trigger in
            if !trigger.isEmpty {
                _ = try? DatabaseManager.shared.addTrigger(userId: userId, triggerName: trigger)
            }
        }
        
        preventativeMeds.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.forEach { med in
            if !med.isEmpty {
                _ = try? DatabaseManager.shared.addMedication(category: "preventative", medName: med, prescription: "", start: Date(), end: nil)
            }
        }
        
        emergencyMeds.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.forEach { med in
            if !med.isEmpty {
                _ = try? DatabaseManager.shared.addMedication(category: "emergency", medName: med, prescription: "", start: Date(), end: nil)
            }
        }
    }
    
    static func isPasswordResetValid(newPassword: String, confirmPassword: String, currentHashedPassword: String) -> Bool {
        guard !newPassword.isEmpty, !confirmPassword.isEmpty else { return false }
        guard newPassword == confirmPassword else { return false }
        guard DatabaseManager.hashString(newPassword) != currentHashedPassword else { return false }
        return isPasswordValid(newPassword)
    }
    
    static func updatePassword(forEmail email: String, newPassword: String) throws {
        let (userId, currentPassword) = getCurrentPassword(forEmail: email)
        guard let id = userId else {
            throw NSError(domain: "PasswordReset", code: 0, userInfo: [NSLocalizedDescriptionKey: "No valid user ID found"])
        }
        
        guard isPasswordResetValid(newPassword: newPassword, confirmPassword: newPassword, currentHashedPassword: currentPassword) else {
            throw NSError(domain: "PasswordReset", code: 1, userInfo: [NSLocalizedDescriptionKey: "Password does not meet requirements"])
        }
        
        let hashedPassword = DatabaseManager.hashString(newPassword)
        let user = DatabaseManager.shared.users.filter(DatabaseManager.shared.user_id == id)
        try _ = DatabaseManager.shared.run(user.update(DatabaseManager.shared.password <- hashedPassword))
        print("Password successfully updated for user \(id)")
    }
    
    func getUserInfo(userId: Int64) -> (email: String, password: String, securityQuestion: String, securityAnswer: String, colorScheme: String) {
        let email = getSingleColumnValue(userId: userId, columnName: "email") ?? ""
        let password = getSingleColumnValue(userId: userId, columnName: "password") ?? ""
        let securityQuestion = getSingleColumnValue(userId: userId, columnName: "security_question") ?? ""
        let securityAnswer = getSingleColumnValue(userId: userId, columnName: "security_answer") ?? ""
        let colorScheme = getSingleColumnValue(userId: userId, columnName: "color_scheme") ?? ""
        return (email, password, securityQuestion, securityAnswer, colorScheme)
    }

    func getTriggers(forUserId userId: Int64) -> [String] {
        getForeignKeyColumnValues(userId: userId, tableName: "triggers", columnName: "trigger_name")
    }

    func getMedications(forUserId userId: Int64) -> [String] {
        getForeignKeyColumnValues(userId: userId, tableName: "medications", columnName: "med_name")
    }

    func getSymptoms(forUserId userId: Int64) -> [String] {
        getForeignKeyColumnValues(userId: userId, tableName: "symptoms", columnName: "symptom_name")
    }
    
    func attemptLogin(email: String, password: String) -> (userId: Int64?, error: String?) {
        let normalizedEmail = normalizedValue(email)
        let hashedPassword = DatabaseManager.hashString(password)
        
        do {
            if let id = try loginUser(emailAddress: normalizedEmail, passwordInput: hashedPassword) {
                return (id, nil)
            } else {
                return (nil, "Invalid email or password.")
            }
        } catch {
            return (nil, "Database error: \(error.localizedDescription)")
        }
    }
    
    static func hashString(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}
