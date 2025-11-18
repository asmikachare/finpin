//
//  Models.swift
//  Finpin
//
//  Created by Asmi Kachare on 10/26/25.
//

import Foundation
import CoreLocation

struct Trip: Identifiable {
    let id = UUID()
    let name: String
    let startDate: Date
    let endDate: Date
    let totalBudget: Double
    var expenses: [Expense]
    var pins: [TripPin] = []
    
    var spent: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var remaining: Double {
        totalBudget - spent
    }
    
    var duration: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }
}

struct Expense: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let amount: Double
    let category: String
    let date: Date
    
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        lhs.id == rhs.id
    }
}

struct TripPin: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let costEstimate: Double
    var notes: String = ""
    
    init(name: String, coordinate: CLLocationCoordinate2D, costEstimate: Double, notes: String = "") {
        self.name = name
        self.coordinate = coordinate
        self.costEstimate = costEstimate
        self.notes = notes
    }
}
