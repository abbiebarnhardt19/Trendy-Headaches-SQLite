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
    let screen_width = UIScreen.main.bounds.width
    let leading_padding = CGFloat(UIScreen.main.bounds.width * 0.8)

    
    var body: some View {
        NavigationStack {
            ZStack{
                //set background color
                Color(hex: background)
                    .ignoresSafeArea()
                ScrollView{
                    
                    //seperate otherwise the background gets weird
                    ZStack{
                        //full width blob
                        WavyTopBottomRectangle(waves: 20, amplitude:10, accent:accent, x:300, y:-575, width:1000, height: 400)
                        WavyTopBottomRectangle(waves: 20, amplitude:8, accent:accent, x:300, y:550, width:1000, height: 400)
                        
                        VStack{
                            //header and instructions
                            CustomText(text:"One Last Step", color:accent, textAlignment: .center, textSize: 50)
                                .padding(.vertical, 15)
                            
                            CustomText(text: "Add multiple items by separating them with commas.", color: accent, width: screen_width - 30, textAlignment: .center, multilineAlignment: .center, textSize: 18)
                                .padding(.bottom, 20)
                            
                            
                            //symptoms label and textbox
                            CustomText(text: "Symptom or Illness", color: accent)
                                .padding(.leading, leading_padding)
                            
                            CustomTextField(background: background, accent: accent, placeholder: "", text: $symptoms)
                            
                            //prev meds label and textbox
                            CustomText(text: "Preventative Treatments", color: accent)
                                .padding(.leading, leading_padding)
                            
                            CustomTextField(background: background, accent: accent, placeholder: "", text: $preventativeMeds)
                            
                            //emerg meds label and textbox
                            CustomText(text: "Emergency Treatments", color: accent)
                                .padding(.leading, leading_padding)
                            
                            CustomTextField(background: background, accent: accent, placeholder: "", text: $emergencyMeds)
                            
                            //triggers label and textbox
                            CustomText(text: "Triggers", color: accent)
                                .padding(.leading, leading_padding)
                            
                            CustomTextField(background: background, accent: accent, placeholder: "", text: $triggers)
                            
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
}


#Preview {
    NavigationStack {
        CreateAccountView2()
    }
}
