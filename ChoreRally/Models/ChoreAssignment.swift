//
//  ChoreAssignment.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This model represents a single instance of a chore being assigned to a child.
//

import Foundation
import FirebaseFirestore

struct ChoreAssignment: Identifiable, Codable {
    @DocumentID var id: String?
    
    let choreID: String
    let childProfileID: String
    
    let dateAssigned: Timestamp
    var dateCompleted: Timestamp?
    var dueDate: Timestamp? // New property for the due date
    
    var status: Status
    let value: Double // The value of the chore at the time of assignment
    
    // Enum for the lifecycle of a chore
    enum Status: String, Codable {
        case assigned = "Assigned"
        case completed = "Completed" // Child marked as done, pending approval
        case approved = "Approved"   // Parent approved, payment is due
        case rejected = "Rejected"   // Parent rejected, needs to be redone
    }
}
