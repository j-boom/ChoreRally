//
//  EditChoreAssignmentView.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/27/25.
//


//
//  EditChoreAssignmentView.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This view allows a parent to edit the details of an assigned chore.
//

import SwiftUI

struct EditChoreAssignmentView: View {
    
    @StateObject private var viewModel: EditChoreAssignmentViewModel
    @Environment(\.presentationMode) var presentationMode
    
    private let details: ChoreAssignmentDetails
    
    init(details: ChoreAssignmentDetails, familyID: String) {
        self.details = details
        _viewModel = StateObject(wrappedValue: EditChoreAssignmentViewModel(details: details, familyID: familyID))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Chore Details")) {
                Text(details.chore.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Assigned to: \(details.child.name)")
            }
            
            Section(header: Text("Edit Due Date")) {
                DatePicker("Due Date", selection: $viewModel.dueDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
            
            Section {
                Button("Save Changes") {
                    viewModel.saveChanges()
                }
                .frame(maxWidth: .infinity)
            }
            
            Section {
                Button("Unassign Chore", role: .destructive) {
                    viewModel.showingDeleteConfirm = true
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Edit Assignment")
        .onChange(of: viewModel.isSaveSuccessful) {
            if viewModel.isSaveSuccessful {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .alert("Are you sure?", isPresented: $viewModel.showingDeleteConfirm) {
            Button("Unassign", role: .destructive) { viewModel.unassignChore() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the chore from \(details.child.name)'s list. This cannot be undone.")
        }
    }
}
