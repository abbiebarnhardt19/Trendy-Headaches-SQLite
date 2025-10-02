//
//  Custom Data Types.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI


//structs for functions to return

struct LogList {
    var log_type: String
    var log_id: Int64
    var symptom: String
    var date: Date
    var submit_date: Date
    var severity: Int64
    var id: String { "\(log_type)_\(log_id)" }
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
