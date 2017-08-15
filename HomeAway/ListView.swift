//
//  ListView.swift
//  HomeAway
//
//  Created by Dalton Cherry on 8/14/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import UIKit

protocol ListViewDelegate: class {
    func didRunSearch(text: String)
    func didSelect(model: FeedViewModel)
}

class ListView: UIView, UISearchBarDelegate, CollectionViewManagerDelegate {
    let searchBarHeight: CGFloat = 66
    let searchBar = UISearchBar()
    var collectionView: UICollectionView!
    let dataManager = CollectionViewManager()
    let emptyView = EmptyView()
    weak var delegate: ListViewDelegate?
    let moreItem = CollectionViewMoreItem()
    var isLoading = false
    
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
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = dataManager
        collectionView.dataSource = dataManager
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: searchBarHeight, left: 0, bottom: 0, right: 0)
        addSubview(collectionView)
        dataManager.delegate = self
        
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: FeedViewModel.cellIdentifer)
        collectionView.register(CollectionViewMoreCell.self, forCellWithReuseIdentifier: CollectionViewMoreItem.cellIdentifer)
        
        searchBar.delegate = self
        searchBar.prompt = " " //force the search bar to account for the status bar
        searchBar.barTintColor = UIColor.mainBlue
        searchBar.placeholder = NSLocalizedString("Search Events", comment: "")
        addSubview(searchBar)
        
        emptyView.isHidden = true
        addSubview(emptyView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: searchBarHeight)
        collectionView.frame = bounds
        emptyView.frame = CGRect(x: 0, y: searchBarHeight, width: bounds.width, height: bounds.height - searchBarHeight)
    }
    
    func startLoading() {
        emptyView.isHidden = true
        if isLoading {
            return
        }
        isLoading = true
        dataManager.items.append(moreItem)
        collectionView.reloadData()
    }
    
    func update(viewModels: [FeedViewModel]) {
        dataManager.items.removeAll()
        for model in viewModels {
            dataManager.items.append(model)
        }
        collectionView.reloadData()
        isLoading = false
        emptyView.isHidden = dataManager.items.count > 0
    }
    
    func showEmptyView() {
        emptyView.isHidden = false
    }
    
    //MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.didRunSearch(text: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //MARK: - CollectionViewManagerDelegate
    
    func didSelect(_ item: SourceItemProtocol, indexPath: IndexPath) {
        guard let model = item as? FeedViewModel else {return}
        delegate?.didSelect(model: model)
    }
    
    func sizeForItem(_ item: SourceItemProtocol, indexPath: IndexPath) -> CGSize {
        if let i = item as? FeedViewModel {
            return CGSize(width: bounds.width, height: FeedView.caculateHeight(width: bounds.width, model: i))
        }
        return CGSize(width: bounds.width, height: 80)
    }
    
    func updateDisplay(_ collectionView: UICollectionView, item: SourceItemProtocol, cell: UICollectionViewCell, indexPath: IndexPath, isDisplaying: Bool) {
        if let moreCell = cell as? CollectionViewMoreCell {
            if isDisplaying {
                moreCell.start()
            } else {
                moreCell.stop()
            }
        }
    }
    
}
