//
//  UserSelectionViewModel.swift
//  ChoreRally
//
//  This ViewModel now uses the FirestoreService.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class UserSelectionViewModel: ObservableObject {
    
    @Published var parentProfiles: [UserProfile] = []
    @Published var childProfiles: [UserProfile] = []
    @Published var errorMessage: String?
    @Published var shouldShowOnboarding = false
    @Published var isLoading = true
    @Published var navigationSelection: String?
    @Published var profileForPinEntry: UserProfile?
    @Published var pinErrorMessage: String?
    
    var familyID: String?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchProfiles()
    }
    
    func logout() {
        try? Auth.auth().signOut()
    }

    func verifyPin(enteredPin: String) {
        guard let profile = profileForPinEntry else { return }
        
        if profile.pin == enteredPin {
            pinErrorMessage = nil
            profileForPinEntry = nil
            navigationSelection = profile.id
        } else {
            pinErrorMessage = "Incorrect PIN. Please try again."
        }
    }

    func fetchProfiles() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            errorMessage = "Error: Not logged in."
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUserID).getDocument { [weak self] (document, error) in
            defer { self?.isLoading = false }
            
            if let familyID = try? document?.data(as: UserModel.self).familyID {
                self?.familyID = familyID
                self?.listenForProfileChanges(familyID: familyID)
            } else {
                self?.shouldShowOnboarding = true
            }
        }
    }

    func listenForProfileChanges(familyID: String) {
        FirestoreService.fetchProfiles(familyID: familyID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "Error fetching profiles: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] profiles in
                self?.parentProfiles = profiles.filter { $0.isParent }
                self?.childProfiles = profiles.filter { !$0.isParent }
            })
            .store(in: &cancellables)
    }
}
