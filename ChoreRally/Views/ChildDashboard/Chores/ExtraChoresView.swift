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
                    List {
                        ForEach(viewModel.availableChores) { chore in
                            ExtraChoreRow(chore: chore, isSelected: viewModel.selectedChores.contains(chore.id ?? "")) {
                                toggleSelection(for: chore)
                            }
                        }
                    }
                    
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

// A reusable row for the extra chores list.
struct ExtraChoreRow: View {
    let chore: Chore
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(chore.name)
                        .font(.headline)
                    Text(chore.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .secondary)
                    .font(.title2)
            }
            .contentShape(Rectangle()) // Makes the whole row tappable
        }
        .buttonStyle(PlainButtonStyle())
    }
}
