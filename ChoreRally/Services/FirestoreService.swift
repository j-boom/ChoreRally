//
//  FirestoreService.swift
//  ChoreRally
//
//  Created by Gemini on 2025-08-27.
//
//  This service provides a centralized place for all Firestore database interactions.
//

import Foundation
import FirebaseFirestore
import Combine

// A tuple to hold the combined results from our database queries.
typealias FamilyData = (assignments: [ChoreAssignment], chores: [Chore], profiles: [UserProfile])
typealias LedgerData = (assignments: [ChoreAssignment], chores: [Chore], payments: [Payment])

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
    
    /// Deletes a specific chore document from a family's collection.
        static func deleteChore(_ choreID: String, in familyID: String) -> AnyPublisher<Void, Error> {
            let db = Firestore.firestore()
            let docRef = db.collection("families").document(familyID).collection("chores").document(choreID)
            
            return Future<Void, Error> { promise in
                docRef.delete { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
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
    
    /// Fetches all data needed for the child's ledger view.
    static func fetchDataForLedger(familyID: String) -> AnyPublisher<LedgerData, Error> {
        let db = Firestore.firestore()
        let familyRef = db.collection("families").document(familyID)
        
        let assignmentsPublisher = familyRef.collection("assignments").snapshotPublisher(as: ChoreAssignment.self)
        let choresPublisher = familyRef.collection("chores").snapshotPublisher(as: Chore.self)
        let paymentsPublisher = familyRef.collection("payments").snapshotPublisher(as: Payment.self)
        
        return Publishers.CombineLatest3(assignmentsPublisher, choresPublisher, paymentsPublisher)
            .map { (assignments, chores, payments) in
                return LedgerData(assignments: assignments, chores: chores, payments: payments)
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
    
    /// Fetches the global list of chore templates.
    static func fetchChoreTemplates() -> AnyPublisher<[Chore], Error> {
        let db = Firestore.firestore()
        return db.collection("choreTemplates").snapshotPublisher(as: Chore.self)
    }
    
    /// Updates the status of a specific chore assignment.
    static func updateAssignmentStatus(assignmentID: String, newStatus: ChoreAssignment.Status, in familyID: String) -> AnyPublisher<Void, Error> {
        let db = Firestore.firestore()
        let docRef = db.collection("families").document(familyID).collection("assignments").document(assignmentID)
        
        return Future<Void, Error> { promise in
            docRef.updateData(["status": newStatus.rawValue]) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    /// Creates multiple new chore assignments in a single batch operation.
    static func createAssignments(_ assignments: [ChoreAssignment], in familyID: String) -> AnyPublisher<Void, Error> {
        let db = Firestore.firestore()
        let batch = db.batch()
        let assignmentsCollection = db.collection("families").document(familyID).collection("assignments")
        
        return Future<Void, Error> { promise in
            for assignment in assignments {
                let docRef = assignmentsCollection.document() // Create a new document with a unique ID
                do {
                    try batch.setData(from: assignment, forDocument: docRef)
                } catch {
                    promise(.failure(error))
                    return
                }
            }
            
            batch.commit { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}

// Helper to convert a Firestore query into a Combine publisher.
extension Query {
    func snapshotPublisher<T: Decodable>(as type: T.Type) -> AnyPublisher<[T], Error> {
        let subject = PassthroughSubject<[T], Error>()
        
        let listener = self.addSnapshotListener { querySnapshot, error in
            if let error = error {
                subject.send(completion: .failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                subject.send([])
                return
            }
            
            let data = documents.compactMap { try? $0.data(as: T.self) }
            subject.send(data)
        }
        
        return subject.handleEvents(receiveCancel: {
            listener.remove()
        }).eraseToAnyPublisher()
    }
}
