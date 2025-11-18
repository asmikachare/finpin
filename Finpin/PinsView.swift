//
//  PinsView.swift
//  Finpin
//
//  Created by Asmi Kachare on 10/26/25.
//

import SwiftUI
import MapKit
import CoreLocationUI

struct PinsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var locationManager = LocationManager()
    @StateObject private var aiService = AIService.shared
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var showingAddPinSheet = false
    @State private var selectedPin: TripPin? = nil
    @State private var showingLocationDetails = false
    @State private var locationDetails: LocationDetails? = nil
    @State private var isLoadingDetails = false
    @State private var tappedCoordinate: CLLocationCoordinate2D? = nil
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Map View with proper tap gesture
            Map(coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: appState.currentTrip?.pins ?? []) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    PinView(pin: pin, isSelected: selectedPin?.id == pin.id) {
                        selectedPin = pin
                        fetchPinDetails(pin: pin)
                    }
                }
            }
            .ignoresSafeArea()
            .onTapGesture { tapLocation in
                // This won't work directly, we need a different approach
            }
            .overlay(
                // Invisible view to capture taps
                GeometryReader { geometry in
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            // Convert screen coordinates to map coordinates
                            let mapPoint = MKMapPoint(x: location.x, y: location.y)
                            let coordinate = convertToCoordinate(from: location, in: geometry.size)
                            handleMapTap(at: coordinate)
                        }
                        .allowsHitTesting(!isLoadingDetails) // Disable while loading
                }
            )
            .onAppear {
                setupInitialRegion()
                locationManager.requestLocation()
            }
            
            // Top Info Panel
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Pins")
                            .font(.largeTitle.bold())
                        
                        if isLoadingDetails {
                            ProgressView()
                                .scaleEffect(0.8)
                                .padding(.leading, 8)
                        }
                    }
                    
                    if let trip = appState.currentTrip {
                        Text(trip.name)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        if !trip.pins.isEmpty {
                            Text("\(trip.pins.count) locations • Est. $\(Int(trip.pins.reduce(0) { $0 + $1.costEstimate }))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text("📍 Tap anywhere on map to add a location")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .padding(.leading)
                .padding(.top, 10)
                
                Spacer()
                
                // AI-powered location details card
                if let details = locationDetails, showingLocationDetails {
                    AILocationCard(details: details, onClose: {
                        withAnimation {
                            showingLocationDetails = false
                            locationDetails = nil
                        }
                    }, onAdd: {
                        addPinFromDetails(details)
                    })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Selected pin info card
                if let pin = selectedPin, !showingLocationDetails {
                    PinInfoCard(pin: pin, onClose: {
                        withAnimation {
                            selectedPin = nil
                        }
                    }, onEdit: {
                        // Edit functionality
                    })
                    .transition(.move(edge: .bottom))
                }
            }
            
            // Floating Action Buttons
            VStack {
                Spacer()
                HStack {
                    // AI Assistant Button
                    Button {
                        showAIAssistant()
                    } label: {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .clipShape(Circle())
                            .shadow(color: .purple.opacity(0.3), radius: 6, x: 2, y: 3)
                    }
                    
                    Spacer()
                    
                    // Location button
                    LocationButton(.currentLocation) {
                        locationManager.requestLocation()
                        if let location = locationManager.currentLocation {
                            withAnimation {
                                region.center = location
                                region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            }
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .symbolVariant(.fill)
                    .foregroundColor(.white)
                    
                    // Center all pins
                    Button {
                        centerOnAllPins()
                    } label: {
                        Image(systemName: "map.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.gray)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 1, y: 2)
                    }
                    
                    // Add pin manually
                    if appState.currentTrip != nil {
                        Button {
                            showingAddPinSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 58, height: 58)
                                .background(Color(hex: "#A30000"))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.25), radius: 6, x: 2, y: 3)
                        }
                    }
                }
                .padding(.bottom, 40)
                .padding(.horizontal, 25)
            }
        }
        .sheet(isPresented: $showingAddPinSheet) {
            AddPinSheet(suggestedLocation: tappedCoordinate)
        }
        .alert("AI Travel Assistant", isPresented: $showingAIAlert) {
            Button("OK") { }
        } message: {
            Text(aiAlertMessage)
        }
    }
    
    @State private var showingAIAlert = false
    @State private var aiAlertMessage = ""
    
    // MARK: - Helper Functions
    
    private func convertToCoordinate(from point: CGPoint, in size: CGSize) -> CLLocationCoordinate2D {
        // Simple conversion - this is approximate
        let latDelta = region.span.latitudeDelta
        let lonDelta = region.span.longitudeDelta
        
        let lat = region.center.latitude - (latDelta / 2) + (latDelta * Double(point.y / size.height))
        let lon = region.center.longitude - (lonDelta / 2) + (lonDelta * Double(point.x / size.width))
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    private func setupInitialRegion() {
        if let trip = appState.currentTrip, let firstPin = trip.pins.first {
            region.center = firstPin.coordinate
        } else if let userLocation = locationManager.currentLocation {
            region.center = userLocation
        }
    }
    
    private func handleMapTap(at coordinate: CLLocationCoordinate2D) {
        tappedCoordinate = coordinate
        
        Task {
            await fetchLocationDetails(for: coordinate)
        }
    }
    
    private func fetchLocationDetails(for coordinate: CLLocationCoordinate2D) async {
        isLoadingDetails = true
        
        do {
            let details = try await aiService.getLocationDetails(for: coordinate)
            await MainActor.run {
                self.locationDetails = details
                self.showingLocationDetails = true
                self.isLoadingDetails = false
            }
        } catch {
            await MainActor.run {
                self.isLoadingDetails = false
                // Still show the add pin sheet even if AI fails
                self.tappedCoordinate = coordinate
                self.showingAddPinSheet = true
            }
        }
    }
    
    private func fetchPinDetails(pin: TripPin) {
        Task {
            await fetchLocationDetails(for: pin.coordinate)
        }
    }
    
    private func addPinFromDetails(_ details: LocationDetails) {
        guard let coordinate = tappedCoordinate,
              let tripId = appState.currentTripID else { return }
        
        let newPin = TripPin(
            name: details.name,
            coordinate: coordinate,
            costEstimate: details.estimatedCost,
            notes: details.funTip
        )
        
        appState.addPin(to: tripId, pin: newPin)
        
        withAnimation {
            showingLocationDetails = false
            locationDetails = nil
            tappedCoordinate = nil
        }
    }
    
    private func centerOnAllPins() {
        guard let trip = appState.currentTrip, !trip.pins.isEmpty else { return }
        
        let coordinates = trip.pins.map { $0.coordinate }
        let minLat = coordinates.map { $0.latitude }.min() ?? 40.7580
        let maxLat = coordinates.map { $0.latitude }.max() ?? 40.7580
        let minLon = coordinates.map { $0.longitude }.min() ?? -73.9855
        let maxLon = coordinates.map { $0.longitude }.max() ?? -73.9855
        
        withAnimation {
            region.center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            )
            region.span = MKCoordinateSpan(
                latitudeDelta: max((maxLat - minLat) * 1.3, 0.01),
                longitudeDelta: max((maxLon - minLon) * 1.3, 0.01)
            )
        }
    }
    
    private func showAIAssistant() {
        guard let trip = appState.currentTrip else {
            aiAlertMessage = "Select a trip first to get AI insights!"
            showingAIAlert = true
            return
        }
        
        Task {
            do {
                let insights = try await aiService.getTripInsights(trip: trip)
                await MainActor.run {
                    aiAlertMessage = """
                    🎯 \(insights.pattern)
                    
                    💡 Tip: \(insights.savingTip)
                    
                    🏆 Challenge: \(insights.challenge)
                    """
                    showingAIAlert = true
                }
            } catch {
                await MainActor.run {
                    aiAlertMessage = "Couldn't get AI insights. Try again!"
                    showingAIAlert = true
                }
            }
        }
    }
}

// Keep existing AILocationCard, PinInfoCard, and PinView structs...

// MARK: - AI Location Card
struct AILocationCard: View {
    let details: LocationDetails
    let onClose: () -> Void
    let onAdd: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(details.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    if let city = details.city {
                        Text(city)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
            
            // AI Insights
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.green)
                    Text("Est. $\(Int(details.estimatedCost))")
                        .font(.subheadline.bold())
                }
                
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                    Text("\(details.duration) • Best at \(details.bestTime)")
                        .font(.caption)
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                    Text(details.funTip)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            HStack(spacing: 12) {
                Button(action: onAdd) {
                    Label("Add to Trip", systemImage: "plus.circle")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#A30000"))
                        .cornerRadius(12)
                }
                
                Button(action: onClose) {
                    Text("Cancel")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding()
    }
}

// Updated PinInfoCard with edit functionality
struct PinInfoCard: View {
    let pin: TripPin
    let onClose: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(pin.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                if pin.costEstimate > 0 {
                    Label("Est. $\(Int(pin.costEstimate))", systemImage: "dollarsign.circle")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#A30000"))
                }
                
                if !pin.notes.isEmpty {
                    Text(pin.notes)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding()
    }
}

// Keep existing PinView
struct PinView: View {
    let pin: TripPin
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(isSelected ? Color(hex: "#A30000") : Color.red)
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(isSelected ? Color(hex: "#A30000") : Color.red)
                .offset(y: -5)
        }
        .scaleEffect(isSelected ? 1.3 : 1.0)
        .onTapGesture {
            action()
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var currentLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}
