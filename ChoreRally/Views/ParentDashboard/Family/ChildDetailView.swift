//
//  ChildDetailView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This view allows a parent to edit a child's profile and assign chores.
//

import SwiftUI

struct ChildDetailView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: ChildDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(childProfile: UserProfile, familyID: String) {
        _viewModel = StateObject(wrappedValue: ChildDetailViewModel(childProfile: childProfile, familyID: familyID))
    }
    
    // MARK: - Body
    
    var body: some View {
        Form {
            // --- Profile Details Section ---
            Section(header: Text("Profile Details")) {
                TextField("Name", text: $viewModel.name)
                Stepper("Age: \(viewModel.age)", value: $viewModel.age, in: 3...18)
                HStack {
                    Text("Rate ($/hr)")
                    Spacer()
                    TextField("Rate", value: $viewModel.rate, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            // --- Assign Chores Section ---
            Section(header: Text("Capable Chores")) {
                // We use a multi-selector list to assign chores.
                List(viewModel.allChores) { chore in
                    Button(action: {
                        viewModel.toggleChoreAssignment(chore)
                    }) {
                        HStack {
                            Text(chore.name)
                            Spacer()
                            if viewModel.capableChoreIDs.contains(chore.id ?? "") {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle(viewModel.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    viewModel.saveChanges()
                }
            }
        }
        .onReceive(viewModel.$isSaveSuccessful) { successful in
            if successful {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
