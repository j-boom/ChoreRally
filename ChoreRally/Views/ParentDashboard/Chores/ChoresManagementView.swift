//
//  ChoresManagementView.swift
//  ChoreRally
//
//  Created by Anoop on 2023-12-24.
//
//  This view has been updated to properly initialize its ViewModel.
//

import SwiftUI

struct ChoresManagementView: View {
    
    // You will need to pass the familyID to this view from the ParentDashboardView.
    @StateObject private var viewModel: ChoresManagementViewModel
    
    init(familyID: String) {
        _viewModel = StateObject(wrappedValue: ChoresManagementViewModel(familyID: familyID))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Chores...")
                } else {
                    List {
                        ForEach(viewModel.chores) { chore in
                            VStack(alignment: .leading) {
                                Text(chore.name).font(.headline)
                                Text(chore.description).font(.subheadline).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage Chores")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // This button will eventually navigate to an "Add Chore" screen.
                    Button(action: {
                        // TODO: Implement navigation to AddChoreView
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    ChoresManagementView(familyID: "previewFamilyID")
}
