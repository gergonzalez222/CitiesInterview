//
//  UalaCitiesInterviewApp.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 26/05/2025.
//

import SwiftUI
import SwiftData

@main
struct UalaCitiesInterviewApp: App {

    var body: some Scene {
        WindowGroup {
            CitiesListView(viewModel: CityListViewModel(environment: environment))
        }
        .modelContainer(for: City.self)
    }

    private var environment: CityListEnvironment {
        if isRunningUITests {
            let mockNetwork = MockNetworkingServiceUITests()
            mockNetwork.citiesToReturn = [
                CityDTO(
                    id: 1,
                    name: "Buenos Aires",
                    country: "AR",
                    coordinates: .init(
                        lon: 10.0,
                        lat: 10.0
                    )
                ),
                CityDTO(
                    id: 2,
                    name: "Madrid",
                    country: "SP",
                    coordinates: .init(
                        lon: 10.0,
                        lat: 10.0
                    )
                ),
                CityDTO(
                    id: 3,
                    name: "Lima",
                    country: "PE",
                    coordinates: .init(
                        lon: 10.0,
                        lat: 10.0
                    )
                )
            ]

            let mockPersister = MockCityPersisterUITesting()
            return CityListEnvironment(networkingService: mockNetwork, persister: mockPersister)
        } else {
            return CityListEnvironment(
                networkingService: NetworkingService(),
                persister: CityPersister()
            )
        }
    }

    private var isRunningUITests: Bool {
        CommandLine.arguments.contains("UI-TESTING")
    }
}
