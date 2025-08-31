//
//  ParentHomeView.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This is the main dashboard view for parents.
//

import SwiftUI

struct ParentHomeView: View {
    
    @StateObject private var viewModel: ParentHomeViewModel
    private let familyID: String
    
    init(familyID: String) {
        self.familyID = familyID
        _viewModel = StateObject(wrappedValue: ParentHomeViewModel(familyID: familyID))
    }
    
    var body: some View {
        NavigationView {
            List {
                // --- Overdue Section ---
                Section(header: Text("Overdue")) {
                    if $viewModel.overdueChores.isEmpty {
                        Text("No chores are overdue.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.overdueChores) { details in
                            UpcomingChoreRowView(details: details)
                                .listRowBackground(Color.red.opacity(0.2))
                                .onTapGesture {
                                    viewModel.assignmentToEdit = details
                                }
                        }
                    }
                }
                
                // --- Pending Approval Section ---
                Section(header: Text("Pending Approval")) {
                    if viewModel.pendingApprovals.isEmpty {
                        Text("No chores are waiting for approval.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.pendingApprovals) { details in
                            ApprovalRowView(details: details, viewModel: viewModel)
                        }
                    }
                }
                
                // --- Due Today Section ---
                Section(header: Text("Due Today")) {
                    if viewModel.todaysChores.isEmpty {
                        Text("No chores are due today.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.todaysChores) { details in
                            UpcomingChoreRowView(details: details)
                                .onTapGesture {
                                    viewModel.assignmentToEdit = details
                                }
                        }
                    }
                }
                
                // --- Due Tomorrow Section ---
                Section(header: Text("Due Tomorrow")) {
                    if viewModel.tomorrowsChores.isEmpty {
                        Text("No chores are due tomorrow.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.tomorrowsChores) { details in
                            UpcomingChoreRowView(details: details)
                                .onTapGesture {
                                    viewModel.assignmentToEdit = details
                                }
                        }
                    }
                }
            }
            .navigationTitle("Home")
            // This sheet presents the editing view when a chore is tapped.
            .sheet(item: $viewModel.assignmentToEdit) { details in
                NavigationView {
                    EditChoreAssignmentView(details: details, familyID: familyID)
                }
            }
        }
    }
}

// MARK: - Reusable Row Views

struct ApprovalRowView: View {
    let details: ChoreAssignmentDetails
    @ObservedObject var viewModel: ParentHomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(details.chore.name)
                .font(.headline)
            Text("Completed by: \(details.child.name)")
                .font(.subheadline)
            
            HStack {
                Button(action: { viewModel.approve(details) }) {
                    Text("Approve")
                        .padding(.horizontal)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button(action: { viewModel.reject(details) }) {
                    Text("Reject")
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
}

struct UpcomingChoreRowView: View {
    let details: ChoreAssignmentDetails
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(details.chore.name)
                    .font(.headline)
                Text("Assigned to: \(details.child.name)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(String(format: "$%.2f", details.assignment.value))
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
    }
}

// MARK: - Preview
struct ParentHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ParentHomeView(familyID: "previewFamilyID")
    }
}
