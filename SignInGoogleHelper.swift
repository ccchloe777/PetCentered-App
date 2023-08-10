//
//  SignGoogleHelper.swift
//  PetConnect
//
//  Created by x7 on 2023/8/8.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel{
    let idToken: String
    let accessToken: String
}

final class SignInGoogleHelper{
    
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel{
        guard let topVC = Utilities.shared.topViewController() else{
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else{
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        
        return tokens
    }
}