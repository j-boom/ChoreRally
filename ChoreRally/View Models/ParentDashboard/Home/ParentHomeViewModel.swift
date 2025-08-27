//
//  ParentHomeViewModel.swift
//  ChoreRally
//
//  This ViewModel now uses the FirestoreService.
//

import Foundation
import FirebaseFirestore
import Combine

class ParentHomeViewModel: ObservableObject {
    
    @Published var pendingApprovals: [ChoreAssignmentDetails] = []
    @Published var todaysChores: [ChoreAssignmentDetails] = []
    @Published var tomorrowsChores: [ChoreAssignmentDetails] = []
    @Published var isLoading = true
    @Published var assignmentToEdit: ChoreAssignmentDetails?
    
    private let familyID: String
    private var cancellables = Set<AnyCancellable>()
    
    init(familyID: String) {
        self.familyID = familyID
        fetchData()
    }
    
    func approve(_ details: ChoreAssignmentDetails) {
        guard let assignmentID = details.assignment.id else { return }
        let db = Firestore.firestore()
        db.collection("families").document(familyID).collection("assignments").document(assignmentID)
            .updateData([
                "status": ChoreAssignment.Status.approved.rawValue,
                "dateCompleted": Timestamp(date: Date())
            ])
    }
    
    func reject(_ details: ChoreAssignmentDetails) {
        guard let assignmentID = details.assignment.id else { return }
        let db = Firestore.firestore()
        db.collection("families").document(familyID).collection("assignments").document(assignmentID)
            .updateData(["status": ChoreAssignment.Status.assigned.rawValue])
    }
    
    private func fetchData() {
        FirestoreService.fetchAndCombineData(familyID: familyID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching home data: \(error)")
                }
            }, receiveValue: { [weak self] familyData in
                self?.process(familyData)
            })
            .store(in: &cancellables)
    }
    
    private func process(_ data: FamilyData) {
        let choreDict = Dictionary(data.chores.compactMap { ($0.id, $0) }, uniquingKeysWith: { (first, _) in first })
        let profileDict = Dictionary(data.profiles.compactMap { ($0.id, $0) }, uniquingKeysWith: { (first, _) in first })
        
        let allDetails = data.assignments.compactMap { assignment -> ChoreAssignmentDetails? in
            guard let chore = choreDict[assignment.choreID],
                  let child = profileDict[assignment.childProfileID] else {
                return nil
            }
            return ChoreAssignmentDetails(assignment: assignment, chore: chore, child: child)
        }
        
        self.pendingApprovals = allDetails.filter { $0.assignment.status == .completed }
        let upcomingChores = allDetails.filter { $0.assignment.status == .assigned }
        
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
