import SwiftUI

struct CreateAccountView: SwiftUI.View {
    
    @State private var first_name: String = ""
    @State private var email: String = ""
    @State private var security_question: String = ""
    @State private var security_answer: String = ""
    @State private var password_one: String = ""
    @State private var password_two: String = ""
    @State private var emailAvailable: Bool = true
    
    @State private var emailCheckTask: Task<Void, Never>? = nil
    
    let accent = "#b5c4b9"
    let background = "#001d00"
    
    let leading_padding = CGFloat(310)
    
    private var formIsValid: Bool {
//        !security_question.isEmpty &&
//        !security_answer.isEmpty &&
//        !email.isEmpty &&
//        !password_one.isEmpty &&
//        !password_two.isEmpty &&
//        (password_one == password_two) &&
        DatabaseManager.isPasswordValid(password_one) &&
        emailAvailable
    }
    
    var body: some SwiftUI.View {
        NavigationStack {
            ZStack{
                Color(hex: background)
                    .ignoresSafeArea()
                ScrollView{
                    ZStack{
                        WavyTopBottomRectangle(waves: 20, amplitude:10, accent:accent, x:300, y:-620, width:1000, height: 400)
                        
                        WavyTopBottomRectangle(waves: 20, amplitude:10, accent:accent, x:300, y:600, width:1000, height: 400)
                        
//                        WavyTopBottomRectangle(waves: 40, amplitude:10, accent:accent, x:200, y:-250, 135, width:1000, height:200)
                    
                        VStack{
                            
                            CustomWelcome(text: "Create Account", color: accent, alignment: .center, textAlignment: .center, width:350)
                                .padding(.top, 5)
                            
                            CustomText(text: "Email", color: accent)
                                .padding(.leading, leading_padding)
                            
                            TextField("", text: $email)
                                .textFieldStyle(CustomTextField(background: background, accent: accent))
                                .onChange(of: email) {
                                    emailCheckTask?.cancel()
                                    emailCheckTask = Task {
                                        try? await Task.sleep(nanoseconds: 500_000_000)
                                        if !Task.isCancelled {
                                            emailAvailable = !DatabaseManager.doesEmailExist(email)
                                        }
                                    }
                                }
                            
                            if !emailAvailable && !email.isEmpty {
                                CustomWarningText(text: "There is already an account using this email")
                                    .padding(.bottom, 3)
                            } else {
                                CustomWarningText(text: "")
                                    .padding(.bottom, 3)
                            }
                            
                            CustomText(text: "Password", color: accent)
                                .padding(.leading, leading_padding)
                            
                            SecureField("", text: $password_one)
                                .textFieldStyle(CustomTextField(background: background, accent: accent))
                            
                            if !DatabaseManager.isPasswordValid(password_one) && !password_one.isEmpty {
                                CustomWarningText(text: "8+ chars: uppercase, lowercase, number, & symbol")
                                    .padding(.bottom, 3)
                            } else {
                                CustomWarningText(text: "")
                                    .padding(.bottom, 3)
                            }
                            
                            CustomText(text: "Confirm Password", color: accent)
                                .padding(.leading, leading_padding)
                            
                            SecureField("", text: $password_two)
                                .textFieldStyle(CustomTextField(background: background, accent: accent))
                            
                            if !password_two.isEmpty && password_two != password_one {
                                CustomWarningText(text: "Passwords do not match.")
                                    .padding(.bottom, 3)
                            } else {
                                CustomWarningText(text: "")
                                    .padding(.bottom, 3)
                            }
                            
                            CustomText(text: "Security Question", color: accent)
                                .padding(.leading, leading_padding)
                            
                            TextField("", text: $security_question)
                                .textFieldStyle(CustomTextField(background: background, accent: accent))
                            //this is just here for equal spacing
                            CustomWarningText(text:"")
                                .padding(.bottom, 3)
                            
                            CustomText(text: "Security Question Answer", color: accent)
                                .padding(.leading, leading_padding)
                            
                            TextField("", text: $security_answer)
                                .textFieldStyle(CustomTextField(background: background, accent: accent))
                            
                            CustomNavButton(
                                label: "Continue",
                                destination: CreateAccountView3(
                                    email: email,
                                    password_one: password_one,
                                    security_question: security_question,
                                    security_answer: security_answer
                                ),
                                background: background,
                                accent: accent,
                                width: 150
                            )
                            .disabled(!formIsValid)
                            .opacity(formIsValid ? 1.0 : 0.5)
                            .padding(.bottom, 30)
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
