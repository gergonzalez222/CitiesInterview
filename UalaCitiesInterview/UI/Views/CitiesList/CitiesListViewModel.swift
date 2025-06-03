//
//  CitiesListViewModel.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 28/05/2025.
//

import Foundation
import SwiftData
import Combine

// MARK: - ViewState

struct CityListState: Equatable {
    var cities: [City] = []
    var viewState: ViewState<[City]> = .loading
    var persistTime: TimeInterval?
}

enum CityListAction: Equatable {
    case onAppear(context: ModelContext)
    case search
    case loadNextPage
    case showFavorites
    case updateFavorite(_ City: City)
    case refreshAfterFavorites
}

struct CityListEnvironment {
    let networkingService: NetworkingServiceProtocol
    let persister: CityPersisterProtocol
    
    func setContext(_ context: ModelContext) {
        persister.setContext(context)
    }
}


// MARK: - ViewModel

@MainActor
final class CityListViewModel: ObservableObject {
    @Published private(set) var state = CityListState()
    @Published var searchText: String = ""
    
    @Published var selectdCity: City?
    @Published var showFavorites: Bool = false
    
    private var cancellables = Set<AnyCancellable>()

    private let environment: CityListEnvironment
    private(set) var context: ModelContext?

    private let pageSize: Int = 50
    private var currentOffset: Int = 0

    init(environment: CityListEnvironment) {
        self.environment = environment
    }
    
    func setContext(_ context: ModelContext?) {
        guard let context = context else { return }
        self.context = context
        environment.setContext(context)
    }
    
    // MARK: - Binding
    
    func bindSearchText() {
        $searchText
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                Task {
                    await self?.send(action: .search)
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindShowFavorites() {
        $showFavorites
            .removeDuplicates()
            .sink { [weak self] _ in
                Task {
                    await self?.send(action: .showFavorites)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions

    func send(action: CityListAction) async {
        switch action {
        case .onAppear(let context):
            setContext(context)
                await fetchCities()
                bindSearchText()
                bindShowFavorites()
            
        case .search:
            await performSearch()
            
        case .loadNextPage:
            await loadNextPage()
            
        case .showFavorites:
            await loadFavoritiesCities()
            
        case .updateFavorite(let city):
            environment.persister.setFavorite(city)
            await send(action: .refreshAfterFavorites)
            
        case .refreshAfterFavorites:
                if !searchText.isEmpty {
                    await performSearch()
                } else if showFavorites {
                    await loadFavoritiesCities()
                } else {
                    await loadInitialCities()
                }
            
        }
    }

    // MARK: - Data
    
    private func fetchCities() async {
        state.viewState = .loading
        do {
            let cities = try await environment.networkingService.fetchCities()
            try environment.persister.deleteAllCities()
            let duration = try await environment.persister.saveCitiesInChunks(cities, chunkSize: 2000)
            state.persistTime = duration
            print("⏱ Persistencia completada en: \(duration) segundos")
            await loadInitialCities()
        } catch {
            print("❌ Error: \(error)")
            state.viewState = .error(message: error.localizedDescription)
        }
    }
    
    private func loadInitialCities() async {
        do {
            state.cities = []
            currentOffset = 0
            let cities = try fetchAllCities(offset: currentOffset, limit: pageSize)
            currentOffset += cities.count
            state.cities = cities
            state.viewState = cities.isEmpty ? .noData : .content(cities)
        } catch {
            print("❌ Error: \(error)")
            state.viewState = .error(message: error.localizedDescription)
        }
    }
    
    private func loadFavoritiesCities() async {
        do {
            var cities: [City] = []
            resetPagination()
            
            if showFavorites {
                cities = try fetchFavoritiesCities(offset: currentOffset, limit: pageSize)
            } else {
                cities = try fetchAllCities(offset: currentOffset, limit: pageSize)
            }
            
            currentOffset += cities.count
            state.cities = cities
            state.viewState = cities.isEmpty ? .noData : .content(cities)
        } catch {
            print("❌ Error: \(error)")
            state.viewState = .error(message: error.localizedDescription)
        }
    }

    private func performSearch() async {
        do {
            var cities: [City] = []
            resetPagination()
            if searchText.isEmpty {
                if showFavorites {
                    cities = try fetchFavoritiesCities(offset: currentOffset, limit: pageSize)
                } else {
                    cities = try fetchAllCities(offset: currentOffset, limit: pageSize)
                }
            } else {
                cities = try fetchCitiesFiltered(text: searchText, offset: currentOffset, limit: pageSize)
            }
            currentOffset += cities.count
            state.cities = cities
            state.viewState = cities.isEmpty ? .noData : .content(cities)
        } catch {
            print("❌ Error: \(error)")
            state.viewState = .error(message: error.localizedDescription)
        }
    }
    
    private func resetPagination() {
        currentOffset = 0
        state.cities = []
    }
    
    private func loadNextPage() async {
        do {
            let moreCities: [City]
            if !searchText.isEmpty {
                moreCities = try fetchCitiesFiltered(text: searchText, offset: currentOffset, limit: pageSize)
            } else if showFavorites {
                moreCities = try fetchFavoritiesCities(offset: currentOffset, limit: pageSize)
            } else {
                moreCities = try fetchAllCities(offset: currentOffset, limit: pageSize)
            }
            currentOffset += moreCities.count
            state.cities += moreCities
            state.viewState = state.cities.isEmpty ? .noData : .content(state.cities)
        } catch {
            print("❌ Error: \(error)")
            state.viewState = .error(message: error.localizedDescription)
        }
    }
    
    // MARK: - SwiftData Descriptors
    
    private func fetchCitiesFiltered(text: String, offset: Int, limit: Int) throws -> [City] {
        guard let context = context else { throw PersisterError.contextNotSet }
        
        var descriptor = FetchDescriptor<City>()
        descriptor.sortBy = [
            SortDescriptor(\.country, order: .forward),
            SortDescriptor(\.name, order: .forward)
        ]
        
        if showFavorites {
            descriptor.predicate = #Predicate<City> {
                ($0.name.localizedStandardContains(text) || $0.country.localizedStandardContains(text)) &&
                $0.isFavorite == true
            }
        } else {
            descriptor.predicate = #Predicate<City> {
                $0.name.localizedStandardContains(text) || $0.country.localizedStandardContains(text)
            }
        }
        
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset
        return try context.fetch(descriptor)
    }
    
    private func fetchAllCities(offset: Int, limit: Int) throws -> [City] {
        guard let context = context else { throw PersisterError.contextNotSet }
        
        var descriptor = FetchDescriptor<City>()
        descriptor.sortBy = [
            SortDescriptor(\.country, order: .forward),
            SortDescriptor(\.name, order: .forward)
        ]
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset
        return try context.fetch(descriptor)
    }
    
    private func fetchFavoritiesCities(offset: Int, limit: Int) throws -> [City] {
        guard let context = context else { throw PersisterError.contextNotSet }
        
        var descriptor = FetchDescriptor<City>()
        descriptor.sortBy = [
            SortDescriptor(\.country, order: .forward),
            SortDescriptor(\.name, order: .forward)
        ]
        
        descriptor.predicate = #Predicate { $0.isFavorite == true }
        
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset
        return try context.fetch(descriptor)
    }
}
