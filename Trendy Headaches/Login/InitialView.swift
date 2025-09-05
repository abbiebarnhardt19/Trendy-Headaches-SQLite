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
                SameAmplitudeBlob(waves: 10, amplitude: 20, seed: 4)
                    .fill(Color(hex: accent))
                    .frame(width: 700, height: 500)
                    .offset(x:320, y: -120)
                    .rotationEffect(.degrees(120)) 
                
                SameAmplitudeBlob(waves: 10, amplitude:20, seed: 4)
                    .fill(Color(hex: accent))
                    .frame(width: 700, height: 500)
                    .offset(x:195, y: -171)
                    .rotationEffect(.degrees(295))

                

                VStack() {
                    CustomWelcome(text: "Trendy Headaches", color: accent)
                    
                    CustomNavButton(label: "Sign In",
                                    destination: LoginView(),
                                    background: background,
                                    accent: accent,
                                    height: 50,
                                    width: 180)
                    .padding(.vertical, 10)
                    
                    CustomNavButton(label: "Sign Up",
                                    destination: CreateAccountView(),
                                    background: background,
                                    accent: accent,
                                    height: 50,
                                    width: 180)
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
