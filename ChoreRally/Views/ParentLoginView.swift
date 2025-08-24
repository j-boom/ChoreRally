//
//  ParentLoginView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This file defines the UI for the parent login screen.
//  It adheres to MVVM by being a "dumb" view. It only displays data
//  provided by its ViewModel and forwards user actions (like button taps)
//  to the ViewModel to handle.
//

import SwiftUI

struct ParentLoginView: View {
    
    // MARK: - Properties
    
    // The @StateObject property wrapper creates a single, stable instance of our
    // ViewModel for the lifetime of the view. The view observes this object for any
    // changes to its @Published properties.
    @StateObject private var viewModel = ParentLoginViewModel()
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // --- App Title ---
                // Text("Allowance Manager")
                Text("ChoreRally")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 40)
                
                // --- Email Field ---
                TextField("Email Address", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                // --- Password Field ---
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                // --- Error Message Display ---
                // This text view only appears if the viewModel's errorMessage
                // property is not nil and not empty.
                if let errorMessage = viewModel.errorMessage, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                // --- Login Button ---
                // This button's content changes based on the viewModel's isLoading state.
                Button(action: {
                    // When tapped, this simply calls the corresponding method on the ViewModel.
                    // The view doesn't know or care what happens next; it just reports the action.
                    viewModel.loginButtonTapped()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    } else {
                        Text("Log In")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                // The button is disabled while a login attempt is in progress.
                .disabled(viewModel.isLoading)
                
                // --- Sign Up Navigation ---
                Button(action: {
                    // Reports the sign-up action to the ViewModel.
                    viewModel.signUpButtonTapped()
                }) {
                    Text("Don't have an account? Sign Up")
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Parent Portal")
            .navigationBarHidden(true) // Hiding for a cleaner look on the initial screen
            // --- Add Sheet Modifier ---
            // This modifier observes the 'showingRegistrationSheet' property in the ViewModel.
            // When it becomes true, it presents the ParentRegistrationView as a modal sheet.
            .sheet(isPresented: $viewModel.showingRegistrationSheet) {
                ParentRegistrationView()
            }
        }
    }
}

// MARK: - Preview

struct ParentLoginView_Previews: PreviewProvider {
    static var previews: some View {
        ParentLoginView()
    }
}
