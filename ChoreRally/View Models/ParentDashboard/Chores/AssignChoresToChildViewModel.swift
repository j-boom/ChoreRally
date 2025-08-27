//
//  AssignChoresToChildViewModel.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/26/25.
//


//
//  AssignChoresToChildViewModel.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This ViewModel handles the logic for assigning a chore to a specific child.
//

import Foundation
import FirebaseFirestore
import Combine

class AssignChoresToChildViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var capableChores: [Chore] = []
    @Published var recentlyAssignedChoreIDs = Set<String>()
    
    private let childProfile: UserProfile
    private let familyID: String
    private var allChoresListener: ListenerRegistration?
    
    init(childProfile: UserProfile, familyID: String) {
        self.childProfile = childProfile
        self.familyID = familyID
        fetchCapableChores()
    }
    
    deinit {
        allChoresListener?.remove()
    }
    
    // MARK: - Public Methods
    
    /// Creates a new ChoreAssignment in Firestore with a due date.
    func assignChore(_ chore: Chore, dueDate: Date) {
        guard let choreID = chore.id, let childProfileID = childProfile.id else {
            print("Error: Missing choreID or childProfileID")
            return
        }
        
        // Calculate the chore's value based on the child's rate.
        let rate = childProfile.rate ?? 0.0
        let timeInHours = Double(chore.estimatedTimeInMinutes) / 60.0
        let value = rate * timeInHours * chore.difficultyMultiplier
        
        let newAssignment = ChoreAssignment(
            choreID: choreID,
            childProfileID: childProfileID,
            dateAssigned: Timestamp(date: Date()),
            dueDate: Timestamp(date: dueDate), // Set the due date
            status: .assigned,
            value: value
        )
        
        let db = Firestore.firestore()
        do {
            try db.collection("families").document(familyID).collection("assignments").addDocument(from: newAssignment) { [weak self] error in
                if let error = error {
                    print("Error creating assignment: \(error)")
                } else {
                    print("Chore assigned successfully!")
                    // Briefly track the assignment to update the UI
                    DispatchQueue.main.async {
                        self?.recentlyAssignedChoreIDs.insert(choreID)
                    }
                }
            }
        } catch {
            print("Error encoding assignment: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchCapableChores() {
        guard let capableIDs = childProfile.capableChoreIDs, !capableIDs.isEmpty else {
            // If the child has no capable chores, there's nothing to fetch.
            self.capableChores = []
            return
        }
        
        let db = Firestore.firestore()
        allChoresListener = db.collection("families").document(familyID).collection("chores").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else { return }
            
            let allChores = documents.compactMap { try? $0.data(as: Chore.self) }
            
            // Filter the master list of chores to get only the ones this child can do.
            self?.capableChores = allChores.filter { chore in
                guard let choreID = chore.id else { return false }
                return capableIDs.contains(choreID)
            }
        }
    }
}
