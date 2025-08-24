//
//  AddChoreView.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/24/25.
//


//
//  AddChoreView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This view provides a form for creating a new custom chore.
//

import SwiftUI

struct AddChoreView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: AddChoreViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(familyID: String) {
        _viewModel = StateObject(wrappedValue: AddChoreViewModel(familyID: familyID))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
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
                        viewModel.saveChore()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Save Chore")
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
            .navigationTitle("Add Custom Chore")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onChange(of: viewModel.isSaveSuccessful) { successful in
                if successful {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
