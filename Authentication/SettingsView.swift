//
//  SettingsView.swift
//  PetConnect
//
//  Created by x7 on 2023/8/7.
//

import SwiftUI
import FirebaseAuth

@MainActor
final class SettingsViewModel: ObservableObject{
    
    @Published var profileImage: UIImage?
    @Published var displayName: String = ""
    @Published var age: Int = 0
    @Published var gender: String = ""
    @Published var hobbies: String = ""
    @Published var email: String = ""
    @Published var showImagePicker: Bool = false
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var hasCustomizedProfile: Bool {
        didSet {
            UserDefaults.standard.set(hasCustomizedProfile, forKey: "hasCustomizedProfile")
        }
    }

    init() {
        // Initialize hasCustomizedProfile based on stored value or default to false
        hasCustomizedProfile = UserDefaults.standard.bool(forKey: "hasCustomizedProfile")
    }

    class UserProfileService {
        // This method represents updating the user's display name on the backend or data storage.
        func updateDisplayName(newDisplayName: String, completion: @escaping (Error?) -> Void) {
            // In this example, we are using a completion block to handle the asynchronous response.
            // Replace this with the appropriate networking code or database update logic.
            // For demonstration purposes, we're assuming the update is successful, so we call the completion with nil error.
            // In a real implementation, you would handle potential errors and call the completion accordingly.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion(nil)
            }
        }
    }

    private let userProfileService = UserProfileService()
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
        
        // Clear user defaults here
        clearProfileData()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateDisplayName() {
        userProfileService.updateDisplayName(newDisplayName: displayName) { [self] error in
            if let error = error {
                // Handle the error (e.g., show an alert to the user).
                print("Error updating display name: \(error)")
            } else {
                // The display name update was successful.
                print("Display name updated successfully.")
                // Show the toast message
                showToast = true
                toastMessage = "Name updated successfully."

                // Save the user's profile data after updating the display name
                    
                saveProfileData(email: email)
                
                // Mark the profile as customized for the current user
                hasCustomizedProfile = true
            }
        }
    }

    
    func updateUserProfileData() {
        // Update the viewModel with the new user's data
        retrieveProfileData(email: email)
    }
    
    func saveProfileData(email: String) {
        let defaults = UserDefaults.standard
        let emailKey = "profile_" + email
        
        defaults.set(profileImage?.pngData(), forKey: "\(emailKey)_profileImage")
        defaults.set(displayName, forKey: "\(emailKey)_displayName")
        defaults.set(age, forKey: "\(emailKey)_age")
        defaults.set(gender, forKey: "\(emailKey)_gender")
        defaults.set(hobbies, forKey: "\(emailKey)_hobbies")
    }

    func retrieveProfileData(email: String) {
        let defaults = UserDefaults.standard
        let emailKey = "profile_" + email
        
        if let imageData = defaults.data(forKey: "\(emailKey)_profileImage"),
           let image = UIImage(data: imageData) {
            profileImage = image
        }
        displayName = defaults.string(forKey: "\(emailKey)_displayName") ?? ""
        age = defaults.integer(forKey: "\(emailKey)_age")
        gender = defaults.string(forKey: "\(emailKey)_gender") ?? ""
        hobbies = defaults.string(forKey: "\(emailKey)_hobbies") ?? ""
    }


    
    private func clearProfileData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "profileImage")
        defaults.removeObject(forKey: "displayName")
        defaults.removeObject(forKey: "age")
        defaults.removeObject(forKey: "gender")
        defaults.removeObject(forKey: "hobbies")
        
        // Reset profile data properties to their default values
        profileImage = nil
        displayName = ""
        age = 0
        gender = ""
        hobbies = ""
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool

    var body: some View {
        ScrollView {
            
            // Profile Settings section
            profileSetting
            // Account Settings section
            Section {
                Button("Reset password") {
                    Task {
                        do {
                            try await viewModel.resetPassword()
                            print("PASSWORD RESET!")
                        } catch {
                            print(error)
                        }
                    }
                }
                Button("Log Out") {
                    Task {
                        do {
                            try viewModel.signOut()
                            showSignInView = true
                        } catch {
                            print(error)
                        }
                    }
                }
            } header: {
                Text("Account Settings")
            }
        }
        .navigationTitle("Profile")
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePickerView(image: $viewModel.profileImage)
        }
        .overlay(
            // Show the ToastView when showToast is true
            viewModel.showToast ? ToastView(message: viewModel.toastMessage) : nil
        )
        .onAppear {
            if let user = Auth.auth().currentUser {
                viewModel.email = user.email ?? "" // Set the user's email in the viewModel
                viewModel.retrieveProfileData(email: viewModel.email) // Load the user's profile data
            }
        }
    }

    // Add the closing curly brace for the profileSetting computed property
    private var profileSetting: some View {
        Section {
            VStack {
                // Display the selected profile image or a default image if none is selected
                Image(uiImage: viewModel.profileImage ?? UIImage(named: "default_profile")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 3)
                    .onTapGesture {
                        viewModel.showImagePicker = true
                    }
                
                // Other profile data fields
                TextField("Name", text: $viewModel.displayName, onCommit: {
                    Task {
                        do {
                            // Replace with an actual asynchronous operation if needed
                            try await Task.sleep(nanoseconds: 1)
                            await viewModel.updateDisplayName()
                        } catch {
                            print(error)
                        }
                    }
                })
                .padding()
                
                TextField("Age", value: $viewModel.age, format: .number)
                    .padding()
                
                TextField("Gender", text: $viewModel.gender)
                    .padding()
                
                TextField("Hobbies", text: $viewModel.hobbies)
                    .padding()
            }
            .padding(.vertical) // Add vertical padding to the VStack
        }
    }
}


struct Previews_SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSignInView: .constant(false))
    }
}

