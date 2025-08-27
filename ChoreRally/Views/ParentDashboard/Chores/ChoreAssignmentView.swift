//
//  ChoreAssignmentView.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This is the main view for the Assignments tab.
//

import SwiftUI

struct ChoreAssignmentView: View {
    
    @StateObject private var viewModel: ChoreAssignmentViewModel
    private let familyID: String
    
    init(familyID: String) {
        self.familyID = familyID
        _viewModel = StateObject(wrappedValue: ChoreAssignmentViewModel(familyID: familyID))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Assign Chores To")) {
                    ForEach(viewModel.childProfiles) { child in
                        ChildRowView(childProfile: child)
                            .onTapGesture {
                                viewModel.selectedChildForAssignment = child
                            }
                    }
                }
            }
            .navigationTitle("Chore Assignments")
            // This sheet presents the assignment view modally.
            .sheet(item: $viewModel.selectedChildForAssignment) { child in
                // Wrap the destination in its own NavigationView for the modal context.
                NavigationView {
                    AssignChoresToChildView(childProfile: child, familyID: familyID)
                }
            }
        }
    }
}

struct ChoreAssignmentView_Previews: PreviewProvider {
    static var previews: some View {
        ChoreAssignmentView(familyID: "previewFamilyID")
    }
}
