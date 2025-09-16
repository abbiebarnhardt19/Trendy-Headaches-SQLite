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
    @State private var selectedTab: Int = 2
    @State private var refreshTrigger: Bool = false

    var body: some View {
        TabView(selection: $selectedTab) {
            LogView(userID: userID)
                .tabItem { Label("Log", systemImage: "square.and.pencil") }
                .tag(0)

            AnalyticsView(userID: userID)
                .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis") }
                .tag(1)

            ProfileView(userID: userID)
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(2)
        }
        .id(refreshTrigger) // force redraw
        .onAppear { updateTabBarAppearance() }
        .onChange(of: themeManager.backgroundColor) { _ in
            updateTabBarAppearance()
            DispatchQueue.main.async {
                refreshTrigger.toggle() // redraw TabView without losing state
            }
        }
        .onChange(of: themeManager.accentColor) { _ in
            updateTabBarAppearance()
            DispatchQueue.main.async {
                refreshTrigger.toggle()
            }
        }
    }

    private func updateTabBarAppearance() {
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
