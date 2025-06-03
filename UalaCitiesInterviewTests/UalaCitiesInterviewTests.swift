//
//  UalaCitiesInterviewTests.swift
//  UalaCitiesInterviewTests
//
//  Created by Martin German Gonzalez Moran on 26/05/2025.
//

import XCTest
@testable import UalaCitiesInterview
import SwiftData

@MainActor
final class CityListViewModelTests: XCTestCase {

    private var viewModel: CityListViewModel!
    private var mockNetworkingService: MockNetworkingService!
    private var mockPersister: MockCityPersister!
    private var modelContext: ModelContext!

    override func setUp() {
        mockNetworkingService = MockNetworkingService()
        mockPersister = MockCityPersister()

        let container = try! ModelContainer(for: City.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        modelContext = ModelContext(container)

        let environment = CityListEnvironment(networkingService: mockNetworkingService, persister: mockPersister)
        viewModel = CityListViewModel(environment: environment)
        viewModel.setContext(modelContext)
    }

    override func tearDown() {
        viewModel = nil
        mockNetworkingService = nil
        mockPersister = nil
        modelContext = nil
    }

    func testSearchEmptyText() async {
        // Given
        insertCity(id: 1, name: "Buenos Aires", country: "Argentina")
        insertCity(id: 2, name: "Montevideo", country: "Uruguay")
        
        try? modelContext.save()

        // When
        viewModel.searchText = ""
        await viewModel.send(action: .search)

        // Then
        XCTAssertEqual(viewModel.state.cities.count, 2)
    }

    func testSearchSingleCharacter() async {
        // Given
        insertCity(id: 1, name: "Buenos Aires", country: "Argentina")
        insertCity(id: 2, name: "Montevideo", country: "Uruguay")
        insertCity(id: 3, name: "Madrid", country: "Spain")
        
        try? modelContext.save()

        // When
        viewModel.searchText = "M"
        await viewModel.send(action: .search)

        // Then
        XCTAssertEqual(viewModel.state.cities.count, 2)
        XCTAssertTrue(viewModel.state.cities.contains(where: { $0.name == "Montevideo" }))
        XCTAssertTrue(viewModel.state.cities.contains(where: { $0.name == "Madrid" }))
    }

    func testSearchTwoCharacters() async {
        // Given
        insertCity(id: 1, name: "Madrid", country: "Spain")
        insertCity(id: 2, name: "Malaga", country: "Spain")
        insertCity(id: 3, name: "Praga", country: "Chezc Republic")
        
        try? modelContext.save()

        // When
        viewModel.searchText = "Ma"
        await viewModel.send(action: .search)
        
        // Then
        XCTAssertEqual(viewModel.state.cities.count, 2)
        
        XCTAssertTrue(viewModel.state.cities.contains(where: { $0.name == "Madrid" }))
        XCTAssertTrue(viewModel.state.cities.contains(where: { $0.name == "Malaga" }))
    }

    func testSearchFullName() async throws {
        // Given
        insertCity(id: 1, name: "Lima", country: "Peru")
        insertCity(id: 2, name: "Barcelona", country: "Spain")
        
        try? modelContext.save()

        // When
        viewModel.searchText = "Barcelona"
        await viewModel.send(action: .search)
        
        // Then
        XCTAssertEqual(viewModel.state.cities.count, 1)
        XCTAssertEqual(viewModel.state.cities.first?.name, "Barcelona")
    }
    
    func testShowFavorites() async {
        // Given
        insertCity(id: 1,name: "Quito", country: "Ecuador", isFavorite: true)
        insertCity(id: 2,name: "Caracas", country: "Venezuela", isFavorite: false)
        
        try? modelContext.save()

        // When
        viewModel.showFavorites = true
        await viewModel.send(action: .showFavorites)

        // Then
        XCTAssertEqual(viewModel.state.cities.count, 1)
        XCTAssertEqual(viewModel.state.cities.first?.name, "Quito")
    }
    
    func testLoadNextPage() async {
        // Given
        for i in 1...100 {
            insertCity(id: i, name: "City\(i)", country: "Country\(i)")
        }
        try? modelContext.save()
        

        // When - Then
        await viewModel.send(action: .loadNextPage)
        XCTAssertEqual(viewModel.state.cities.count, 50)

        await viewModel.send(action: .loadNextPage)
        XCTAssertEqual(viewModel.state.cities.count, 100)
    }
    
    private func insertCity(id: Int, name: String, country: String, isFavorite: Bool = false) {
        let city = City(id: id, name: name, country: country, latitude: 0.0, longitude: 0.0)
        city.isFavorite = isFavorite
        modelContext.insert(city)
    }
}
