//
//  CityDTO.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 26/05/2025.
//

struct CityDTO: Codable {
    let id: Int
    let name: String
    let country: String
    let coordinates: Coordinate
    
    struct Coordinate: Codable {
        let lon: Double
        let lat: Double
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case country
        case coordinates = "coord"
    }
    
    init(id: Int, name: String, country: String, coordinates: Coordinate) {
        self.id = id
        self.name = name
        self.country = country
        self.coordinates = coordinates
    }
    
    func toCity(isFavorite: Bool = false) -> City {
        return City(id: id, name: name, country: country, latitude: coordinates.lat, longitude: coordinates.lon, isFavorite: isFavorite)
    }
    
    static func mockCityDTO() -> CityDTO {
        return CityDTO(
            id: 1234,
            name: "Alabama",
            country: "US",
            coordinates: .init(lon: -51.12312, lat: 78.12512)
        )
    }
}
