//
//  ChildDetailViewModel.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This ViewModel manages the state for editing a child's profile and
//  their assigned chores.
//

import Foundation
import FirebaseFirestore
import Combine

class ChildDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var name: String
    @Published var age: Int
    @Published var rate: Double
    @Published var capableChoreIDs: Set<String>
    
    @Published var allChores: [Chore] = []
    @Published var isSaveSuccessful = false
    
    private let childProfile: UserProfile
    private let familyID: String
    
    init(childProfile: UserProfile, familyID: String) {
        self.childProfile = childProfile
        self.familyID = familyID
        
        // Initialize state from the child's profile
        _name = .init(initialValue: childProfile.name)
        _age = .init(initialValue: childProfile.age ?? 8)
        _rate = .init(initialValue: childProfile.rate ?? 8.0)
        _capableChoreIDs = .init(initialValue: Set(childProfile.capableChoreIDs ?? []))
        
        fetchAllChores()
    }
    
    // MARK: - Public Methods
    
    func toggleChoreAssignment(_ chore: Chore) {
        guard let choreID = chore.id else { return }
        
        if capableChoreIDs.contains(choreID) {
            capableChoreIDs.remove(choreID)
        } else {
            capableChoreIDs.insert(choreID)
        }
    }
    
    func saveChanges() {
        guard let profileID = childProfile.id else { return }
        
        var updatedProfile = childProfile
        updatedProfile.name = name
        updatedProfile.age = age
        updatedProfile.rate = rate
        updatedProfile.capableChoreIDs = Array(capableChoreIDs)
        
        let db = Firestore.firestore()
        let profileDocument = db.collection("families").document(familyID).collection("profiles").document(profileID)
        
        do {
            try profileDocument.setData(from: updatedProfile) { [weak self] error in
                if error == nil {
                    DispatchQueue.main.async {
                        self?.isSaveSuccessful = true
                    }
                }
            }
        } catch {
            print("Error saving profile: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchAllChores() {
        let db = Firestore.firestore()
        db.collection("families").document(familyID).collection("chores").getDocuments { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else { return }
            // --- Fixed typo: allChoores -> allChores ---
            self?.allChores = documents.compactMap { try? $0.data(as: Chore.self) }
        }
    }
}
