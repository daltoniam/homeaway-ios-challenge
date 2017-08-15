//
//  Event.swift
//  HomeAway
//
//  Created by Dalton Cherry on 8/14/17.
//  Copyright © 2017 vluxe. All rights reserved.
//

import Foundation

struct Performer: JSONJoy {
    let image: String?
    init(_ decoder: JSONDecoder) throws {
        image = decoder["image"].getOptional()
    }
}

struct Event: JSONJoy {
    let id: Int
    let date: String
    let title: String
    let shortTitle: String
    let displayLocation: String
    let lat: Double?
    let lon: Double?
    let performers: [Performer]
    init(_ decoder: JSONDecoder) throws {
        id = try decoder["id"].get()
        let dateStr: String = try decoder["datetime_utc"].get()
        date = Utils.format(date: dateStr)
        title = try decoder["title"].get()
        shortTitle = try decoder["short_title"].get()
        displayLocation = try decoder["venue"]["display_location"].get()
        performers = try decoder["performers"].get()
        lat = decoder["venue"]["location"]["lat"].getOptional()
        lon = decoder["venue"]["location"]["lon"].getOptional()
    }
}

struct Events: JSONJoy {
    let events: [Event]
    init(_ decoder: JSONDecoder) throws {
        events = try decoder["events"].get()
    }
}
