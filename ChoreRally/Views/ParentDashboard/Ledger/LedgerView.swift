//
//  LedgerView.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/26/25.
//


//
//  LedgerView.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This view displays the financial ledger for the family.
//

import SwiftUI

struct LedgerView: View {
    
    @StateObject private var viewModel: LedgerViewModel
    
    init(familyID: String) {
        _viewModel = StateObject(wrappedValue: LedgerViewModel(familyID: familyID))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // --- Child Filter Buttons ---
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button("All") { viewModel.selectedChildID = nil }
                            .buttonStyle(.borderedProminent)
                            .tint(viewModel.selectedChildID == nil ? .blue : .gray)
                        
                        ForEach(viewModel.childProfiles) { child in
                            Button(child.name) { viewModel.selectedChildID = child.id }
                                .buttonStyle(.borderedProminent)
                                .tint(viewModel.selectedChildID == child.id ? .blue : .gray)
                        }
                    }
                    .padding()
                }
                
                // --- Ledger List ---
                List(viewModel.filteredLedgerEntries) { details in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(details.chore.name)
                                .font(.headline)
                            Text("Completed by \(details.child.name) on \(details.assignment.dateCompleted?.dateValue() ?? Date(), style: .date)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(String(format: "$%.2f", details.assignment.value))
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    }
                }
                
                // --- Totals and Pay Button ---
                VStack {
                    Text("Total Owed")
                        .font(.title2)
                    Text(String(format: "$%.2f", viewModel.totalOwed))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Button(action: { viewModel.paySelectedChild() }) {
                        Text("Pay \(viewModel.selectedChildID == nil ? "All" : viewModel.childProfiles.first { $0.id == viewModel.selectedChildID }?.name ?? "")")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(viewModel.totalOwed == 0)
                    .padding()
                }
                .background(Color(.systemGray6))
            }
            .navigationTitle("Ledger")
        }
    }
}

struct LedgerView_Previews: PreviewProvider {
    static var previews: some View {
        LedgerView(familyID: "previewFamilyID")
    }
}
