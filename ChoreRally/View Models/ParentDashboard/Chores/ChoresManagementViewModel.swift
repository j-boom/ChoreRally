//
//  ChoresManagementViewModel.swift
//  ChoreRally
//
//  This ViewModel now uses the FirestoreService.
//

import Foundation
import FirebaseFirestore
import Combine

class ChoresManagementViewModel: ObservableObject {

    @Published var choresByCategory: [Chore.ChoreCategory: [Chore]] = [:]
    @Published var choreCategories: [Chore.ChoreCategory] = []
    @Published var isLoading = true
    @Published var shouldShowInitialSetup = false
    @Published var shouldShowAddChoreSheet = false
    @Published var selectedChoreForEditing: Chore?
    
    private let familyID: String
    private var cancellables = Set<AnyCancellable>()

    init(familyID: String) {
        self.familyID = familyID
        fetchChores()
    }

    func fetchChores() {
        isLoading = true
        FirestoreService.fetchChores(familyID: familyID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching chores: \(error)")
                }
            }, receiveValue: { [weak self] chores in
                self?.groupAndSortChores(chores)
                if chores.isEmpty {
                    self?.shouldShowInitialSetup = true
                }
            })
            .store(in: &cancellables)
    }
    
    func deleteChore(in category: Chore.ChoreCategory, at offsets: IndexSet) {
        guard let choresInCategory = choresByCategory[category] else { return }
        let choresToDelete = offsets.map { choresInCategory[$0] }
        let db = Firestore.firestore()
        
        for chore in choresToDelete {
            if let choreID = chore.id {
                db.collection("families").document(familyID).collection("chores").document(choreID).delete()
            }
        }
    }

    private func groupAndSortChores(_ chores: [Chore]) {
        choresByCategory = Dictionary(grouping: chores, by: { $0.category })
        choreCategories = choresByCategory.keys.sorted { $0.rawValue < $1.rawValue }
    }
}
