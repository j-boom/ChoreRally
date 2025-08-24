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
        
        let newChore = Chore(
            name: name,
            description: description,
            estimatedTimeInMinutes: estimatedTime,
            difficultyMultiplier: difficulty.multiplier,
            category: category
        )
        
        let db = Firestore.firestore()
        let choresCollection = db.collection("families").document(familyID).collection("chores")
        
        do {
            try choresCollection.addDocument(from: newChore) { [weak self] error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = "Error saving chore: \(error.localizedDescription)"
                    } else {
                        print("New chore saved successfully.")
                        self?.isSaveSuccessful = true
                    }
                }
            }
        } catch {
            isLoading = false
            errorMessage = "Failed to save chore: \(error.localizedDescription)"
        }
    }
}
