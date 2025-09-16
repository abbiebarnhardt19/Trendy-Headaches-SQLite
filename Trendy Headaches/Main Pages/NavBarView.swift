//
//  NavBarView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//
import SwiftUI

struct NavBarView: View {
    let userID: Int64
    var backgroundColor: String
    var accentColor: String
    var width: CGFloat
    
    var body: some View {
        ZStack {
            Color(hex: backgroundColor)
            HStack {
                NavigationLink(
                    destination: LogView(userID: userID, backgroundColor: backgroundColor, accentColor: accentColor)
                        .navigationBarBackButtonHidden(true)
                ) {
                    VStack(spacing: 2) {
                        Image(systemName: "square.and.pencil")
                        CustomText(text: "Log", color: accentColor, textAlignment: .center, multilineAlignment: .center, textSize: 15)
                            .padding(.bottom, 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(PlainButtonStyle())

                
                
                
                
                NavigationLink(destination: AnalyticsView(userID: userID, backgroundColor: backgroundColor, accentColor: accentColor).navigationBarBackButtonHidden(true)) {
                    VStack(spacing: 2) {
                        Image(systemName: "chart.bar.xaxis")
                        CustomText(text: "Analytics", color:accentColor, textAlignment: .center, multilineAlignment: .center, textSize: 15)
                            .padding(.bottom, 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: ProfileView(userID: userID, backgroundColor: .constant(backgroundColor), accentColor: .constant(accentColor)).navigationBarBackButtonHidden(true)) {
                    VStack(spacing: 2) {
                        Image(systemName: "person.fill")
                        CustomText(text: "Profile", color:accentColor, textAlignment: .center, multilineAlignment: .center, textSize: 15)
                            .padding(.bottom, 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // fill the bar
            .foregroundColor(Color(hex: accentColor))
        }
        .frame(maxWidth: width)  // force full width
        .frame(height: 80)           // fixed height
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    NavBarView(
        userID: 1,
        backgroundColor: "#001d00",
        accentColor: "#b5c4b9",
        width: 300
    )
}
