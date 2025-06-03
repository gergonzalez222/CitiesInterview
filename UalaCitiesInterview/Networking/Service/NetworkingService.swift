//
//  NetworkingService.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 26/05/2025.
//

import Foundation

// MARK: - NetworkingServiceError

enum NetworkingServiceError: Error {
    case badURL
    case badResponse(Int?)
    case decodingFailure(Error)
    case networkFailure(Error)
}

// MARK: - NetworkingService Implementation

final class NetworkingService: NetworkingServiceProtocol {
    private let endpoint = "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json"

    func fetchCities() async throws -> [City] {
        guard let url = URL(string: endpoint) else {
            throw NetworkingServiceError.badURL
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw NetworkingServiceError.networkFailure(error)
        }

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkingServiceError.badResponse((response as? HTTPURLResponse)?.statusCode)
        }

        return try decodeCities(from: data)
    }

    private func decodeCities(from data: Data) throws -> [City] {
        let decoded = try JSONDecoder().decode([CityDTO].self, from: data)
        return decoded.map { $0.toCity() }
    }
}

// MARK: - MockNetworkingService Implementation

final class MockNetworkingService: NetworkingServiceProtocol {
    var citiesToReturn: [City] = []
    var shouldFail = false

    func fetchCities() async throws -> [City] {
        if shouldFail {
            throw NSError(domain: "MockNetworkingService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Simulated network error"])
        }
        return citiesToReturn
    }
}

final class MockNetworkingServiceUITests: NetworkingServiceProtocol {
    var citiesToReturn: [CityDTO] = []

    func fetchCities() async throws -> [City] {
        return citiesToReturn.map { $0.toCity(isFavorite: true ) }
    }
}
