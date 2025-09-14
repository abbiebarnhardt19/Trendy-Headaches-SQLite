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
    
    @State private var showPolicy = false
    @State private var agreedToPolicy = false
    @State private var navigateToCreateAccount = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: background).ignoresSafeArea()
                
                SameAmplitudeBlob(waves: 10, amplitude: 20, accent: accent, x: 140, y: -220, rotation: 120)
                SameAmplitudeBlob(waves: 10, amplitude: 20, accent: accent, x: 140, y: -220, rotation: 295)

                VStack {
                    CustomWelcome(text: "Trendy Headaches", color: accent, textAlignment: .center, width: 300)
                    
                    // Sign In button (normal navigation)
                    CustomNavButton(label: "Sign In", destination: LoginView(), background: background, accent: accent)
                    
                    // Sign Up button (intercept tap)
                    CustomButton(text: "Sign Up", background: background, accent: accent, height: 55, width: 180) {
                        showPolicy = true
                    }
                }
            }
            .onAppear {
                _ = DatabaseManager.shared
            }
            .fullScreenCover(isPresented: $showPolicy) {
                PolicySheetView(
                    policyFileName: "DataPolicy",
                    showsAgreeButton: true,
                    onAgree: { navigateToCreateAccount = true }
                )
            }
            .navigationDestination(isPresented: $navigateToCreateAccount) {
                CreateAccountView()
            }
        }
    }
}



#Preview {
    InitialView()
}
