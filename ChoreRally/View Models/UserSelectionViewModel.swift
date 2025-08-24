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
    
    // --- Add new property to control onboarding ---
    @Published var shouldShowOnboarding = false
    
    // --- Add new property to handle initial loading state ---
    @Published var isLoading = true
    
    // This will be used to store a reference to our Firestore listener.
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        fetchProfiles()
    }
    
    deinit {
        // It's crucial to remove the listener when the ViewModel is deallocated
        // to prevent memory leaks.
        listenerRegistration?.remove()
    }
    
    // MARK: - Public Methods
    
    func fetchProfiles() {
        // --- This method has been refactored for the new architecture ---
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            errorMessage = "Error: Not logged in."
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        
        // STEP 1: Find the user's familyID from the 'users' collection.
        db.collection("users").document(currentUserID).getDocument { [weak self] (document, error) in
            // --- Make sure to stop loading once the check is complete ---
            defer { self?.isLoading = false }
            
            if let error = error {
                self?.errorMessage = "Error fetching user data: \(error.localizedDescription)"
                return
            }
            
            // --- Check if a family document exists for the user ---
            if let familyID = try? document?.data(as: UserModel.self).familyID {
                // If a familyID exists, listen for profile updates.
                self?.listenForProfileChanges(familyID: familyID, db: db)
            } else {
                // --- If no familyID is found, trigger the onboarding flow ---
                print("No family found for this user. Triggering onboarding.")
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
    
    func profileTapped(profile: UserProfile) {
        // Here we will add the navigation logic based on which profile was tapped.
        print("\(profile.name) was tapped. ID: \(profile.id ?? "N/A")")
        
        if profile.isParent {
            // Navigate to parent PIN entry / dashboard
        } else {
            // Navigate to child PIN entry / dashboard
        }
    }
    
    func addUserTapped() {
        // Navigate to the "Add User" screen.
        print("Add User was tapped.")
    }
}
