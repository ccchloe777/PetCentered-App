//
//  AuthenticationManager.swift
//  PetConnect
//
//  Created by x7 on 2023/8/7.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?

    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}


final class AuthenticationManager{
    
    static let shared = AuthenticationManager()
    private init(){ }
    
    weak var settingsViewModel: SettingsViewModel?
    
    func getAuthenticatedUser() throws -> AuthDataResultModel{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func clearUserProfileData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "profileImage")
        defaults.removeObject(forKey: "displayName")
        defaults.removeObject(forKey: "age")
        defaults.removeObject(forKey: "gender")
        defaults.removeObject(forKey: "hobbies")
    }
}

extension AuthenticationManager{
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let userData = AuthDataResultModel(user: authDataResult.user)
        
        return userData
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        try await user.updateEmail(to: email)
    }
}

extension AuthenticationManager{
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken:tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
