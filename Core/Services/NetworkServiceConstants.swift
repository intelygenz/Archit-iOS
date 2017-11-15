//  NetworkServiceConstants.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation

struct NetworkServiceConstants {
    struct Host {
        static let api = "http://www.omdbapi.com/"
        static let poster = "http://img.omdbapi.com/"
    }
    struct Parameters {
        enum Search: String {
            case imdbID = "i"
            case title = "s"
            case type
            case year = "y"
            case plot
            case page
            case callback
        }
        static let key = "apikey"
        static let version = "v"
        static let format = "r"
    }
    struct Values {
        struct Search {
            enum SearchType: String {
                case movie, series, episode
            }
            enum Plot: String {
                case short, full
            }
            static let PageRange = 1...100
        }
        static let key = "25a206c6"
        static let version = "1"
        enum Format: String {
            case json, xml
        }
    }
}
