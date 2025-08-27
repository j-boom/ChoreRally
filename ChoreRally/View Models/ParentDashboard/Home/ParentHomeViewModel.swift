//
//  ParentHomeViewModel.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This ViewModel powers the main Parent Home dashboard view.
//

import Foundation
import FirebaseFirestore
import Combine

// This custom struct makes it easier to pass around the combined data needed by the view.
struct ChoreAssignmentDetails: Identifiable {
    var id: String { assignment.id ?? UUID().uuidString }
    let assignment: ChoreAssignment
    let chore: Chore
    let child: UserProfile
}

class ParentHomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var pendingApprovals: [ChoreAssignmentDetails] = []
    @Published var todaysChores: [ChoreAssignmentDetails] = []
    @Published var tomorrowsChores: [ChoreAssignmentDetails] = []
    @Published var isLoading = true
    
    private let familyID: String
    private var cancellables = Set<AnyCancellable>()
    
    init(familyID: String) {
        self.familyID = familyID
        fetchData()
    }
    
    // MARK: - Public Methods
    
    /// Updates an assignment's status to 'Approved'.
    func approve(_ details: ChoreAssignmentDetails) {
        guard let assignmentID = details.assignment.id else { return }
        let db = Firestore.firestore()
        db.collection("families").document(familyID).collection("assignments").document(assignmentID)
            .updateData([
                "status": ChoreAssignment.Status.approved.rawValue,
                "dateCompleted": Timestamp(date: Date())
            ])
    }
    
    /// Updates an assignment's status back to 'Assigned'.
    func reject(_ details: ChoreAssignmentDetails) {
        guard let assignmentID = details.assignment.id else { return }
        let db = Firestore.firestore()
        db.collection("families").document(familyID).collection("assignments").document(assignmentID)
            .updateData(["status": ChoreAssignment.Status.assigned.rawValue])
    }
    
    // MARK: - Private Methods
    
    private func fetchData() {
        let assignmentsPublisher = Firestore.firestore().collection("families").document(familyID).collection("assignments").snapshotPublisher(as: ChoreAssignment.self)
        let choresPublisher = Firestore.firestore().collection("families").document(familyID).collection("chores").snapshotPublisher(as: Chore.self)
        let profilesPublisher = Firestore.firestore().collection("families").document(familyID).collection("profiles").snapshotPublisher(as: UserProfile.self)
        
        Publishers.CombineLatest3(assignmentsPublisher, choresPublisher, profilesPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching data: \(error)")
                }
            }, receiveValue: { [weak self] assignments, chores, profiles in
                self?.processFetchedData(assignments: assignments, chores: chores, profiles: profiles)
            })
            .store(in: &cancellables)
    }
    
    private func processFetchedData(assignments: [ChoreAssignment], chores: [Chore], profiles: [UserProfile]) {
        // Create arrays of key-value pairs first to help the compiler with type inference.
        let chorePairs = chores.compactMap { chore -> (String, Chore)? in
            guard let id = chore.id else { return nil }
            return (id, chore)
        }
        let choreDict = Dictionary(uniqueKeysWithValues: chorePairs)
        
        let profilePairs = profiles.compactMap { profile -> (String, UserProfile)? in
            guard let id = profile.id else { return nil }
            return (id, profile)
        }
        let profileDict = Dictionary(uniqueKeysWithValues: profilePairs)
        
        let allDetails = assignments.compactMap { assignment -> ChoreAssignmentDetails? in
            guard let chore = choreDict[assignment.choreID],
                  let child = profileDict[assignment.childProfileID] else {
                return nil
            }
            return ChoreAssignmentDetails(assignment: assignment, chore: chore, child: child)
        }
        
        // Explicitly specify the enum type to help the compiler.
        self.pendingApprovals = allDetails.filter { $0.assignment.status == ChoreAssignment.Status.completed }
        let upcomingChores = allDetails.filter { $0.assignment.status == ChoreAssignment.Status.assigned }
        
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

// Helper to convert a Firestore query into a Combine publisher.
extension Query {
    func snapshotPublisher<T: Decodable>(as type: T.Type) -> AnyPublisher<[T], Error> {
        Future<[T], Error> { promise in
            self.addSnapshotListener { querySnapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else if let documents = querySnapshot?.documents {
                    let data = documents.compactMap { try? $0.data(as: T.self) }
                    promise(.success(data))
                }
            }
        }.eraseToAnyPublisher()
    }
}
