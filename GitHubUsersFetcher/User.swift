//
//  User.swift
//  GitHubUsersFetcher
//
//  Created by Sebastian Staszczyk on 23/05/2021.
//

import Foundation

struct User {
   let id: Int
   let login: String
   let userUrl: String
   let avatarUrl: String
   var publicRepos: Int?
}

extension User: Decodable {
   
   enum CodingKeys: String, CodingKey {
      case id, login
      case userUrl = "url"
      case avatarUrl = "avatar_url"
      case publicRepos = "public_repos"
   }
}
