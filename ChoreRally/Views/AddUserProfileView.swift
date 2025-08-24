//
//  AddUserProfileView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This view provides a form for adding a new child profile to the family.
//

import SwiftUI

struct AddUserProfileView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: AddUserProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // State for showing the informational alert
    @State private var showingRateInfoAlert = false
    
    init(familyID: String) {
        _viewModel = StateObject(wrappedValue: AddUserProfileViewModel(familyID: familyID))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Child's Details")) {
                    TextField("Child's Name", text: $viewModel.name)
                    
                    // Age picker
                    Picker("Age", selection: $viewModel.age) {
                        ForEach(3...18, id: \.self) { age in
                            Text("\(age)").tag(age)
                        }
                    }
                }
                
                Section(header: Text("Allowance Rate")) {
                    HStack {
                        Text("Rate ($/hr)")
                        Spacer()
                        TextField("Rate", value: $viewModel.rate, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    // "What's this?" button
                    Button(action: {
                        showingRateInfoAlert = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("What's this?")
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        viewModel.saveProfile()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Save Profile")
                        }
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Child Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            // --- This syntax has been updated to fix the deprecation warning ---
            .onChange(of: viewModel.isSaveSuccessful) {
                if viewModel.isSaveSuccessful {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .alert("About the Rate", isPresented: $showingRateInfoAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The hourly rate is a guideline to help you set values for chores. For example, a 15-minute chore for a child with an $8/hr rate might be valued at $2. You can always adjust this later.")
            }
        }
    }
}

// MARK: - Preview

struct AddUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // We provide a dummy familyID for the preview to work.
        AddUserProfileView(familyID: "previewFamilyID")
    }
}
