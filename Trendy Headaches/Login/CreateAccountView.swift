import SwiftUI

struct CreateAccountView: SwiftUI.View {
    
    //editable fields
    @State private var first_name: String = ""
    @State private var email: String = ""
    @State private var security_question: String = ""
    @State private var security_answer: String = ""
    @State private var password_one: String = ""
    @State private var password_two: String = ""
    @State private var emailAvailable: Bool = true
    @State private var emailCheckTask: Task<Void, Never>? = nil
    
    //colors and padding
    let accent = "#b5c4b9"
    let background = "#001d00"
    let leading_padding = CGFloat(UIScreen.main.bounds.width * 0.825)
    
    //check if everything is filled out, email is available, passwords match, and passwords are complex enough
    private var formIsValid: Bool {
        !security_question.isEmpty &&
        !security_answer.isEmpty &&
        !email.isEmpty &&
        !password_one.isEmpty &&
        !password_two.isEmpty &&
        (password_one == password_two) &&
        DatabaseManager.isPasswordValid(password_one) &&
        emailAvailable
    }
    
    var body: some SwiftUI.View {
        NavigationStack {
            ZStack{
                //set the background color
                Color(hex: background)
                    .ignoresSafeArea()
                
                ScrollView{
                    ZStack{
                        //full width blob
                        WavyTopBottomRectangle(waves: 20, amplitude:10, accent:accent, x:300, y:-630, width:1000, height: 400)
                        WavyTopBottomRectangle(waves: 20, amplitude:10, accent:accent, x:300, y:600, width:1000, height: 400)
                    
                        VStack{
                            //header text
                            CustomText(text: "Create Account", color: accent, textAlignment: .center, textSize: 50)
                                .padding(.bottom, 10)
                                .padding(.top, 20)
                            
                            //email header
                            CustomText(text: "Email", color: accent)
                                .padding(.leading, leading_padding)
                            
                            //email text box, use debouncing to see if email is available after user stops typing
                            CustomTextField(background: background, accent: accent, placeholder: "", text: $email)
                                .onChange(of: email) {
                                    emailCheckTask?.cancel()
                                    emailCheckTask = Task {
                                        try? await Task.sleep(nanoseconds: 500_000_000)
                                        if !Task.isCancelled {
                                            emailAvailable = !DatabaseManager.doesEmailExist(email)
                                        }
                                    }
                                }
                            
                            //if the email exists in the database, display warning
                            if !emailAvailable && !email.isEmpty {
                                CustomWarningText(text: "There is already an account using this email")
                                    .padding(.bottom, 3)
                            }
                            
                            //reserve room for warning
                            else {
                                CustomWarningText(text: "")
                                    .padding(.bottom, 11)
                            }
                            
                            //password one label and textbox
                            CustomText(text: "Password", color: accent)
                                .padding(.leading, leading_padding)
                            
                            CustomTextField(background: background, accent: accent, placeholder: "", text: $password_one, isSecure: true)
                            
                            //complexity warning
                            if !DatabaseManager.isPasswordValid(password_one) && !password_one.isEmpty {
                                CustomWarningText(text: "8+ chars: uppercase, lowercase, number, & symbol")
                                    .padding(.bottom, 3)
                            }
                            
                            //reserve room for warning
                            else {
                                CustomWarningText(text: "")
                                    .padding(.bottom, 11)
                            }
                            
                            //password two label and textbox
                            CustomText(text: "Confirm Password", color: accent)
                                .padding(.leading, leading_padding)
                            
                            CustomTextField(background: background, accent: accent, placeholder: "", text: $password_two, isSecure: true)
                            
                            //passwords don't match warning
                            if !password_two.isEmpty && password_two != password_one {
                                CustomWarningText(text: "Passwords do not match.")
                                    .padding(.bottom, 3)
                            }
                            
                            //reserve room for warning
                            else {
                                CustomWarningText(text: "")
                                    .padding(.bottom, 11)
                            }
                            
                            //security question label and textbox
                            CustomText(text: "Security Question", color: accent)
                                .padding(.leading, leading_padding)
                            
                            CustomTextField(background: background, accent: accent, placeholder: "", text: $security_question)

                            //for equal spacing
                            CustomWarningText(text:"")
                                .padding(.bottom, 11)
                            
                            //security question answer label and textbox
                            CustomText(text: "Security Question Answer", color: accent)
                                .padding(.leading, leading_padding)
                            
                            CustomTextField(background: background, accent: accent, placeholder: "", text: $security_answer, isSecure: true)
                            
                            //button to move to create account view 3 (color theme) with the entered information
                            //disabled until form is valid
                            CustomNavButton(label: "Continue", destination: CreateAccountView3(email: email, password_one: password_one, security_question: security_question, security_answer: security_answer), background: background, accent: accent, width: 150)
                            .disabled(!formIsValid)
                            .opacity(formIsValid ? 1.0 : 0.5)
                            .padding(.bottom, 45)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
    }
}
