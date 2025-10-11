//
//  InitialView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI

struct InitialView: View {
    //  Theme
    private let accent = "#b5c4b9"
    private let background = "#001d00"
    private let screenWidth = UIScreen.main.bounds.width

    //  State
    @State private var showPolicy = false
    @State private var navigateToCreateAccount = false

    var body: some View {
        NavigationStack {
            ZStack {
                InitialViewBackgroundComponents(background: background, accent: accent)

                //  Content
                VStack(spacing: 20) {
                    CustomText( text: "Trendy Headaches", color: accent, width: screenWidth - 50, textAlignment: .center, multilineAlignment: .center, textSize: 50 )

                    // Sign In Button
                    CustomNavButton( label: "Sign In", destination: LoginView(), background: background, accent: accent)

                    // Sign Up Button (Shows Policy First)
                    CustomButton(text: "Sign Up", background: background, accent: accent,  height: 55, width: 180 ) {
                        showPolicy = true
                    }
                }
            }
            // Launch database
            .onAppear {
                _ = DatabaseManager.shared // Ensures database is initialized
            }

            //  Modals & Navigation
            .fullScreenCover(isPresented: $showPolicy) {
                PolicySheetView(policyFileName: "DataPolicy", showsAgreeButton: true,
                    onAgree: { navigateToCreateAccount = true })
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
