//
//  FinpinApp.swift
//  Finpin
//
//  Created by Asmi Kachare on 10/26/25.
//

import SwiftUI

@main
struct FinpinApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
        }
    }
}
