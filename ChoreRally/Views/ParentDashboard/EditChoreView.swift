//
//  EditChoreView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This view provides a form for editing an existing chore.
//

import SwiftUI

struct EditChoreView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: EditChoreViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // The view is initialized with the chore to be edited and the familyID.
    init(chore: Chore, familyID: String) {
        _viewModel = StateObject(wrappedValue: EditChoreViewModel(chore: chore, familyID: familyID))
    }
    
    // MARK: - Body
    
    var body: some View {
        // --- The NavigationView has been removed from this view ---
        Form {
            Section(header: Text("Chore Details")) {
                TextField("Chore Name", text: $viewModel.name)
                TextField("Description", text: $viewModel.description)
            }
            
            Section(header: Text("Settings")) {
                Picker("Category", selection: $viewModel.category) {
                    ForEach(Chore.ChoreCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                
                Picker("Difficulty", selection: $viewModel.difficulty) {
                    ForEach(Chore.Difficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.rawValue).tag(difficulty)
                    }
                }
                
                Stepper("Estimated Time: \(viewModel.estimatedTime) minutes", value: $viewModel.estimatedTime, in: 5...120, step: 5)
            }
            
            Section {
                Button(action: {
                    viewModel.updateChore()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Save Changes")
                    }
                }
            }
            
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Edit Chore")
        // The toolbar with the "Cancel" button has been removed.
        .onChange(of: viewModel.isSaveSuccessful) { successful in
            if successful {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
