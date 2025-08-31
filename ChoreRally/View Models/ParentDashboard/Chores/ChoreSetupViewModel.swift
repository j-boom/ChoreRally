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
    
    @Published var choreTemplates: [Chore] = []
    @Published var selectedChores = Set<Chore>()
    @Published var isLoading = false
    @Published var isSetupComplete = false
    
    private let familyID: String
    private var cancellables = Set<AnyCancellable>()
    
    init(familyID: String) {
        self.familyID = familyID
        fetchChoreTemplates()
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
        
        for var chore in selectedChores {
            chore.id = nil // Ensure new documents are created in the family's collection
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
    
    private func fetchChoreTemplates() {
        FirestoreService.fetchChoreTemplates()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching chore templates: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] templates in
                self?.choreTemplates = templates
            })
            .store(in: &cancellables)
    }
}

