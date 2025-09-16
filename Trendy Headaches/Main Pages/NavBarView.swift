//
//  NavBarView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//
import SwiftUI

struct NavBarView: View {
    let userID: Int64
    @EnvironmentObject var themeManager: ThemeManager
    @State private var refreshTrigger = false   // 🔹 trigger for TabView refresh

    var body: some View {
        TabView {
            LogView(userID: userID)
                .tabItem { Label("Log", systemImage: "square.and.pencil") }

            AnalyticsView(userID: userID)
                .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis") }

            ProfileView(userID: userID)
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .id(refreshTrigger)   // 🔹 force TabView to reload when trigger changes
        .onAppear {
            updateTabBarAppearance()
        }
        .onChange(of: themeManager.backgroundColor) { _ in
            updateTabBarAppearance()
            refreshTrigger.toggle()  // 🔹 force redraw
        }
        .onChange(of: themeManager.accentColor) { _ in
            updateTabBarAppearance()
            refreshTrigger.toggle()  // 🔹 force redraw
        }
    }

    func updateTabBarAppearance() {
        let bgUIColor = UIColor(Color(hex: themeManager.backgroundColor))
        let accentUIColor = UIColor(Color(hex: themeManager.accentColor))

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
}

#Preview {
    NavBarView(userID: 1)
        .environmentObject(ThemeManager())
}
