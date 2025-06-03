//
//  CityPersisterProtocol.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 30/05/2025.
//

import SwiftData
import Foundation

protocol CityPersisterProtocol {
    func setContext(_ context: ModelContext)
    func deleteAllCities() throws
    func saveCitiesInChunks(_ cities: [City], chunkSize: Int) async throws -> TimeInterval
    func setFavorite(_ city: City)
}
