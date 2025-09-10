import SwiftUI
import CryptoKit

struct CreateAccountView2: View {
    //information from previous pages
    var background: String = ""
    var accent: String = ""
    var email: String = ""
    var passwordOne: String = ""
    var currentSecurityQuestion: String = ""
    var currentSecurityAnswer: String = ""
    
    //editable variables for this page
    @State private var symptoms: String = ""
    @State private var preventativeMeds: String = ""
    @State private var emergencyMeds: String = ""
    @State private var triggers: String = ""
    @State private var errorMessage: String = ""
    @State private var accountCreated = false
    
    //leading padding constant
    let leading_padding = CGFloat(300)
    
    var body: some View {
        NavigationStack {
            ZStack{
                //set background color
                Color(hex: background)
                    .ignoresSafeArea()
                
                //seperate otherwise the background gets weird
                ZStack{
                    //full width blob
                    WavyTopBottomRectangle(waves: 20, amplitude:10, accent:accent, x:300, y:-575, width:1000, height: 400)
                    WavyTopBottomRectangle(waves: 20, amplitude:8, accent:accent, x:300, y:550, width:1000, height: 400)
                    
                    VStack{
                        //header and instructions
                        CustomWelcome(text:"One Last Step", color:accent, textAlignment: .center, width:350)
                        CustomInstructions(text: "These fields are optional and help us provide personalized insights from your data. Add multiple items by separating them with commas.", color: accent)
                        
                        
                        //symptoms label and textbox
                        CustomText(text: "Symptom or Illness", color: accent)
                            .padding(.leading, leading_padding)
                        
                        TextField("", text: $symptoms)
                            .textFieldStyle(CustomTextField(background: background, accent: accent))
                        
                        //prev meds label and textbox
                        CustomText(text: "Preventative Medications", color: accent)
                            .padding(.leading, leading_padding)
                        
                        TextField("", text: $preventativeMeds)
                            .textFieldStyle(CustomTextField(background: background, accent: accent))
                        
                        //emerg meds label and textbox
                        CustomText(text: "Emergency Medications", color: accent)
                            .padding(.leading, leading_padding)
                        
                        TextField("", text: $emergencyMeds)
                            .textFieldStyle(CustomTextField(background: background, accent: accent))
                        
                        //triggers label and textbox
                        CustomText(text: "Triggers", color: accent)
                            .padding(.leading, leading_padding)
                        
                        TextField("", text: $triggers)
                            .textFieldStyle(CustomTextField(background: background, accent: accent))
                        
                        //on click attempt to add user
                        CustomButton(text: "Submit", background: background, accent: accent) {
                            do {
                                try DatabaseManager.createUser(
                                    email: email,
                                    password: passwordOne,
                                    securityQuestion: currentSecurityQuestion,
                                    securityAnswer: currentSecurityAnswer,
                                    background: background,
                                    accent: accent,
                                    symptoms: symptoms,
                                    preventativeMeds: preventativeMeds,
                                    emergencyMeds: emergencyMeds,
                                    triggers: triggers
                                )
                                errorMessage = ""
                                accountCreated = true
                            } catch {
                                errorMessage = "Failed to create account"
                            }
                        }
                        .padding(.bottom, 40)
                        
                        //show error message if it exists
                        if !errorMessage.isEmpty {
                            CustomWarningText(text: errorMessage)
                        }
                    }
                    .padding()
                }
                //once create account is successful, move to login page
                .navigationDestination(isPresented: $accountCreated) {
                    LoginView(background: background, accent: accent)
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        CreateAccountView2()
    }
}
