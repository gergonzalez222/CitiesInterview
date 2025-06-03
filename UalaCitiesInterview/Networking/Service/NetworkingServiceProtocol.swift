//
//  NetworkingServiceProtocol.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 26/05/2025.
//

// MARK: - NetworkingServiceProtocol

protocol NetworkingServiceProtocol: AnyObject {
    func fetchCities() async throws -> [City]
}
