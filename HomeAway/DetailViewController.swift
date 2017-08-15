//
//  DetailViewController.swift
//  HomeAway
//
//  Created by Dalton Cherry on 8/14/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    let viewModel: FeedViewModel
    
    init(model: FeedViewModel) {
        viewModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var detailView: DetailView {
        return view as! DetailView
    }
    
    override func loadView() {
        view = DetailView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailView.viewModel = viewModel
        title = viewModel.shortTitle

        view.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: self, action: #selector(favAction))
        checkFavStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        UIApplication.shared.statusBarStyle = .default
    }
    
    func checkFavStatus() {
        if FavService.shared.check(id: viewModel.id) {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        } else {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.gray
        }
    }
    
    func favAction() {
        if FavService.shared.check(id: viewModel.id) {
            FavService.shared.remove(id: viewModel.id)
            navigationItem.rightBarButtonItem?.tintColor = UIColor.gray
        } else {
            FavService.shared.add(id: viewModel.id)
            navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        }
    }
}
