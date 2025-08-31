//
//  ExtraChoresView.swift
//  ChoreRally
//
//  Created by Gemini on 2025-08-28.
//
//  This view displays a list of available chores for a child to take on.
//

import SwiftUI

struct ExtraChoresView: View {
    
    @StateObject private var viewModel: ExtraChoresViewModel
    
    init(childProfile: UserProfile, familyID: String) {
        _viewModel = StateObject(wrappedValue: ExtraChoresViewModel(childProfile: childProfile, familyID: familyID))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.canTakeExtraChores {
                    // Message shown if assigned chores are not complete.
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Complete your assigned chores first!")
                            .font(.headline)
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    // The list of available chores.
                    ChoreListView(
                        chores: viewModel.availableChores,
                        actionType: .checkmark(
                            isSelected: { chore in
                                viewModel.selectedChores.contains(chore.id ?? "")
                            },
                            action: { chore in
                                toggleSelection(for: chore)
                            }
                        ),
                        onDelete: nil,
                        rowContent: { chore in
                            ChoreRowView(chore: chore)
                        }
                    )
                    
                    // The submit button, only enabled if chores are selected.
                    Button("Submit Completed Chores") {
                        viewModel.submitCompletedChores()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .disabled(viewModel.selectedChores.isEmpty)
                }
            }
            .navigationTitle("Extra Chores")
        }
    }
    
    private func toggleSelection(for chore: Chore) {
        guard let choreID = chore.id else { return }
        if viewModel.selectedChores.contains(choreID) {
            viewModel.selectedChores.remove(choreID)
        } else {
            viewModel.selectedChores.insert(choreID)
        }
    }
}
