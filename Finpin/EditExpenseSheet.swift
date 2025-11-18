//
//  EditExpenseSheet.swift
//  Finpin
//
//  Created by Asmi Kachare on 11/17/25.
//

import SwiftUI

struct EditExpenseSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    let expense: Expense
    let tripId: UUID
    
    @State private var expenseTitle: String
    @State private var expenseAmount: String
    @State private var selectedCategory: String
    @State private var expenseDate: Date
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingDeleteConfirmation = false
    
    let categories = ["Food", "Transport", "Accommodation", "Activity", "Shopping", "Other"]
    
    init(expense: Expense, tripId: UUID) {
        self.expense = expense
        self.tripId = tripId
        _expenseTitle = State(initialValue: expense.title)
        _expenseAmount = State(initialValue: String(Int(expense.amount)))
        _selectedCategory = State(initialValue: expense.category)
        _expenseDate = State(initialValue: expense.date)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFF9F7").ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expense Title")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Enter expense title", text: $expenseTitle)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.1), radius: 2)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack {
                            Text("$")
                                .foregroundColor(.gray)
                            TextField("0", text: $expenseAmount)
                                .keyboardType(.decimalPad)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.1), radius: 2)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.1), radius: 2)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(.caption)
                            .foregroundColor(.gray)
                        DatePicker("", selection: $expenseDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.1), radius: 2)
                    }
                    
                    Spacer()
                    
                    // Delete button
                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Expense", systemImage: "trash")
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#A30000"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundColor(Color(hex: "#A30000"))
                    .fontWeight(.semibold)
                }
            }
            .alert("Invalid Input", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .alert("Delete Expense", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteExpense()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this expense?")
            }
        }
    }
    
    private func saveChanges() {
        guard !expenseTitle.isEmpty else {
            alertMessage = "Please enter an expense title"
            showingAlert = true
            return
        }
        
        guard let amount = Double(expenseAmount), amount > 0 else {
            alertMessage = "Please enter a valid amount"
            showingAlert = true
            return
        }
        
        // Find and update the expense
        if let tripIndex = appState.trips.firstIndex(where: { $0.id == tripId }),
           let expenseIndex = appState.trips[tripIndex].expenses.firstIndex(where: { $0.id == expense.id }) {
            
            // Create updated expense
            let updatedExpense = Expense(
                title: expenseTitle,
                amount: amount,
                category: selectedCategory,
                date: expenseDate
            )
            
            // Replace with new expense (keeping same ID would require making Expense mutable)
            appState.trips[tripIndex].expenses.remove(at: expenseIndex)
            appState.trips[tripIndex].expenses.insert(updatedExpense, at: expenseIndex)
        }
        
        dismiss()
    }
    
    private func deleteExpense() {
        appState.deleteExpense(from: tripId, expense: expense)
        dismiss()
    }
}
