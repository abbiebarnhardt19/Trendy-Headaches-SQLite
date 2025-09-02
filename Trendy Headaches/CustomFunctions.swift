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
    
    func addMedication(category: String, medName: String, start: Date, end: Date?) throws -> Int64 {
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
            
            // Build the "end" column name dynamically
            let endColumnName = "\(tableName.lowercased().dropLast())_end"
            let endColumn = SQLite.Expression<String?>(endColumnName)
            
            let query = table
                .filter(idColumn == userId)
                .filter(endColumn == nil)  // only rows where `tablenameend` is NULL
            
            return try prepare(query).map { row in
                row[targetColumn]
            }
        } catch {
            print("DB error in getForeignKeyColumnValues:", error)
            return []
        }
    }
    
    func emailExists(_ emailAddress: String) throws -> Bool {
        let cleaned = DatabaseManager.normalizedValue(emailAddress)
        let query = users.filter(email == cleaned)
        return try pluck(query) != nil
    }
    
    static func normalizedValue(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    // MARK: - User Helper Functions (directly in DatabaseManager)
    
    static func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    static func doesEmailExist(_ email: String) -> Bool {
        let cleaned = DatabaseManager.normalizedValue(email)
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
        background: String,
        accent: String,
        symptoms: String,
        preventativeMeds: String,
        emergencyMeds: String,
        triggers: String
    ) throws {
        let normalizedEmail = DatabaseManager.normalizedValue(email)
        let hashedPassword = DatabaseManager.hashString(password)
        let hashedSecurityAnswer = DatabaseManager.hashString(DatabaseManager.normalizedValue(securityAnswer))
        
        let userId: Int64
        do {
            userId = try DatabaseManager.shared.addUser(
                security_question_string: securityQuestion,
                security_answer_string: hashedSecurityAnswer,
                emailAddress: normalizedEmail,
                passwordHash: hashedPassword,
                userBackground: background,
                userAccent: accent,
                preventativeMedsCSV: preventativeMeds,
                emergencyMedsCSV: emergencyMeds,
                symptomsCSV: symptoms,
                triggersCSV: triggers
            )
        } catch {
            print("Failed to add user to database: \(error)")
            throw error
        }
        
        // Symptoms
        for symptom in symptoms.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !symptom.isEmpty {
            do {
                _ = try DatabaseManager.shared.addSymptom(userId: userId, symptomName: symptom)
            } catch {
                print("Failed to add symptom '\(symptom)' for user \(userId): \(error)")
            }
        }
        
        // Triggers
        for trigger in triggers.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !trigger.isEmpty {
            do {
                _ = try DatabaseManager.shared.addTrigger(userId: userId, triggerName: trigger)
            } catch {
                print("Failed to add trigger '\(trigger)' for user \(userId): \(error)")
            }
        }
        
        // Preventative Medications
        for med in preventativeMeds.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !med.isEmpty {
            do {
                _ = try DatabaseManager.shared.addMedication(category: "preventative", medName: med, start: Date(), end: nil)
            } catch {
                print("Failed to add preventative medication '\(med)' for user \(userId): \(error)")
            }
        }
        
        // Emergency Medications
        for med in emergencyMeds.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !med.isEmpty {
            do {
                _ = try DatabaseManager.shared.addMedication(category: "emergency", medName: med, start: Date(), end: nil)
            } catch {
                print("Failed to add emergency medication '\(med)' for user \(userId): \(error)")
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
    
    func getUserInfo(userId: Int64) -> (email: String, password: String, securityQuestion: String, securityAnswer: String, backgroundColor: String, accentColor: String) {
        let email = getSingleColumnValue(userId: userId, columnName: "email") ?? ""
        let password = getSingleColumnValue(userId: userId, columnName: "password") ?? ""
        let securityQuestion = getSingleColumnValue(userId: userId, columnName: "security_question") ?? ""
        let securityAnswer = getSingleColumnValue(userId: userId, columnName: "security_answer") ?? ""
        let backgroundColor = getSingleColumnValue(userId: userId, columnName: "backgroundColor") ?? ""
        let accentColor = getSingleColumnValue(userId: userId, columnName: "accentColor") ?? ""
        return (email, password, securityQuestion, securityAnswer, backgroundColor, accentColor)
    }

    func getTriggers(forUserId userId: Int64) -> [String] {
        getForeignKeyColumnValues(userId: userId, tableName: "triggers", columnName: "trigger_name")
    }

    func getMeds(forUserId userId: Int64, medCategory: String) -> [String] {
        do {
            let idColumn = SQLite.Expression<Int64>("user_id")
            let nameColumn = SQLite.Expression<String>("med_name")
            let categoryColumn = SQLite.Expression<String>("med_category")
            let endDateColumn = SQLite.Expression<Date?>("med_end")
            
            return try prepare(
                medications
                    .filter(idColumn == userId &&
                            categoryColumn == medCategory &&
                            endDateColumn == nil)
            ).map { row in
                row[nameColumn]
            }
        } catch {
            print("DB error in getPreventativeMeds:", error)
            return []
        }
    }

    func getSymptoms(forUserId userId: Int64) -> [String] {
        getForeignKeyColumnValues(userId: userId, tableName: "symptoms", columnName: "symptom_name")
    }
    
    func attemptLogin(email: String, password: String) -> (userId: Int64?, error: String?) {
        let normalizedEmail = DatabaseManager.normalizedValue(email)
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
    
    static func getThemeColors(theme: String) -> (background: String, accent: String) {
        var selected_background = ""
        var selected_accent = ""
        
        if theme == "Classic Light" {
            selected_background = "#FAF7F7"
            selected_accent = "#5E5D5D"
        }
        else if theme == "Light Pink" {
            selected_background = "#FFCEFF"
            selected_accent = "#A4133C"
        }
        else if theme == "Light Yellow" {
            selected_background = "FFFAE5"
            selected_accent = "#848383"
        }
        else if theme == "Classic Dark" {
            selected_background = "#0A0A0A"
            selected_accent = "#CCCCCC"
        }
        else  if theme == "Dark Green" {
            selected_background = "#001D00"
            selected_accent = "#B5C4B9"
        }
        else if theme == "Dark Blue" {
            selected_background = "#000814"
            selected_accent = "#B6CCFE"
        }
        else if theme == "Dark Purple" {
            selected_background = "#240046"
            selected_accent = "#E7C6FF"
        }
        else
        {
            selected_background = "#001d00"
            selected_accent = "#b5c4b9"
        }
        return (selected_background, selected_accent)
    }
    
    static func getThemeName(selected_background: String, selected_accent: String) -> String{
        var themeName = ""
        
        if selected_background == "#FAF7F7" && selected_accent == "#5E5D5D" {
            themeName = "Custom Light"
        }
        else if selected_background == "#FFCEFF" && selected_accent == "#A4133C"{
            themeName = "Light Pink"
        }
        else  if selected_background == "#FFFAE5" && selected_accent == "#848383"{
            themeName = "Light Yellow"
        }
        else if selected_background == "#0A0A0A" && selected_accent == "#CCCCCC" {
            themeName = "Classic Dark"
        }
        else if selected_background == "#001D00" && selected_accent == "#B5C4B9" {
            themeName = "Dark Green"
        }
        else if selected_background == "#000814" && selected_accent == "#B6CCFE"{
            themeName = "Dark Blue"
        }
        else if selected_background == "#240046" && selected_accent == "#E7E6FF" {
            themeName = "Dark Purple"
        }
        else{
            themeName = "Custom"
        }
        return themeName
    }
    
    static func getColors(email: String) -> (background: String, accent: String) {
        var selected_background = ""
        var selected_accent = ""

        if let userID = DatabaseManager.shared.getUserFromEmail(email: email) {
            selected_background = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "background_color") ?? ""
            selected_accent = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "accent_color") ?? ""
        }

        return (selected_background, selected_accent)
    }
    
    static func deleteListDuplicates(list: [String]) -> [String]{
        var tempList = [String]()
        for item in list{
            if !tempList.contains(item){
                tempList.append(item)
            }
        }
        
        return tempList
    }
}

