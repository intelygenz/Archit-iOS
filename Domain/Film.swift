//  Film.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation

public struct Film {
    public let imdbID: String
    public let title: String
    public let year: String
    public let type: String
    public let ratings: [String: String]
    public let poster: URL?
    public let rated: String?
    public let released: Date?
    public let runtime: TimeInterval?
    public let genre: String?
    public let director: String?
    public let writer: String?
    public let actors: String?
    public let plot: String?
    public let language: String?
    public let country: String?
    public let awards: String?
    public let metascore: String?
    public let imdbRating: String?
    public let imdbVotes: String?
    public let dvd: Date?
    public let boxOffice: String?
    public let production: String?
    public let website: URL?

    public init(imdbID: String, title: String, year: String, type: String, ratings: [String: String], poster: URL?, rated: String?, released: Date?, runtime: TimeInterval?, genre: String?, director: String?, writer: String?, actors: String?, plot: String?, language: String?, country: String?, awards: String?, metascore: String?, imdbRating: String?, imdbVotes: String?, dvd: Date?, boxOffice: String?, production: String?, website: URL?) {
        self.imdbID = imdbID
        self.title = title
        self.year = year
        self.type = type
        self.ratings = ratings
        self.poster = poster
        self.rated = rated
        self.released = released
        self.runtime = runtime
        self.genre = genre
        self.director = director
        self.writer = writer
        self.actors = actors
        self.plot = plot
        self.language = language
        self.country = country
        self.awards = awards
        self.metascore = metascore
        self.imdbRating = imdbRating
        self.imdbVotes = imdbVotes
        self.dvd = dvd
        self.boxOffice = boxOffice
        self.production = production
        self.website = website
    }
}
