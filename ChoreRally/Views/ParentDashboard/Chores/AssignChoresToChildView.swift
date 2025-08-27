//
//  AssignChoresToChildView.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/26/25.
//


//
//  AssignChoresToChildView.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This view displays a list of chores that can be assigned to a specific child.
//

import SwiftUI

struct AssignChoresToChildView: View {
    
    @StateObject private var viewModel: AssignChoresToChildViewModel
    private let childProfile: UserProfile
    
    // State to manage the date picker sheet
    @State private var choreToAssign: Chore?
    @State private var dueDate = Date()
    
    init(childProfile: UserProfile, familyID: String) {
        self.childProfile = childProfile
        _viewModel = StateObject(wrappedValue: AssignChoresToChildViewModel(childProfile: childProfile, familyID: familyID))
    }
    
    var body: some View {
        List {
            if viewModel.capableChores.isEmpty {
                Text("\(childProfile.name) hasn't been approved for any chores yet. You can assign capable chores from the 'Family' tab.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(viewModel.capableChores) { chore in
                    HStack {
                        ChoreRowView(chore: chore)
                        Spacer()
                        
                        if viewModel.recentlyAssignedChoreIDs.contains(chore.id ?? "") {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title)
                        } else {
                            Button("Assign") {
                                // Set the chore to be assigned, which triggers the sheet
                                self.choreToAssign = chore
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Assign to \(childProfile.name)")
        // This sheet presents the date picker when a chore is selected.
        .sheet(item: $choreToAssign) { chore in
            VStack {
                Text("Set Due Date for \"\(chore.name)\"")
                    .font(.headline)
                    .padding()
                
                DatePicker("Due Date", selection: $dueDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Button("Confirm Assignment") {
                    viewModel.assignChore(chore, dueDate: dueDate)
                    self.choreToAssign = nil // Dismiss the sheet
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
    }
}

struct AssignChoresToChildView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProfile = UserProfile(id: "1", name: "Alex", avatarSymbolName: "face.smiling", isParent: false, age: 10, rate: 10.0, capableChoreIDs: ["a", "b"])
        
        NavigationView {
            AssignChoresToChildView(childProfile: sampleProfile, familyID: "previewFamilyID")
        }
    }
}
