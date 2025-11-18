//
//  BudgetView.swift
//  Finpin
//
//  Created by Asmi Kachare on 10/26/25.
//

import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var aiService = AIService.shared
    @State private var showingAddExpenseSheet = false
    @State private var showingEditExpenseSheet = false
    @State private var selectedExpenseForEdit: Expense? = nil
    @State private var selectedCategory: String? = nil
    @State private var showingBudgetAdvisor = false
    @State private var budgetAdvice: BudgetAdvice? = nil
    @State private var isLoadingAdvice = false
    
    var body: some View {
        ZStack {
            Color(hex: "#FFF9F7").ignoresSafeArea()
            
            if let trip = appState.currentTrip {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header with AI Assistant
                        HStack {
                            Text("Budget")
                                .font(.largeTitle.bold())
                                .foregroundColor(Color(hex: "#A30000"))
                            
                            Spacer()
                            
                            // AI Budget Advisor
                            Button {
                                fetchBudgetAdvice(for: trip)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "sparkles")
                                    Text("AI Advice")
                                }
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .cornerRadius(20)
                            }
                            
                            Button {
                                showingAddExpenseSheet = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(Color(hex: "#A30000"))
                            }
                        }
                        .padding(.horizontal)
                        
                        // AI Budget Advice Card
                        if let advice = budgetAdvice, showingBudgetAdvisor {
                            AIBudgetCard(advice: advice, onDismiss: {
                                withAnimation {
                                    showingBudgetAdvisor = false
                                }
                            })
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Trip Info & Stats
                        VStack(spacing: 16) {
                            Text(trip.name)
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            HStack {
                                StatBox(title: "Total", value: trip.totalBudget, color: "#F4F4F4")
                                StatBox(title: "Spent", value: trip.spent, color: trip.spent > trip.totalBudget * 0.8 ? "#FFE5E5" : "#FFEAEA")
                                StatBox(title: "Remaining", value: trip.remaining, color: trip.remaining > 0 ? "#E9FBE7" : "#FFE5E5")
                            }
                            
                            // Budget progress with warning
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Budget Usage")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("\(Int((trip.spent / trip.totalBudget) * 100))%")
                                        .font(.caption.bold())
                                        .foregroundColor(trip.spent > trip.totalBudget * 0.8 ? .red : Color(hex: "#A30000"))
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 12)
                                        
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(trip.spent > trip.totalBudget ? Color.red :
                                                  trip.spent > trip.totalBudget * 0.8 ? Color.orange :
                                                  Color(hex: "#A30000"))
                                            .frame(width: min(geometry.size.width * (trip.spent / trip.totalBudget), geometry.size.width), height: 12)
                                    }
                                }
                                .frame(height: 12)
                                
                                if trip.spent > trip.totalBudget * 0.8 {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                        Text("You've used \(Int((trip.spent / trip.totalBudget) * 100))% of your budget!")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.horizontal)
                        
                        // Category breakdown
                        if !trip.expenses.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("By Category")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(categoryBreakdown(for: trip), id: \.category) { item in
                                            CategoryCard(
                                                category: item.category,
                                                amount: item.amount,
                                                total: trip.spent,
                                                isWarning: budgetAdvice?.watchCategories.contains(item.category) ?? false
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Transactions Header
                        HStack {
                            Text("Transactions")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            if !trip.expenses.isEmpty {
                                Text("\(trip.expenses.count) items")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        
                        if trip.expenses.isEmpty {
                            VStack {
                                Image(systemName: "creditcard.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No expenses yet")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                Text("Tap + to add your first expense")
                                    .font(.caption)
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(trip.expenses.sorted(by: { $0.date > $1.date })) { expense in
                                    ExpenseRow(
                                        expense: expense,
                                        tripId: trip.id,
                                        onEdit: {
                                            selectedExpenseForEdit = expense
                                            showingEditExpenseSheet = true
                                        }
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "airplane.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No trip selected")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Select or create a trip to manage expenses")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.7))
                }
            }
        }
        .sheet(isPresented: $showingAddExpenseSheet) {
            AddExpenseSheet()
        }
        .sheet(isPresented: $showingEditExpenseSheet) {
            if let expense = selectedExpenseForEdit {
                EditExpenseSheet(expense: expense, tripId: appState.currentTripID ?? UUID())
            }
        }
    }
    
    private func fetchBudgetAdvice(for trip: Trip) {
        isLoadingAdvice = true
        
        Task {
            do {
                let advice = try await aiService.getBudgetAdvice(
                    spent: trip.spent,
                    total: trip.totalBudget,
                    remaining: trip.remaining,
                    recentExpenses: trip.expenses
                )
                
                await MainActor.run {
                    self.budgetAdvice = advice
                    self.showingBudgetAdvisor = true
                    self.isLoadingAdvice = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingAdvice = false
                }
            }
        }
    }
    
    private func categoryBreakdown(for trip: Trip) -> [(category: String, amount: Double)] {
        let grouped = Dictionary(grouping: trip.expenses, by: { $0.category })
        return grouped.map { (category: $0.key, amount: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.amount > $1.amount }
    }
}

// AI Budget Advice Card
struct AIBudgetCard: View {
    let advice: BudgetAdvice
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                    Text("Your AI Budget Buddy")
                        .font(.headline)
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            Text(advice.message)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            if !advice.suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Smart Savings:")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                    
                    ForEach(advice.suggestions, id: \.self) { suggestion in
                        HStack(alignment: .top) {
                            Text("•")
                            Text(suggestion)
                                .font(.caption)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            
            if !advice.watchCategories.isEmpty {
                HStack {
                    Image(systemName: "eye.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("Watch: \(advice.watchCategories.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.05), Color.blue.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(LinearGradient(
                    colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct CategoryCard: View {
    let category: String
    let amount: Double
    let total: Double
    let isWarning: Bool
    
    private var categoryIcon: String {
        switch category {
        case "Food": return "fork.knife"
        case "Transport": return "car.fill"
        case "Accommodation": return "bed.double.fill"
        case "Activity": return "ticket.fill"
        case "Shopping": return "bag.fill"
        default: return "tag.fill"
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Image(systemName: categoryIcon)
                    .font(.title2)
                    .foregroundColor(isWarning ? .orange : Color(hex: "#A30000"))
                
                if isWarning {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .offset(x: 12, y: -12)
                }
            }
            
            Text(category)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("$\(Int(amount))")
                .font(.headline.bold())
                .foregroundColor(isWarning ? .orange : .black)
            
            Text("\(Int((amount / total) * 100))%")
                .font(.caption)
                .foregroundColor(isWarning ? .orange : Color(hex: "#A30000"))
        }
        .frame(width: 90)
        .padding()
        .background(isWarning ? Color.orange.opacity(0.1) : Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 1, y: 2)
        .overlay(
            isWarning ?
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange, lineWidth: 1) : nil
        )
    }
}

struct ExpenseRow: View {
    let expense: Expense
    let tripId: UUID
    let onEdit: () -> Void
    @EnvironmentObject var appState: AppState
    
    private var categoryIcon: String {
        switch expense.category {
        case "Food": return "fork.knife"
        case "Transport": return "car.fill"
        case "Accommodation": return "bed.double.fill"
        case "Activity": return "ticket.fill"
        case "Shopping": return "bag.fill"
        default: return "tag.fill"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: categoryIcon)
                .font(.title3)
                .foregroundColor(Color(hex: "#A30000"))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.headline)
                    .foregroundColor(.black)
                HStack {
                    Text(expense.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("-$\(Int(expense.amount))")
                .foregroundColor(Color(hex: "#A30000"))
                .font(.headline.bold())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 1, y: 2)
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                appState.deleteExpense(from: tripId, expense: expense)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct StatBox: View {
    var title: String
    var value: Double
    var color: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text("$\(Int(value))")
                .font(.headline.bold())
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: color))
        .cornerRadius(14)
    }
}
