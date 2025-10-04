////
////  ListFunctions.swift
////  Trendy Headaches
////
////  Created by Abigail Barnhardt on 10/2/25.
////
//
import SQLite
import Foundation
//
//extension DatabaseManager {
//    
//    //function to get all the logs that go in the table
//    func getLogList(userID: Int64) -> [LogList] {
//        var logsList: [LogList] = []
//        
//        do {
//            //first get all the symptom logs
//            let query = DatabaseManager.shared.logs
//                .filter(DatabaseManager.shared.user_id == userID)
//            
//            for row in try DatabaseManager.shared.prepare(query) {
//                //just get data displayed in the table and the id
//                let logID = row[DatabaseManager.shared.log_id]
//                let date = row[DatabaseManager.shared.date]
//                let submit_date = row[DatabaseManager.shared.submit_time]
//                let severity = row[DatabaseManager.shared.severity]
//                let symptomID = row[DatabaseManager.shared.symptom_id]
//                
//                // get symptom name using id
//                var symptomName = "Unknown"
//                if let symptomRow = try DatabaseManager.shared.pluck(
//                    DatabaseManager.shared.symptoms.filter(DatabaseManager.shared.symptom_id == symptomID)) {
//                    symptomName = symptomRow[DatabaseManager.shared.symptom_name]
//                }
//                //make a log instance and add it to the list
//                let log = LogList(log_type: "Symptom",  log_id: logID, symptom: symptomName, date: date, submit_date: submit_date, severity: severity)
//                logsList.append(log)
//            }
//            
//            //now get the side effect logs
//            let query2 = DatabaseManager.shared.side_effects.filter(DatabaseManager.shared.user_id == userID)
//            for row in try DatabaseManager.shared.prepare(query2) {
//                //just get data displayed in the table and the id
//                let logID = row[DatabaseManager.shared.side_effect_id]
//                let date = row[DatabaseManager.shared.side_effect_date]
//                let severity = row[DatabaseManager.shared.side_effect_severity]
//                let side_effect = row[DatabaseManager.shared.side_effect_name]
//                
//                //make a log instance and add it to the list
//                let log = LogList( log_type: "Side Effect", log_id: logID, symptom: side_effect,  date: date, submit_date: date,  severity: severity )
//                
//                logsList.append(log)
//            }
//            
//        } catch {
//            print("Error fetching logs: \(error)")
//        }
//        
//        //sort the logs my onset date and submit time
//        logsList.sort {
//            if $0.date != $1.date {
//                return $0.date > $1.date
//            } else {
//                return $0.submit_date > $1.submit_date
//            }
//        }
//        return logsList
//    }
//}


import SQLite

//extension DatabaseManager {
//    
//    func getLogList(userID: Int64) -> [UnifiedLog] {
//        var logsList: [UnifiedLog] = []
//        
//        do {
//            // --- SYMPTOM LOGS ---
//            let symptomQuery = logs.filter(user_id == userID)
//            
//            for row in try DatabaseManager.shared.prepare(symptomQuery) {
//                let log = UnifiedLog(
//                    log_id: row[log_id],
//                    user_id: row[user_id],
//                    log_type: "Symptom",
//                    date: row[date],
//                    severity: row[severity],
//                    submit_time: row[submit_time],
//                    
//                    // Symptom-specific
//                    symptom_id: row[symptom_id],
//                    
//                    //symptom_name: row[symptom_name]
//                    onset_time: row[onset_time],
//                    med_taken: row[med_taken],
//                    medication_id: row[medication_id],
////                    medication_name: row[medication_name],
//                    med_worked: row[med_worked],
//                    symptom_description: row[symptom_description],
//                    notes: row[notes]
////
//                )
//                
//                logsList.append(log)
//            }
//            
//            // --- SIDE EFFECT LOGS ---
//            let sideEffectQuery = side_effects.filter(user_id == userID)
//            
//            for row in try DatabaseManager.shared.prepare(sideEffectQuery) {
//                let log = UnifiedLog(
//                    log_id: row[side_effect_id],         // use side_effect_id as log_id
//                    user_id: row[user_id],
//                    log_type: "SideEffect",
//                    date: row[side_effect_date],
//                    severity: row[side_effect_severity],
//                    submit_time: row[side_effect_date],  // no submit_time column? reuse date
//                    
//                    // Symptom-specific — none here
//                    symptom_id: nil,
////                    symptom_name: row[side_effect_name]
////                    symptom_name: nil,
//                   onset_time: nil,
//                    med_taken: nil,
//                    medication_id: nil,
////                    medication_name: row[medication_name],
//                    med_worked: nil,
//                    symptom_description: nil,
//                    notes: nil
//                )
//                
//                logsList.append(log)
//            }
//            
//        } catch {
//            print("❌ Error fetching logs: \(error)")
//        }
//        
//        // --- Sort by date and submit_time ---
//        logsList.sort {
//            if $0.date != $1.date {
//                return $0.date > $1.date
//            } else {
//                return ($0.submit_time ?? $0.date) > ($1.submit_time ?? $1.date)
//            }
//        }
//        
//        return logsList
//    }
//    
//    // Helpers for optional array columns (if you store them as CSV or JSON)
//    private func parseIntArray(_ string: String?) -> [Int64]? {
//        guard let str = string, !str.isEmpty else { return nil }
//        return str.split(separator: ",").compactMap { Int64($0.trimmingCharacters(in: .whitespaces)) }
//    }
//    
//    private func parseStringArray(_ string: String?) -> [String]? {
//        guard let str = string, !str.isEmpty else { return nil }
//        return str.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
//    }
//}
//
//extension DatabaseManager {
//    func getLogList(userID: Int64) -> [UnifiedLog] {
//        var unifiedLogs: [UnifiedLog] = []
//        
//        do {
//            // 1️⃣ Query all logs for this user
//            let logQuery = logs.filter(self.user_id == userID)
//            
//            for logRow in try self.prepare(logQuery) {
//                
//                // Extract IDs
//                let sid = logRow[self.symptom_id]
//                let mid = logRow[self.log_medication_id]
//                
//                // 2️⃣ Get symptom name if available
//                var symptomName: String? = nil
//                    let symptomQuery = symptoms.filter(self.symptom_id == sid)
//                    if let symptomRow = try self.pluck(symptomQuery) {
//                        symptomName = symptomRow[self.symptom_name]
//                }
//                
//                // 3️⃣ Get medication name if available
//                var medicationName: String? = nil
//                if let mid = mid {
//                    let medQuery = medications.filter(self.medication_id == mid)
//                    if let medRow = try self.pluck(medQuery) {
//                        medicationName = medRow[self.medication_name]
//                    }
//                }
//                
//                // 4️⃣ Get triggers (optional many-to-many join)
//                var triggerNames: [String] = []
//                let triggerJoin = log_triggers
//                    .join(triggers, on: log_triggers[self.lt_trigger_id] == triggers[self.trigger_id])
//                    .filter(log_triggers[self.lt_log_id] == logRow[self.log_id])
//                
//                for trigRow in try self.prepare(triggerJoin) {
//                    triggerNames.append(trigRow[self.trigger_name])
//                }
//                
//                // 5️⃣ Create UnifiedLog entry
//                let unifiedLog = UnifiedLog(
//                    log_id: logRow[self.log_id],
//                    user_id: logRow[self.user_id],
//                    log_type: "Symptom",
//                    date: logRow[self.date],
//                    severity: logRow[self.severity],
//                    submit_time: logRow[self.submit_time],
//                    
//                    symptom_id: sid,
//                    symptom_name: symptomName,
//                    onset_time: logRow[self.onset_time],
//                    med_taken: logRow[self.med_taken],
//                    medication_id: mid,
//                    medication_name: medicationName,
//                    med_worked: logRow[self.med_worked],
//                    symptom_description: logRow[self.symptom_description],
//                    notes: logRow[self.notes],
//                    
//                    trigger_ids: nil,
//                    trigger_names: triggerNames,
//                    
//                    // Side-effect fields nil for symptom logs
//                    side_effect_id: nil,
//                    side_effect_name: nil,
//                    side_effect_severity: nil
//                )
//                
//                unifiedLogs.append(unifiedLog)
//            }
//        } catch {
//            print("Error fetching unified logs: \(error)")
//        }
//        
//        return unifiedLogs
//    }
//}
extension DatabaseManager {
    func getLogList(userID: Int64) -> [UnifiedLog] {
        var unifiedLogs: [UnifiedLog] = []
        
        do {
            // ===== 1️⃣ SYMPTOM LOGS =====
            let symptomLogsQuery = logs.filter(self.user_id == userID)
            
            for row in try self.prepare(symptomLogsQuery) {
                let sid = row[self.symptom_id]
                let mid = row[self.log_medication_id]
                
                // Fetch symptom name via ID
                var symptomName: String? = nil
                let symptomQuery = symptoms.filter(self.symptom_id == sid)
                if let symptomRow = try self.pluck(symptomQuery) {
                    symptomName = symptomRow[self.symptom_name]
                }
                
                // Fetch medication name (if any)
                var medicationName: String? = nil
                if let mid = mid {
                    let medQuery = medications.filter(self.medication_id == mid)
                    if let medRow = try self.pluck(medQuery) {
                        medicationName = medRow[self.medication_name]
                    }
                }
                
                // Fetch triggers (optional)
                var triggerNames: [String] = []
                let triggerJoin = log_triggers
                    .join(triggers, on: log_triggers[self.lt_trigger_id] == triggers[self.trigger_id])
                    .filter(log_triggers[self.lt_log_id] == row[self.log_id])
                
                for trigRow in try self.prepare(triggerJoin) {
                    triggerNames.append(trigRow[self.trigger_name])
                }
                
                // Create Symptom log
                let unifiedLog = UnifiedLog(
                    log_id: row[self.log_id],
                    user_id: row[self.user_id],
                    log_type: "Symptom",
                    date: row[self.date],
                    severity: row[self.severity],
                    submit_time: row[self.submit_time],
                    
                    // Symptom-specific
                    symptom_id: sid,
                    symptom_name: symptomName,
                    onset_time: row[self.onset_time],
                    med_taken: row[self.med_taken],
                    medication_id: mid,
                    medication_name: medicationName,
                    med_worked: row[self.med_worked],
                    symptom_description: row[self.symptom_description],
                    notes: row[self.notes],
                    trigger_ids: nil,
                    trigger_names: triggerNames
                )
                
                unifiedLogs.append(unifiedLog)
            }
            
            // ===== 2️⃣ SIDE EFFECT LOGS =====
            let sideEffectQuery = side_effects.filter(self.user_id == userID)
            
            for row in try self.prepare(sideEffectQuery) {
                let mid = row[self.side_effect_medication_id]
                
                // Fetch medication name
                var medicationName: String? = nil
                if let mid = mid {
                    let medQuery = medications.filter(self.medication_id == mid)
                    if let medRow = try self.pluck(medQuery) {
                        medicationName = medRow[self.medication_name]
                    }
                }
                
                // Create SideEffect log
                let unifiedLog = UnifiedLog(
                    log_id: row[self.side_effect_id],
                    user_id: row[self.user_id],
                    log_type: "Side Effect",
                    date: row[self.side_effect_date],
                    severity: row[self.side_effect_severity],
                    submit_time: row[self.side_effect_submit_time],
                    
                    // Symptom-specific (nil)
                    symptom_id: nil,
                    symptom_name: row[self.side_effect_name],
                    onset_time: nil,
                    med_taken: nil,
                    medication_id: row[self.side_effect_medication_id],
                    medication_name: medicationName,
                    med_worked: nil,
                    symptom_description: nil,
                    notes: nil,
                    trigger_ids: nil,
                    trigger_names: nil
                )
                
                unifiedLogs.append(unifiedLog)
            }
            
            // ===== 3️⃣ SORT COMBINED RESULTS =====
            unifiedLogs.sort {
                if $0.date == $1.date {
                    return ($0.submit_time) > ($1.submit_time)
                }
                return $0.date > $1.date
            }
            
        } catch {
            print("❌ Error fetching unified logs: \(error)")
        }
        
        return unifiedLogs
    }
}
