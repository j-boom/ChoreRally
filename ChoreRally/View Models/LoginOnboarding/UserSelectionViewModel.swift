//
//  UserSelectionViewModel.swift
//  ChoreRally
//
//  This ViewModel now uses the FirestoreService for all data fetching.
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
    
    // --- BUG FIX ---
    // This property was missing, causing the build to fail.
    @Published var selectedChildProfile: UserProfile?
    
    var familyID: String?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchInitialData()
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

    func fetchInitialData() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            errorMessage = "Error: Not logged in."
            isLoading = false
            return
        }
        
        isLoading = true
        FirestoreService.fetchFamilyID(for: currentUserID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Error fetching user data: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] familyID in
                if let familyID = familyID {
                    self?.familyID = familyID
                    self?.listenForProfileChanges(familyID: familyID)
                } else {
                    self?.shouldShowOnboarding = true
                }
            })
            .store(in: &cancellables)
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
