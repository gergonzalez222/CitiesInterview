//
//  String.swift
//  UalaCitiesInterview
//
//  Created by Martin German Gonzalez Moran on 26/05/2025.
//

// MARK: Emoji Flag Mapper

extension String {
    var flagEmoji: String {
        let base: UInt32 = 127397
        let uppercased = self.uppercased()

        guard uppercased.count == 2 else { return "🏳️" }

        var emoji = ""
        for scalar in uppercased.unicodeScalars {
            guard let flagScalar = UnicodeScalar(base + scalar.value) else {
                return "🏳️"
            }
            emoji.unicodeScalars.append(flagScalar)
        }

        return emoji
    }
}

