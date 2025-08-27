//
//  LedgerViewModel.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/26/25.
//


//
//  LedgerViewModel.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This ViewModel powers the Ledger tab.
//

import Foundation
import FirebaseFirestore
import Combine

class LedgerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var childProfiles: [UserProfile] = []
    @Published var selectedChildID: String? = nil {
        didSet { filterAndCalculate() }
    }
    
    @Published var filteredLedgerEntries: [ChoreAssignmentDetails] = []
    @Published var totalOwed: Double = 0.0
    
    private let familyID: String
    private var allUnpaidChores: [ChoreAssignmentDetails] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(familyID: String) {
        self.familyID = familyID
        fetchData()
    }
    
    // MARK: - Public Methods
    
    /// Pays the total owed amount for the currently selected child.
    func paySelectedChild() {
        let choresToPay = filteredLedgerEntries
        guard !choresToPay.isEmpty else { return }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        for details in choresToPay {
            if let assignmentID = details.assignment.id {
                let docRef = db.collection("families").document(familyID).collection("assignments").document(assignmentID)
                batch.updateData(["isPaid": true], forDocument: docRef)
            }
        }
        
        batch.commit { error in
            if let error = error {
                print("Error paying chores: \(error)")
            } else {
                print("Successfully paid \(choresToPay.count) chores.")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchData() {
        let assignmentsPublisher = Firestore.firestore().collection("families").document(familyID).collection("assignments").snapshotPublisher(as: ChoreAssignment.self)
        let choresPublisher = Firestore.firestore().collection("families").document(familyID).collection("chores").snapshotPublisher(as: Chore.self)
        let profilesPublisher = Firestore.firestore().collection("families").document(familyID).collection("profiles").snapshotPublisher(as: UserProfile.self)
        
        Publishers.CombineLatest3(assignmentsPublisher, choresPublisher, profilesPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching ledger data: \(error)")
                }
            }, receiveValue: { [weak self] assignments, chores, profiles in
                self?.processData(assignments: assignments, chores: chores, profiles: profiles)
            })
            .store(in: &cancellables)
    }
    
    private func processData(assignments: [ChoreAssignment], chores: [Chore], profiles: [UserProfile]) {
        let choreDict = Dictionary(uniqueKeysWithValues: chores.compactMap { ($0.id, $0) })
        let profileDict = Dictionary(uniqueKeysWithValues: profiles.compactMap { ($0.id, $0) })
        
        let allDetails = assignments.compactMap { assignment -> ChoreAssignmentDetails? in
            guard let chore = choreDict[assignment.choreID], let child = profileDict[assignment.childProfileID] else { return nil }
            return ChoreAssignmentDetails(assignment: assignment, chore: chore, child: child)
        }
        
        self.childProfiles = profiles.filter { !$0.isParent }.sorted { $0.name < $1.name }
        self.allUnpaidChores = allDetails.filter { $0.assignment.status == .approved && $0.assignment.isPaid == false }
        
        filterAndCalculate()
    }
    
    private func filterAndCalculate() {
        if let childID = selectedChildID {
            filteredLedgerEntries = allUnpaidChores.filter { $0.child.id == childID }
        } else {
            filteredLedgerEntries = allUnpaidChores
        }
        
        totalOwed = filteredLedgerEntries.reduce(0) { $0 + $1.assignment.value }
    }
}
