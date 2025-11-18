# 🌍 Finpin - AI-Powered Travel Budget Tracker

<div align="center">
  
  ![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
  ![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)
  ![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-green.svg)
  ![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)
  
  **"Plan smart. Spend smarter."**
  
  An intelligent travel budget tracking app that helps students and travelers plan trips, track expenses, and pin destinations with AI-powered insights.
  
</div>

## ✨ Features

### 🗺️ **Smart Map Pins**
- Tap anywhere on the map to add locations
- AI automatically fetches location details and cost estimates
- Search for places by name with auto-complete
- Real-time location name detection

### 💰 **AI Budget Advisor**
- Friendly budget warnings and spending insights
- Category-wise expense tracking
- Smart suggestions to save money
- Real-time budget monitoring with visual indicators

### 📊 **Trip Management**
- Create and manage multiple trips
- Track expenses by category (Food, Transport, Activities, etc.)
- Visual budget progress bars
- Trip duration and cost calculations

### 🤖 **AI Features** (Powered by Gemini)
- **Location Intelligence**: Automatic cost estimation for places
- **Budget Buddy**: Personalized spending advice that talks like a friend
- **Smart Categorization**: Auto-categorize expenses
- **Trip Insights**: Fun challenges and money-saving tips

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+ deployment target
- Swift 5.9+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/finpin.git
   cd finpin
   ```

2. **Open in Xcode**
   ```bash
   open Finpin.xcodeproj
   ```

3. **Add Location Permission**
   
   Add to your `Info.plist`:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>Finpin needs your location to show nearby places and track your travel destinations</string>
   ```

4. **Configure API Keys** (Optional - for full AI features)

   In `AIService.swift`, replace the placeholder keys:
   ```swift
   private let geminiAPIKey = "YOUR_GEMINI_API_KEY"
   private let googlePlacesAPIKey = "YOUR_GOOGLE_PLACES_API_KEY"
   ```

   **Note**: The app works with mock data if API keys are not provided!

### Getting API Keys

#### Gemini API (Free)
1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Click "Create API Key"
3. Copy and paste into the app

#### Google Places API (Free $200 credit)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable "Places API" and "Geocoding API"
4. Create credentials → API Key

## 📱 App Architecture

```
Finpin/
├── Models/
│   ├── Trip.swift
│   ├── Expense.swift
│   └── TripPin.swift
├── Views/
│   ├── MainTabView.swift
│   ├── TripsView.swift
│   ├── BudgetView.swift
│   ├── PinsView.swift
│   └── ProfileView.swift
├── Services/
│   └── AIService.swift
├── Sheets/
│   ├── AddTripSheet.swift
│   ├── AddExpenseSheet.swift
│   ├── EditExpenseSheet.swift
│   └── AddPinSheet.swift
└── Extensions/
    └── Color+Extensions.swift
```

## 🎨 Design System

### Colors
- **Primary**: Finpin Red `#A30000`
- **Background**: Soft White `#FFF9F7`
- **Cards**: Light Gray `#F4F4F4`
- **Success**: Green Tint `#E9FBE7`
- **Warning**: Orange/Red gradients

### Key Components
- Custom map annotations with tap gestures
- AI-powered location cards
- Budget progress indicators
- Category-based expense tracking
- Real-time search with MKLocalSearch

## 🧠 AI Integration

The app features a friendly AI assistant that:
- Estimates costs for any location you tap
- Provides personalized budget advice
- Suggests money-saving alternatives
- Offers fun travel challenges

Example AI responses:
- "Whoa there, big spender! 😅 Time to get creative with free activities!"
- "Book sunset tickets online for shorter lines! 🌅"
- "Try local markets - better food, better prices!"

## 🔄 Current Status

### ✅ Completed
- [x] Core trip management
- [x] Expense tracking with categories
- [x] Interactive map with pins
- [x] AI service integration
- [x] Mock data for testing
- [x] Location search and auto-complete
- [x] Budget warnings and insights
- [x] Edit/delete functionality

### 🚧 In Development
- [ ] Data persistence with SwiftData
- [ ] Firebase cloud sync
- [ ] Photo attachments for expenses
- [ ] Export trip summaries
- [ ] Currency conversion
- [ ] Share trips with friends
- [ ] Apple Wallet integration

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Asmi Kachare**
- Computer Science Senior at ASU
- Vice President, Indian Students' Association
- [GitHub](https://github.com/yourusername)
- [LinkedIn](https://linkedin.com/in/yourusername)

## 🙏 Acknowledgments

- Google Gemini API for AI capabilities
- Google Maps Platform for location services
- SwiftUI community for inspiration
- CalHacks for the hackathon opportunity

## 📸 Screenshots

<div align="center">
  <img src="screenshots/trips.png" width="250" alt="Trips View">
  <img src="screenshots/map.png" width="250" alt="Map with Pins">
  <img src="screenshots/budget.png" width="250" alt="Budget Tracking">
</div>

---

<div align="center">
  Made with ❤️ and ☕ by Asmi
  
  **Star ⭐ this repo if you find it helpful!**
</div>
