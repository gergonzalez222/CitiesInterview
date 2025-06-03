//
//  CityPersister.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 26/05/2025.
//

import SwiftData
import Foundation

enum PersisterError: Error {
    case contextNotSet
}

// MARK: - CityPersister Implementation

final class CityPersister: CityPersisterProtocol {
    private var context: ModelContext?

    func setContext(_ context: ModelContext) {
        self.context = context
    }

    func deleteAllCities() throws {
        guard let context = context else { throw PersisterError.contextNotSet }
        let existing = try context.fetch(FetchDescriptor<City>())
        var deletedCount = 0
        for city in existing {
            context.delete(city)
            deletedCount += 1
        }
        try context.save()
        print("🗑️ Eliminadas \(deletedCount) ciudades")
    }

    func saveCitiesInChunks(_ cities: [City], chunkSize: Int = 2000) async throws -> TimeInterval {
        
        let start = Date()

        let modelContainer = try ModelContainer(for: City.self)

        let chunks = cities.chunked(into: chunkSize)
        let totalChunks = chunks.count

        try await withThrowingTaskGroup(of: Int.self) { group in
            for (index, chunk) in chunks.enumerated() {
                group.addTask {
                    let context = ModelContext(modelContainer)
                    var savedCount = 0

                    for city in chunk {
                        context.insert(city)
                        savedCount += 1
                    }

                    try context.save()

                    print("📂 Guardado chunk \(index + 1) / \(totalChunks) - \(chunk.count) ciudades")
                    return savedCount
                }
            }

            let totalSaved = try await group.reduce(0, +)
            print("✅ Total de ciudades guardadas: \(totalSaved)")
        }

        return Date().timeIntervalSince(start)
    }


    func setFavorite(_ city: City) {
        city.isFavorite.toggle()
        do {
            try context?.save()
        } catch {
            print("Error al guardar favorito: \(error)")
        }
    }
}

// MARK: - MockCityPersister Implementation

final class MockCityPersister: CityPersisterProtocol {
    var context: ModelContext?

    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    func deleteAllCities() throws {}
    
    func saveCitiesInChunks(_ cities: [City], chunkSize: Int) async throws -> TimeInterval { 0.0 }
    
    func setFavorite(_ city: City) {}
}

final class MockCityPersisterUITesting: CityPersisterProtocol {
    var context: ModelContext?

    func setContext(_ context: ModelContext) {
        self.context = context
        
        try? deleteAllCities()
    }

    func deleteAllCities() throws {
        guard let context else { return }
        let allCities = try context.fetch(FetchDescriptor<City>())
        for city in allCities {
            context.delete(city)
        }
        try context.save()
    }

    func saveCitiesInChunks(_ cities: [City], chunkSize: Int) async throws -> TimeInterval {
        guard let context else { return 0.0 }

        return try await Task { @MainActor in
            let start = Date()
            for chunk in cities.chunked(into: chunkSize) {
                for city in chunk {
                    context.insert(city)
                }
            }
            try context.save()
            return Date().timeIntervalSince(start)
        }.value
    }

    func setFavorite(_ city: City) {
        city.isFavorite.toggle()
        try? context?.save()
    }
}
