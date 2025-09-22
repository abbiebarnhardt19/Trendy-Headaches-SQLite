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
    
    @Namespace var namespace
    
    var body: some View {

        ZStack {
            Color(hex: background)
            HStack {
                NavigationLink(
                    destination: LogView(userID: userID, background: $background, accent: $accent)
                        .navigationBarBackButtonHidden(true)
                        
                ) {
                    VStack(spacing: 2) {
                        Image(systemName: "square.and.pencil")
                        CustomText(text: "Log", color: accent, textAlignment: .center, multilineAlignment: .center, textSize: 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.leading, 15)
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(
                    destination: ListView(userID: userID, background: $background, accent: $accent)
                        .navigationBarBackButtonHidden(true)
                        
                ) {
                    VStack(spacing: 2) {
                        Image(systemName: "list.bullet")
                        CustomText(text: "List", color: accent, textAlignment: .center, multilineAlignment: .center, textSize: 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 3)
                }
                .buttonStyle(PlainButtonStyle())
                
                

                NavigationLink(destination: AnalyticsView(userID: userID, background: $background, accent: $accent).navigationBarBackButtonHidden(true)) {
                    VStack(spacing: 2) {
                        Image(systemName: "chart.bar.xaxis")
                        CustomText(text: "Analytics", color:accent, textAlignment: .center, multilineAlignment: .center, textSize: 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: ProfileView(userID: userID, background: $background, accent: $accent).navigationBarBackButtonHidden(true)) {
                    VStack(spacing: 2) {
                        Image(systemName: "person.fill")
                        CustomText(text: "Profile", color:accent, textAlignment: .center, multilineAlignment: .center, textSize: 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.trailing, 15)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) 
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


