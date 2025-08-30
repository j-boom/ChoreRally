//
//  ExtraChoresViewModel.swift
//  ChoreRally
//
//  Created by Gemini on 2025-08-28.
//
//  This ViewModel has been updated to correctly handle Firestore Timestamps.
//

import Foundation
import Combine
import FirebaseFirestore // <-- Make sure this is imported

class ExtraChoresViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var availableChores: [Chore] = []
    @Published var canTakeExtraChores: Bool = false
    @Published var selectedChores = Set<String>()
    
    // MARK: - Properties
    
    private let childProfile: UserProfile
    private let familyID: String
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init(childProfile: UserProfile, familyID: String) {
        self.childProfile = childProfile
        self.familyID = familyID
        fetchData()
    }
    
    // MARK: - Public Methods
    
    func submitCompletedChores() {
        guard !selectedChores.isEmpty else { return }
        
        let newAssignments = selectedChores.map { choreID -> ChoreAssignment in
            let chore = self.availableChores.first(where: { $0.id == choreID })
            
            let baseRatePerMinute = 0.15
            let timeValue = Double(chore?.estimatedTimeInMinutes ?? 0) * baseRatePerMinute
            let finalValue = timeValue * (chore?.difficultyMultiplier ?? 1.0)
            
            // --- THIS IS THE FIX ---
            // We now convert the Swift Date into a Firestore Timestamp.
            let assignedTimestamp = Timestamp(date: Date())
            
            return ChoreAssignment(
                choreID: choreID,
                childProfileID: self.childProfile.id ?? "",
                dateAssigned: assignedTimestamp, // Use the new Timestamp
                dueDate: nil,
                status: ChoreAssignment.Status.completed,
                value: finalValue
            )
        }
        
        FirestoreService.createAssignments(newAssignments, in: familyID)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error creating completed assignments: \(error.localizedDescription)")
                }
            }, receiveValue: {
                print("Successfully submitted completed extra chores.")
                self.selectedChores.removeAll()
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    
    private func fetchData() {
        FirestoreService.fetchAndCombineData(familyID: familyID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] familyData in
                self?.process(familyData)
            })
            .store(in: &cancellables)
    }
    
    private func process(_ data: FamilyData) {
        guard let childID = self.childProfile.id else { return }
        
        let assignedChores = data.assignments.filter { $0.childProfileID == childID }
        self.canTakeExtraChores = !assignedChores.contains { $0.status == .assigned }
        
        let assignedChoreIDs = Set(assignedChores.map { $0.choreID })
        self.availableChores = data.chores.filter { chore in
            guard let choreID = chore.id else { return false }
            return !assignedChoreIDs.contains(choreID)
        }
    }
}
