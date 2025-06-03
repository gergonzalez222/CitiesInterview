//
//  ViewState.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 28/05/2025.
//

enum ViewState<T>: Equatable {
    static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool { return true }
    
    case noData
    case loading
    case error(message: String)
    case content(T)
}
