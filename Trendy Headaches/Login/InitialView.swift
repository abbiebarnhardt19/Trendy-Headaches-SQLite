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
                DiagonalCornerWave(waves: 8, amplitude: 20)
                    .fill(Color(hex: accent))
                    .frame(width: 350, height: 350)
                    .offset(x:275, y: -50)
                    .rotationEffect(.degrees(270))
                
                DiagonalCornerWave(waves: 8, amplitude: 20)
                    .fill(Color(hex: accent))
                    .frame(width: 350, height: 350)
                    .offset(x:275, y: -50)
                    .rotationEffect(.degrees(90))

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
