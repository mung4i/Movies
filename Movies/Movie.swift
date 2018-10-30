//
//  Movie.swift
//  Movies
//
//  Created by Martin Mungai on 30/10/2018.
//  Copyright © 2018 Martin Mungai. All rights reserved.
//

import Foundation

struct Movie {
    
    let id: String
    let poster: String
    let title: String
    let type: String
    let year: String
    
    enum CodingKeys: String, CodingKey {
        case id = "imdbID"
        case poster = "Poster"
        case title = "Title"
        case type = "Type"
        case year = "Year"
        
    }
}

extension Movie: Decodable {
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        poster = try container.decode(String.self, forKey: .poster)
        title = try container.decode(String.self, forKey: .title)
        type = try container.decode(String.self, forKey: .type)
        year = try container.decode(String.self, forKey: .year)
    }
    
    init(data: Data) throws {
        self = try JSONDecoder().decode(Movie.self, from: data)
    }
}
 

