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
    func getForeignKeyColumnValues(
        userId: Int64,
        tableName: String,
        columnName: String,
        filterColumn: String? = nil,
        filterValue: String? = nil
    ) -> [String] {
        do {
            let idColumn = SQLite.Expression<Int64>("user_id")
            let targetColumn = SQLite.Expression<String>(columnName)
            let table = Table(tableName)
            
            var query = table.filter(idColumn == userId)
            
            let endColumnName = "\(tableName.lowercased().dropLast())_end"
            let endColumn = SQLite.Expression<String?>(endColumnName)
            
            query = query.filter(endColumn == nil)
            if let filterColumn, let filterValue {
                let extraColumn = SQLite.Expression<String>(filterColumn)
                query = query.filter(extraColumn == filterValue)
            }
            
            let results = try prepare(query).map { row in
                row[targetColumn]
            }
            return results
            
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
            print("\(error)")
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
                print("\(error)")
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
                print("\(error)")
            }
        }
        
        // insert into prev meds table
        //seperate by comma and remove whitespace
        for med in preventativeMeds.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !med.isEmpty {
            let insertMed = DatabaseManager.shared.medications.insert(
                DatabaseManager.shared.user_id <- userId,
                DatabaseManager.shared.medication_category <- "preventative",
                DatabaseManager.shared.medication_name <- med,
                DatabaseManager.shared.medication_start <- Date(),
                DatabaseManager.shared.medication_end <- nil
            )
            do {
                _ = try DatabaseManager.shared.run(insertMed)
            } catch {
                print("\(error)")
            }
        }
        
        // insert into emeg meds table
        //seperate by comma and remove whitespace
        for med in emergencyMeds.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !med.isEmpty {
            let insertMed = DatabaseManager.shared.medications.insert(
                DatabaseManager.shared.user_id <- userId,
                DatabaseManager.shared.medication_category <- "emergency",
                DatabaseManager.shared.medication_name <- med,
                DatabaseManager.shared.medication_start <- Date(),
                DatabaseManager.shared.medication_end <- nil
            )
            do {
                _ = try DatabaseManager.shared.run(insertMed)
            } catch {
                print("\(error)")
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
    
    //function to get hex codes from theme name
    static func getThemeColors(theme: String, currentBackground: String, currentAccent: String) -> (background: String, accent: String) {
        switch theme {
        case "Classic Light":
            return ("#FAF7F7", "#5E5D5D")
        case "Light Pink":
            return ("#F3D9DC", "#C78283")
        case "Classic Dark":
            return ("#0A0A0A", "#CCCCCC")
        case "Dark Green":
            return ("#001D00", "#B5C4B9")
        case "Dark Blue":
            return ("#0b3954", "#b5c6e0")
        case "Dark Purple":
            return ("#291C2D", "#CEC5dE")
        case "Custom":
            // Return whatever the user already has
            return (currentBackground, currentAccent)
        default:
            // Fallback for unknown theme names
            return (currentBackground, currentAccent)
        }
    }
    
    
    //function to get theme name from hex codes
    static func getThemeName(selected_background: String, selected_accent: String) -> String{
        var themeName = ""
        let background = selected_background.uppercased()
        let accent = selected_accent.uppercased()
        
        if background == "#FAF7F7" && accent == "#5E5D5D" {
            themeName = "Classic Light"
        }
        else if background == "#F3D9DC" && accent == "#C78283"{
            themeName = "Light Pink"
        }
        else if background == "#0A0A0A" && accent == "#CCCCCC" {
            themeName = "Classic Dark"
        }
        else if background == "#001D00" && accent == "#B5C4B9" {
            themeName = "Dark Green"
        }
        else if background == "#0b3954" && accent == "#b5c6e0"{
            themeName = "Dark Blue"
        }
        else if background == "#291C2D" && accent == "#CEC5dE" {
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
    
    //delete user function
    func deleteUser(userID: Int64) {
        do {
            let users = Table("users")
            let id = SQLite.Expression<Int64>("user_id")
            
            let deleteQuery = users.filter(id == userID).delete()
            let deletedCount = try run(deleteQuery)
            
            if deletedCount > 0 {
                print("Successfully deleted user \(userID)")
            } else {
                print("⚠️ No user found with id \(userID)")
            }
        } catch {
            print("❌ Failed to delete user \(userID): \(error)")
        }
    }
    
    func updateUser(userID: Int64, newValue: String, column: String){
        do {
            let users = Table("users")
            let id = SQLite.Expression<Int64>("user_id")
            let columnToUpdate = SQLite.Expression<String>(column)
            
            let updateQuery = users.filter(id == userID).update(columnToUpdate <- newValue)
            let updateCount = try DatabaseManager.shared.run(updateQuery)
            
            if updateCount > 0 {
                print("Successfully updated \(column)")
            } else {
                print("No user found with id \(userID)")
            }
        } catch {
            print("Failed to delete user \(userID): \(error)")
        }
    }
    
    
    func insertItem(table: Table, userID: Int64, nameColumn: SQLite.Expression<String>, name: String, startColumn: SQLite.Expression<Date>, endColumn: SQLite.Expression<Date?>, medicationCategory: String? = nil) {
        var setters: [Setter] = [
            user_id <- userID,
            nameColumn <- name,
            startColumn <- Date(),
            endColumn <- nil
        ]
        
        // Always use DatabaseManager.shared.med_category as the column
        if let category = medicationCategory {
            setters.append(DatabaseManager.shared.medication_category <- category)
        }
        
        let insert = table.insert(setters)
        do {
            _ = try run(insert)
            print("✅ Inserted \(name)")
        } catch {
            print("❌ Failed to insert \(name): \(error)")
        }
    }
    
    
    func updateItem(
        table: Table,
        userID: Int64,
        oldValue: String,
        newValue: String,
        nameColumn: SQLite.Expression<String>,
        medicationCategory: String? = nil
    ) {
        var filter = table.filter(user_id == userID && nameColumn == oldValue)
        
        // If a category is provided, filter by it too
        if let category = medicationCategory {
            filter = filter.filter(DatabaseManager.shared.medication_category == category)
        }
        
        do {
            _ = try run(filter.update(nameColumn <- newValue))
            if let category = medicationCategory {
                print("✅ Updated \(oldValue) → \(newValue) (\(category))")
            } else {
                print("✅ Updated \(oldValue) → \(newValue)")
            }
        } catch {
            print("❌ Failed to update \(oldValue): \(error)")
        }
    }
    
    
    func endItem(
        table: Table,
        userID: Int64,
        name: String,
        nameColumn: SQLite.Expression<String>,
        endColumn: SQLite.Expression<Date?>,
        medicationCategory: String? = nil
    ) {
        var filter = table.filter(user_id == userID && nameColumn == name)
        
        // If a category is provided, filter by it too
        if let category = medicationCategory {
            filter = filter.filter(DatabaseManager.shared.medication_category == category)
        }
        
        do {
            _ = try run(filter.update(endColumn <- Date()))
            if let category = medicationCategory {
                print("✅ Ended \(name) (\(category)) at \(Date())")
            } else {
                print("✅ Ended \(name) at \(Date())")
            }
        } catch {
            print("❌ Failed to end \(name): \(error)")
        }
    }
    
    func loadData(
        userID: Int64,
        symptoms: inout [String],
        triggers: inout [String],
        prevMeds: inout [String],
        emergencyMeds: inout [String],
        securityQuestion: inout String,
        securityAnswer: inout String,
        newSecurityQuestion: inout String,
        backgroundColor: inout String,
        accentColor: inout String,
        newBackground: inout String,
        newAccent: inout String,
        themeName: inout String,
        newThemeName: inout String
    ) {
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
    
    func getIDFromName(tableName: String, names: [String], userID: Int64) -> [Int64] {
        // Convert "symptoms" -> "symptom_name" and "symptom_id"
        let singular = String(tableName.dropLast())
        let idColumn = SQLite.Expression<Int64>("\(singular)_id")
        let nameColumn = SQLite.Expression<String>("\(singular)_name")
        let userColumn = SQLite.Expression<Int64>("user_id")
        let table = Table(tableName)
        
        var ids: [Int64] = []
        
        for name in names {
            let query = table.filter(userColumn == userID && nameColumn == name)
            do {
                if let row = try DatabaseManager.shared.pluck(query) {
                    ids.append(row[idColumn])
                } else {
                    print("No row found for '\(name)'")
                }
            } catch {
                print("Error querying \(tableName) for '\(name)': \(error)")
            }
        }
        
        return ids
    }
    
    
    
    //create log function
    func createLog(
        userID: Int64,
        date: Date,
        symptom_onset: String?,
        symptom: Int64,
        severity: Int64,
        med_taken: Bool,
        med_taken_id: Int64?,
        symptom_desc: String,
        notes: String,
        submit: Date,
        triggerIDs: [Int64] = []
    ) -> Int64? {
        
        do {
            // Insert log row
            let insert = DatabaseManager.shared.logs.insert(
                DatabaseManager.shared.user_id <- userID,
                DatabaseManager.shared.date <- date,
                DatabaseManager.shared.onset_time <- symptom_onset,
                DatabaseManager.shared.severity <- severity,
                DatabaseManager.shared.symptom_id <- symptom,
                DatabaseManager.shared.med_taken <- med_taken,
                DatabaseManager.shared.log_medication_id <- med_taken_id,
                DatabaseManager.shared.med_worked <- nil, // now nullable
                DatabaseManager.shared.symptom_description <- symptom_desc,
                DatabaseManager.shared.notes <- notes,
                DatabaseManager.shared.submit_time <- submit
            )
            
            // Execute insert
            let logID = try DatabaseManager.shared.run(insert)
            
            // If triggers were passed in, associate them in the junction table
            for trigID in triggerIDs {
                let linkInsert = DatabaseManager.shared.log_triggers.insert(
                    DatabaseManager.shared.lt_log_id <- logID,
                    DatabaseManager.shared.lt_trigger_id <- trigID
                )
                _ = try DatabaseManager.shared.run(linkInsert)
            }
            
            // Fetch and print the inserted row
            // Fetch and print the inserted row in a readable format
            let query = DatabaseManager.shared.logs.filter(DatabaseManager.shared.log_id == logID)
            if let insertedRow = try DatabaseManager.shared.pluck(query) {
                let id: Int64 = insertedRow[DatabaseManager.shared.log_id]
                let user: Int64 = insertedRow[DatabaseManager.shared.user_id]
                let date: Date = insertedRow[DatabaseManager.shared.date]
                let onset: String = insertedRow[DatabaseManager.shared.onset_time] ?? " "
                let symptomID: Int64 = insertedRow[DatabaseManager.shared.symptom_id]
                let severity: Int64 = insertedRow[DatabaseManager.shared.severity]
                let medTaken: Bool = insertedRow[DatabaseManager.shared.med_taken]
                let medID: Int64? = insertedRow[DatabaseManager.shared.log_medication_id]
                let medWorked: Bool? = insertedRow[DatabaseManager.shared.med_worked]
                let desc: String = insertedRow[DatabaseManager.shared.symptom_description]
                let notes: String = insertedRow[DatabaseManager.shared.notes]
                let submitTime: Date = insertedRow[DatabaseManager.shared.submit_time]

                print("""
                    Inserted Log:
                    logID: \(id)
                    userID: \(user)
                    date: \(date)
                    onset_time: \(onset)
                    symptom_id: \(symptomID)
                    severity: \(severity)
                    med_taken: \(medTaken)
                    med_taken_id: \(medID ?? -1)
                    med_worked: \(medWorked.map { "\($0)" } ?? "nil")
                    symptom_description: \(desc)
                    notes: \(notes)
                    submit_time: \(submitTime)
                    """)
            }

            
            return logID
            
        } catch {
            print("Failed to create log: \(error)")
            return nil
        }
    }

    
//    struct Log {
//        var id: Int64
//        var userID: Int64
//        var date: Date
//        var symptomOnset: String
//        var symptom: Int64
//        var severity: Int64
//        var medTaken: Bool
//        var medTakenID: Int64?
//        var medWorked: Bool?
//        var symptomDesc: String
//        var notes: String
//        var submit: Date
//        var triggerIDs: [Int64]
//    }
//    
//    
//    func getLog(byID logID: Int64) -> Log? {
//        do {
//            print("entered do")
//            let query = logs.filter(log_id == logID)
//            if let row = try pluck(query) {
//                let triggerQuery = log_triggers.filter(lt_log_id == logID)
//                let triggers = try prepare(triggerQuery).map { $0[lt_trigger_id] }
//                
//                // Return a Log struct, not a tuple
//                return Log(
//                    id: row[log_id],
//                    userID: row[user_id],
//                    date: row[date],
//                    symptomOnset: row[onset_time],
//                    symptom: row[symptom_id],
//                    severity: row[severity],
//                    medTaken: row[med_taken],
//                    medTakenID: row[log_medication_id],
//                    medWorked: row[med_worked],
//                    symptomDesc: row[symptom_description],
//                    notes: row[notes],
//                    submit: row[submit_time],
//                    triggerIDs: triggers
//                )
//            } else {
//                print("No log found with ID \(logID)")
//                return nil
//            }
//        } catch {
//            print("Failed to fetch log: \(error)")
//            return nil
//        }
//    }
    
    func createSideEffectLog(
        userID: Int64,
        date: Date,
        side_effect: String,
        side_effect_severity: Int64,
        medication_id: Int64 ) -> Int64? {
            
            do {
                // Insert log row
                let insert = DatabaseManager.shared.side_effects.insert(
                    DatabaseManager.shared.user_id <- userID,
                    DatabaseManager.shared.side_effect_date <- date,
                    DatabaseManager.shared.side_effect_name <- side_effect,
                    DatabaseManager.shared.side_effect_severity <- side_effect_severity,
                    DatabaseManager.shared.medication_id <- medication_id
                )
                
                // Execute insert
                let logID = try DatabaseManager.shared.run(insert)
                
                return logID // Return the actual log's primary key
                
            } catch {
                print("Failed to create log: \(error)")
                return nil
            }
        }
    
    //    func emergencyMedPopup(userID: Int64) -> [(Date, String, String)] {
    //        var results: [(Date, String, String)] = []
    //
    //        do {
    //            let logs = DatabaseManager.shared.logs
    //            let symptoms = DatabaseManager.shared.symptoms
    //            var symptomName = ""
    //            var medName = ""
    //
    //            let query = logs
    //                .filter(DatabaseManager.shared.user_id == userID)
    //                .filter(DatabaseManager.shared.med_taken == true)
    //                .filter(DatabaseManager.shared.med_worked != true && DatabaseManager.shared.med_worked != false)
    //
    //            let rows = try DatabaseManager.shared.prepare(query)
    //
    //            for row in rows {
    //                let onsetDate = row[DatabaseManager.shared.date]
    //                let symptomID = row[DatabaseManager.shared.symptom_id]
    //                let medID = row[DatabaseManager.shared.medication_id]
    //
    //                // Lookup symptom name
    //                let symptomQuery = symptoms.filter(DatabaseManager.shared.symptom_id == symptomID)
    //                if let symptomRow = try DatabaseManager.shared.pluck(symptomQuery) {
    //                    symptomName = symptomRow[DatabaseManager.shared.symptom_name]
    //                }
    //
    //                let medQuery = medications.filter(DatabaseManager.shared.medication_id == medID)
    //                if let medRow = try DatabaseManager.shared.pluck(medQuery) {
    //                    medName = medRow[DatabaseManager.shared.medication_name]
    //
    //                }
    //                print("here")
    //                results.append((onsetDate, symptomName,medName))
    //                print(results)
    //            }
    //
    //        } catch {
    //            print("Database error: \(error)")
    //        }
    //
    //        return results
    //    }
    
    func emergencyMedPopup(userID: Int64) -> [Int64] {
        var results: [Int64] = []
        
        do {
            let logs = DatabaseManager.shared.logs
            
            let query = logs
                .filter(DatabaseManager.shared.user_id == userID)
                .filter(DatabaseManager.shared.med_taken == true)
                .filter(DatabaseManager.shared.med_worked != true && DatabaseManager.shared.med_worked != false)
            
            let rows = try DatabaseManager.shared.prepare(query)
            
            for row in rows {
                let logID = row[DatabaseManager.shared.log_id] // Get just the log ID
                results.append(logID)
            }
            
        } catch {
            print("Database error: \(error)")
        }
        return results
    }
    
    
    func updateMedEffective(logID: Int64, medEffectiveValue: Bool) {
        do {
            // Build the filter query for the log we want to update
            let log = logs.filter(log_id == logID)
            
            // Use the helper run(_:) for updates
            _ = try run(log.update(med_worked <- medEffectiveValue))
            
        } catch {
            print(" Failed to update log \(logID): \(error)")
        }
    }
    
    
    
    func getLogDetails(logID: Int64) -> (userID: Int64, date: Date, symptomName: String, symptomID: Int64, emergencyMedID: Int64, emergencyMedName: String)? {
        do {
            let logs = DatabaseManager.shared.logs
            let symptoms = DatabaseManager.shared.symptoms
            let medications = DatabaseManager.shared.medications
            
            // Get the log row for the given logID
            let logQuery = logs.filter(DatabaseManager.shared.log_id == logID)
            if let logRow = try DatabaseManager.shared.pluck(logQuery) {
                
                // Extract base log info
                let userID = logRow[DatabaseManager.shared.user_id]
                let date = logRow[DatabaseManager.shared.date]
                let symptomID = logRow[DatabaseManager.shared.symptom_id]
                let emergencyMedID = logRow[DatabaseManager.shared.medication_id]
                
                // Get symptom name
                var symptomName = ""
                let symptomQuery = symptoms.filter(DatabaseManager.shared.symptom_id == symptomID)
                if let symptomRow = try DatabaseManager.shared.pluck(symptomQuery) {
                    symptomName = symptomRow[DatabaseManager.shared.symptom_name]
                }
                
                // Get medication name
                var emergencyMedName = ""
                let medQuery = medications.filter(DatabaseManager.shared.medication_id == emergencyMedID)
                if let medRow = try DatabaseManager.shared.pluck(medQuery) {
                    emergencyMedName = medRow[DatabaseManager.shared.medication_name]
                }
                
                return (userID, date, symptomName, symptomID, emergencyMedID, emergencyMedName)
            }
        } catch {
            print("Database error while fetching log details: \(error)")
        }
        
        return nil
    }
    
    struct SymptomLog {
        var log_id: Int64
        var user_id: Int64
        var date: Date
        var onset_time: String?
        var severity: Int64
        var symptom_id: Int64?
        var med_taken: Bool
        var medication_id: Int64?
        var med_worked: Bool?
        var symptom_description: String?
        var notes: String?
        var submit_time: Date
        var symptom_name: String?
        var medication_name: String?
        var trigger_ids: [Int64] = []
        var trigger_names: [String] = []
    }
    
    
    func getSymptomLog(by logID: Int64) -> SymptomLog? {
        do {
            let query = logs.filter(self.log_id == logID)
            if let row = try pluck(query) {
                // Symptom is non-optional in logs
                let symptomID = row[self.symptom_id]
                var symptomName: String? = nil
                let symptomQuery = symptoms.filter(self.symptom_id == symptomID)
                if let sRow = try pluck(symptomQuery) {
                    symptomName = sRow[self.symptom_name]
                }

                // Medication is optional
                let medicationID: Int64? = row[self.log_medication_id]
                var medicationName: String? = nil
                if let mID = medicationID {
                    let medQuery = medications.filter(self.medication_id == mID)
                    if let mRow = try pluck(medQuery) {
                        medicationName = mRow[self.medication_name]
                    }
                }

                // Triggers
                var triggerIDs: [Int64] = []
                var triggerNames: [String] = []

                let triggerQuery = log_triggers.filter(lt_log_id == logID)
                for tRow in try prepare(triggerQuery) {
                    let tID = tRow[lt_trigger_id]
                    triggerIDs.append(tID)

                    if let tRow = try pluck(triggers.filter(trigger_id == tID)) {
                        triggerNames.append(tRow[trigger_name])
                    }
                }

                return SymptomLog(
                    log_id: row[self.log_id],
                    user_id: row[self.user_id],
                    date: row[self.date],
                    onset_time: row[self.onset_time],
                    severity: row[self.severity],
                    symptom_id: symptomID,
                    med_taken: row[self.med_taken],
                    medication_id: medicationID,
                    med_worked: row[self.med_worked],
                    symptom_description: row[self.symptom_description],
                    notes: row[self.notes],
                    submit_time: row[self.submit_time],
                    symptom_name: symptomName,
                    medication_name: medicationName,
                    trigger_ids: triggerIDs,
                    trigger_names: triggerNames
                )
            }
        } catch {
            print("Error fetching symptom log \(logID): \(error)")
        }
        return nil
    }

    
    func updateSymptomLog(
        logID: Int64,
        userID: Int64,
        date: Date?,
        onsetTime: String?,
        severity: Int64?,
        symptomID: Int64?,
        medTaken: Bool?,
        medicationID: Int64?,
        medWorked: Bool?,
        symptomDescription: String?,
        notes: String?,
        triggerIDs: [Int64]?
    ) {
        do {
            // Fetch current row
            let query = logs.filter(self.log_id == logID)
            guard let row = try pluck(query) else { return }
            
            // Build update dictionary dynamically
            var setters: [Setter] = []
            
            if let newDate = date, newDate != row[self.date] {
                setters.append(self.date <- newDate)
            }
            
            if let newOnset = onsetTime, newOnset != row[self.onset_time] {
                setters.append(self.onset_time <- newOnset)
            }
            
            if let newSeverity = severity, newSeverity != row[self.severity] {
                setters.append(self.severity <- newSeverity)
            }
            
            if let newSymptomID = symptomID, newSymptomID != row[self.symptom_id] {
                setters.append(self.symptom_id <- newSymptomID)
            }
            
            if let newMedTaken = medTaken, newMedTaken != row[self.med_taken] {
                setters.append(self.med_taken <- newMedTaken)
            }
            
            if let newMedicationID = medicationID, newMedicationID != row[self.medication_id] {
                setters.append(self.medication_id <- newMedicationID)
            }
            
            if let newMedWorked = medWorked, newMedWorked != row[self.med_worked] {
                setters.append(self.med_worked <- newMedWorked)
            }
            
            if let newSymptomDesc = symptomDescription, newSymptomDesc != row[self.symptom_description] {
                setters.append(self.symptom_description <- newSymptomDesc)
            }
            
            if let newNotes = notes, newNotes != row[self.notes] {
                setters.append(self.notes <- newNotes)
            }
            
            // Perform update only if there’s something to update
            if !setters.isEmpty {
                let updateQuery = query.update(setters)
               _ =  try run(updateQuery)
            }
            
            // Update triggers separately if needed
            if let newTriggerIDs = triggerIDs {
                // Remove old triggers for this log
               _ = try run(log_triggers.filter(lt_log_id == logID).delete())
                
                // Insert new trigger links
                for tID in newTriggerIDs {
                    _ = try run(log_triggers.insert(lt_log_id <- logID, lt_trigger_id <- tID))
                }
            }
            print("Update complete")
            
        } catch {
            print("Error updating symptom log: \(error)")
        }
    }
    
    struct SideEffectLog {
        var side_effect_id: Int64
        var user_id: Int64
        var date: Date
        var side_effect_name: String?
        var side_effect_severity: Int64
        var medication_id: Int64?
        var medication_name: String?
    }

    func getSideEffectLog(by logID: Int64) -> SideEffectLog? {
        do {
            let query = side_effects.filter(self.side_effect_id == logID)
            if let row = try pluck(query) {
                let medicationID = row[self.medication_id]
                
                // Lookup medication name
                var medicationName: String? = nil
                let medID = medicationID   // plain Int64

                let medQuery = medications.filter(self.medication_id == medID)
                if let medRow = try pluck(medQuery) {
                    medicationName = medRow[self.medication_name]
                }

                
                return SideEffectLog(
                    side_effect_id: row[self.side_effect_id],
                    user_id: row[self.user_id],
                    date: row[self.side_effect_date],
                    side_effect_name: row[self.side_effect_name],
                    side_effect_severity: row[self.side_effect_severity],
                    medication_id: medicationID,
                    medication_name: medicationName
                )
            }
        } catch {
            print("Error fetching side effect log \(logID): \(error)")
        }
        return nil
    }

    
    
    func updateSideEffectLog(
        logID: Int64,
        userID: Int64,
        date: Date?,
        sideEffectName: String?,
        sideEffectSeverity: Int64?,
        medicationID: Int64?
    ) {
        do {
            // Fetch current row
            let query = side_effects.filter(self.side_effect_id == logID)
            guard let row = try pluck(query) else { return }
            
            // Build update dictionary dynamically
            var setters: [Setter] = []
            
            if let newDate = date, newDate != row[self.side_effect_date] {
                setters.append(self.side_effect_date <- newDate)
            }
            
            if let newName = sideEffectName, newName != row[self.side_effect_name] {
                setters.append(self.side_effect_name <- newName)
            }
            
            if let newSeverity = sideEffectSeverity, newSeverity != row[self.side_effect_severity] {
                setters.append(self.side_effect_severity <- newSeverity)
            }
            
            if let newMedicationID = medicationID, newMedicationID != row[self.medication_id] {
                setters.append(self.medication_id <- newMedicationID)
            }
            
            // Perform update only if there’s something to update
            if !setters.isEmpty {
                let updateQuery = query.update(setters)
                _ = try run(updateQuery)
            }
            
            print("Side effect log update complete")
            
        } catch {
            print("Error updating side effect log: \(error)")
        }
    }



}



