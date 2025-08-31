//
//  ChoresManagementViewModel.swift
//  ChoreRally
//
//  Created by Anoop on 2023-12-24.
//
//  This ViewModel has been updated to correctly handle loading states.
//

import Foundation
import Combine
import FirebaseFirestore

class ChoresManagementViewModel: ObservableObject {
    
    @Published var chores: [Chore] = []
    @Published var isLoading = true
    @Published var shouldShowAddChoreSheet = false
    @Published var selectedChoreForEditing: Chore?
    
    let familyID: String
    private var cancellables = Set<AnyCancellable>()
    
    init(familyID: String) {
        self.familyID = familyID
        fetchData()
    }
    
    func deleteChore(_ chore: Chore) {
        guard let choreID = chore.id else { return }
        
        FirestoreService.deleteChore(choreID, in: familyID)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error deleting chore: \(error.localizedDescription)")
                }
            }, receiveValue: {
                print("Chore deleted successfully.")
            })
            .store(in: &cancellables)
    }
    
    private func fetchData() {
        isLoading = true
        FirestoreService.fetchChores(familyID: familyID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Error fetching chores: \(error.localizedDescription)")
                    // Also set loading to false in case of an error.
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] chores in
                // --- THIS IS THE FIX ---
                // The loading state is now correctly updated as soon as the
                // first value is received from the data stream.
                self?.chores = chores
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
}

