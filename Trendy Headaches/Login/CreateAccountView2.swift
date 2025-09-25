import SwiftUI
import CryptoKit

struct CreateAccountView2: View {
    // Info from previous pages
    var background: String = ""
    var accent: String = ""
    var email: String = ""
    var passwordOne: String = ""
    var currentSecurityQuestion: String = ""
    var currentSecurityAnswer: String = ""
    
    // Editable variables for this page
    @State private var symptoms: String = ""
    @State private var preventativeMeds: String = ""
    @State private var emergencyMeds: String = ""
    @State private var triggers: String = ""
    @State private var errorMessage: String = ""
    @State private var accountCreated = false
    
    // Layout constants
    private let screenWidth = UIScreen.main.bounds.width
    private let leadingPadding = UIScreen.main.bounds.width * 0.8
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: background)
                    .ignoresSafeArea()
                
                ScrollView {
                    ZStack {
                        // Background blobs
                        WavyTopBottomRectangle(waves: 20, amplitude: 10, accent: accent, x: 300, y: -575, width: 1000, height: 400)
                        WavyTopBottomRectangle(waves: 20, amplitude: 8, accent: accent, x: 300, y: 550, width: 1000, height: 400)
                        
                        VStack(spacing: 15) {
                            // Header
                            CustomText(text: "One Last Step", color: accent, textAlignment: .center, textSize: 50)
                                .padding(.top, 15)
                            
                            CustomText(text: "Add multiple items by separating them with commas.", color: accent,  width: screenWidth - 30, textAlignment: .center, multilineAlignment: .center,  textSize: 18)
                            .padding(.bottom, 20)
                            
                            // Input fields
                            Group {
                                labeledField("Symptom or Illness", text: $symptoms)
                                labeledField("Preventative Treatments", text: $preventativeMeds)
                                labeledField("Emergency Treatments", text: $emergencyMeds)
                                labeledField("Triggers", text: $triggers)
                            }
                            
                            // Submit button
                            CustomButton(text: "Submit", background: background, accent: accent) {
                                createAccount()
                            }
                            .padding(.bottom, 40)
                            
                            // Error message
                            if !errorMessage.isEmpty {
                                CustomWarningText(text: errorMessage)
                            }
                        }
                        .padding()
                    }
                    .navigationDestination(isPresented: $accountCreated) {
                        LoginView(background: background, accent: accent)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func labeledField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            CustomText(text: label, color: accent)
                .padding(.leading, leadingPadding)
            CustomTextField(background: background, accent: accent, placeholder: "", text: text)
                .padding(.leading, leadingPadding-10)
        }
    }
    
    private func createAccount() {
        do {
            try DatabaseManager.createUser(email: email, password: passwordOne,  securityQuestion: currentSecurityQuestion,  securityAnswer: currentSecurityAnswer,  background: background, accent: accent, symptoms: symptoms, preventativeMeds: preventativeMeds, emergencyMeds: emergencyMeds, triggers: triggers)
            errorMessage = ""
            accountCreated = true
        } catch {
            errorMessage = "Failed to create account"
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView2()
    }
}
