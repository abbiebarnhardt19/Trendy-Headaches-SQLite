//
//  InitialView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI

struct InitialView: View {
    @State private var controlPoints = BlobShape.createPoints(minGrowth: 7, edges: 50)
    let accent = "#b5c4b9"
    let background = "#001d00"
    
    var body: some View {
        NavigationStack {
            ZStack {
                DiagonalCornerWave(waves: 12, amplitude: 25)
                    .fill(Color(hex: accent))
                    .frame(width: 700, height: 500)
                    .offset(x:225, y: -125)
                    .rotationEffect(.degrees(280))
                
                DiagonalCornerWave(waves: 12, amplitude: 25)
                    .fill(Color(hex: accent))
                    .frame(width: 700, height: 500)
                    .offset(x:225, y: -125)
                    .rotationEffect(.degrees(100))

                // Foreground content (buttons)
                VStack(spacing: 20) {
                    Text("Trendy Headaches")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 40, design: .serif))
                        .foregroundColor(Color(hex: accent))
                        .padding(.bottom, 10)
                    
                    CustomNavButton(label: "Sign In",
                                    destination: LoginView(),
                                    background: background,
                                    accent: accent,
                                    height: 50,
                                    width: 150)
                    
                    CustomNavButton(label: "Sign Up",
                                    destination: CreateAccountView(),
                                    background: background,
                                    accent: accent)
                }
            }
            .CustomView(color: background)
            .onAppear {
                _ = DatabaseManager.shared
            }
        }

    }
}


#Preview {
    InitialView()
}
