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
                Color(hex: background).ignoresSafeArea()
                
                SameAmplitudeBlob(waves: 10, amplitude: 20, accent:accent, x:-100, y: -120, rotation: 120)
                
                SameAmplitudeBlob(waves: 10, amplitude:20, accent:accent, x:-0, y: 100, rotation: 295)

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
            
            .onAppear {
                _ = DatabaseManager.shared
            }
        }

    }
}


#Preview {
    InitialView()
}
