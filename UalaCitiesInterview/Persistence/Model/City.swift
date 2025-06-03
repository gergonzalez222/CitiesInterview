//
//  City.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 26/05/2025.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class City: Identifiable, Hashable, Sendable {
    @Attribute(.unique) var id: Int
    var name: String
    var country: String
    var latitude: Double
    var longitude: Double
    var isFavorite: Bool = false

    init(id: Int, name: String, country: String, latitude: Double, longitude: Double, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.isFavorite = isFavorite
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func placeholder() -> City {
        .init(id: 1, name: "Alabama", country: "US", latitude: -32.889698, longitude: -68.844576)
    }
}
