//
//  MainTabView.swift
//  Finpin
//
//  Created by Asmi Kachare on 10/26/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TripsView()
                .tabItem {
                    Label("Trips", systemImage: "airplane")
                }
            PinsView()
                .tabItem {
                    Label("Pins", systemImage: "mappin.and.ellipse")
                }
            BudgetView()
                .tabItem {
                    Label("Budget", systemImage: "dollarsign.circle")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}
