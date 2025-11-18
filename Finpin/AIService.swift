//
//  AIService.swift
//  Finpin
//
//  Created by Asmi Kachare on 11/17/25.
//

import Foundation
import CoreLocation

// MARK: - AI Service for Gemini API
class AIService: ObservableObject {
    static let shared = AIService()
    
    // Replace with your actual API keys
    private let geminiAPIKey = "YOUR_GEMINI_API_KEY"
    private let googlePlacesAPIKey = "YOUR_GOOGLE_PLACES_API_KEY"
    
    // MARK: - Location & Cost Estimation
    func getLocationDetails(for coordinate: CLLocationCoordinate2D) async throws -> LocationDetails {
        // First, get place details from Google Places API
        let placeInfo = try await fetchPlaceInfo(coordinate: coordinate)
        
        // Then, use Gemini to estimate costs and provide insights
        let prompt = """
        You're my friendly travel buddy helping me plan my trip! 🎒
        
        I'm visiting \(placeInfo.name) in \(placeInfo.city ?? "this location").
        
        Can you tell me:
        1. Typical cost to visit this place (entry fees, activities)
        2. Average time people spend here
        3. Best time of day to visit
        4. One fun tip or must-do thing here
        
        Keep it short and friendly, like you're texting a friend!
        Format the response as JSON with keys: estimatedCost, duration, bestTime, funTip
        """
        
        let geminiResponse = try await callGeminiAPI(prompt: prompt)
        let details = try parseLocationResponse(geminiResponse, placeInfo: placeInfo)
        
        return details
    }
    
    // MARK: - Budget Advisory
    func getBudgetAdvice(spent: Double, total: Double, remaining: Double, recentExpenses: [Expense]) async throws -> BudgetAdvice {
        let percentSpent = (spent / total) * 100
        let expenseList = recentExpenses.prefix(5).map { "\($0.category): $\($0.amount)" }.joined(separator: ", ")
        
        let prompt = """
        Hey! You're my friendly budget buddy helping me stay on track during my trip! 💰
        
        Here's my situation:
        - Total budget: $\(Int(total))
        - Already spent: $\(Int(spent)) (\(Int(percentSpent))%)
        - Remaining: $\(Int(remaining))
        - Recent expenses: \(expenseList)
        
        \(percentSpent > 75 ? "I'm getting close to my limit! 😅" : "")
        
        Can you:
        1. Give me a friendly heads up about my spending
        2. If I'm overspending, suggest 2-3 practical ways to save
        3. Recommend what categories I should watch out for
        
        Talk to me like a friend who cares but isn't judgy! Keep it real and helpful.
        Format as JSON with keys: message, suggestions (array), watchCategories (array)
        """
        
        let response = try await callGeminiAPI(prompt: prompt)
        return try parseBudgetAdvice(response)
    }
    
    // MARK: - Smart Expense Categorization
    func suggestExpenseDetails(title: String, location: String?) async throws -> ExpenseSuggestion {
        let prompt = """
        Quick help! I just made a purchase: "\(title)"
        \(location != nil ? "Location: \(location!)" : "")
        
        Can you guess:
        1. What category this belongs to (Food/Transport/Accommodation/Activity/Shopping/Other)
        2. Typical price range for this
        
        Just give me your best guess!
        Format as JSON with keys: category, minPrice, maxPrice
        """
        
        let response = try await callGeminiAPI(prompt: prompt)
        return try parseExpenseSuggestion(response)
    }
    
    // MARK: - Trip Insights
    func getTripInsights(trip: Trip) async throws -> TripInsights {
        let categories = Dictionary(grouping: trip.expenses, by: { $0.category })
        let topCategory = categories.max(by: { $0.value.reduce(0) { $0 + $1.amount } < $1.value.reduce(0) { $0 + $1.amount } })?.key ?? "General"
        
        let prompt = """
        Hey travel friend! 🌍 Quick check-in on my \(trip.name) trip:
        
        - Days: \(trip.duration)
        - Budget: $\(Int(trip.totalBudget))
        - Spent so far: $\(Int(trip.spent))
        - Mostly spending on: \(topCategory)
        - Places pinned: \(trip.pins.count)
        
        Give me:
        1. A friendly one-liner about my spending pattern
        2. One money-saving tip based on what you see
        3. A fun challenge or goal for the rest of my trip
        
        Keep it encouraging and fun!
        Format as JSON with keys: pattern, savingTip, challenge
        """
        
        let response = try await callGeminiAPI(prompt: prompt)
        return try parseTripInsights(response)
    }
    
    // MARK: - Private API Calls
    private func callGeminiAPI(prompt: String) async throws -> String {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=\(geminiAPIKey)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "contents": [[
                "parts": [[
                    "text": prompt
                ]]
            ]]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        guard let text = response.candidates?.first?.content?.parts?.first?.text else {
            throw AIError.noResponse
        }
        
        return text
    }
    
    private func fetchPlaceInfo(coordinate: CLLocationCoordinate2D) async throws -> PlaceInfo {
        // Reverse geocoding using Google Places API
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinate.latitude),\(coordinate.longitude)&key=\(googlePlacesAPIKey)")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)
        
        guard let result = response.results?.first else {
            return PlaceInfo(name: "Unknown Location", city: nil, country: nil)
        }
        
        return PlaceInfo(
            name: result.formatted_address ?? "Unknown Location",
            city: result.address_components?.first(where: { $0.types?.contains("locality") ?? false })?.long_name,
            country: result.address_components?.first(where: { $0.types?.contains("country") ?? false })?.long_name
        )
    }
    
    // MARK: - Response Parsing
    private func parseLocationResponse(_ response: String, placeInfo: PlaceInfo) throws -> LocationDetails {
        // Extract JSON from response
        guard let jsonData = extractJSON(from: response)?.data(using: .utf8) else {
            throw AIError.parsingError
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
            
            return LocationDetails(
                name: placeInfo.name,
                estimatedCost: (json["estimatedCost"] as? Double) ?? 0,
                duration: json["duration"] as? String ?? "2-3 hours",
                bestTime: json["bestTime"] as? String ?? "Morning",
                funTip: json["funTip"] as? String ?? "Enjoy your visit!",
                city: placeInfo.city,
                country: placeInfo.country
            )
        } catch {
            // Fallback with defaults
            return LocationDetails(
                name: placeInfo.name,
                estimatedCost: 50,
                duration: "2-3 hours",
                bestTime: "Anytime",
                funTip: "Have a great time!",
                city: placeInfo.city,
                country: placeInfo.country
            )
        }
    }
    
    private func parseBudgetAdvice(_ response: String) throws -> BudgetAdvice {
        guard let jsonData = extractJSON(from: response)?.data(using: .utf8) else {
            throw AIError.parsingError
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
            
            return BudgetAdvice(
                message: json["message"] as? String ?? "Keep tracking your expenses!",
                suggestions: json["suggestions"] as? [String] ?? [],
                watchCategories: json["watchCategories"] as? [String] ?? []
            )
        } catch {
            return BudgetAdvice(
                message: "You're doing great! Keep monitoring your spending.",
                suggestions: [],
                watchCategories: []
            )
        }
    }
    
    private func parseExpenseSuggestion(_ response: String) throws -> ExpenseSuggestion {
        guard let jsonData = extractJSON(from: response)?.data(using: .utf8) else {
            throw AIError.parsingError
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
            
            return ExpenseSuggestion(
                category: json["category"] as? String ?? "Other",
                minPrice: json["minPrice"] as? Double ?? 0,
                maxPrice: json["maxPrice"] as? Double ?? 100
            )
        } catch {
            return ExpenseSuggestion(category: "Other", minPrice: 0, maxPrice: 100)
        }
    }
    
    private func parseTripInsights(_ response: String) throws -> TripInsights {
        guard let jsonData = extractJSON(from: response)?.data(using: .utf8) else {
            throw AIError.parsingError
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
            
            return TripInsights(
                pattern: json["pattern"] as? String ?? "You're managing well!",
                savingTip: json["savingTip"] as? String ?? "Consider local markets for meals",
                challenge: json["challenge"] as? String ?? "Try to discover one hidden gem!"
            )
        } catch {
            return TripInsights(
                pattern: "Interesting spending pattern!",
                savingTip: "Look for free activities",
                challenge: "Explore like a local!"
            )
        }
    }
    
    private func extractJSON(from text: String) -> String? {
        // Find JSON content in the response
        if let startRange = text.range(of: "{"),
           let endRange = text.range(of: "}", options: .backwards) {
            return String(text[startRange.lowerBound...endRange.upperBound])
        }
        return nil
    }
}

// MARK: - Data Models
struct LocationDetails {
    let name: String
    let estimatedCost: Double
    let duration: String
    let bestTime: String
    let funTip: String
    let city: String?
    let country: String?
}

struct BudgetAdvice {
    let message: String
    let suggestions: [String]
    let watchCategories: [String]
}

struct ExpenseSuggestion {
    let category: String
    let minPrice: Double
    let maxPrice: Double
}

struct TripInsights {
    let pattern: String
    let savingTip: String
    let challenge: String
}

struct PlaceInfo {
    let name: String
    let city: String?
    let country: String?
}

// MARK: - API Response Models
struct GeminiResponse: Codable {
    let candidates: [Candidate]?
    
    struct Candidate: Codable {
        let content: Content?
    }
    
    struct Content: Codable {
        let parts: [Part]?
    }
    
    struct Part: Codable {
        let text: String?
    }
}

struct GooglePlacesResponse: Codable {
    let results: [PlaceResult]?
    
    struct PlaceResult: Codable {
        let formatted_address: String?
        let address_components: [AddressComponent]?
    }
    
    struct AddressComponent: Codable {
        let long_name: String?
        let types: [String]?
    }
}

enum AIError: Error {
    case noResponse
    case parsingError
    case networkError
}
