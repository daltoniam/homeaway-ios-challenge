//
//  DetailView.swift
//  HomeAway
//
//  Created by Dalton Cherry on 8/14/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import UIKit
import MapKit

class DetailView: UIView {
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    let dateLabel = UILabel()
    let mapView = MKMapView()
    
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
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        
        scrollView.addSubview(imageView)
        
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        scrollView.addSubview(titleLabel)
        
        detailLabel.numberOfLines = 1
        detailLabel.font = UIFont.systemFont(ofSize: 12)
        detailLabel.textColor = UIColor.lightGray
        scrollView.addSubview(detailLabel)
        
        dateLabel.numberOfLines = 1
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = UIColor.lightGray
        scrollView.addSubview(dateLabel)
        
        scrollView.addSubview(mapView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        let pad: CGFloat = 10
        var top: CGFloat = pad
        let left = pad
        imageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 200)
        top += imageView.bounds.height + pad / 2
        
        let maxWidth = bounds.width - (left + pad)
        let textSize = Utils.getTextSize(titleLabel, width: maxWidth)
        titleLabel.frame = CGRect(x: left, y: top, width: maxWidth, height: textSize.height)
        top += titleLabel.bounds.height + pad / 2
        
        detailLabel.frame = CGRect(x: left, y: top, width: maxWidth, height: 15)
        top += detailLabel.bounds.height + pad / 2
        
        dateLabel.frame = CGRect(x: left, y: top, width: maxWidth, height: 15)
        top += dateLabel.bounds.height + pad
        
        mapView.frame = CGRect(x: 0, y: top, width: bounds.width, height: 200)
        top += mapView.bounds.height + pad / 2
        
        if top < bounds.height {
            top = bounds.height
        }
        
        scrollView.contentSize = CGSize(width: bounds.width, height: top)
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
        if let loc = model.location {
            let radius: CLLocationDistance = 1000
            let coord = CLLocationCoordinate2D(latitude: loc.lat, longitude: loc.lon)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coord,
                                                                      radius * 2.0, radius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
            mapView.isHidden = false
        } else {
            mapView.isHidden = true
        }
    }
    
}
