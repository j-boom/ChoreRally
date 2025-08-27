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
    var dueDate: Timestamp?
    
    var status: Status
    let value: Double
    var isPaid: Bool? = false
    
    // Enum for the lifecycle of a chore
    enum Status: String, Codable {
        case assigned = "Assigned"
        case completed = "Completed"
        case approved = "Approved"
        case rejected = "Rejected"
    }
}
