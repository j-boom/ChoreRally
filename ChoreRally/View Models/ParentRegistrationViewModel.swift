//
//  ParentRegistrationViewModel.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This ViewModel handles all the logic for creating a new parent account.
//

import Foundation
import Combine
import FirebaseAuth

class ParentRegistrationViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // This property will be used to signal the View to dismiss itself upon success.
    @Published var isRegistrationSuccessful = false
    
    // MARK: - Public Methods
    
    func createAccountButtonTapped() {
        errorMessage = nil
        
        // --- Input Validation ---
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        // You can add more robust password requirements here (e.g., minimum length).
        
        isLoading = true
        
        // --- Firebase Auth Call ---
        // This is the actual call to Firebase to create a new user.
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    // If Firebase returns an error, display it.
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                // If the user is created successfully...
                if authResult?.user != nil {
                    print("New user account created successfully.")
                    // Set our flag to true, which the view is listening for.
                    self?.isRegistrationSuccessful = true
                }
            }
        }
    }
}
