//
//  AssignChoresToChildViewModel.swift
//  ChoreRally
//


import Foundation
import FirebaseFirestore
import Combine

class AssignChoresToChildViewModel: ObservableObject {

    @Published var capableChores: [Chore] = []
    @Published var recentlyAssignedChoreIDs = Set<String>()
    
    // State for the assignment sheet
    @Published var choreToAssign: Chore?
    @Published var dueDate = Date()
    @Published var assignmentValue = 0.0
    @Published var hourlyRate = 0.0
    
    private let childProfile: UserProfile
    private let familyID: String
    private var cancellables = Set<AnyCancellable>()

    init(childProfile: UserProfile, familyID: String) {
        self.childProfile = childProfile
        self.familyID = familyID
        fetchCapableChores()
    }

    func selectChoreForAssignment(_ chore: Chore) {
        if chore.isTimeBased ?? false {
            self.hourlyRate = childProfile.rate ?? 0.0 // Default to child's rate
        } else {
            self.assignmentValue = calculateValue(for: chore)
        }
        self.choreToAssign = chore
    }
    
    func assignChore() {
        guard let chore = choreToAssign, let choreID = chore.id, let childProfileID = childProfile.id else {
            return
        }
        
        let newAssignment: ChoreAssignment
        
        if chore.isTimeBased ?? false {
            newAssignment = ChoreAssignment(
                choreID: choreID,
                childProfileID: childProfileID,
                dateAssigned: Timestamp(date: Date()),
                dueDate: Timestamp(date: dueDate),
                status: .assigned,
                value: 0, // Initial value is 0 until time is submitted
                hourlyRate: self.hourlyRate
            )
        } else {
            newAssignment = ChoreAssignment(
                choreID: choreID,
                childProfileID: childProfileID,
                dateAssigned: Timestamp(date: Date()),
                dueDate: Timestamp(date: dueDate),
                status: .assigned,
                value: self.assignmentValue
            )
        }
        
        let db = Firestore.firestore()
        do {
           try db.collection("families").document(familyID).collection("assignments").addDocument(from: newAssignment) { [weak self] error in
               if error == nil {
                   DispatchQueue.main.async {
                       self?.recentlyAssignedChoreIDs.insert(choreID)
                       self?.choreToAssign = nil // Dismiss sheet
                   }
               }
           }
        } catch {
            print("Error assigning chore: \(error)")
        }
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
    
    private func calculateValue(for chore: Chore) -> Double {
        let rate = childProfile.rate ?? 0.0
        let timeInHours = Double(chore.estimatedTimeInMinutes) / 60.0
        return rate * timeInHours * chore.difficultyMultiplier
    }
}

