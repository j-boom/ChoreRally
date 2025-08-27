//
//  EditChoreAssignmentViewModel.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/27/25.
//


//
//  EditChoreAssignmentViewModel.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This ViewModel powers the editing screen for an assigned chore.
//

import Foundation
import FirebaseFirestore
import Combine

class EditChoreAssignmentViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var dueDate: Date
    @Published var isSaveSuccessful = false
    @Published var showingDeleteConfirm = false
    
    private let assignmentDetails: ChoreAssignmentDetails
    private let familyID: String
    
    init(details: ChoreAssignmentDetails, familyID: String) {
        self.assignmentDetails = details
        self.familyID = familyID
        // Initialize the date picker with the chore's current due date, or today if nil
        _dueDate = .init(initialValue: details.assignment.dueDate?.dateValue() ?? Date())
    }
    
    // MARK: - Public Methods
    
    /// Updates the due date of the chore assignment in Firestore.
    func saveChanges() {
        guard let assignmentID = assignmentDetails.assignment.id else { return }
        
        let db = Firestore.firestore()
        db.collection("families").document(familyID).collection("assignments").document(assignmentID)
            .updateData(["dueDate": Timestamp(date: dueDate)]) { [weak self] error in
                if let error = error {
                    print("Error updating due date: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self?.isSaveSuccessful = true
                    }
                }
            }
    }
    
    /// Deletes the chore assignment from Firestore.
    func unassignChore() {
        guard let assignmentID = assignmentDetails.assignment.id else { return }
        
        let db = Firestore.firestore()
        db.collection("families").document(familyID).collection("assignments").document(assignmentID).delete { [weak self] error in
            if let error = error {
                print("Error unassigning chore: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.isSaveSuccessful = true
                }
            }
        }
    }
}
