//
//  ChildHomeView.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/27/25.
//

import SwiftUI

struct ChildHomeView: View {
    
    @StateObject private var viewModel: ChildHomeViewModel
    
    init(childProfile: UserProfile, familyID: String) {
        _viewModel = StateObject(wrappedValue: ChildHomeViewModel(childProfile: childProfile, familyID: familyID))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Due Today")) {
                    if viewModel.todaysChores.isEmpty {
                        Text("No chores due today. Great job!")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.todaysChores) { details in
                            ChildChoreRowView(details: details, viewModel: viewModel)
                        }
                    }
                }
                
                Section(header: Text("Due Tomorrow")) {
                    if viewModel.tomorrowsChores.isEmpty {
                        Text("No chores due tomorrow.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.tomorrowsChores) { details in
                            ChildChoreRowView(details: details, viewModel: viewModel)
                        }
                    }
                }
            }
            .navigationTitle("My Chores")
        }
    }
}

// Reusable row for the child's chore list
struct ChildChoreRowView: View {
    let details: ChoreAssignmentDetails
    @ObservedObject var viewModel: ChildHomeViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(details.chore.name)
                    .font(.headline)
                Text(details.chore.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Mark as Done") {
                viewModel.markChoreAsCompleted(details)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding(.vertical)
    }
}
