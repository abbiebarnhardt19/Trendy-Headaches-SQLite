//
//  ListFunctions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SQLite

extension DatabaseManager {
    
    //function to get all the logs that go in the table
    func getLogList(userID: Int64) -> [LogList] {
        var logsList: [LogList] = []
        
        do {
            //first get all the symptom logs
            let query = DatabaseManager.shared.logs
                .filter(DatabaseManager.shared.user_id == userID)
            
            for row in try DatabaseManager.shared.prepare(query) {
                //just get data displayed in the table and the id
                let logID = row[DatabaseManager.shared.log_id]
                let date = row[DatabaseManager.shared.date]
                let submit_date = row[DatabaseManager.shared.submit_time]
                let severity = row[DatabaseManager.shared.severity]
                let symptomID = row[DatabaseManager.shared.symptom_id]
                
                // get symptom name using id
                var symptomName = "Unknown"
                if let symptomRow = try DatabaseManager.shared.pluck(
                    DatabaseManager.shared.symptoms.filter(DatabaseManager.shared.symptom_id == symptomID)) {
                    symptomName = symptomRow[DatabaseManager.shared.symptom_name]
                }
                //make a log instance and add it to the list
                let log = LogList(log_type: "Symptom",  log_id: logID, symptom: symptomName, date: date, submit_date: submit_date, severity: severity)
                logsList.append(log)
            }
            
            //now get the side effect logs
            let query2 = DatabaseManager.shared.side_effects.filter(DatabaseManager.shared.user_id == userID)
            for row in try DatabaseManager.shared.prepare(query2) {
                //just get data displayed in the table and the id
                let logID = row[DatabaseManager.shared.side_effect_id]
                let date = row[DatabaseManager.shared.side_effect_date]
                let severity = row[DatabaseManager.shared.side_effect_severity]
                let side_effect = row[DatabaseManager.shared.side_effect_name]
                
                //make a log instance and add it to the list
                let log = LogList( log_type: "Side Effect", log_id: logID, symptom: side_effect,  date: date, submit_date: date,  severity: severity )
                
                logsList.append(log)
            }
            
        } catch {
            print("Error fetching logs: \(error)")
        }
        
        //sort the logs my onset date and submit time
        logsList.sort {
            if $0.date != $1.date {
                return $0.date > $1.date
            } else {
                return $0.submit_date > $1.submit_date
            }
        }
        return logsList
    }
}
