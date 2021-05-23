//
//  PlaceholderImage.swift
//  GitHubUsersFetcher
//
//  Created by Sebastian Staszczyk on 23/05/2021.
//

import UIKit

class PlaceholderImage: UIImageView {
   private let angle = 45 * CGFloat.pi / 180
   
   private let gradientLayer: CAGradientLayer
   private let animation: CABasicAnimation
   private let placeholderImage: UIImage
   
   init(placeholderImage: UIImage = UIImage(systemName: "photo")!) {
      self.placeholderImage = placeholderImage
      animation = CABasicAnimation(keyPath: "transform.translation.x")
      gradientLayer = CAGradientLayer()
      super.init(image: placeholderImage)
      
      tintColor = UIColor.systemGray3
      
      gradientLayer.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
      gradientLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
      gradientLayer.colors = [UIColor.clear.cgColor, UIColor.label.cgColor, UIColor.clear.cgColor]
      gradientLayer.locations = [0, 0.5, 0]
      
      animation.repeatCount = .infinity
      animation.fromValue = -70
      animation.toValue = 70
      animation.duration = 1
      
      setDefault()
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
}

// MARK: -- Intents

extension PlaceholderImage {
   
   func setImage(_ image: UIImage) {
      self.image = image
      layer.mask = nil
      gradientLayer.removeAllAnimations()
   }
   
   func setDefault() {
      image = placeholderImage
      layer.mask = gradientLayer
      gradientLayer.add(animation, forKey: "placeholderAnimation")
   }
}

