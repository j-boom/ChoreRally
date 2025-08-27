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
    
    enum Status: String, Codable {
        case assigned = "Assigned"
        case completed = "Completed"
        case approved = "Approved"
        case rejected = "Rejected"
    }
}

// This custom struct is now globally accessible to any file that imports the models.
struct ChoreAssignmentDetails: Identifiable, Hashable {
    static func == (lhs: ChoreAssignmentDetails, rhs: ChoreAssignmentDetails) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String { assignment.id ?? UUID().uuidString }
    let assignment: ChoreAssignment
    let chore: Chore
    let child: UserProfile
}
