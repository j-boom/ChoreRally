//
//  FamilyManagementViewModel.swift
//  ChoreRally
//
//  This ViewModel now uses the FirestoreService.
//

import Foundation
import FirebaseFirestore
import Combine

class FamilyManagementViewModel: ObservableObject {

    @Published var parentProfiles: [UserProfile] = []
    @Published var childProfiles: [UserProfile] = []
    @Published var shouldShowAddUserSheet = false
    @Published var selectedChildForEditing: UserProfile?

    private let familyID: String
    private var cancellables = Set<AnyCancellable>()

    init(familyID: String) {
        self.familyID = familyID
        fetchProfiles()
    }

    func fetchProfiles() {
        FirestoreService.fetchProfiles(familyID: familyID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { error in
                // Handle error if needed
            }, receiveValue: { [weak self] profiles in
                self?.parentProfiles = profiles.filter { $0.isParent }
                self?.childProfiles = profiles.filter { !$0.isParent }.sorted { ($0.age ?? 0) > ($1.age ?? 0) }
            })
            .store(in: &cancellables)
    }
    
    func deleteChild(at offsets: IndexSet) {
        let profilesToDelete = offsets.map { self.childProfiles[$0] }
        let db = Firestore.firestore()
        
        for profile in profilesToDelete {
            if let profileID = profile.id {
                db.collection("families").document(familyID).collection("profiles").document(profileID).delete()
            }
        }
    }
}
