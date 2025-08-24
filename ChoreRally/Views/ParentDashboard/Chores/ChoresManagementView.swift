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
        // --- The NavigationView is needed here because this view is inside a TabView ---
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if !viewModel.chores.isEmpty {
                    // If chores exist, show the list
                    List {
                        // --- The list is now sectioned by category ---
                        ForEach(viewModel.choreCategories, id: \.self) { category in
                            Section(header: Text(category.rawValue)) {
                                ForEach(viewModel.choresByCategory[category] ?? []) { chore in
                                    ChoreRowView(chore: chore)
                                        .onTapGesture {
                                            // Tapping a row now sets the chore to be edited
                                            viewModel.selectedChoreForEditing = chore
                                        }
                                }
                                .onDelete { indexSet in
                                    viewModel.deleteChore(in: category, at: indexSet)
                                }
                            }
                        }
                    }
                } else {
                    // If no chores exist, show a helpful message
                    Text("No chores found. Tap the '+' to add your first chore.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
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
            // --- This sheet presents the EditChoreView as a modal ---
            .sheet(item: $viewModel.selectedChoreForEditing) { chore in
                EditChoreView(chore: chore, familyID: familyID)
            }
        }
    }
}
