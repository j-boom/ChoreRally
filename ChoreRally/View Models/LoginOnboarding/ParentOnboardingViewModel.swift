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
    
    // MARK: - Published Properties
    
    @Published var name = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isOnboardingComplete = false
    
    // MARK: - Public Methods
    
    /// Creates the new Family document, the first parent UserProfile, and the parent's UserModel all at once.
    func createFamilyAndFirstProfile() {
        // --- Validation ---
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your name."
            return
        }
        
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "Could not find user. Please log in again."
            return
        }
        
        isLoading = true
        
        // --- Create references to the Firestore locations we need ---
        let db = Firestore.firestore()
        let newFamilyRef = db.collection("families").document() // Creates a reference with a new, unique ID
        let userRef = db.collection("users").document(currentUser.uid)
        
        // --- Create the data models ---
        let parentProfile = UserProfile(
            name: name,
            avatarSymbolName: "person.crop.circle.fill",
            isParent: true
        )
        
        let userModel = UserModel(
            familyID: newFamilyRef.documentID, // Use the ID from our new family reference
            email: currentUser.email ?? ""
        )
        
        // --- Use a batched write to perform all operations at once ---
        // A batched write ensures that either all operations succeed, or they all fail.
        // This prevents our database from getting into a weird, inconsistent state.
        let batch = db.batch()
        
        // Operation 1: Create an empty document for the new family.
        batch.setData([:], forDocument: newFamilyRef)
        
        // Operation 2: Create the new parent profile inside the family's "profiles" sub-collection.
        let newProfileRef = newFamilyRef.collection("profiles").document()
        try? batch.setData(from: parentProfile, forDocument: newProfileRef)
        
        // Operation 3: Create the user model to link the logged-in user to the new family.
        try? batch.setData(from: userModel, forDocument: userRef)
        
        // --- Commit the batch ---
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
