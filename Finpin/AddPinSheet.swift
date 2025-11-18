//
//  AddPinSheet.swift
//  Finpin
//
//  Created by Asmi Kachare on 10/26/25.
//

import SwiftUI
import MapKit
import CoreLocationUI

struct AddPinSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()
    @StateObject private var aiService = AIService.shared
    
    @State private var pinName = ""
    @State private var costEstimate = ""
    @State private var searchText = ""
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var selectedMapItem: MKMapItem?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoadingLocation = false
    @State private var locationDetails: LocationDetails?
    @State private var notes = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    
    var suggestedLocation: CLLocationCoordinate2D?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFF9F7").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Search Bar
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Search or tap map")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                
                                TextField("Search for a place (e.g., Empire State Building)", text: $searchText)
                                    .onSubmit {
                                        performSearch()
                                    }
                                
                                if isSearching {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                                
                                if !searchText.isEmpty {
                                    Button {
                                        searchText = ""
                                        searchResults = []
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.1), radius: 2)
                            
                            // Search Results
                            if !searchResults.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(searchResults, id: \.self) { item in
                                        Button {
                                            selectSearchResult(item)
                                        } label: {
                                            HStack {
                                                Image(systemName: "mappin.circle")
                                                    .foregroundColor(Color(hex: "#A30000"))
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(item.name ?? "Unknown")
                                                        .font(.subheadline)
                                                        .foregroundColor(.primary)
                                                    
                                                    if let address = item.placemark.title {
                                                        Text(address)
                                                            .font(.caption)
                                                            .foregroundColor(.gray)
                                                            .lineLimit(1)
                                                    }
                                                }
                                                
                                                Spacer()
                                            }
                                            .padding(.vertical, 8)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.1), radius: 2)
                            }
                        }
                        
                        // AI Auto-fill Button
                        if selectedLocation != nil && locationDetails == nil {
                            Button {
                                fetchLocationDetails()
                            } label: {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("Get AI suggestions for this location")
                                    if isLoadingLocation {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    }
                                }
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .cornerRadius(12)
                            }
                            .disabled(isLoadingLocation)
                        }
                        
                        // AI Suggestion Card
                        if let details = locationDetails {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.purple)
                                    Text("AI Suggestions")
                                        .font(.caption.bold())
                                        .foregroundColor(.purple)
                                }
                                
                                Text(details.funTip)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Label("Est. $\(Int(details.estimatedCost))", systemImage: "dollarsign.circle")
                                    Text("•")
                                    Label(details.duration, systemImage: "clock")
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.purple.opacity(0.05))
                            .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location Name")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("Enter location name", text: $pinName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.1), radius: 2)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Estimated Cost (Optional)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            HStack {
                                Text("$")
                                    .foregroundColor(.gray)
                                TextField("0", text: $costEstimate)
                                    .keyboardType(.decimalPad)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.1), radius: 2)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("Add notes or reminders", text: $notes, axis: .vertical)
                                .lineLimit(3...5)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.1), radius: 2)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Location on Map")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                // Current location button
                                LocationButton(.currentLocation) {
                                    useCurrentLocation()
                                }
                                .labelStyle(.iconOnly)
                                .symbolVariant(.fill)
                                .tint(Color(hex: "#A30000"))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            ZStack {
                                MapViewWithTap(
                                    region: $region,
                                    selectedLocation: $selectedLocation,
                                    selectedMapItem: $selectedMapItem,
                                    onLocationSelected: { coordinate, mapItem in
                                        handleLocationSelection(coordinate: coordinate, mapItem: mapItem)
                                    }
                                )
                                .frame(height: 300)
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.2), radius: 4)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Pin")
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
                        savePin()
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
        .onAppear {
            setupInitialLocation()
        }
    }
    
    // MARK: - Helper Functions
    
    private func setupInitialLocation() {
        if let suggested = suggestedLocation {
            selectedLocation = suggested
            region.center = suggested
            reverseGeocodeLocation(suggested)
        } else if let userLocation = locationManager.currentLocation {
            region.center = userLocation
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        searchResults = []
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false
            
            if let response = response {
                searchResults = response.mapItems
            }
        }
    }
    
    private func selectSearchResult(_ item: MKMapItem) {
        selectedMapItem = item
        selectedLocation = item.placemark.coordinate
        pinName = item.name ?? ""
        searchText = ""
        searchResults = []
        
        // Update map region to show selected location
        withAnimation {
            region.center = item.placemark.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        }
        
        // Optionally fetch AI details
        if locationDetails == nil {
            fetchLocationDetails()
        }
    }
    
    private func handleLocationSelection(coordinate: CLLocationCoordinate2D, mapItem: MKMapItem?) {
        selectedLocation = coordinate
        selectedMapItem = mapItem
        
        if let mapItem = mapItem, let name = mapItem.name {
            pinName = name
        } else {
            reverseGeocodeLocation(coordinate)
        }
    }
    
    private func reverseGeocodeLocation(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                if pinName.isEmpty {
                    pinName = placemark.name ??
                             placemark.thoroughfare ??
                             "\(placemark.locality ?? "Unknown Location")"
                }
            }
        }
    }
    
    private func useCurrentLocation() {
        locationManager.requestLocation()
        if let location = locationManager.currentLocation {
            selectedLocation = location
            region.center = location
            region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            reverseGeocodeLocation(location)
        }
    }
    
    private func fetchLocationDetails() {
        guard let location = selectedLocation else { return }
        
        isLoadingLocation = true
        
        Task {
            do {
                let details = try await aiService.getLocationDetails(for: location)
                await MainActor.run {
                    self.locationDetails = details
                    if pinName.isEmpty {
                        self.pinName = details.name
                    }
                    if costEstimate.isEmpty {
                        self.costEstimate = String(Int(details.estimatedCost))
                    }
                    if notes.isEmpty {
                        self.notes = details.funTip
                    }
                    self.isLoadingLocation = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingLocation = false
                }
            }
        }
    }
    
    private func savePin() {
        guard !pinName.isEmpty else {
            alertMessage = "Please enter a location name"
            showingAlert = true
            return
        }
        
        guard let location = selectedLocation else {
            alertMessage = "Please select a location on the map"
            showingAlert = true
            return
        }
        
        let cost = Double(costEstimate) ?? 0
        
        // Save the pin to the current trip
        if let tripId = appState.currentTripID {
            let newPin = TripPin(
                name: pinName,
                coordinate: location,
                costEstimate: cost,
                notes: notes
            )
            appState.addPin(to: tripId, pin: newPin)
        }
        
        dismiss()
    }
}

// Custom Map View with Tap Gesture
struct MapViewWithTap: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var selectedMapItem: MKMapItem?
    var onLocationSelected: (CLLocationCoordinate2D, MKMapItem?) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        mapView.showsUserLocation = true
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        
        // Update annotation
        mapView.removeAnnotations(mapView.annotations)
        if let location = selectedLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            mapView.addAnnotation(annotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewWithTap
        
        init(_ parent: MapViewWithTap) {
            self.parent = parent
        }
        
        @objc func handleMapTap(gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            parent.selectedLocation = coordinate
            parent.onLocationSelected(coordinate, nil)
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
        }
    }
}

// Temporary struct for map annotations
struct TempPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
