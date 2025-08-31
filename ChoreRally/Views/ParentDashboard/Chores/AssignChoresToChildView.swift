//
//  AssignChoresToChildView.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/26/25.
//


import SwiftUI

struct AssignChoresToChildView: View {
    
    @StateObject private var viewModel: AssignChoresToChildViewModel
    private let childProfile: UserProfile
    
    init(childProfile: UserProfile, familyID: String) {
        self.childProfile = childProfile
        _viewModel = StateObject(wrappedValue: AssignChoresToChildViewModel(childProfile: childProfile, familyID: familyID))
    }
    
    var body: some View {
        VStack {
            if viewModel.capableChores.isEmpty {
                Text("\(childProfile.name) hasn't been approved for any chores yet. You can assign capable chores from the 'Family' tab.")
                    .foregroundColor(.secondary)
                    .padding()
                Spacer()
            } else {
                ChoreListView(
                    chores: viewModel.capableChores,
                    actionType: .button(title: "Assign", action: { chore in
                        viewModel.selectChoreForAssignment(chore)
                    }),
                    onDelete: nil,
                    rowContent: { chore in
                        ChoreRowView(chore: chore)
                    }
                )
            }
        }
        .navigationTitle("Assign to \(childProfile.name)")
        .sheet(item: $viewModel.choreToAssign) { chore in
            // Using a helper view to prevent other potential compiler issues.
            AssignmentSheetView(viewModel: viewModel, chore: chore)
        }
    }
}

// MARK: - Helper Views

private struct AssignmentSheetView: View {
    @ObservedObject var viewModel: AssignChoresToChildViewModel
    let chore: Chore

    var body: some View {
        VStack {
            Text("Assign \"\(chore.name)\"")
                .font(.headline)
                .padding()
            
            Form {
                DatePicker("Due Date", selection: $viewModel.dueDate, in: Date()..., displayedComponents: .date)
                
                if chore.isTimeBased ?? false {
                     HStack {
                         Text("Hourly Rate")
                         Spacer()
                         TextField("Rate", value: $viewModel.hourlyRate, format: .currency(code: "USD"))
                             .keyboardType(.decimalPad)
                             .multilineTextAlignment(.trailing)
                     }
                } else {
                    HStack {
                        Text("Value")
                        Spacer()
                        TextField("Value", value: $viewModel.assignmentValue, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            
            Button("Confirm Assignment") {
                viewModel.assignChore()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}
