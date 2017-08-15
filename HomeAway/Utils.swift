//
//  Utils.swift
//  HomeAway
//
//  Created by Dalton Cherry on 8/14/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import UIKit

struct Utils {
    static let dateFormatter = DateFormatter()
    
    static func getTextSize(_ label: UILabel, width: CGFloat) -> CGSize {
        let font = label.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        guard let text = label.text else {return CGSize(width: 0, height: 0)}
        return (text as NSString).boundingRect(with: CGSize(width: width, height: 0), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: font], context: nil).size
    }
    
    static func format(date: String) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateStyle = .full
        if let d = date {
            return  dateFormatter.string(from: d)
        }
        return ""
    }
}
