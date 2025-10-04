//
//  ListFunctions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SQLite
import Foundation

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
