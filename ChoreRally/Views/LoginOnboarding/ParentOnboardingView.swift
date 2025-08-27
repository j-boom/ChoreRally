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
    
    @StateObject private var viewModel = ParentOnboardingViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
            
            // The view now switches based on the current onboarding step.
            switch viewModel.currentStep {
            case .enterName:
                nameEntryView
            case .setPin:
                ParentPinView(title: "Set a 4-Digit PIN", onPinEntered: viewModel.advanceToPinConfirmation)
            case .confirmPin:
                ParentPinView(title: "Confirm Your PIN", onPinEntered: viewModel.createFamilyAndFirstProfile)
            }
        }
        .onChange(of: viewModel.isOnboardingComplete) {
            if viewModel.isOnboardingComplete {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var nameEntryView: some View {
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
            
            Button(action: viewModel.advanceToPinSetup) {
                Text("Continue")
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
}
