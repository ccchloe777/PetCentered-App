//
//  LoginView.swift
//  PetConnect
//
//  Created by x7 on 2023/8/7.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

@MainActor
final class AuthenticationViewModel: ObservableObject {
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
}

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 255/255, green: 252/255, blue: 193/255), Color(red: 255/255, green: 143/255, blue: 143/255)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("welcome_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: 250, height: 250)
                    .shadow(color: Color(red: 1.0, green: 0.562, blue: 0.223), radius: 20, x: 0, y: 10)

                
                Text("Step into a World of Paw-sibilities!")
                    .font(.custom("MarkerFelt-Thin", size: 40))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)

                
                NavigationLink(destination: SignInEmailView(showSignInView: $showSignInView)) {
                    HStack {
                        Image("email_logo")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("Sign In/Up with Email")
                            .font(.custom("MarkerFelt-Thin", size: 23))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                        
                }
                
                Button(action: {
                    Task {
                        do {
                            try await viewModel.signInGoogle()
                            showSignInView = false
                        } catch {
                            print(error)
                        }
                    }
                }) {
                    HStack {
                        Image("google_logo")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("Sign In with Google")
                            .font(.custom("MarkerFelt-Thin", size: 23))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding()
                }

            }
            .padding()
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(false))
        }
    }
}
