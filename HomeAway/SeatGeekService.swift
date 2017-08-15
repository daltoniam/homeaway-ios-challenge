//
//  SeatGeekService.swift
//  HomeAway
//
//  Created by Dalton Cherry on 8/14/17.
//  Copyright © 2017 vluxe. All rights reserved.
//
//
// This is our API class to handle Seat Geek requests.

import Foundation


class SeatGeekService {
    static let kAPIURL = "https://api.seatgeek.com"
    static let kAPIVersion = "/2"
    static let clientID = "ODUxMTg2MXwxNTAyNzM2OTIzLjky"
    static let clientSecret = "0defd5f0a149db373d5a5741cc04f396613644653bb7ff13ceb25fe8eade0424"
    static let SGClientErrorDomain = "com.homeaway.seatgeek"
    static let SGClientDeserializationCode = 100
    static let shared = SeatGeekService(client: HTTPClient())
    
    let baseURL = "\(kAPIURL)\(kAPIVersion)"
    let httpClient: HTTPClient
    
    init(client: HTTPClient) {
        httpClient = client
    }
    
    /**
     This method GETs the events using a standard HTTP request. /events?client_id=<your client id>&q=Texas+Ranger
      - Parameter query: The query string to send as a query to the Seat Geek API.
     - Parameter completion: The closure that returns a parsed and object ready version event API.
     */
    func getEvents(query: String, completion: @escaping ((Events?, Error?) -> (Void))) {
        guard let url = URL(string: "\(baseURL)/events") else {return} //this won't fail
        let params = ["client_id": SeatGeekService.clientID, "client_secret": SeatGeekService.clientSecret, "q": query]
        httpClient.get(url: url, parameters: params, completion: { (data, response, error) -> (Void) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else {
                let error = NSError(domain: SeatGeekService.SGClientErrorDomain, code: SeatGeekService.SGClientDeserializationCode, userInfo: nil)
                completion(nil, error as Error)
                return
            }
            let decoder = JSONDecoder(data)
            do {
                let events = try Events(decoder)
                completion(events, nil)
            } catch {
                let error = NSError(domain: SeatGeekService.SGClientErrorDomain, code: SeatGeekService.SGClientDeserializationCode, userInfo: nil)
                completion(nil, error as Error)
            }
        })
    }
}
