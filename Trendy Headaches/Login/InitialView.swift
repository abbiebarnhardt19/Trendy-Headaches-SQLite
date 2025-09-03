//
//  InitialView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI

struct InitialView: View {
    @State private var controlPoints = BlobShape.createPoints(minGrowth: 7, edges: 50)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background blobs
//                BlobShape(controlPoints: controlPoints)
//                    .fill(Color(hex: "#b5c4b9"))
//                    .frame(width: 500, height: 800)
//                    .offset(x: -75, y: -500)
                
                DiagonalCornerWave(waves: 8, amplitude: 20)
                    .fill(Color(hex: "#b5c4b9"))
                    .frame(width: 350, height: 350)
                    .offset(x:275, y: -50)
                    .rotationEffect(.degrees(270))
                
                DiagonalCornerWave(waves: 8, amplitude: 20)
                    .fill(Color(hex: "#b5c4b9"))
                    .frame(width: 350, height: 350)
                    .offset(x:275, y: -50)
                    .rotationEffect(.degrees(90))

                
                // Foreground content (buttons)
                VStack(spacing: 20) {
                    Text("Trendy Headaches")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 40, design: .serif))
                        .foregroundColor(Color(hex: "#b5c4b9"))
                        .padding(.bottom, 10)
                    
                    CustomNavButton(label: "Sign In",
                                    destination: LoginView(),
                                    background: "#001d00",
                                    accent: "#b5c4b9")
                    
                    CustomNavButton(label: "Sign Up",
                                    destination: CreateAccountView(),
                                    background: "#001d00",
                                    accent: "#b5c4b9")
                }
            }
            .CustomView(color: "#001d00")
            .onAppear {
                _ = DatabaseManager.shared
            }
        }

    }
}


#Preview {
    InitialView()
}
