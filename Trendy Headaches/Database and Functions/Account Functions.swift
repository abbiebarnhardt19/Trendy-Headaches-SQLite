//
//  Account Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SQLite
import Foundation
import CryptoKit

extension DatabaseManager {
    
    //check if the email is present in the users table
    static func doesEmailExist(_ emailAddress: String) -> Bool {
        let cleaned = DatabaseManager.normalizedValue(emailAddress)
        let query = DatabaseManager.shared.users.filter(DatabaseManager.shared.email == cleaned)
        do {
            return try DatabaseManager.shared.pluck(query) != nil
        } catch {
            print("SQLite error in doesEmailExist: \(error)")
            return false
        }
    }
    
    //lowercase string and remove whitespace
    static func normalizedValue(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    //check if password meets complexity requirements
    static func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    //add user to the database
    static func createUser(email: String, password: String, securityQuestion: String, securityAnswer: String, background: String, accent: String, symptoms: String, preventativeMeds: String, emergencyMeds: String, triggers: String)
    throws {
        let normalizedEmail = DatabaseManager.normalizedValue(email)
        let hashedPassword = DatabaseManager.hashString(password)
        let hashedSecurityAnswer = DatabaseManager.hashString(DatabaseManager.normalizedValue(securityAnswer))
        
        // Insert into users table
        let insertUser = DatabaseManager.shared.users.insert(
            DatabaseManager.shared.security_question <- securityQuestion,
            DatabaseManager.shared.security_answer <- hashedSecurityAnswer,
            DatabaseManager.shared.email <- normalizedEmail,
            DatabaseManager.shared.password <- hashedPassword,
            DatabaseManager.shared.background_color <- background,
            DatabaseManager.shared.accent_color <- accent)
        
        //get user ID to use as foriegn key
        let userId: Int64
        do {
            userId = try DatabaseManager.shared.run(insertUser)
        } catch {
            print("SQLite error in createUser (users): \(error)")
            throw error
        }
        
        // insert into symptoms table, seperate by comma and remove whitespace
        for symptom in symptoms.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !symptom.isEmpty {
            let insertSymptom = DatabaseManager.shared.symptoms.insert(
                DatabaseManager.shared.user_id <- userId,
                DatabaseManager.shared.symptom_name <- symptom,
                DatabaseManager.shared.symptom_start <- Date(),
                DatabaseManager.shared.symptom_end <- nil
            )
            do {
                _ = try DatabaseManager.shared.run(insertSymptom)
            } catch {
                print("SQLite error in createUser (symptoms): \(error)")
            }
        }
        
        // insert into triggers table, seperate by comma and remove whitespace
        for trigger in triggers.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !trigger.isEmpty {
            let insertTrigger = DatabaseManager.shared.triggers.insert(
                DatabaseManager.shared.user_id <- userId,
                DatabaseManager.shared.trigger_name <- trigger,
                DatabaseManager.shared.trigger_start <- Date(),
                DatabaseManager.shared.trigger_end <- nil)
            
            do {
                _ = try DatabaseManager.shared.run(insertTrigger)
            } catch {
                print("SQLite error in createUser (triggers): \(error)")
            }
        }
        
        // insert into prev meds table, seperate by comma and remove whitespace
        for med in preventativeMeds.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !med.isEmpty {
            let insertMed = DatabaseManager.shared.medications.insert(
                DatabaseManager.shared.user_id <- userId,
                DatabaseManager.shared.medication_category <- "preventative",
                DatabaseManager.shared.medication_name <- med,
                DatabaseManager.shared.medication_start <- Date(),
                DatabaseManager.shared.medication_end <- nil)
            
            do {
                _ = try DatabaseManager.shared.run(insertMed)
            } catch {
                print("SQLite error in createUser (prev meds): \(error)")
            }
        }
        
        // insert into emeg meds table, seperate by comma and remove whitespace
        for med in emergencyMeds.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !med.isEmpty {
            let insertMed = DatabaseManager.shared.medications.insert(
                DatabaseManager.shared.user_id <- userId,
                DatabaseManager.shared.medication_category <- "emergency",
                DatabaseManager.shared.medication_name <- med,
                DatabaseManager.shared.medication_start <- Date(),
                DatabaseManager.shared.medication_end <- nil)
            do {
                _ = try DatabaseManager.shared.run(insertMed)
            } catch {
                print("SQLite error in createUser (emergencyMeds): \(error)")
            }
        }
    }
    
    //get info to display on profile page
    func getUserInfo(userId: Int64) -> (email: String, password: String, securityQuestion: String, securityAnswer: String, backgroundColor: String, accentColor: String) {
        let email = getSingleColumnValue(userId: userId, columnName: "email") ?? ""
        let password = getSingleColumnValue(userId: userId, columnName: "password") ?? ""
        let securityQuestion = getSingleColumnValue(userId: userId, columnName: "security_question") ?? ""
        let securityAnswer = getSingleColumnValue(userId: userId, columnName: "security_answer") ?? ""
        let backgroundColor = getSingleColumnValue(userId: userId, columnName: "backgroundColor") ?? ""
        let accentColor = getSingleColumnValue(userId: userId, columnName: "accentColor") ?? ""
        return (email, password, securityQuestion, securityAnswer, backgroundColor, accentColor)
    }
    
    //get the meds, needs special function to split between emergency and preventative
    func getMeds(forUserId userId: Int64, medCategory: String) -> [String] {
        do {
            let idColumn = SQLite.Expression<Int64>("user_id")
            let nameColumn = SQLite.Expression<String>("medication_name")
            let categoryColumn = SQLite.Expression<String>("medication_category")
            let endDateColumn = SQLite.Expression<Date?>("medication_end")
            
            return try prepare(
                medications
                    .filter(idColumn == userId &&
                            categoryColumn == medCategory &&
                            endDateColumn == nil)
            ).map { row in
                row[nameColumn]
            }
        } catch {
            print("Oops! Something went wrong. Please try again later.")
            return []
        }
    }
    
    //check if there is an email that matches in the database and if the password matches
    //if there is, return the user ID so it can be passed to the main app
    func attemptLogin(email: String, password: String) -> (userId: Int64?, error: String?) {
        let normalizedEmail = DatabaseManager.normalizedValue(email)
        let hashedPassword = DatabaseManager.hashString(password)
        
        do {
            // Query for a matching user
            let query = users.filter(self.email == normalizedEmail && self.password == hashedPassword)
            
            if let user = try pluck(query) {
                return (user[user_id], nil)
            } else {
                return (nil, "Invalid email or password")
            }
        } catch {
            return (nil, "Oops! Something went wrong. Please try again later.")
        }
    }
    
    //hasing function
    static func hashString(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
    
    //reset password function
    static func resetPassword(forEmail email: String, newPassword: String) -> Bool {
        do {
            guard let userID = DatabaseManager.shared.getUserFromEmail(email: email) else {
                print("Oops! Something went wrong. Please try again later.")
                return false
            }
            
            let hashedPassword = DatabaseManager.hashString(newPassword)
            let userFilter = DatabaseManager.shared.users.filter(DatabaseManager.shared.user_id == userID)
            
            _ = try DatabaseManager.shared.run(userFilter.update(DatabaseManager.shared.password <- hashedPassword))
            return true
            
        } catch {
            print("Oops! Something went wrong. Please try again later.")
            return false
        }
    }
    
    //delete user function
    func deleteUser(userID: Int64) {
        do {
            let users = Table("users")
            let id = SQLite.Expression<Int64>("user_id")
            
            let deleteQuery = users.filter(id == userID).delete()
            let _ = try run(deleteQuery)

        } catch {
            print("Failed to delete user \(userID): \(error)")
        }
    }
    
    func updateUser(userID: Int64, newValue: String, column: String){
        do {
            let users = Table("users")
            let id = SQLite.Expression<Int64>("user_id")
            let columnToUpdate = SQLite.Expression<String>(column)
            
            let updateQuery = users.filter(id == userID).update(columnToUpdate <- newValue)
            let _ = try DatabaseManager.shared.run(updateQuery)
            
        } catch {
            print("Failed to delete user \(userID): \(error)")
        }
    }
    
    func loadData(userID: Int64,  symptoms: inout [String], triggers: inout [String], prevMeds: inout [String],  emergencyMeds: inout [String], securityQuestion: inout String, securityAnswer: inout String, newSecurityQuestion: inout String, backgroundColor: inout String, accentColor: inout String, newBackground: inout String, newAccent: inout String,  themeName: inout String, newThemeName: inout String) {
        symptoms = DatabaseManager.shared.getForeignKeyColumnValues(userId: userID, tableName: "symptoms", columnName: "symptom_name")
        symptoms=DatabaseManager.deleteListDuplicates(list:symptoms)
        
        triggers = DatabaseManager.shared.getForeignKeyColumnValues(userId: userID, tableName: "triggers", columnName: "trigger_name")
        triggers=DatabaseManager.deleteListDuplicates(list:triggers)
        
        prevMeds = DatabaseManager.shared.getForeignKeyColumnValues(userId: userID, tableName: "medications", columnName: "medication_name", filterColumn: "medication_category", filterValue: "preventative")
        prevMeds=DatabaseManager.deleteListDuplicates(list:prevMeds)
        
        emergencyMeds = DatabaseManager.shared.getForeignKeyColumnValues(userId: userID, tableName: "medications", columnName: "medication_name", filterColumn: "medication_category", filterValue: "emergency")
        emergencyMeds=DatabaseManager.deleteListDuplicates(list:emergencyMeds)
        
        securityQuestion = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "security_question") ?? "None set"
        securityAnswer = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "security_answer") ?? "None set"
        newSecurityQuestion = securityQuestion
        
        backgroundColor = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "background_color") ?? "None set"
        
        accentColor = DatabaseManager.shared.getSingleColumnValue(userId: userID, columnName: "accent_color") ?? "None set"
        
        newAccent = accentColor
        newBackground = backgroundColor
        
        themeName = DatabaseManager.getThemeName(selected_background: newBackground, selected_accent: newAccent)
        newThemeName = themeName.contains("Custom") ? "Custom" : themeName
    }
    
    func insertItem(table: Table, userID: Int64, nameColumn: SQLite.Expression<String>, name: String, startColumn: SQLite.Expression<Date>, endColumn: SQLite.Expression<Date?>, medicationCategory: String? = nil) {
        
        var setters: [Setter] = [user_id <- userID, nameColumn <- name, startColumn <- Date(), endColumn <- nil ]
        
        // Always use DatabaseManager.shared.med_category as the column
        if let category = medicationCategory {
            setters.append(DatabaseManager.shared.medication_category <- category)
        }
        
        let insert = table.insert(setters)
        do {
            _ = try run(insert)
        } catch {
            print("Failed to insert \(name): \(error)")
        }
    }
    
    func updateItem(table: Table, userID: Int64, oldValue: String, newValue: String, nameColumn: SQLite.Expression<String>, medicationCategory: String? = nil ) {
        var filter = table.filter(user_id == userID && nameColumn == oldValue)
        
        // If a category is provided, filter by it too
        if let category = medicationCategory {
            filter = filter.filter(DatabaseManager.shared.medication_category == category)
        }
        
        do {
            _ = try run(filter.update(nameColumn <- newValue))
        } catch {
            print(" Failed to update \(oldValue): \(error)")
        }
    }
    
    func endItem( table: Table, userID: Int64, name: String, nameColumn: SQLite.Expression<String>, endColumn: SQLite.Expression<Date?>, medicationCategory: String? = nil ) {
        var filter = table.filter(user_id == userID && nameColumn == name)
        
        // If a category is provided, filter by it too
        if let category = medicationCategory {
            filter = filter.filter(DatabaseManager.shared.medication_category == category)
        }
        
        do {
            _ = try run(filter.update(endColumn <- Date()))
            if let category = medicationCategory {
                print("Ended \(name) (\(category)) at \(Date())")
            } else {
                print("Ended \(name) at \(Date())")
            }
        } catch {
            print("Failed to end \(name): \(error)")
        }
    }
    
    //delete list duplicates, used for rows that are created from csvs
    static func deleteListDuplicates(list: [String]) -> [String]{
        var tempList = [String]()
        for item in list{
            if !tempList.contains(item){
                tempList.append(item)
            }
        }
        return tempList
    }
    
    //get the user ID from the email address
    func getUserFromEmail(email: String) -> Int64? {
        do {
            let emailColumn = SQLite.Expression<String>("email")
            let targetColumn = SQLite.Expression<Int64>("user_id")
            if let row = try pluck(users.filter(emailColumn == email)) {
                return row[targetColumn]
            }
        } catch {
            print("Oops! Something went wrong. Please try again later.")
        }
        return nil
    }
}
