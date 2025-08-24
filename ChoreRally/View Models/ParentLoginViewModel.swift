//
//  ParentLoginViewModel.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This file defines the ViewModel for the ParentLoginView.
//  It is the "brain" of the login screen, containing all the state and business logic.
//  It has no knowledge of UIKit or SwiftUI; its only job is to manage data and
//  perform actions based on requests from the View.
//

import Foundation
import Combine // Needed for ObservableObject and @Published
import FirebaseAuth

class ParentLoginViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // @Published is a property wrapper that announces when the property's value
    // has changed. Any view observing this ViewModel (like ParentLoginView) will
    // automatically re-render its UI to reflect the new state.
    
    @Published var email = ""
    @Published var password = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // --- Add new state property for showing the registration sheet ---
    @Published var showingRegistrationSheet = false
    
    // MARK: - Public Methods
    
    /// Called by the View when the user taps the 'Log In' button.
    func loginButtonTapped() {
        // Reset previous error messages
        errorMessage = nil
        
        // --- Input Validation ---
        // Basic checks before making a network request.
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in both email and password."
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        isLoading = true
        
        // --- Real Firebase Login ---
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                // On a successful login, the LaunchView's listener will automatically
                // detect the change in auth state and navigate to the dashboard.
                // We don't need to manually trigger navigation from here.
                print("Login successful!")
            }
        }
    }
    
    /// Called by the View when the user taps the 'Sign Up' button.
    func signUpButtonTapped() {
        // --- Old code ---
        // print("Sign up button tapped. Should navigate to registration screen.")
        // errorMessage = "Sign-up functionality is not yet implemented."
        
        // --- New code ---
        // Set the property to true to trigger the .sheet modifier in the View.
        showingRegistrationSheet = true
    }
}
