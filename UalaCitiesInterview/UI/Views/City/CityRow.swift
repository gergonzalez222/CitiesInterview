//
//  CityRow.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 27/05/2025.
//

import SwiftUI

struct CityRow: View {
    let city: City
    let onFavorite: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                
                Text("\(city.name) \(city.country)")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Latitud: \(city.latitude, specifier: "%.4f")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Longitud: \(city.longitude, specifier: "%.4f")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                onFavorite()
            } label: {
                Image(systemName: city.isFavorite ? "bolt.heart.fill" : "bolt.heart")
                    .foregroundStyle(city.isFavorite ? .cyan : .gray)
                    .symbolEffect(.bounce, value: city.isFavorite)
            }
        }
        .padding(12)
    }
}

#Preview {
    CityRow(city: .init(id: 123, name: "Mendoza", country: "VE", latitude: 51.123345, longitude: -98.234567), onFavorite: {})
}
