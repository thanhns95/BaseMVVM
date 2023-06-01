//
//  Fonts.swift
//  Common
//
//  Created by it on 28/10/2022.
//

import Foundation
import UIKit

  struct Fonts {
      static func regular(size: CGFloat) -> UIFont {
        
        return .systemFont(ofSize: size, weight: .regular)
    }
    
      static func medium(size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .medium)
    }
    
      static func semibold(size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .semibold)
    }
    
      static func bold(size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .bold)
    }
}
