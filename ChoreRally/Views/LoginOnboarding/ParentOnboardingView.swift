//
//  ParentOnboardingView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This view is for the initial parent setup, presented when a new
//  parent logs in for the first time.
//

import SwiftUI

struct ParentOnboardingView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = ParentOnboardingViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Let's get your profile set up.")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 40)
            
            TextField("Your Name", text: $viewModel.name)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                viewModel.createFamilyAndFirstProfile()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Save and Continue")
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .disabled(viewModel.isLoading)
            
            Spacer()
        }
        .padding()
        .onChange(of: viewModel.isOnboardingComplete) { complete in
            if complete {
                // When the profile is saved, dismiss this sheet.
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
