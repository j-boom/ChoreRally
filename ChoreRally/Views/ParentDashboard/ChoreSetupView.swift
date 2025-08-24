//
//  ChoreSetupView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This view is presented once to help parents quickly set up an initial
//  list of chores from a set of templates.
//

import SwiftUI

struct ChoreSetupView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: ChoreSetupViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(familyID: String) {
        _viewModel = StateObject(wrappedValue: ChoreSetupViewModel(familyID: familyID))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Select chores to add to your family's list. You can always edit or add more later.")
                    .padding()
                    .multilineTextAlignment(.center)
                
                List {
                    ForEach(viewModel.choreCategories, id: \.self) { category in
                        Section(header: Text(category.rawValue)) {
                            // --- FIX: Use the chore's ID for identification ---
                            ForEach(viewModel.templatesByCategory[category] ?? []) { chore in
                                ChoreSelectionRow(chore: chore, isSelected: viewModel.selectedChores.contains(chore)) {
                                    viewModel.toggleChoreSelection(chore)
                                }
                            }
                        }
                    }
                }
                
                Button(action: {
                    viewModel.saveSelectedChores()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Add \(viewModel.selectedChores.count) Chores")
                            .fontWeight(.bold)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
            }
            .navigationTitle("Chore Setup")
            .onChange(of: viewModel.isSetupComplete) { complete in
                if complete {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

// MARK: - Reusable Row Component

struct ChoreSelectionRow: View {
    let chore: Chore
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .secondary)
                VStack(alignment: .leading) {
                    Text(chore.name)
                        .font(.headline)
                    Text(chore.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
        }
    }
}
