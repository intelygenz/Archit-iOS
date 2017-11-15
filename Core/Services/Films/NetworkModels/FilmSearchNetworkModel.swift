//  FilmSearchNetworkModel.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation

struct FilmSearchNetworkModel: Codable {
    let results: [FilmNetworkModel]?
    let total: String?
    let response: String
    let error: String?

    enum CodingKeys: String, CodingKey {
        case results = "Search"
        case total = "totalResults"
        case response = "Response"
        case error = "Error"
    }
}
