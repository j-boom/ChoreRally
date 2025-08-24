//
//  ParentRegistrationView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This file defines the UI for the parent registration screen.
//  It follows the same "dumb view" principle as the login screen.
//

import SwiftUI

struct ParentRegistrationView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = ParentRegistrationViewModel()
    
    // This gives us the ability to programmatically dismiss this view
    // once the account is successfully created.
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Create Parent Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)
            
            TextField("Email Address", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            SecureField("Confirm Password", text: $viewModel.confirmPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            if let errorMessage = viewModel.errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                viewModel.createAccountButtonTapped()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Create Account")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .cornerRadius(10)
            .disabled(viewModel.isLoading)
            
            Spacer()
        }
        .padding()
        // This listens for the 'isRegistrationSuccessful' flag from the ViewModel.
        // When it becomes true, we dismiss the registration sheet.
        .onChange(of: viewModel.isRegistrationSuccessful) { successful in
            if successful {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: - Preview
struct ParentRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        ParentRegistrationView()
    }
}
