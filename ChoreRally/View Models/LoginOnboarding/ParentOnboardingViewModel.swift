//
//  ParentOnboardingViewModel.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This ViewModel handles the logic for creating the first parent profile.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class ParentOnboardingViewModel: ObservableObject {
    
    // Enum to manage the different steps of the onboarding process.
    enum OnboardingStep {
        case enterName
        case setPin
        case confirmPin
    }
    
    // MARK: - Published Properties
    @Published var currentStep: OnboardingStep = .enterName
    @Published var name = ""
    @Published var pin = ""
    @Published var confirmedPin = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isOnboardingComplete = false
    
    // MARK: - Public Methods
    
    func advanceToPinSetup() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your name."
            return
        }
        errorMessage = nil
        currentStep = .setPin
    }
    
    func advanceToPinConfirmation(pin: String) {
        self.pin = pin
        currentStep = .confirmPin
    }
    
    func createFamilyAndFirstProfile(confirmedPin: String) {
        guard pin == confirmedPin else {
            errorMessage = "PINs do not match. Please try again."
            // Reset to the beginning of the PIN setup
            self.pin = ""
            self.confirmedPin = ""
            currentStep = .setPin
            return
        }
        
        self.confirmedPin = confirmedPin
        errorMessage = nil
        
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "Could not find user. Please log in again."
            return
        }
        
        isLoading = true
        
        let db = Firestore.firestore()
        let newFamilyRef = db.collection("families").document()
        let userRef = db.collection("users").document(currentUser.uid)
        
        let parentProfile = UserProfile(
            name: name,
            avatarSymbolName: "person.crop.circle.fill",
            isParent: true,
            pin: pin // Save the new PIN
        )
        
        let userModel = UserModel(
            familyID: newFamilyRef.documentID,
            email: currentUser.email ?? ""
        )
        
        let batch = db.batch()
        batch.setData([:], forDocument: newFamilyRef)
        let newProfileRef = newFamilyRef.collection("profiles").document()
        try? batch.setData(from: parentProfile, forDocument: newProfileRef)
        try? batch.setData(from: userModel, forDocument: userRef)
        
        batch.commit { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Error creating family: \(error.localizedDescription)"
                } else {
                    print("Family and initial profile created successfully!")
                    self?.isOnboardingComplete = true
                }
            }
        }
    }
}
