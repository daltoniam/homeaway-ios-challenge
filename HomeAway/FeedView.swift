//
//  FeedView.swift
//  HomeAway
//
//  Created by Dalton Cherry on 8/14/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import UIKit
import Kingfisher

/**
 View Model for the Feed View. Basically encapsulates the event object to add some handy indirection
 */
struct FeedViewModel: SourceItemProtocol {
    static var cellIdentifer: String {
        return "feedcell"
    }
    let event: Event
    let isFaved: Bool
    
    init(event: Event, isFaved: Bool) {
        self.event = event
        self.isFaved = isFaved
    }
   
    var id: Int {
        return event.id
    }
    
    var title: String {
        return event.title
    }
    
    var shortTitle: String {
        return event.shortTitle
    }
    
    var displayLocation: String {
        return event.displayLocation
    }
    
    var date: String {
        return event.date
    }
    
    var imageURL: URL? {
        guard let url = event.performers.first?.image else {return nil}
        return URL(string: url)
    }
    
    var location: (lat: Double, lon: Double)? {
        guard let lat = event.lat, let lon = event.lon else {return nil}
        return (lat, lon)
    }
}

class FeedView: UIView {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    let dateLabel = UILabel()
    let favView = UIImageView()
    let bottomLine = UIView()
    static let shared = FeedView() //use for easy size caculations
    
    var viewModel: FeedViewModel? {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        addSubview(imageView)
        
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        addSubview(titleLabel)
        
        detailLabel.numberOfLines = 1
        detailLabel.font = UIFont.systemFont(ofSize: 12)
        detailLabel.textColor = UIColor.lightGray
        addSubview(detailLabel)
        
        dateLabel.numberOfLines = 1
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = UIColor.lightGray
        addSubview(dateLabel)
        
        favView.isHidden = true
        favView.image = UIImage(named: "heart")
        addSubview(favView)
        
        bottomLine.backgroundColor = UIColor.lineGray
        addSubview(bottomLine)
    }
    
    /**
     This layouts out subviews (and is called by layoutSubviews) but also returns the height of all the elements.
     */
    @discardableResult func calculateHeight(_ width: CGFloat) -> CGFloat {
        let pad: CGFloat = 10
        let lineH: CGFloat = 1
        var top = pad
        var left = pad
        let imgSize: CGFloat = 60
        imageView.frame = CGRect(x: pad, y: top, width: imgSize, height: imgSize)
        left += imageView.bounds.width + pad
        
        favView.frame = CGRect(x: 5, y: 5, width: 15, height: 15)
        
        let maxWidth = width - (left + pad)
        let textSize = Utils.getTextSize(titleLabel, width: maxWidth)
        titleLabel.frame = CGRect(x: left, y: top, width: maxWidth, height: textSize.height)
        top += titleLabel.bounds.height + pad / 2
        
        detailLabel.frame = CGRect(x: left, y: top, width: maxWidth, height: 15)
        top += detailLabel.bounds.height + pad / 2
        
        dateLabel.frame = CGRect(x: left, y: top, width: maxWidth, height: 15)
        top += dateLabel.bounds.height + pad
        
        bottomLine.frame = CGRect(x: pad, y: bounds.height - lineH, width: width - pad, height: lineH)
        
        let minH = imgSize + (pad * 2)
        if top < minH {
            top = minH
        }
        return top
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calculateHeight(bounds.width)
    }
    
    func update() {
        guard let model = viewModel else {return}
        titleLabel.text = model.title
        detailLabel.text = model.displayLocation
        dateLabel.text = model.date
        imageView.image = nil
        if let url = model.imageURL {
            imageView.kf.setImage(with: url)
        }
        favView.isHidden = !model.isFaved
    }
    
    /**
     This class method figures out how tall to make the cell before laying it out in the collection view.
     This method is normally called in the sizeForItem: call for the CollectionViewManager.
     //NOTE:
     This is a caculated trade off for the sake of simplicity and less code to mantain. 
     One could argue it would be better to not have the singleton and just repeat 
     some of the height detection code in the class method.
     That of course is more code to mantain and mostly repeated logic, but doesn't have a singleton.
     */
    class func caculateHeight(width: CGFloat, model: FeedViewModel) -> CGFloat {
        let view = FeedView.shared
        view.viewModel = model
        return view.calculateHeight(width)
    }
}
