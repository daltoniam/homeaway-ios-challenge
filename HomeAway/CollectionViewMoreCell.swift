//
//  CollectionViewMoreCell.swift
//  HomeAway
//
//  Created by Dalton Cherry on 8/14/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import Foundation
import Jazz

class CollectionViewMoreItem: SourceItemProtocol {
    static var cellIdentifer: String {
        return "moreitem"
    }
}

class CollectionViewMoreCell: UICollectionViewCell, SourceCellProtocol {
    let loadingView = LoadingView(frame: CGRect.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadingView.lineWidth = 4
        loadingView.color = UIColor.mainBlue
        contentView.addSubview(loadingView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size: CGFloat = 34
        loadingView.frame = CGRect(x: (contentView.bounds.width - size) / 2,
                                   y: (contentView.bounds.height - size) / 2,
                                   width: size, height: size)
    }
    
    func update(_ object: SourceItemProtocol) {
        //doesn't have to do anything!
    }
    
    //normally called by the updateDisplay: method of CollectionViewManager to start and stop the animation
    func start() {
        loadingView.isHidden = false
        loadingView.start()
    }
    
    func stop() {
        loadingView.isHidden = true
        loadingView.stop()
    }
}
