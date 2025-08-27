//
//  FamilyManagementViewModel.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This ViewModel fetches and manages the user profiles for the family tab.
//

import Foundation
import FirebaseFirestore
import Combine

class FamilyManagementViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var parentProfiles: [UserProfile] = []
    @Published var childProfiles: [UserProfile] = []
    @Published var shouldShowAddUserSheet = false
    
    // This property will hold the child profile when a row is tapped, triggering the sheet.
    @Published var selectedChildForEditing: UserProfile?
    
    private let familyID: String
    private var listenerRegistration: ListenerRegistration?
    
    init(familyID: String) {
        self.familyID = familyID
        fetchProfiles()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    // MARK: - Public Methods
    
    /// Deletes a child's profile from Firestore.
    func deleteChild(at offsets: IndexSet) {
        let profilesToDelete = offsets.map { self.childProfiles[$0] }
        let db = Firestore.firestore()
        
        for profile in profilesToDelete {
            if let profileID = profile.id {
                db.collection("families").document(familyID).collection("profiles").document(profileID).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
            }
        }
    }
    
    func fetchProfiles() {
        let db = Firestore.firestore()
        let profilesCollection = db.collection("families").document(familyID).collection("profiles")
        
        listenerRegistration = profilesCollection.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents in 'profiles' collection")
                return
            }
            
            let allProfiles = documents.compactMap { queryDocumentSnapshot -> UserProfile? in
                return try? queryDocumentSnapshot.data(as: UserProfile.self)
            }
            
            self?.parentProfiles = allProfiles.filter { $0.isParent }
            
            // Filter and sort the child profiles by age, oldest first.
            self?.childProfiles = allProfiles.filter { !$0.isParent }.sorted {
                // Use 0 as a default age for sorting if it's not set.
                ($0.age ?? 0) > ($1.age ?? 0)
            }
        }
    }
}
