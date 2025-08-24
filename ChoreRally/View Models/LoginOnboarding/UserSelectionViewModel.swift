//
//  UserSelectionViewModel.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This ViewModel is responsible for fetching user profiles from Firestore
//  and handling navigation logic from the UserSelectionView.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class UserSelectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var parentProfiles: [UserProfile] = []
    @Published var childProfiles: [UserProfile] = []
    @Published var errorMessage: String?
    
    @Published var shouldShowOnboarding = false
    
    // --- This property now drives the navigation ---
    @Published var navigationSelection: String?
    
    @Published var isLoading = true
    
    var familyID: String?
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        fetchProfiles()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    // MARK: - Public Methods
    
    func fetchProfiles() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            errorMessage = "Error: Not logged in."
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUserID).getDocument { [weak self] (document, error) in
            defer { self?.isLoading = false }
            
            if let error = error {
                self?.errorMessage = "Error fetching user data: \(error.localizedDescription)"
                return
            }
            
            if let familyID = try? document?.data(as: UserModel.self).familyID {
                self?.familyID = familyID
                self?.listenForProfileChanges(familyID: familyID, db: db)
            } else {
                self?.shouldShowOnboarding = true
            }
        }
    }
    
    private func listenForProfileChanges(familyID: String, db: Firestore) {
        let profilesCollection = db.collection("families").document(familyID).collection("profiles")
        
        self.listenerRegistration = profilesCollection.addSnapshotListener { [weak self] (querySnapshot, error) in
            if let error = error {
                self?.errorMessage = "Error fetching profiles: \(error.localizedDescription)"
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                self?.errorMessage = "No profiles found."
                return
            }
            
            let allProfiles = documents.compactMap { document -> UserProfile? in
                try? document.data(as: UserProfile.self)
            }
            
            self?.parentProfiles = allProfiles.filter { $0.isParent }
            self?.childProfiles = allProfiles.filter { !$0.isParent }
        }
    }
    
    // The profileTapped function is no longer needed for parent navigation
    // as the NavigationLink handles it directly.
}
