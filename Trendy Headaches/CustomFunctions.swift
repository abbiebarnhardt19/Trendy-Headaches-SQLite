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
    
    // get a single column value using userID
    func getSingleColumnValue(userId: Int64, columnName: String) -> String? {
        do {
            let idColumn = SQLite.Expression<Int64>("user_id")
            let targetColumn = SQLite.Expression<String>(columnName)
            if let row = try pluck(users.filter(idColumn == userId)) {
                return row[targetColumn]
            }
        } catch {
            print("Oops! Something went wrong. Please try again later.")
        }
        return nil
    }
    
    //get all the values for a user from a table where userID is a foriegn key
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
            print("Oops! Something went wrong. Please try again later.")
            return []
        }
    }
    
    //check if the email is present in the users table
    static func doesEmailExist(_ emailAddress: String) -> Bool {
        let cleaned = DatabaseManager.normalizedValue(emailAddress)
        let query = DatabaseManager.shared.users.filter(DatabaseManager.shared.email == cleaned)
        do {
            return try DatabaseManager.shared.pluck(query) != nil
        } catch {
            print("Oops! Something went wrong. Please try again later.")
            return false
        }
    }
    
    //normalize string and remove whitespace
    static func normalizedValue(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    //check if password meets complexity requirements
    static func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    
    //add user to the database
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
        
        // Insert into users table
        let insertUser = DatabaseManager.shared.users.insert(
            DatabaseManager.shared.security_question <- securityQuestion,
            DatabaseManager.shared.security_answer <- hashedSecurityAnswer,
            DatabaseManager.shared.email <- normalizedEmail,
            DatabaseManager.shared.password <- hashedPassword,
            DatabaseManager.shared.background_color <- background,
            DatabaseManager.shared.accent_color <- accent
        )
        
        //get user ID to use as foriegn key
        let userId: Int64
        do {
            userId = try DatabaseManager.shared.run(insertUser)
        } catch {
            print("Oops! Something went wrong. Please try again later.")
            throw error
        }
        
        // insert into symptoms table
        //seperate by comma and remove whitespace
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
                print("Oops! Something went wrong. Please try again later.")
            }
        }
        
        // insert into triggers table
        //seperate by comma and remove whitespace
        for trigger in triggers.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !trigger.isEmpty {
            let insertTrigger = DatabaseManager.shared.triggers.insert(
                DatabaseManager.shared.user_id <- userId,
                DatabaseManager.shared.trigger_name <- trigger,
                DatabaseManager.shared.trigger_start <- Date(),
                DatabaseManager.shared.trigger_end <- nil
            )
            do {
                _ = try DatabaseManager.shared.run(insertTrigger)
            } catch {
                print("Oops! Someting went wrong. Please try again later.")
            }
        }
        
        // insert into prev meds table
        //seperate by comma and remove whitespace
        for med in preventativeMeds.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !med.isEmpty {
            let insertMed = DatabaseManager.shared.medications.insert(
                DatabaseManager.shared.user_id <- userId,
                DatabaseManager.shared.med_category <- "preventative",
                DatabaseManager.shared.med_name <- med,
                DatabaseManager.shared.med_start <- Date(),
                DatabaseManager.shared.med_end <- nil
            )
            do {
                _ = try DatabaseManager.shared.run(insertMed)
            } catch {
                print("Oops! Something went wrong. Please try again later.")
            }
        }
        
        // insert into emeg meds table
        //seperate by comma and remove whitespace
        for med in emergencyMeds.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !med.isEmpty {
            let insertMed = DatabaseManager.shared.medications.insert(
                DatabaseManager.shared.user_id <- userId,
                DatabaseManager.shared.med_category <- "emergency",
                DatabaseManager.shared.med_name <- med,
                DatabaseManager.shared.med_start <- Date(),
                DatabaseManager.shared.med_end <- nil
            )
            do {
                _ = try DatabaseManager.shared.run(insertMed)
            } catch {
                print("Oops! Something went wrong. Please try again later.")
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
    
    //function to get hex codes from theme name
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
    
    //function to get theme name from hex codes
    static func getThemeName(selected_background: String, selected_accent: String) -> String{
        var themeName = ""
        
        if selected_background == "#FAF7F7" && selected_accent == "#5E5D5D" {
            themeName = "Classic Light"
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
            themeName = "Custom (\(selected_background) and \(selected_accent))"
        }
        return themeName
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
}
