//
//  ChoresManagementViewModel.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This ViewModel fetches and manages the list of chores for a family.
//

import Foundation
import FirebaseFirestore
import Combine

class ChoresManagementViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var chores: [Chore] = []
    // --- New properties for grouping and sorting ---
    @Published var choresByCategory: [Chore.ChoreCategory: [Chore]] = [:]
    @Published var choreCategories: [Chore.ChoreCategory] = []
    
    @Published var errorMessage: String?
    @Published var isLoading = true
    
    // This will control showing the setup sheet automatically
    @Published var shouldShowInitialSetup = false
    
    // This will control showing the sheet when the '+' is tapped
    @Published var shouldShowAddChoreSheet = false
    
    // --- New property to control editing sheet ---
    @Published var selectedChoreForEditing: Chore?
    
    private let familyID: String
    private var listenerRegistration: ListenerRegistration?
    
    init(familyID: String) {
        self.familyID = familyID
        fetchChores()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    // MARK: - Public Methods
    
    func fetchChores() {
        let db = Firestore.firestore()
        let choresCollection = db.collection("families").document(familyID).collection("chores")
        
        self.listenerRegistration = choresCollection.addSnapshotListener { [weak self] (querySnapshot, error) in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = "Error fetching chores: \(error.localizedDescription)"
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                self?.errorMessage = "No chores found."
                return
            }
            
            let fetchedChores = documents.compactMap { document -> Chore? in
                try? document.data(as: Chore.self)
            }
            
            self?.chores = fetchedChores
            
            // --- Group and sort the chores for the view ---
            self?.groupAndSortChores(fetchedChores)
            
            // If the fetched chores list is empty, trigger the initial setup.
            if fetchedChores.isEmpty {
                self?.shouldShowInitialSetup = true
            }
        }
    }
    
    /// Deletes a chore from Firestore.
    func deleteChore(in category: Chore.ChoreCategory, at offsets: IndexSet) {
        guard let choresInCategory = choresByCategory[category] else { return }
        let choresToDelete = offsets.map { choresInCategory[$0] }
        let db = Firestore.firestore()
        
        for chore in choresToDelete {
            if let choreID = chore.id {
                db.collection("families").document(familyID).collection("chores").document(choreID).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func groupAndSortChores(_ chores: [Chore]) {
        // Group chores by their category
        choresByCategory = Dictionary(grouping: chores, by: { $0.category })
        
        // Sort the categories for a consistent order in the UI
        choreCategories = choresByCategory.keys.sorted { $0.rawValue < $1.rawValue }
    }
}
