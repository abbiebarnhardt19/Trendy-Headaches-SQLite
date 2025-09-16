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
                navButton(image: "square.and.pencil", text: "Log") {
                    // navigate to log
                }
                navButton(image: "chart.bar.xaxis", text: "Analytics") {
                    // navigate to analytics
                }
                navButton(image: "person.fill", text: "Profile") {
                    // navigate to profile
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // fill the bar
            .foregroundColor(Color(hex: accentColor))
        }
        .frame(maxWidth: width)  // force full width
        .frame(height: 60)           // fixed height
        .ignoresSafeArea(edges: .bottom)
    }

    private func navButton(image: String, text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: image)
                Text(text)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .contentShape(Rectangle()) // makes entire space tappable
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
