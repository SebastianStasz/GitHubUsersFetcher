//
//  UserCell.swift
//  GitHubUsersFetcher
//
//  Created by Sebastian Staszczyk on 23/05/2021.
//

import UIKit

class UserCell: UITableViewCell {
   static let id = "UserCell"
   
   private var cellHorizontalStack: UIStackView!
   private var innerHorizontalStack: UIStackView!
   
   private let userNameLabel = UILabel()
   private let nrOfRepoLabel = UILabel()
   let avatarImageView = AsyncImageView()
   
   func configuration(with user: User) {
      avatarImageView.url = user.avatarUrl
      userNameLabel.text = user.login
      nrOfRepoLabel.text = String(user.publicRepos ?? 0)
   }
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      setupViews()
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
}

// MARK: -- View Setup

extension UserCell {
   
   private func setupViews() {
      // User Name Label
      userNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
      userNameLabel.tintColor = UIColor.secondaryLabel
      
      // Number Of Repositories Label
      nrOfRepoLabel.font = .systemFont(ofSize: 14, weight: .medium)
      nrOfRepoLabel.tintColor = UIColor.secondaryLabel
      
      // User Avatar Image View
      avatarImageView.layer.cornerRadius = 10
      avatarImageView.layer.borderWidth = 2
      avatarImageView.layer.borderColor = UIColor.systemGray3.cgColor
      avatarImageView.clipsToBounds = true
      
      innerHorizontalStack = UIStackView(arrangedSubviews: [avatarImageView, userNameLabel])
      innerHorizontalStack.axis = .horizontal
      innerHorizontalStack.spacing = 20
      
      cellHorizontalStack = UIStackView(arrangedSubviews: [innerHorizontalStack, nrOfRepoLabel])
      cellHorizontalStack.distribution = .equalSpacing
      cellHorizontalStack.alignment = .center
      cellHorizontalStack.axis = .horizontal
      
      addSubview(cellHorizontalStack)
      setupAutoLayout()
   }
   
   private func setupAutoLayout() {
      cellHorizontalStack.translatesAutoresizingMaskIntoConstraints = false
      avatarImageView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
         cellHorizontalStack.topAnchor.constraint(equalTo: topAnchor),
         cellHorizontalStack.bottomAnchor.constraint(equalTo: bottomAnchor),
         cellHorizontalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
         cellHorizontalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
         
         avatarImageView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
         avatarImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
      ])
   }
}

