//
//  Array.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 28/05/2025.
//

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
