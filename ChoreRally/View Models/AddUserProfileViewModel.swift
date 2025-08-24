//
//  AddUserProfileViewModel.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This ViewModel handles the logic for creating a new UserProfile.
//

import Foundation
import FirebaseFirestore
import Combine

class AddUserProfileViewModel: ObservableObject {
    
    // MARK - Published Properties
    
    @Published var name = ""
    @Published var age = 8 // Default age
    @Published var rate = 8.0 // Default rate, will be updated by age
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSaveSuccessful = false
    
    private let familyID: String
    private var cancellables = Set<AnyCancellable>()
    
    init(familyID: String) {
        self.familyID = familyID
        
        // This subscriber automatically updates the rate whenever the age changes.
        $age
            .map { Double($0) } // Convert the Int age to a Double
            .assign(to: \.rate, on: self) // Assign it to the rate property
            .store(in: &cancellables) // Store the subscription
    }
    
    // MARK: - Public Methods
    
    func saveProfile() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a name."
            return
        }
        
        isLoading = true
        
        let newProfile = UserProfile(
            name: name,
            avatarSymbolName: "face.smiling.fill",
            isParent: false,
            age: age,
            rate: rate
        )
        
        let db = Firestore.firestore()
        let profileCollection = db.collection("families").document(familyID).collection("profiles")
        
        do {
            try profileCollection.addDocument(from: newProfile) { [weak self] error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = "Error saving profile: \(error.localizedDescription)"
                    } else {
                        print("New child profile saved successfully.")
                        self?.isSaveSuccessful = true
                    }
                }
            }
        } catch {
            isLoading = false
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
        }
    }
}
