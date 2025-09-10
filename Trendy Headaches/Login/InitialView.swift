//
//  InitialView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI

struct InitialView: View {
    
    //set constants
    let accent = "#b5c4b9"
    let background = "#001d00"
    
    var body: some View {
        NavigationStack {
            ZStack {
                //set the background color
                Color(hex: background).ignoresSafeArea()
                
                //color symetrical slight wave blobs
                SameAmplitudeBlob(waves: 10, amplitude: 20, accent:accent, x:140, y: -220, rotation: 120)
                SameAmplitudeBlob(waves: 10, amplitude:20, accent:accent, x:140, y: -220, rotation: 295)

                //seperate the main body
                VStack {
                    //header text
                    CustomWelcome(text: "Trendy Headaches", color: accent, textAlignment: .center,  width: 300)
                    
                    //nav buttons
                    CustomNavButton(label: "Sign In", destination: LoginView(), background: background, accent: accent)
                    CustomNavButton(label: "Sign Up", destination: CreateAccountView(), background: background, accent: accent)
                }
            }
            //access the database when the screen first loads
            .onAppear {
                _ = DatabaseManager.shared
            }
        }

    }
}

#Preview {
    InitialView()
}
