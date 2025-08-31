//
//  LogView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//

import SwiftUI

struct LogView: View {
    
    var userID: Int64? = nil
    var backgroundColor: String = ""
    var accentColor: String = ""
    
    var body: some View {
        VStack {
            CustomText(text: "Log", color: accentColor)
        }
        .padding()
        .CustomView(color: backgroundColor)
    }
}

#Preview {
    LogView(userID: 1, backgroundColor: "#001d00", accentColor: "#b5c4b9")
}
