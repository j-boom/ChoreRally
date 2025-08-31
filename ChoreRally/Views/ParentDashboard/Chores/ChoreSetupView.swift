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
                
                ChoreListView(
                    chores: viewModel.choreTemplates,
                    actionType: .checkmark(
                        isSelected: { chore in
                            viewModel.selectedChores.contains(where: { $0.id == chore.id })
                        },
                        action: { chore in
                            viewModel.toggleChoreSelection(chore)
                        }
                    ),
                    onDelete: nil,
                    rowContent: { chore in
                        ChoreRowView(chore: chore)
                    }
                )
                
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

