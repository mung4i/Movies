//
//  MovieResponse.swift
//  Movies
//
//  Created by Martin Mungai on 30/10/2018.
//  Copyright © 2018 Martin Mungai. All rights reserved.
//

import Foundation

struct MovieResponse {
    
    // Root Keys
    let totalResults: String
    let response: String
    let movies: [Movie]
    
    enum CodingKeys: String, CodingKey {
        
        case response = "Response"
        case totalResults = "totalResults"
        case search = "Search"
    }
}

extension MovieResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        response = try container.decode(String.self, forKey: .response)
        totalResults = try container.decode(String.self, forKey: .totalResults)
        
        var search = try container.nestedUnkeyedContainer(forKey: .search)
        var _movies = [Movie]()
        while !search.isAtEnd {
            let movie = try search.decode(Movie.self)
            _movies.append(movie)
        }
        self.movies = _movies
    }
    
    init(data: Data) throws {
        self = try JSONDecoder().decode(MovieResponse.self, from: data)
    }
}
