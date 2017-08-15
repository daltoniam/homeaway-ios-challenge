//
//  ListViewController.swift
//  HomeAway
//
//  Created by Dalton Cherry on 8/14/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, ListViewDelegate {
    
    var listView: ListView {
        return view as! ListView
    }
    
    override func loadView() {
        view = ListView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listView.delegate = self
        queryEvents(query: "texas rangers")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
        reload()
    }

    func queryEvents(query: String) {
        listView.startLoading()
        SeatGeekService.shared.getEvents(query: query, completion: {[weak self] (eventObj, error) -> (Void) in
            if let _ = error {
                self?.listView.showEmptyView()
                return
            }
            guard let eventObj = eventObj else {
                self?.listView.showEmptyView()
                return
            }
            var models = [FeedViewModel]()
            for event in eventObj.events {
                models.append(FeedViewModel(event: event, isFaved: FavService.shared.check(id: event.id)))
            }
            self?.listView.update(viewModels: models)
        })
    }
    
    func reload() {
        var models = [FeedViewModel]()
        for item in listView.dataManager.items {
            if let model = item as? FeedViewModel {
                models.append(FeedViewModel(event: model.event, isFaved: FavService.shared.check(id: model.id)))
            }
        }
        listView.update(viewModels: models)
    }
    
    //MARK: - ListViewDelegate
    
    func didRunSearch(text: String) {
        queryEvents(query: text)
    }
    
    func didSelect(model: FeedViewModel) {
        let vc = DetailViewController(model: model)
        navigationController?.pushViewController(vc, animated: true)
    }

}

