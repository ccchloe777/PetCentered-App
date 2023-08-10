//
//  SigninEmailView.swift
//  PetConnect
//
//  Created by x7 on 2023/8/7.
//

import SwiftUI

final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var emailErrorMessage = ""
    @Published var passwordErrorMessage = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else{
            print("No email or password found")
            return
        }
        let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
        print("Successed")
        print(returnedUserData)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else{
            print("No email or password found")
            return
        }
        let returnedUserData = try await AuthenticationManager.shared.signInUser(email: email, password: password)
        print("Successed")
        print(returnedUserData)
    }
    
    func isValidEmail(email: String) -> Bool {
            let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            return emailPredicate.evaluate(with: email)
        }

        func isStrongPassword(password: String) -> Bool {
            let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*#?&]{8,}$"
            let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
            return passwordPredicate.evaluate(with: password)
        }
    
}

struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool

    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(20)
                .autocapitalization(.none)
                .disableAutocorrection(true) // Optional: Disable autocorrection for email

            // Display the email error message if it exists
            Text(viewModel.emailErrorMessage)
                .foregroundColor(.red)

            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(20)

            // Display the password error message if it exists
            Text(viewModel.passwordErrorMessage)
                .foregroundColor(.red)

            Button {
                Task {
                    // Reset error messages
                    viewModel.emailErrorMessage = ""
                    viewModel.passwordErrorMessage = ""

                    guard viewModel.isValidEmail(email: viewModel.email) else {
                        viewModel.emailErrorMessage = "Invalid email format"
                        return
                    }

                    guard viewModel.isStrongPassword(password: viewModel.password) else {
                        viewModel.passwordErrorMessage = "Weak password"
                        return
                    }

                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }

                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(width: 300, height: 60)
                    .background(.blue)
                    .cornerRadius(20)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Sign In With Email")
    }
}



struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            SignInEmailView(showSignInView: .constant(false))
        }
    }
}

