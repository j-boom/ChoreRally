//
//  EditChoreViewModel.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This ViewModel handles the logic for editing an existing chore.
//

import Foundation
import FirebaseFirestore

class EditChoreViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var name: String
    @Published var description: String
    @Published var category: Chore.ChoreCategory
    @Published var difficulty: Chore.Difficulty
    @Published var estimatedTime: Int
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSaveSuccessful = false
    
    private let familyID: String
    private let chore: Chore // Store the original chore
    
    init(chore: Chore, familyID: String) {
        self.chore = chore
        self.familyID = familyID
        
        // Initialize the published properties with the chore's data
        _name = .init(initialValue: chore.name)
        _description = .init(initialValue: chore.description)
        _category = .init(initialValue: chore.category)
        _estimatedTime = .init(initialValue: chore.estimatedTimeInMinutes)
        
        // Find the matching difficulty enum case from the multiplier
        let matchingDifficulty = Chore.Difficulty.allCases.first { $0.multiplier == chore.difficultyMultiplier }
        _difficulty = .init(initialValue: matchingDifficulty ?? .moderate)
    }
    
    // MARK: - Public Methods
    
    func updateChore() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a name for the chore."
            return
        }
        
        guard let choreID = chore.id else {
            errorMessage = "Error: Chore ID is missing."
            return
        }
        
        isLoading = true
        
        // Create an updated Chore object
        var updatedChore = chore
        updatedChore.name = name
        updatedChore.description = description
        updatedChore.category = category
        updatedChore.difficultyMultiplier = difficulty.multiplier
        updatedChore.estimatedTimeInMinutes = estimatedTime
        
        let db = Firestore.firestore()
        let choreDocument = db.collection("families").document(familyID).collection("chores").document(choreID)
        
        do {
            // Use 'setData(from:)' to update the entire document.
            try choreDocument.setData(from: updatedChore) { [weak self] error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = "Error updating chore: \(error.localizedDescription)"
                    } else {
                        print("Chore updated successfully.")
                        self?.isSaveSuccessful = true
                    }
                }
            }
        } catch {
            isLoading = false
            errorMessage = "Failed to update chore: \(error.localizedDescription)"
        }
    }
}
