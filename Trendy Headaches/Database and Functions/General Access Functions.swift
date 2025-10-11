//
//  General Access Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/30/25.
//

import SQLite

extension Database {
    
    // get a single column value using userID
    func getSingleColumnValue(userId: Int64, columnName: String) -> String? {
        do {
            //set variables
            let idColumn = SQLite.Expression<Int64>("user_id")
            let targetColumn = SQLite.Expression<String>(columnName)
            
            //grab the row and column
            if let row = try pluck(users.filter(idColumn == userId)) {
                return row[targetColumn]
            }
        } catch {
            print("SQLite error in getSingleColumnValue: \(error)")
        }
        return nil
    }
    
    //get all the values for a user from a table where userID is a foreign key
    func getForeignKeyColumnValues(userId: Int64, tableName: String, columnName: String,  filterColumn: String? = nil, filterValue: String? = nil) -> [String] {
        do {
            //set variables
            let idColumn = SQLite.Expression<Int64>("user_id")
            let targetColumn = SQLite.Expression<String>(columnName)
            let table = Table(tableName)
            
            var query = table.filter(idColumn == userId)
            
            //ensure values are current, use the table name to create the end column name
            let endColumnName = "\(tableName.lowercased().dropLast())_end"
            let endColumn = SQLite.Expression<String?>(endColumnName)
            
            //get all the values for the user where there is no end
            query = query.filter(endColumn == nil)
            if let filterColumn, let filterValue {
                let extraColumn = SQLite.Expression<String>(filterColumn)
                query = query.filter(extraColumn == filterValue)
            }
            
            //actually run the queries to get the results
            let results = try prepare(query).map { row in
                row[targetColumn]
            }
            return results
            
        } catch {
            print("SQLite error in getForeignKeyColumnValues: \(error)")
            return []
        }
    }
}
