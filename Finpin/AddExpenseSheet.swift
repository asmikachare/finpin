//
//  AddExpenseSheet.swift
//  Finpin
//
//  Created by Asmi Kachare on 10/26/25.
//

import SwiftUI

struct AddExpenseSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var expenseTitle = ""
    @State private var expenseAmount = ""
    @State private var selectedCategory = "Food"
    @State private var expenseDate = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let categories = ["Food", "Transport", "Accommodation", "Activity", "Shopping", "Other"]
    
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
                    
                    // Budget warning if expense would exceed remaining budget
                    if let trip = appState.currentTrip,
                       let amount = Double(expenseAmount),
                       amount > trip.remaining {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("This expense exceeds your remaining budget")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Expense")
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
                        saveExpense()
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
        }
    }
    
    private func saveExpense() {
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
        
        guard let currentTripIndex = appState.trips.firstIndex(where: { $0.id == appState.currentTripID }) else {
            alertMessage = "No trip selected"
            showingAlert = true
            return
        }
        
        let newExpense = Expense(
            title: expenseTitle,
            amount: amount,
            category: selectedCategory,
            date: expenseDate
        )
        
        appState.trips[currentTripIndex].expenses.append(newExpense)
        dismiss()
    }
}
