//
//  Bool.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 02/06/2025.
//

import Foundation

extension Bool {
    static func random() -> Bool {
        return arc4random_uniform(2) == 0
    }
}
