//
//  ChoreSetupViewModel.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This ViewModel provides chore templates and handles saving the selected
//  chores to Firestore.
//

import Foundation
import FirebaseFirestore
import Combine

class ChoreSetupViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var templatesByCategory: [Chore.ChoreCategory: [Chore]] = [:]
    @Published var selectedChores = Set<Chore>()
    @Published var isLoading = false
    @Published var isSetupComplete = false
    
    let choreCategories = Chore.ChoreCategory.allCases
    private let familyID: String
    
    init(familyID: String) {
        self.familyID = familyID
        loadChoreTemplates()
    }
    
    // MARK: - Public Methods
    
    func toggleChoreSelection(_ chore: Chore) {
        if selectedChores.contains(chore) {
            selectedChores.remove(chore)
        } else {
            selectedChores.insert(chore)
        }
    }
    
    func saveSelectedChores() {
        isLoading = true
        let db = Firestore.firestore()
        let choresCollection = db.collection("families").document(familyID).collection("chores")
        
        // Use a batched write to add all selected chores at once.
        let batch = db.batch()
        
        for chore in selectedChores {
            let newChoreRef = choresCollection.document()
            try? batch.setData(from: chore, forDocument: newChoreRef)
        }
        
        batch.commit { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if error == nil {
                    print("Chore templates saved successfully.")
                    self?.isSetupComplete = true
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadChoreTemplates() {
        // --- This function now loads chores from the local JSON file ---
        guard let url = Bundle.main.url(forResource: "ChoreTemplates", withExtension: "json") else {
            print("ChoreTemplates.json file not found.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            var templates = try JSONDecoder().decode([Chore].self, from: data)
            
            // --- Manually assign a temporary unique ID for the UI ---
            for i in 0..<templates.count {
                templates[i].id = UUID().uuidString
            }
            
            // Group the templates by category for the view.
            templatesByCategory = Dictionary(grouping: templates, by: { $0.category })
        } catch {
            print("Error decoding chore templates: \(error)")
        }
    }
}
