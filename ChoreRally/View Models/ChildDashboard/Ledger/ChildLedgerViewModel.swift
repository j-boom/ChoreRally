//
//  ChildLedgerViewModel.swift
//  ChoreRally
//
//  Created by Gemini on 2025-08-28.
//
//  This ViewModel has been updated to provide the correct data structure to the view.
//

import Foundation
import Combine

/// A helper struct to group a payment with its associated chore details.
struct PaymentGroup: Identifiable {
    let id: String
    let payment: Payment
    // This property is required by the ChildLedgerView.
    let details: [ChoreAssignmentDetails]
}

class ChildLedgerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var unpaidChores: [ChoreAssignmentDetails] = []
    @Published var paidChoreGroups: [PaymentGroup] = []
    @Published var totalOwed: Double = 0.0
    
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
    
    // MARK: - Private Methods
    private func fetchData() {
        FirestoreService.fetchDataForLedger(familyID: familyID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] ledgerData in
                self?.process(ledgerData)
            })
            .store(in: &cancellables)
    }
    
    private func process(_ data: (assignments: [ChoreAssignment], chores: [Chore], payments: [Payment])) {
        guard let childID = self.childProfile.id else { return }
        
        let choreDict = Dictionary(data.chores.compactMap { ($0.id, $0) }, uniquingKeysWith: { (first, _) in first })
        
        // --- 1. Process Unpaid Chores ---
        let unpaidAssignments = data.assignments.filter {
            $0.childProfileID == childID && $0.status == .approved && $0.isPaid != true
        }
        
        self.unpaidChores = unpaidAssignments.compactMap { assignment -> ChoreAssignmentDetails? in
            guard let chore = choreDict[assignment.choreID] else { return nil }
            return ChoreAssignmentDetails(assignment: assignment, chore: chore, child: self.childProfile)
        }
        
        self.totalOwed = unpaidChores.reduce(0) { $0 + $1.assignment.value }
        
        // --- 2. Process Paid Chores ---
        let childPayments = data.payments.filter { $0.childProfileID == childID }.sorted { $0.paymentDate.dateValue() > $1.paymentDate.dateValue() }
        
        self.paidChoreGroups = childPayments.compactMap { payment -> PaymentGroup? in
            guard let paymentID = payment.id else { return nil }
            
            // This now finds the full ChoreAssignmentDetails for each paid chore.
            let detailsForPayment = payment.includedAssignmentIDs.compactMap { assignmentID -> ChoreAssignmentDetails? in
                guard let assignment = data.assignments.first(where: { $0.id == assignmentID }),
                      let chore = choreDict[assignment.choreID] else {
                    return nil
                }
                return ChoreAssignmentDetails(assignment: assignment, chore: chore, child: self.childProfile)
            }
            
            // The PaymentGroup is now created with the 'details' property.
            return PaymentGroup(id: paymentID, payment: payment, details: detailsForPayment)
        }
    }
}
