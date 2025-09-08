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
                
                SameAmplitudeBlob(waves: 10, amplitude: 20, accent:accent, x:140, y: -220, rotation: 120)
                
                SameAmplitudeBlob(waves: 10, amplitude:20, accent:accent, x:140, y: -220, rotation: 295)

                VStack {
                    CustomWelcome(text: "Trendy Headaches", color: accent, alignment: .center,textAlignment: .center,  width: 300)
                    
                    CustomNavButton(label: "Sign In", destination: LoginView(), background: background, accent: accent)
                    
                    CustomNavButton(label: "Sign Up", destination: CreateAccountView(), background: background, accent: accent)
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
