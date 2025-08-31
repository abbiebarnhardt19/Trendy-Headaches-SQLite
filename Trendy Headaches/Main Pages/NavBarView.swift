//
//  NavBarView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//
import SwiftUI

struct NavBarView: View {
    
    let userID: Int64               // Non-optional now
    var backgroundColor: String
    var accentColor: String
    
    init(userID: Int64, backgroundColor: String = "#001d00", accentColor: String = "#b5c4b9") {
        self.userID = userID
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor

        // Configure Tab Bar appearance
        let bgUIColor = UIColor(Color(hex: backgroundColor))
        let accentUIColor = UIColor(Color(hex: accentColor))

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = bgUIColor

        appearance.stackedLayoutAppearance.selected.iconColor = accentUIColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accentUIColor]

        appearance.stackedLayoutAppearance.normal.iconColor = accentUIColor.withAlphaComponent(0.66)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: accentUIColor.withAlphaComponent(0.66)]

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        TabView {
            LogView(userID: userID, backgroundColor: backgroundColor, accentColor: accentColor)
                .tabItem { Label("Log", systemImage: "square.and.pencil") }

            AnalyticsView(userID: userID, backgroundColor: backgroundColor, accentColor: accentColor)
                .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis") }

            ProfileView(userID: userID, backgroundColor: backgroundColor, accentColor: accentColor)
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}

#Preview {
    NavBarView(userID: 1, backgroundColor: "#001d00", accentColor: "#b5c4b9")
}
