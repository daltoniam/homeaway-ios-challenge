//
//  EmptyView.swift
//  HomeAway
//
//  Created by Dalton Cherry on 8/14/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import UIKit

class EmptyView: UIView {
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = UIColor.white
        
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.text = NSLocalizedString("No Results", comment: "")
        addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let titleH: CGFloat = 25
        titleLabel.frame = CGRect(x: 0, y: (bounds.height - titleH) / 2, width: bounds.width, height: titleH)
    }
}
