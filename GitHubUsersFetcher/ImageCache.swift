//
//  ImageCache.swift
//  GitHubUsersFetcher
//
//  Created by Sebastian Staszczyk on 23/05/2021.
//

import UIKit

protocol Cacheable {
   associatedtype cachedBy
   associatedtype keyType
   associatedtype valueType
   
   subscript(by key: cachedBy) -> valueType? { get set }
   init(countLimit: Int, totalSize: Int)
}

struct ImageCache: Cacheable {
   static let shared = ImageCache(countLimit: 200, totalSize: 30)
   private let cache = NSCache<keyType, valueType>()
   
   subscript(by key: String) -> UIImage? {
      get { cache.object(forKey: key as keyType) }
      set {
         if let new = newValue {
            cache.setObject(new, forKey: key as keyType )
         } else {
            cache.removeObject(forKey: key as keyType)
         }
      }
   }
   
   init(countLimit: Int, totalSize: Int) {
      cache.countLimit = countLimit
      cache.totalCostLimit = totalSize * 1024 * 1024
   }
   
   typealias keyType = NSString
   typealias valueType = UIImage
}

