//
//  LedgerViewModel.swift
//  ChoreRally
//
//  This ViewModel now uses the FirestoreService.
//

import Foundation
import FirebaseFirestore
import Combine

class LedgerViewModel: ObservableObject {
    
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
    
    private func fetchData() {
        FirestoreService.fetchAndCombineData(familyID: familyID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching ledger data: \(error)")
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
            guard let chore = choreDict[assignment.choreID], let child = profileDict[assignment.childProfileID] else { return nil }
            return ChoreAssignmentDetails(assignment: assignment, chore: chore, child: child)
        }
        
        self.childProfiles = data.profiles.filter { !$0.isParent }.sorted { $0.name < $1.name }
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
