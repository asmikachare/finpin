//
//  AppState.swift
//  Finpin
//
//  Created by Asmi Kachare on 10/26/25.
//

import Foundation
import CoreLocation

@MainActor
class AppState: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var currentTripID: UUID?
    @Published var pins: [TripPin] = []
    
    init() {
        // Demo trip data
        let sampleTrip = Trip(
            name: "NYC Adventure",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            totalBudget: 2500,
            expenses: [
                Expense(title: "Hotel Booking", amount: 600, category: "Accommodation", date: Date()),
                Expense(title: "Flight Tickets", amount: 450, category: "Transport", date: Date()),
                Expense(title: "Dinner at Times Square", amount: 120, category: "Food", date: Date()),
                Expense(title: "Broadway Show", amount: 250, category: "Activity", date: Date()),
                Expense(title: "Museum Tickets", amount: 50, category: "Activity", date: Date())
            ],
            pins: [
                TripPin(name: "Times Square",
                       coordinate: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
                       costEstimate: 200),
                TripPin(name: "Central Park",
                       coordinate: CLLocationCoordinate2D(latitude: 40.7829, longitude: -73.9654),
                       costEstimate: 0),
                TripPin(name: "Statue of Liberty",
                       coordinate: CLLocationCoordinate2D(latitude: 40.6892, longitude: -74.0445),
                       costEstimate: 50)
            ]
        )
        trips = [sampleTrip]
        currentTripID = sampleTrip.id
    }
    
    var currentTrip: Trip? {
        trips.first { $0.id == currentTripID }
    }
    
    func addPin(to tripId: UUID, pin: TripPin) {
        if let index = trips.firstIndex(where: { $0.id == tripId }) {
            trips[index].pins.append(pin)
        }
    }
    
    func deleteExpense(from tripId: UUID, expense: Expense) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }),
           let expenseIndex = trips[tripIndex].expenses.firstIndex(where: { $0.id == expense.id }) {
            trips[tripIndex].expenses.remove(at: expenseIndex)
        }
    }
    
    func deleteTrip(_ trip: Trip) {
        trips.removeAll { $0.id == trip.id }
        if currentTripID == trip.id {
            currentTripID = trips.first?.id
        }
    }
}
