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

class ChoresManagementViewModel: ObservableObject {
    
    @Published var chores: [Chore] = []
    @Published var isLoading = true
    
    private let familyID: String
    private var cancellables = Set<AnyCancellable>()
    
    init(familyID: String) {
        self.familyID = familyID
        fetchData()
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
