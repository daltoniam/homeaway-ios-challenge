//
//  FavService.swift
//  HomeAway
//
//  Created by Dalton Cherry on 8/14/17.
//  Copyright © 2017 vluxe. All rights reserved.
//
//  Simple class to save the favorite items to the user defaults.
//  If this was going to store thousands of records it would make sense to add some SQL calls, but for such a simple app
//  this should be fine.
//  This class also favors the map over an array since look ups are going to be far more frequent then inserts.
//  An argument might be made to just iterate an array since there are only a few items (CPU spatial caching and such), but that would need some benchmarking time to prove which would be more faster.

import Foundation

class FavService {
    static let kFavDefaultName = "favDefaults"
    static let shared = FavService()
    var favMap = [Int: Bool]()
    
    init() {
        load()
    }
    
    /**
     Simple private helper method to load the items into the map from the defaults
     */
    func load() {
        guard let array = UserDefaults.standard.array(forKey: FavService.kFavDefaultName) as? Array<Int> else {return}
        for item in array {
            favMap[item] = true
        }
    }
    
    /**
     Simple private helper method to save the items to the defaults
     */
    func save() {
        var collect = [Int]()
        for id in favMap.keys {
            collect.append(id)
        }
        UserDefaults.standard.set(collect, forKey: FavService.kFavDefaultName)
        UserDefaults.standard.synchronize()
    }
    
    /**
     Adds a key to the map then calls save
     */
    func add(id: Int) {
        favMap[id] = true //the bool is just a placeholder to take advantage of the map
        save()
    }
    
    /**
     Removes a key from the map then calls save
     */
    func remove(id: Int) {
        favMap.removeValue(forKey: id)
        save()
    }
    
    /**
     Checks to see if an id key is in the map
     */
    func check(id: Int) -> Bool {
        if let _ = favMap[id] {
            return true
        }
        return false
    }
}
