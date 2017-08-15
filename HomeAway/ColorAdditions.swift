//
//  ColorAdditions.swift
//  HomeAway
//
//  Created by Dalton Cherry on 8/14/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    static var mainBlue: UIColor  { return UIColor(r: 61, g: 110, b: 181, a: 1) }
    static var lineGray: UIColor  { return UIColor(r: 236, g: 236, b: 236, a: 1) }
}
