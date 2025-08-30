//
//  CustomFunctions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/30/25.
//

import SQLite
import Foundation

extension DatabaseManager {
    
    // MARK: - User Functions
    func addSymptom(userId: Int64, symptomName: String) throws -> Int64 {
        let insert = symptoms.insert(
            user_id <- userId,
            symptom_name <- symptomName
        )
        let rowId = try run(insert)
        return rowId
    }
    
    func addMedication(category: String, medName: String, prescription: String, start: Date, end: Date?) throws -> Int64 {
        let insert = medications.insert(
            med_category <- category,
            med_name <- medName,
            med_start <- start,
            med_end <- end
        )
        let rowId = try run(insert)
        return rowId
    }
    
    func addTrigger(userId: Int64, triggerName: String) throws -> Int64 {
        let insert = triggers.insert(
            user_id <- userId,
            trigger_name <- triggerName
        )
        let rowId = try run(insert)
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
        let rowId = try run(insert)
        return rowId
    }
    
    func addLogTrigger(logIdVal: Int64, triggerIdVal: Int64) throws {
        let insert = logTriggers.insert(
            log_id <- logIdVal,
            trigger_id <- triggerIdVal
        )
        try _ = run(insert)
    }
    
    //login function, returns row of the user
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
        let cleaned = normalizedValue(emailAddress) // trim + lowercase
        let query = users.filter(email == cleaned)  // direct equality
        return try pluck(query) != nil
    }

    func normalizedValue(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    struct PasswordResetHelper {

        // MARK: - Password Complexity Check
        static func isPasswordValid(_ password: String) -> Bool {
            let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d]).{8,}$"
            return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
        }

        // MARK: - Password Reset Validation
        static func isPasswordResetValid(newPassword: String, confirmPassword: String, currentHashedPassword: String) -> Bool {
            guard !newPassword.isEmpty, !confirmPassword.isEmpty else { return false }
            guard newPassword == confirmPassword else { return false }
            guard hashString(newPassword) != currentHashedPassword else { return false }
            return isPasswordValid(newPassword)
        }

        // MARK: - Get current password hash for a given email
        static func getCurrentPassword(forEmail email: String) -> (userId: Int64?, currentPassword: String) {
            guard let id = DatabaseManager.shared.getUserFromEmail(email: email) else {
                return (nil, "")
            }

            let currentPassword = DatabaseManager.shared.getSingleColumnValue(
                userId: id,
                columnName: "password"
            ) ?? ""

            return (id, currentPassword)
        }

        // MARK: - Update password for a given email
        static func updatePassword(forEmail email: String, newPassword: String) throws {
            let (userId, currentPassword) = getCurrentPassword(forEmail: email)
            guard let id = userId else {
                throw NSError(domain: "PasswordReset", code: 0, userInfo: [NSLocalizedDescriptionKey: "No valid user ID found"])
            }

            guard isPasswordResetValid(newPassword: newPassword, confirmPassword: newPassword, currentHashedPassword: currentPassword) else {
                throw NSError(domain: "PasswordReset", code: 1, userInfo: [NSLocalizedDescriptionKey: "Password does not meet requirements"])
            }

            let hashedPassword = hashString(newPassword)

            // Ignore return value explicitly
            _ = try DatabaseManager.shared.run(
                DatabaseManager.shared.users.filter(DatabaseManager.shared.user_id == id)
                    .update(DatabaseManager.shared.password <- hashedPassword)
            )

            print("Password successfully updated for user \(id)")
        }

        // MARK: - Hash helper
        private static func hashString(_ str: String) -> String {
            CryptoHelper.hashString(str)
        }
    }
    
    struct UserHelpers {
        // Checks if an email exists in the database
        static func doesEmailExist(_ email: String) -> Bool {
            do {
                let cleaned = DatabaseManager.shared.normalizedValue(email)
                return try DatabaseManager.shared.emailExists(cleaned)
            } catch {
                print("Database error: \(error)")
                return false
            }
        }
        
        // Returns the security question and hashed answer for a given email
        static func getSecurityQuestionAndAnswer(forEmail email: String) -> (userId: Int64?, question: String, hashedAnswer: String) {
            guard let id = DatabaseManager.shared.getUserFromEmail(email: email) else {
                return (nil, "", "")
            }
            
            let question = DatabaseManager.shared.getSingleColumnValue(userId: id, columnName: "security_question") ?? ""
            let hashedAnswer = DatabaseManager.shared.getSingleColumnValue(userId: id, columnName: "security_answer") ?? ""
            
            return (id, question, hashedAnswer)
        }
    }

}
