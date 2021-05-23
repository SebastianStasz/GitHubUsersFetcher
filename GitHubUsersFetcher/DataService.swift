//
//  DataService.swift
//  GitHubUsersFetcher
//
//  Created by Sebastian Staszczyk on 23/05/2021.
//

import Combine
import Foundation

protocol APIService {
   func fetchData<T: Decodable>(with request: URLRequest) -> AnyPublisher<T, Error>
   func fetchData<T: Decodable>(from url: URL) -> AnyPublisher<T, Error>
}

class DataService: APIService {
   static let shared = DataService()
   
   private let decoder = JSONDecoder()
   
   func fetchData<T: Decodable>(with request: URLRequest) -> AnyPublisher<T, Error> {
      URLSession.shared.dataTaskPublisher(for: request)
         .map(\.data)
         .decode(type: T.self, decoder: decoder)
         .eraseToAnyPublisher()
   }
   
   func fetchData<T: Decodable>(from url: URL) -> AnyPublisher<T, Error> {
      URLSession.shared.dataTaskPublisher(for: url)
         .map(\.data)
         .decode(type: T.self, decoder: decoder)
         .eraseToAnyPublisher()
   }
}
