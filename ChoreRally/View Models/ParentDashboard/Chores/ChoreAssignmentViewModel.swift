//
//  ChoreAssignmentViewModel.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This ViewModel powers the main Chore Assignment view.
//

import Foundation
import FirebaseFirestore
import Combine

class ChoreAssignmentViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var childProfiles: [UserProfile] = []
    @Published var chores: [Chore] = []
    @Published var assignments: [ChoreAssignment] = []
    
    // This will be used to trigger the modal sheet.
    @Published var selectedChildForAssignment: UserProfile?
    
    private let familyID: String
    private var cancellables = Set<AnyCancellable>()
    
    init(familyID: String) {
        self.familyID = familyID
        fetchData()
    }
    
    private func fetchData() {
        fetchChildren()
        // We can add functions to fetch chores and assignments here later
    }
    
    private func fetchChildren() {
        let db = Firestore.firestore()
        db.collection("families").document(familyID).collection("profiles")
            .whereField("isParent", isEqualTo: false)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No child profiles found")
                    return
                }
                
                let profiles = documents.compactMap { try? $0.data(as: UserProfile.self) }
                
                // Sort the children by age, oldest first.
                self?.childProfiles = profiles.sorted {
                    ($0.age ?? 0) > ($1.age ?? 0)
                }
            }
    }
}
