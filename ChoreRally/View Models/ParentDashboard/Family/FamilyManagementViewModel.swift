//
//  FamilyManagementViewModel.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/24/25.
//


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
            self?.childProfiles = allProfiles.filter { !$0.isParent }
        }
    }
}
