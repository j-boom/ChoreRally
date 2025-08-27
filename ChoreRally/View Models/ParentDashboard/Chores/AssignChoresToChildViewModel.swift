//
//  AssignChoresToChildViewModel.swift
//  ChoreRally
//
//  This ViewModel now uses the FirestoreService.
//

import Foundation
import FirebaseFirestore
import Combine

class AssignChoresToChildViewModel: ObservableObject {

    @Published var capableChores: [Chore] = []
    @Published var recentlyAssignedChoreIDs = Set<String>()
    
    private let childProfile: UserProfile
    private let familyID: String
    private var cancellables = Set<AnyCancellable>()

    init(childProfile: UserProfile, familyID: String) {
        self.childProfile = childProfile
        self.familyID = familyID
        fetchCapableChores()
    }

    private func fetchCapableChores() {
        guard let capableIDs = childProfile.capableChoreIDs, !capableIDs.isEmpty else {
            self.capableChores = []
            return
        }
        
        FirestoreService.fetchChores(familyID: familyID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] allChores in
                self?.capableChores = allChores.filter { chore in
                    guard let choreID = chore.id else { return false }
                    return capableIDs.contains(choreID)
                }
            })
            .store(in: &cancellables)
    }
    
    func assignChore(_ chore: Chore, dueDate: Date) {
        guard let choreID = chore.id, let childProfileID = childProfile.id else {
            return
        }
        
        let rate = childProfile.rate ?? 0.0
        let timeInHours = Double(chore.estimatedTimeInMinutes) / 60.0
        let value = rate * timeInHours * chore.difficultyMultiplier
        
        let newAssignment = ChoreAssignment(
            choreID: choreID,
            childProfileID: childProfileID,
            dateAssigned: Timestamp(date: Date()),
            dueDate: Timestamp(date: dueDate),
            status: .assigned,
            value: value
        )
        
        let db = Firestore.firestore()
        try? db.collection("families").document(familyID).collection("assignments").addDocument(from: newAssignment)
    }
}
