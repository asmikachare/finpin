//
//  ProfileView.swift
//  Finpin
//
//  Created by Asmi Kachare on 10/26/25.
//


import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color(hex: "#FFF9F7").ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Profile")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color(hex: "#A30000"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                
                Circle()
                    .fill(Color(hex: "#A30000"))
                    .frame(width: 100, height: 100)
                    .overlay(Text("A").font(.largeTitle.bold()).foregroundColor(.white))
                
                Text("Asmi Kachare")
                    .font(.title2.bold())
                    .foregroundColor(Color(hex: "#222222"))
                
                List {
                    Label("Currency Settings", systemImage: "dollarsign.circle")
                    Label("Notifications", systemImage: "bell")
                    Label("Privacy", systemImage: "lock")
                }
                .scrollContentBackground(.hidden)
                .background(Color(hex: "#FFF9F7"))
            }
        }
    }
}
