//
//  CitiesListView.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 29/05/2025.
//

import SwiftUI

struct CitiesListView: View {
    @Environment(\.modelContext) private var context
    @ObservedObject var viewModel: CityListViewModel

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            contentView
                .navigationTitle("Ciudades")
                .searchable(text: $viewModel.searchText)
                .textInputAutocapitalization(.never)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(
                            action: {
                                viewModel.showFavorites.toggle()
                            },
                            label: {
                                Text("Favoritos")
                                    .foregroundStyle(viewModel.showFavorites ? .green : .blue)
                            }
                        )
                        .accessibilityIdentifier("ShowFavoritesButton_ID")
                    }
                    
                }
        } detail: {
            if let city = viewModel.selectdCity {
                CityMapView(city: city)
            } else {
                Text("Selecciona una ciudad")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
        .task {
            await viewModel.send(action: .onAppear(context: context))
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state.viewState {
        case .loading:
            ProgressView("Cargando...")
                .frame(maxWidth: .infinity, minHeight: 300)

        case .noData:
            Text("No se encontraron ciudades")
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, minHeight: 300)

        case .error(let message):
            Text("Error: \(message)")
                .foregroundColor(.red)
                .padding()

        case .content:
            List(viewModel.state.cities, id: \City.id) { city in
                NavigationLink(destination: CityMapView(city: city)) {
                    Button(action: {
                        viewModel.selectdCity = city
                    }) {
                        CityRow(city: city, onFavorite: {
                            Task {
                                await viewModel.send(action: .updateFavorite(city))
                            }
                        })
                    }
                    .onAppear {
                        if city == viewModel.state.cities.last {
                            Task {
                                await viewModel.send(action: .loadNextPage)
                            }
                        }
                    }
                    .accessibilityIdentifier("ToggleFavoriteButton_ID")
                }
            }
            .listStyle(.plain)
            .accessibilityIdentifier("CityListView_ID")
        }
    }
}
