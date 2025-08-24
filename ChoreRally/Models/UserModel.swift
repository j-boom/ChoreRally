//
//  UserModel.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This model represents a registered user with a login. It links their
//  Firebase Auth UID to a specific family ID in Firestore.
//

import Foundation
import FirebaseFirestore

struct UserModel: Identifiable, Codable {
    // The ID for this document will be the user's FirebaseAuth UID.
    @DocumentID var id: String?
    
    // This is the ID of the family document this user belongs to.
    let familyID: String
    
    // We can store the user's email for reference.
    let email: String
}
