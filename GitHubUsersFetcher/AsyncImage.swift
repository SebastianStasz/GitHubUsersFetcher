//
//  AsyncImage.swift
//  GitHubUsersFetcher
//
//  Created by Sebastian Staszczyk on 23/05/2021.
//

import Combine
import UIKit

extension AsyncImageView {
   static let defaultPlaceholder = UIImage(systemName: "photo")!
   static let dataService = DataService.shared
   static let imageCache = ImageCache.shared
}

class AsyncImageView: UIView {
   private var cancellables: Set<AnyCancellable> = []
   private let dataService: APIService
   private var cache: ImageCache?
   private let imageView: PlaceholderImage
   
   @Published private(set) var isLoading = false
   @Published var url = ""
   @Published private var image: UIImage?
   
   init(placeholder: UIImage? = nil, dataService: APIService = dataService, cache: ImageCache? = imageCache) {
      let placeholder = placeholder ?? UIImage(systemName: "person")!
      imageView = PlaceholderImage(placeholderImage: placeholder)
      self.dataService = dataService
      self.cache = cache
      
      super.init(frame: .zero)
      fetchImage()
      
      addSubview(imageView)
      
      imageView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
         imageView.topAnchor.constraint(equalTo: topAnchor),
         imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
         imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
         imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
      ])
      
      $image
         .sink { [unowned self] img in
            if let img = img {
               imageView.setImage(img)
            } else {
               imageView.setDefault()
            }
         }
         .store(in: &cancellables)
   }
   
   private func fetchImage() {
      $url
         .dropFirst()
         .filter { [unowned self] url in
            image = nil
            guard !isLoading, let img = cache?[by: url] else { return true }
            image = img
            return false
         }
         .compactMap { URL(string: $0) }
         .map { [unowned self] url in
            downloadImage(from: url)
         }
         .switchToLatest()
         .sink { _ in } receiveValue: { [unowned self] downloadedImg in
            isLoading = false
            image = downloadedImg
            cacheImage(downloadedImg, by: url)
         }
         .store(in: &cancellables)
   }
   
   private func cacheImage(_ image: UIImage?, by url: String) {
       image.map { cache?[by: url] = $0 }
   }

   private func downloadImage(from url: URL) -> AnyPublisher<UIImage, URLError> {
      URLSession.shared.dataTaskPublisher(for: url)
         .map(\.data)
         .compactMap { UIImage(data: $0) }
         .receive(on: DispatchQueue.main)
         .eraseToAnyPublisher()
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
}

