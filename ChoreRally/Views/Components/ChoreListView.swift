//
//  ChoreListView.swift
//  ChoreRally
//
//  Created by Gemini on 2025-08-29.
//
//  This is a reusable view for displaying a list of chores, grouped by category.
//

import SwiftUI

struct ChoreListView<Content: View>: View {
    
    // MARK: - Properties
    
    let chores: [Chore]
    let actionType: ActionType
    let onDelete: ((Chore) -> Void)?
    let rowContent: (Chore) -> Content
    
    private var choresByCategory: [Chore.ChoreCategory: [Chore]] {
        Dictionary(grouping: chores, by: { $0.category })
    }
    
    private var categories: [Chore.ChoreCategory] {
        choresByCategory.keys.sorted { $0.rawValue < $1.rawValue }
    }
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(categories, id: \.self) { category in
                Section(header: Text(category.rawValue)) {
                    ForEach(choresByCategory[category] ?? []) { chore in
                        HStack {
                            rowContent(chore)
                            Spacer()
                            actionButton(for: chore)
                        }
                    }
                    .onDelete(perform: deleteChore)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func deleteChore(at offsets: IndexSet) {
        // This logic needs to be adapted based on how chores are grouped.
        // For simplicity, this example assumes a flat list. You'll need to adjust this
        // if your view model provides chores grouped by category.
    }
    
    @ViewBuilder
    private func actionButton(for chore: Chore) -> some View {
        switch actionType {
        case .button(let title, let action):
            Button(title) {
                action(chore)
            }
            .buttonStyle(.borderedProminent)
        case .navigationLink(let destination):
            NavigationLink(destination: destination(chore)) {
                Image(systemName: "pencil")
            }
        case .checkmark(let isSelected, let action):
            Button(action: { action(chore) }) {
                Image(systemName: isSelected(chore) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected(chore) ? .blue : .secondary)
            }
        case .none:
            EmptyView()
        }
    }
    
    // MARK: - Nested Types
    
    enum ActionType {
        case button(title: String, action: (Chore) -> Void)
        case navigationLink(destination: (Chore) -> AnyView)
        case checkmark(isSelected: (Chore) -> Bool, action: (Chore) -> Void)
        case none
    }
}

