//
//  NavBarView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//

import SwiftUI

struct NavBarView: View {
    let userID: Int64
    @Binding var background: String
    @Binding var accent: String
    
    // Simple model for each tab
    struct NavItem {
        let icon: String
        let label: String
        let destination: AnyView
        let padding: EdgeInsets?
    }
    
    var navItems: [NavItem]
    {
        [NavItem(icon: "square.and.pencil", label: "Log", destination: AnyView(LogView(userID: userID, background: $background, accent: $accent) .navigationBarBackButtonHidden(true)), padding: EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0)),
            
            NavItem( icon: "list.bullet",  label: "List", destination: AnyView( ListView(userID: userID, background: $background, accent: $accent, logID: 0).navigationBarBackButtonHidden(true) ), padding: EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 0)),
            
            NavItem( icon: "chart.bar.xaxis",  label: "Analytics",  destination: AnyView( AnalyticsView(userID: userID, background: $background, accent: $accent) .navigationBarBackButtonHidden(true) ),padding: nil),
            
            NavItem(icon: "person.fill", label: "Profile", destination: AnyView( ProfileView(userID: userID, background: $background, accent: $accent) .navigationBarBackButtonHidden(true)),  padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15))]
    }
    
    var body: some View {
        ZStack {
            Color(hex: background)
            HStack {
                ForEach(navItems.indices, id: \.self) { index in
                    let item = navItems[index]
                    NavigationLink(destination: item.destination) {
                        VStack(spacing: 2) {
                            Image(systemName: item.icon)
                            CustomText(text: item.label, color: accent,  textAlignment: .center, multilineAlignment: .center, textSize: 15)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(item.padding ?? EdgeInsets())
                    }
                    .buttonStyle(.plain)
                }
            }
            .foregroundColor(Color(hex: accent))
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
        .frame(height: 70)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    NavBarView(
        userID: 1,
        background: .constant("#001d00"),
        accent: .constant("#b5c4b9")
    )
}
