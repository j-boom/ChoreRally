//
//  ChildHomeViewModel.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This ViewModel powers the child's home screen.
//

import Foundation
import FirebaseFirestore
import Combine

class ChildHomeViewModel: ObservableObject {
    
    @Published var overdueChores: [ChoreAssignmentDetails] = []
    @Published var todaysChores: [ChoreAssignmentDetails] = []
    @Published var tomorrowsChores: [ChoreAssignmentDetails] = []
    
    private let childProfile: UserProfile
    private let familyID: String
    private var cancellables = Set<AnyCancellable>()
    
    init(childProfile: UserProfile, familyID: String) {
        self.childProfile = childProfile
        self.familyID = familyID
        fetchData()
    }
    
    /// Marks a chore as 'Completed' by calling the FirestoreService.
    func markChoreAsCompleted(_ details: ChoreAssignmentDetails) {
        guard let assignmentID = details.assignment.id else { return }
        
        FirestoreService.updateAssignmentStatus(
            assignmentID: assignmentID,
            newStatus: .completed,
            in: familyID
        )
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Error updating chore status: \(error.localizedDescription)")
            }
        }, receiveValue: {
            print("Chore status updated successfully.")
        })
        .store(in: &cancellables)
    }
    
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
        
        let choreDict = Dictionary(data.chores.compactMap { ($0.id, $0) }, uniquingKeysWith: { (first, _) in first })
        
        // First, get all assignments for this specific child.
        let childAssignments = data.assignments.filter { $0.childProfileID == childID }
        
        let allDetails = childAssignments.compactMap { assignment -> ChoreAssignmentDetails? in
            guard let chore = choreDict[assignment.choreID] else { return nil }
            return ChoreAssignmentDetails(assignment: assignment, chore: chore, child: self.childProfile)
        }
        
        let upcomingChores = allDetails.filter { $0.assignment.status == .assigned }
        
        let now = Date()
        let startOfToday = Calendar.current.startOfDay(for: now)
        
        self.overdueChores = upcomingChores.filter {
            guard let dueDate = $0.assignment.dueDate?.dateValue() else { return false }
            return dueDate < startOfToday
        }
        
        self.todaysChores = upcomingChores.filter {
            guard let dueDate = $0.assignment.dueDate?.dateValue() else { return false }
            return Calendar.current.isDateInToday(dueDate)
        }
        
        self.tomorrowsChores = upcomingChores.filter {
            guard let dueDate = $0.assignment.dueDate?.dateValue() else { return false }
            return Calendar.current.isDateInTomorrow(dueDate)
        }
    }
}
