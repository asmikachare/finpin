//
//  TripsView.swift
//  Finpin
//
//  Created by Asmi Kachare on 10/26/25.
//

import SwiftUI

struct TripsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFF9F7").ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Trips")
                            .font(.largeTitle.bold())
                            .foregroundColor(Color(hex: "#A30000"))
                        
                        Spacer()
                        
                        Button {
                            showingAddSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(Color(hex: "#A30000"))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if appState.trips.isEmpty {
                        VStack {
                            Spacer()
                            Text("No trips yet")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Tap + to add your first trip")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.7))
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        List {
                            ForEach(appState.trips) { trip in
                                TripCard(trip: trip) {
                                    appState.currentTripID = trip.id
                                }
                                .listRowBackground(Color(hex: "#FFF9F7"))
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    appState.deleteTrip(appState.trips[index])
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTripSheet()
        }
    }
}

struct TripCard: View {
    let trip: Trip
    let action: () -> Void
    @EnvironmentObject var appState: AppState
    
    var isSelected: Bool {
        appState.currentTripID == trip.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.name)
                        .font(.headline)
                        .foregroundColor(Color(hex: "#222222"))
                    
                    Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if isSelected {
                    Text("Active")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#A30000"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Budget")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("$\(Int(trip.totalBudget))")
                        .font(.subheadline.bold())
                        .foregroundColor(Color(hex: "#222222"))
                }
                
                VStack(alignment: .leading) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("$\(Int(trip.spent))")
                        .font(.subheadline.bold())
                        .foregroundColor(Color(hex: "#A30000"))
                }
                
                VStack(alignment: .leading) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("$\(Int(trip.remaining))")
                        .font(.subheadline.bold())
                        .foregroundColor(trip.remaining > 0 ? .green : .red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(trip.duration) days")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(trip.pins.count) pins")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(trip.spent > trip.totalBudget ? Color.red : Color(hex: "#A30000"))
                        .frame(width: min(geometry.size.width * (trip.spent / trip.totalBudget), geometry.size.width), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 2, y: 2)
        .onTapGesture {
            action()
        }
    }
}
