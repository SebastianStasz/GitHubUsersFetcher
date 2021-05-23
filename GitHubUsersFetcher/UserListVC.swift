//
//  UserListVC.swift
//  GitHubUsersFetcher
//
//  Created by Sebastian Staszczyk on 23/05/2021.
//

import Combine
import UIKit

class UserListVC: UIViewController {
   private var canRefresh = true
   private var cancellables: Set<AnyCancellable> = []
   private let gitHubUsersService: GitHubUsersService
   private let userListTB = UITableView()
   private var spinner: UIActivityIndicatorView!
   
   init(gitHubUsersService: GitHubUsersService) {
      self.gitHubUsersService = gitHubUsersService
      super.init(nibName: nil, bundle: nil)
      
      gitHubUsersService.insertItemsAtIndexPath
         .sink { [unowned self] indexPaths in
            userListTB.insertRows(at: indexPaths, with: .automatic)
            userListTB.tableFooterView = nil
         }
         .store(in: &cancellables)
      
      gitHubUsersService.updateItemAtIndexPath
         .receive(on: DispatchQueue.main)
         .sink { [unowned self] inexPath in
            userListTB.reloadRows(at: [inexPath], with: .none)
         }
         .store(in: &cancellables)
      
      gitHubUsersService.$isLoading
         .receive(on: DispatchQueue.main)
         .sink { [unowned self] isLoading in
            if isLoading && gitHubUsersService.users.isEmpty {
               userListTB.backgroundView = spinner
               userListTB.separatorStyle = .none
            } else {
               userListTB.backgroundView = nil
               userListTB.separatorStyle = .singleLine
            }
         }
         .store(in: &cancellables)
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      userListTB.delegate = self
      userListTB.dataSource = self
      
      spinner = Self.spinner(for: view)
      
      title = "GitHub Users"
      navigationController?.navigationBar.isTranslucent = true
      navigationController?.navigationBar.prefersLargeTitles = true
      
      let refreshBTN = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
      navigationItem.rightBarButtonItem = refreshBTN
      
      userListTB.rowHeight = 100
      userListTB.allowsSelection = false
      userListTB.register(UserCell.self, forCellReuseIdentifier: UserCell.id)
      
      view = userListTB
   }
   
   @objc private func refresh() {
      guard canRefresh else { return }
      canRefresh = false
      
      gitHubUsersService.refresh()
      userListTB.reloadData()
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
         self?.canRefresh = true
      }
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
}

// MARK: -- TableView Configuration

extension UserListVC: UITableViewDelegate, UITableViewDataSource {
   
   
//   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//      gitHubUsersService.users.count
//   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      let count = gitHubUsersService.users.count
      return count
//      return count == 0 ? 0 : count - 15
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.id) as! UserCell
      let user = gitHubUsersService.users[indexPath.row]
      cell.configuration(with: user)
      return cell
   }
}

// MARK: -- Scroll Behaviour

extension UserListVC: UIScrollViewDelegate {
   
   func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      guard !gitHubUsersService.isLoading else { return }
      
      let offsetY = scrollView.contentOffset.y
      let contentHeight = userListTB.contentSize.height
      
      if (offsetY > contentHeight - 200 - scrollView.frame.size.height) {
         userListTB.tableFooterView = createSpinnerView()
         gitHubUsersService.loadMore()
      }
   }
   
   private func createSpinnerView() -> UIView {
      let view = UIView(frame: CGRect(x: 0, y: -30, width: view.frame.size.width, height: 50))
      let spinner = Self.spinner(for: view)
      view.addSubview(spinner)
      
      return view
   }
}

extension UIViewController {
   static func spinner(for view: UIView) -> UIActivityIndicatorView {
      let spinner = UIActivityIndicatorView()
      spinner.center = view.center
      spinner.startAnimating()
      return spinner
   }
}

