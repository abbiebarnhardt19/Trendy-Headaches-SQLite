//
//  ThemeManager.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 9/15/25.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var backgroundColor: String
    @Published var accentColor: String
    
    init(background: String = "#001d00", accent: String = "#b5c4b9") {
        self.backgroundColor = background
        self.accentColor = accent
    }
}
