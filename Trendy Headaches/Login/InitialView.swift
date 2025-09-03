//
//  InitialView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI

struct InitialView: View {
    @State private var controlPoints = BlobShape.createPoints(minGrowth: 7, edges: 30)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background blobs
                BlobShape(controlPoints: controlPoints)
                    .fill(Color(hex: "#b5c4b9"))
                    .frame(width: 500, height: 500)
                    .offset(x: -100, y: -400)
                
                BlobShape(controlPoints: controlPoints)
                    .fill(Color(hex: "#b5c4b9"))
                    .frame(width: 500, height: 500)
                    .offset(x: 100, y: 400)
                
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
