//
//  GitHubUsersService.swift
//  GitHubUsersFetcher
//
//  Created by Sebastian Staszczyk on 23/05/2021.
//

import Combine
import Foundation

class GitHubUsersService: ObservableObject {
   private let tknSource = "http://v-ie.uek.krakow.pl/~s215740/tkn.json"
   private var cancellables: Set<AnyCancellable> = []
   private let dataService: APIService
   private var gitHubAPI: GitHubAPI
   
   private var sinceUser = 0
   private let perPage = 15
   
   let updateItemAtIndexPath = PassthroughSubject<IndexPath, Never>()
   let insertItemsAtIndexPath = PassthroughSubject<[IndexPath], Never>()
   private let fetchUsersDetails = PassthroughSubject<[User], Never>()
   @Published private var usersURLRequest: URLRequest?
   
   private(set) var users: [User] = []
   @Published private(set) var isLoading = false
   
   init(dataService: APIService) {
      self.dataService = dataService
      self.gitHubAPI = GitHubAPI(apiToken: "")
      
      dataService.fetchData(from: URL(string: tknSource)!)
         .sink { [unowned self] in
            if case .finished = $0 {
               usersURLRequest = gitHubAPI.getUsersURLRequest(since: sinceUser, perPage: perPage)
            }
         } receiveValue: { [unowned self] (tkn: [String : String]) in
            gitHubAPI = GitHubAPI(apiToken: tkn.values.first!)
         }
         .store(in: &cancellables)
      
      setupDataFetching()
   }
}

// MARK: -- Data Fetching

extension GitHubUsersService {
   
   private func setupDataFetching() {
      
      $usersURLRequest
         .compactMap { $0 }
         .flatMap { [unowned self] urlRequest -> AnyPublisher<[User], Error> in
            isLoading = true
            return dataService.fetchData(with: urlRequest)
         }
         .receive(on: DispatchQueue.main)
         .sink { if case .failure(let error) = $0 {
            print("Fetching users error: \(error)")
         }
         } receiveValue: { [unowned self] newUsers in
            let lastIndex = users.endIndex
            sinceUser = newUsers.last!.id
            users.append(contentsOf: newUsers)
            let range = lastIndex..<lastIndex + newUsers.count
            insertItemsAtIndexPath.send(range.map { IndexPath(row: $0, section: 0) })
            fetchUsersDetails.send(newUsers)
            isLoading = false
         }
         .store(in: &cancellables)
      
      fetchUsersDetails
         .sink { [unowned self] usersDetail in
            _ = usersDetail.map { user in
               let urlRequest = gitHubAPI.getURLRequest(for: user.userUrl)
               
               dataService.fetchData(with: urlRequest!)
                  .sink { _ in } receiveValue: { (user: User) in
                     let index = users.firstIndex(where: { $0.id == user.id })
                     assert(index != nil, "User should already be in the array.")
                     if let index = index {
                        users[index].publicRepos = user.publicRepos
                        updateItemAtIndexPath.send(IndexPath(row: index, section: 0))
                     }
                  }
                  .store(in: &cancellables)
            }
         }
         .store(in: &cancellables)
   }
}

// MARK: -- Intents

extension GitHubUsersService {
   
   func loadMore() {
      usersURLRequest = gitHubAPI.getUsersURLRequest(since: sinceUser, perPage: perPage)
   }
   
   func refresh() {
      users = []
      sinceUser = 0
      loadMore()
   }
}

