//
//  Payment.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/28/25.
//


//
//  Payment.swift
//  ChoreRally
//
//  Created by Gemini on 2025-08-28.
//
//  This model represents a single payment event made to a child.
//

import Foundation
import FirebaseFirestore

struct Payment: Identifiable, Codable {
    @DocumentID var id: String?
    
    let childProfileID: String
    let amount: Double
    let paymentDate: Timestamp
    
    // An array of ChoreAssignment IDs included in this payment.
    let includedAssignmentIDs: [String]
}
