//  FilmsNetworkTransformer.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation
import Domain

class FilmsNetworkTransformer: NetworkServiceTransformer<FilmNetworkModel, Film> {

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        return dateFormatter
    }()

    override func transform(source: FilmNetworkModel) -> Film? {
        var ratings = [String: String]()
        source.ratings?.forEach({ rating in
            ratings[rating.source] = rating.value
        })
        var releasedDate: Date?
        if let released = source.released {
            releasedDate = FilmsNetworkTransformer.dateFormatter.date(from: released)
        }
        var runtimeInterval: TimeInterval?
        if let runtime = source.runtime, runtime.contains(" min"), let timeInterval = TimeInterval(runtime.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
            runtimeInterval = timeInterval * 60
        }
        var dvdDate: Date?
        if let dvd = source.dvd {
            dvdDate = FilmsNetworkTransformer.dateFormatter.date(from: dvd)
        }
        var websiteURL: URL?
        if let website = source.website, website != "N/A" {
            websiteURL = URL(string: website)
        }
        var posterURL: URL?
        if source.poster != "N/A" {
            posterURL = URL(string: source.poster)
        }
        return Film(imdbID: source.imdbID, title: source.title, year: source.year, type: source.type, ratings: ratings, poster: posterURL, rated: source.rated, released: releasedDate, runtime: runtimeInterval, genre: source.genre, director: source.director, writer: source.writer, actors: source.actors, plot: source.plot, language: source.language, country: source.country, awards: source.awards, metascore: source.metascore, imdbRating: source.imdbRating, imdbVotes: source.imdbVotes, dvd: dvdDate, boxOffice: source.boxOffice, production: source.production, website: websiteURL)
    }

}
