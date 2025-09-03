//
//  InitialView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI

struct InitialView: View {
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

                VStack() {
                    CustomWelcome(text: "Trendy Headaches", color: accent)
                    
                    CustomNavButton(label: "Sign In",
                                    destination: LoginView(),
                                    background: background,
                                    accent: accent,
                                    height: 60,
                                    width: 160)
                    
                    CustomNavButton(label: "Sign Up",
                                    destination: CreateAccountView(),
                                    background: background,
                                    accent: accent,
                                    height: 60,
                                    width: 160)
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
