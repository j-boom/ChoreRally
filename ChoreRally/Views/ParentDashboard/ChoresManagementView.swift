//
//  ChoresManagementView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This view is the main screen for the "Chores" tab. It displays the
//  master list of chores or triggers the initial chore setup flow.
//

import SwiftUI

struct ChoresManagementView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: ChoresManagementViewModel
    
    // We need the familyID to pass to the setup view.
    private let familyID: String
    
    init(familyID: String) {
        self.familyID = familyID
        _viewModel = StateObject(wrappedValue: ChoresManagementViewModel(familyID: familyID))
    }
    
    // MARK: - Body
    
    var body: some View {
        // --- The NavigationView has been removed from this view ---
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if !viewModel.chores.isEmpty {
                // If chores exist, show the list
                List {
                    ForEach(viewModel.chores) { chore in
                        // Wrap the row in a NavigationLink to enable editing
                        NavigationLink(destination: EditChoreView(chore: chore, familyID: familyID)) {
                            ChoreRowView(chore: chore)
                        }
                    }
                    // The swipe-to-delete modifier is attached to the ForEach
                    .onDelete(perform: viewModel.deleteChore)
                }
            } else {
                // If no chores exist, show a helpful message
                Text("No chores found. Tap the '+' to add your first chore.")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Manage Chores")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.shouldShowAddChoreSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        // This sheet now presents the AddChoreView
        .sheet(isPresented: $viewModel.shouldShowAddChoreSheet) {
            AddChoreView(familyID: familyID)
        }
        // This sheet is triggered automatically on the first visit
        .sheet(isPresented: $viewModel.shouldShowInitialSetup) {
            ChoreSetupView(familyID: familyID)
        }
    }
}
