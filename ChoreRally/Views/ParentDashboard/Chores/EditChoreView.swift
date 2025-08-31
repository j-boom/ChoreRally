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
        // This VStack contains the form and the save button, ensuring the button
        // stays at the bottom of the modal sheet.
        VStack {
            // A simple text title is used since there is no navigation bar.
            Text("Edit Chore")
                .font(.headline)
                .padding()

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
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            
            // This button is now outside the Form, at the bottom of the VStack.
            Button(action: {
                viewModel.updateChore()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Save Changes")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        // The navigation and toolbar modifiers have been removed.
        .onChange(of: viewModel.isSaveSuccessful) { successful in
            if successful {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

