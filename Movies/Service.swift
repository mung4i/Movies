//
//  Service.swift
//  Movies
//
//  Created by Martin Mungai on 30/10/2018.
//  Copyright © 2018 Martin Mungai. All rights reserved.
//

import Foundation

public enum MoviesServiceError: Error {
    case invalidRequest
    case invalidURLComponents
    case invalidURL
    case missingData
}

public enum Result<T> {
    case success(T)
    case failure(Error)
}

public class MoviesService {
    
    private static let apiKey = "1e6ba916"
    private static let baseURL = "https://www.omdbapi.com/"
    
    private let session: URLSession
    typealias searchParameter = [String: String]
    typealias searchResults = [String: Any]
    
    public init() {
        self.session = URLSession.shared
    }
    
    func getImage(from url : URL, queue: DispatchQueue, completion: @escaping (Result<Any>) -> Void) {
        
        let task = session.dataTask(with: url) { (data, _, error) in
            if let data = data {
                queue.async { completion(.success(data)) }
            }
        }
        task.resume()
    }
    
    func sendRequest(search: searchParameter,
                     queue: DispatchQueue,
                     completion: @escaping (Result<Any>) -> Void) {
        
        guard var components = URLComponents(string: MoviesService.baseURL) else {
            completion(.failure(MoviesServiceError.invalidURLComponents)); return
        }
        
        var queryItems = [URLQueryItem]()
        
        search.forEach { queryItems.append(URLQueryItem(name: $0.key, value: $0.value)) }
        queryItems.append(URLQueryItem(name: "apikey", value: MoviesService.apiKey))
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            completion(.failure(MoviesServiceError.invalidURL)); return
        }
        
        var requestURL = URLRequest(url: url)
        
        requestURL.httpMethod = "GET"
        requestURL.addValue(MoviesService.apiKey, forHTTPHeaderField: "apikey")
        
        let task = session.dataTask(with: requestURL) { data, _, error in
            if let error = error {
                queue.async { completion(.failure(error)) }
            }
            
            if let data = data {
                do {
                    let movies = try MovieResponse(data: data)
                    queue.async { completion(.success(movies)) }
                } catch let error {
                    queue.async { completion(.failure(error)) }
                }
            }
        }
        task.resume()
    }
}
