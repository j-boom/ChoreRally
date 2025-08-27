//
//  UserProfile.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This file defines the data model for a user profile.
//  It conforms to Codable to allow for easy conversion to/from Firestore.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    
    var name: String
    var avatarSymbolName: String
    var isParent: Bool
    var pin: String? // New property for the parent's PIN
    
    // --- Child-specific properties ---
    var age: Int?
    var rate: Double?
    
    // --- Renamed for clarity: This is the list of chores a child is able to do. ---
    var capableChoreIDs: [String]?
}
