//
//  AddTripSheet.swift
//  Finpin
//
//  Created by Asmi Kachare on 10/26/25.
//

import SwiftUI

struct AddTripSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var tripName = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 3) // 3 days later
    @State private var totalBudget = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFF9F7").ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Trip Name")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Enter trip name", text: $tripName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.1), radius: 2)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start Date")
                            .font(.caption)
                            .foregroundColor(.gray)
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.1), radius: 2)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("End Date")
                            .font(.caption)
                            .foregroundColor(.gray)
                        DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.1), radius: 2)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Budget")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack {
                            Text("$")
                                .foregroundColor(.gray)
                            TextField("0", text: $totalBudget)
                                .keyboardType(.decimalPad)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.1), radius: 2)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Trip")
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
                        saveTrip()
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
    
    private func saveTrip() {
        guard !tripName.isEmpty else {
            alertMessage = "Please enter a trip name"
            showingAlert = true
            return
        }
        
        guard let budget = Double(totalBudget), budget > 0 else {
            alertMessage = "Please enter a valid budget amount"
            showingAlert = true
            return
        }
        
        let newTrip = Trip(
            name: tripName,
            startDate: startDate,
            endDate: endDate,
            totalBudget: budget,
            expenses: []
        )
        
        appState.trips.append(newTrip)
        appState.currentTripID = newTrip.id
        dismiss()
    }
}
