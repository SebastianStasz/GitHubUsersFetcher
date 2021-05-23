//
//  GitHubAPI.swift
//  GitHubUsersFetcher
//
//  Created by Sebastian Staszczyk on 23/05/2021.
//

import Foundation

struct GitHubAPI {
   private var startComponents: URLComponents
   private let apiToken: String
   
   init(apiToken: String) {
      self.apiToken = apiToken
      startComponents = URLComponents()
      setupUrlComponents()
   }
   
   mutating private func setupUrlComponents() {
      startComponents.scheme = "https"
      startComponents.host = "api.github.com"
      startComponents.queryItems = []
      let perPageQueryItem = URLQueryItem(name: "per_page", value: "20")
      startComponents.queryItems?.append(perPageQueryItem)
   }
}

// MARK: -- Access

extension GitHubAPI {
   
   func getUsersURLRequest(since: Int, perPage: Int) -> URLRequest {
      let perPageQueryItem = URLQueryItem(name: "per_page", value: String(perPage))
      let sinceQueryItem = URLQueryItem(name: "since", value: String(since))
      var usersURL = startComponents
      usersURL.path = "/users"
      usersURL.queryItems = [sinceQueryItem, perPageQueryItem]
      
      let request = getURLRequest(for: usersURL.url!)!
      
      return request
   }
   
   func getURLRequest(for url: String) -> URLRequest? {
      guard let url = URL(string: url) else { return nil }
      guard let request = getURLRequest(for: url) else { return nil }
      return request
   }
   
   func getURLRequest(for url: URL) -> URLRequest? {
      var request = URLRequest(url: url)
      request.setValue("Bearer \(apiToken)", forHTTPHeaderField:"Authorization")
      return request
   }
}

