//
//  FirestoreService.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This service provides a centralized place for all Firestore database interactions.
//

import Foundation
import FirebaseFirestore
import Combine

// A tuple to hold the combined results from our database queries.
typealias FamilyData = (assignments: [ChoreAssignment], chores: [Chore], profiles: [UserProfile])

class FirestoreService {
    
    /// Fetches the familyID for the currently authenticated user.
    static func fetchFamilyID(for userID: String) -> AnyPublisher<String?, Error> {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userID)
        
        return Future<String?, Error> { promise in
            docRef.getDocument { (document, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    let familyID = try? document?.data(as: UserModel.self).familyID
                    promise(.success(familyID))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    /// Fetches all primary collections for a family and combines them.
    static func fetchAndCombineData(familyID: String) -> AnyPublisher<FamilyData, Error> {
        let db = Firestore.firestore()
        let familyRef = db.collection("families").document(familyID)
        
        let assignmentsPublisher = familyRef.collection("assignments").snapshotPublisher(as: ChoreAssignment.self)
        let choresPublisher = familyRef.collection("chores").snapshotPublisher(as: Chore.self)
        let profilesPublisher = familyRef.collection("profiles").snapshotPublisher(as: UserProfile.self)
        
        return Publishers.CombineLatest3(assignmentsPublisher, choresPublisher, profilesPublisher)
            .map { (assignments, chores, profiles) in
                return FamilyData(assignments: assignments, chores: chores, profiles: profiles)
            }
            .eraseToAnyPublisher()
    }
    
    /// Fetches only the chores for a given family.
    static func fetchChores(familyID: String) -> AnyPublisher<[Chore], Error> {
        let db = Firestore.firestore()
        return db.collection("families").document(familyID).collection("chores").snapshotPublisher(as: Chore.self)
    }
    
    /// Fetches only the user profiles for a given family.
    static func fetchProfiles(familyID: String) -> AnyPublisher<[UserProfile], Error> {
        let db = Firestore.firestore()
        return db.collection("families").document(familyID).collection("profiles").snapshotPublisher(as: UserProfile.self)
    }
}

// Helper to convert a Firestore query into a Combine publisher.
extension Query {
    func snapshotPublisher<T: Decodable>(as type: T.Type) -> AnyPublisher<[T], Error> {
        Future<[T], Error> { promise in
            self.addSnapshotListener { querySnapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else if let documents = querySnapshot?.documents {
                    let data = documents.compactMap { try? $0.data(as: T.self) }
                    promise(.success(data))
                }
            }
        }.eraseToAnyPublisher()
    }
}
