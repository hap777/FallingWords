//
//  GameModel.swift
//  FallingWords
//
//  Created by Hossein Asadi on 3/24/22.
//

import Foundation

struct Word: Codable, Equatable {
    let english: String
    let spanish: String

    enum CodingKeys: String, CodingKey {
        case english = "text_eng"
        case spanish = "text_spa"
    }
}
