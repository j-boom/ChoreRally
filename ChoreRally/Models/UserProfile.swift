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
import FirebaseFirestore // Required for @DocumentID

struct UserProfile: Identifiable, Codable {
    
    // This property wrapper maps the Firestore document ID to this property.
    @DocumentID var id: String?
    
    let name: String
    let avatarSymbolName: String
    let isParent: Bool
    
    // We can add the PIN property here later when we build that feature.
    // let pin: String?
}
