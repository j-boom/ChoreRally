//
//  ChoresManagementView.swift
//  ChoreRally
//
//  Created by Anoop on 2023-12-24.
//
//  This view has been updated to properly initialize its ViewModel.
//

import SwiftUI

struct ChoresManagementView: View {
    
    @StateObject private var viewModel: ChoresManagementViewModel
    
    init(familyID: String) {
        _viewModel = StateObject(wrappedValue: ChoresManagementViewModel(familyID: familyID))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Chores...")
                } else {
                    ChoreListView(
                        chores: viewModel.chores,
                        actionType: .button(title: "Edit", action: { chore in
                            viewModel.selectedChoreForEditing = chore
                        }),
                        onDelete: viewModel.deleteChore,
                        rowContent: { chore in
                            ChoreRowView(chore: chore)
                        }
                    )
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
            .sheet(isPresented: $viewModel.shouldShowAddChoreSheet) {
                AddChoreView(familyID: viewModel.familyID)
            }
            .sheet(item: $viewModel.selectedChoreForEditing) { chore in
                // The NavigationView wrapper has been removed to create a true modal presentation.
                EditChoreView(chore: chore, familyID: viewModel.familyID)
            }
        }
    }
}

