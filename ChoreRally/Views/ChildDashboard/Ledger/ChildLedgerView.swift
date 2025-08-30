//
//  ChildLedgerView.swift
//  ChoreRally
//
//  Created by Gemini on 2025--28.
//
//  This view has been corrected to pass the proper data to its helper views.
//

import SwiftUI

struct ChildLedgerView: View {
    
    @StateObject private var viewModel: ChildLedgerViewModel
    
    init(childProfile: UserProfile, familyID: String) {
        _viewModel = StateObject(wrappedValue: ChildLedgerViewModel(childProfile: childProfile, familyID: familyID))
    }
    
    var body: some View {
        NavigationView {
            List {
                balanceSection
                unpaidChoresSection
                paymentHistorySection
            }
            .navigationTitle("My Ledger")
        }
    }
    
    // MARK: - View Components
    
    private var balanceSection: some View {
        Section {
            VStack(alignment: .center) {
                Text("You've Earned")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(String(format: "$%.2f", viewModel.totalOwed))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
    
    @ViewBuilder
    private var unpaidChoresSection: some View {
        Section(header: Text("Unpaid Chores")) {
            if viewModel.unpaidChores.isEmpty {
                Text("No unpaid chores. All caught up!")
            } else {
                ForEach(viewModel.unpaidChores) { details in
                    HStack {
                        Text(details.chore.name)
                        Spacer()
                        Text(String(format: "$%.2f", details.assignment.value))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var paymentHistorySection: some View {
        Section(header: Text("Payment History")) {
            ForEach(viewModel.paidChoreGroups) { group in
                // This now uses the new, dedicated row view.
                PaymentGroupRow(group: group)
            }
        }
    }
}

// --- HELPER VIEWS ---

/// A dedicated view for a single, collapsible row in the payment history.
struct PaymentGroupRow: View {
    let group: PaymentGroup
    
    var body: some View {
        DisclosureGroup {
            ForEach(group.details) { details in
                ChoreInPaymentRow(details: details)
            }
        } label: {
            PaymentHeaderRow(payment: group.payment)
        }
    }
}

struct PaymentHeaderRow: View {
    let payment: Payment
    
    var body: some View {
        HStack {
            Text(payment.paymentDate.dateValue(), style: .date)
                .fontWeight(.bold)
            Spacer()
            Text(String(format: "$%.2f", payment.amount))
                .fontWeight(.bold)
        }
    }
}

struct ChoreInPaymentRow: View {
    let details: ChoreAssignmentDetails
    
    var body: some View {
        HStack {
            Text(details.chore.name)
            Spacer()
            Text(String(format: "$%.2f", details.assignment.value))
                .foregroundColor(.secondary)
        }
        .padding(.leading)
    }
}
