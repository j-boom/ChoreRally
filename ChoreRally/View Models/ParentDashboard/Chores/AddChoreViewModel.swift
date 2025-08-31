//
//  AddChoreViewModel.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/24/25.
//


//
//  AddChoreViewModel.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This ViewModel handles the logic for creating a new custom chore.
//

import Foundation
import FirebaseFirestore

class AddChoreViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var name = ""
    @Published var description = ""
    @Published var category = Chore.ChoreCategory.other
    @Published var difficulty = Chore.Difficulty.moderate
    @Published var estimatedTime = 15
    @Published var isTimeBased = false
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSaveSuccessful = false
    
    private let familyID: String
    
    init(familyID: String) {
        self.familyID = familyID
    }
    
    // MARK: - Public Methods
    
    func saveChore() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a name for the chore."
            return
        }
        
        isLoading = true
        let db = Firestore.firestore()
        let choresCollection = db.collection("families").document(familyID).collection("chores")
        
        // --- New: Check for existing chore with the same name ---
        choresCollection.whereField("name", isEqualTo: name.trimmingCharacters(in: .whitespacesAndNewlines)).getDocuments { [weak self] (querySnapshot, error) in
            
            // Ensure we can safely access self
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Error checking for chore: \(error.localizedDescription)"
                }
                return
            }
            
            // If we find any documents, it means the chore already exists.
            if !(querySnapshot?.documents.isEmpty ?? true) {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "A chore with this name already exists."
                }
                return
            }
            
            // --- If no duplicates are found, proceed with saving ---
            let newChore = Chore(
                name: self.name,
                description: self.description,
                estimatedTimeInMinutes: self.isTimeBased ? 0 : self.estimatedTime,
                difficultyMultiplier: self.difficulty.multiplier,
                category: self.category,
                isTimeBased: self.isTimeBased
            )
            
            do {
                try choresCollection.addDocument(from: newChore) { error in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        if let error = error {
                            self.errorMessage = "Error saving chore: \(error.localizedDescription)"
                        } else {
                            print("New chore saved successfully.")
                            self.isSaveSuccessful = true
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Failed to save chore: \(error.localizedDescription)"
                }
            }
        }
    }
}
