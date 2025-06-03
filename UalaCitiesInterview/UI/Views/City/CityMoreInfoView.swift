//
//  CityBottomView.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 27/05/2025.
//

import SwiftUI

import SwiftUI

struct CityMoreInfoView: View {
    let city: City

    var body: some View {
        VStack(spacing: 12) {
            
            Text("🗺️")
                .padding(.top)
                    
            Text("\(city.country)")
                .font(.largeTitle)
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Text("\(city.name)")
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 8) {
                Text("Latitud: \(city.latitude, specifier: "%.4f")")
                    .font(.title3)
                    .fontDesign(.rounded)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary)
                Text("Longitud: \(city.longitude, specifier: "%.4f")")
                    .font(.title3)
                    .fontDesign(.rounded)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary)
            }
            
        }
        .padding()
        .padding(.horizontal, 32)
        .cornerRadius(20)
    }
}

#Preview {
    CityMoreInfoView(city: .init(id: 123, name: "Mendoza", country: "VE", latitude: 51.123345, longitude: -98.234567))
}
