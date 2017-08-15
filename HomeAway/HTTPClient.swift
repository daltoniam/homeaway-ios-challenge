//
//  HTTPClient.swift
//  HomeAway
//
//  Created by Dalton Cherry on 8/14/17.
//  Copyright © 2017 vluxe. All rights reserved.
//
//  This is a stripped down version of SwiftHTTP (https://github.com/daltoniam/SwiftHTTP).
//  I decided to use this instead of SwiftHTTP for the sake of simplicity and brevity.
//  Mainly because SwiftHTTP has file upload support (multipart/form-data) which is unneeded in this simple app.

import Foundation

extension String {
    /**
     A simple extension to the String object to encode it for web request.
     
     :returns: Encoded version of of string it was called as.
     */
    var escaped: String? {
        let set = NSMutableCharacterSet()
        set.formUnion(with: CharacterSet.urlQueryAllowed)
        set.removeCharacters(in: "[].:/?&=;+!@#$()',*\"") // remove the HTTP ones from the set.
        return self.addingPercentEncoding(withAllowedCharacters: set as CharacterSet)
    }
    
    /**
     A simple extension to the String object to url encode quotes only.
     
     :returns: string with .
     */
    var quoteEscaped: String {
        return self.replacingOccurrences(of: "\"", with: "%22").replacingOccurrences(of: "'", with: "%27")
    }
}

/**
 HTTPPair is used as a way to store HTTP key and values.
 */
public struct HTTPPair {
    let key: String?
    let storeVal: AnyObject
    init(key: String?, value: AnyObject) {
        self.key = key
        self.storeVal = value
    }
    
    /**
     Computed property of the string representation of the storedVal.
     
     :returns: the value or its description if it isn't a string
     */
    var value: String {
        if let v = storeVal as? String {
            return v
        } else if let v = storeVal.description {
            return v
        }
        return ""
    }
    
    /**
     Computed property of the key and value
     
     :returns: the key pair both escaped and ready to be sent off in an HTTP Query string
     */
    var escapedValue: String {
        guard let v = value.escaped, let k = key, let escapedKey = k.escaped else {return ""}
        return "\(escapedKey)=\(v)"
    }
}

/**
 This protocol is used to create HTTP Pairs off collection (Dictionary and Array by default).
 This allows for HTTP class to take in a Dictonary or array and will encode and append the parameters 
 to the url thus saving the implementor the trouble of doing so.
 e.g: let url = "domain.com/url?key=value%20that%20needs%20to%20be%20encoding" //have to encode that your self
 func getMethod(url: url)
 one gets to do
 func getMethod(url: url, parameters: ["key": "value that needs to be encoding"]) //all handled for you!
 */
public protocol HTTPParameterProtocol {
    func createPairs(key: String?) -> [HTTPPair]
}

/**
 Implements HTTPParameterProtocol for the Dictionary type.
 */
extension Dictionary: HTTPParameterProtocol {
    public func createPairs(key: String?) -> [HTTPPair] {
        var collect = [HTTPPair]()
        for (k, v) in self {
            guard let nestedKey = k as? String else {return collect}
            let useKey = key != nil ? "\(key!)[\(nestedKey)]" : nestedKey
            //we have to explictly cast the Dictionary and the Array because Swift 3 doesn't work looking at protocol within a protocol (HTTPParameterProtocol inspection with an implement of HTTPParameterProtocol.) I believe this will be resolved in Swift 4.
            if let subParam = v as? Dictionary {
                for s in subParam.createPairs(key: useKey) {
                    collect.append(s)
                }
            } else if let subParam = v as? Array<AnyObject> {
                for s in subParam.createPairs(key: useKey) {
                    collect.append(s)
                }
            } else {
                collect.append(HTTPPair(key: useKey, value: v as AnyObject))
            }
        }
        return collect
    }
}

/**
 Implements HTTPParameterProtocol for the Array type.
 */
extension Array: HTTPParameterProtocol {
    public func createPairs(key: String?) -> [HTTPPair] {
        var collect = [HTTPPair]()
        for v in self {
            let useKey = key != nil ? "\(key!)[]" : key
            if let subParam = v as? Dictionary<String, AnyObject> {
                for s in subParam.createPairs(key: useKey) {
                    collect.append(s)
                }
            } else if let subParam = v as? Array<AnyObject> {
                for s in subParam.createPairs(key: useKey) {
                    collect.append(s)
                }
            } else {
                collect.append(HTTPPair(key: useKey, value: v as AnyObject))
            }
        }
        return collect
    }
}


/**
 The HTTPClient is a wrapper around the standard NSURLSession APIs to abstract them out into simpler RESTFul APIs.
 */
public class HTTPClient: NSObject, URLSessionDataDelegate {
    static let kContentType = "Content-Type"
    
    /**
     This class is used to map the delegate calls of URLSession to the closures that called them. 
     It stores the closure that will be called when a HTTP request finishes and also collects the data as it comes in
     */
    class Response {
        let completionHandler: ((Data?, HTTPURLResponse?, Error?) -> (Void))
        var data = Data()
        init(task: URLSessionTask, completionHandler: @escaping ((Data?, HTTPURLResponse?, Error?) -> (Void))) {
            self.completionHandler = completionHandler
        }
    }
    var session: URLSession! = nil
    let cachePolicy: URLRequest.CachePolicy
    let timeoutInterval: TimeInterval
    var taskMap = [Int: Response]()
    var globalHeaders = [String: String]()
    
    /**
     customizable configuration, cache policy, and timeoutInterval for the requests in case you need something like that.
     */
    init(configuration: URLSessionConfiguration = URLSessionConfiguration.default, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval = 20) {
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
        super.init()
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    /**
     Preforms a HTTP request with the GET verb.
     - Parameter url: The url so send to the HTTP server (e.g. https://domain.com/url)
     - Parameter parameters: The parameters so send to the HTTP server (the things after the question mark). (e.g. https://domain.com/url?key=value)
     - Parameter httpMethod: The HTTP verb to use. This is a default value, but GET, DELETE, and HEAD all use the same HTTP query format, so they change the verb and are good to go.
     - Parameter completion: The closure that returns all the information of the HTTP round trip (since all the NSURLSession API calls are asynchronous). This returns the data of the request, the HTTPURLResponse of the object which contains the status code, response headers, etc and an Error if there was one.
     */
    public func get(url: URL, parameters: HTTPParameterProtocol?, httpMethod: String = "GET", completion: @escaping ((Data?, HTTPURLResponse?, Error?) -> (Void))) {
        let fullURL = parameters != nil ? appendParametersToQueryString(url: url, parameters: parameters!) : url
        var req = createRequest(url: fullURL)
        req.httpMethod = httpMethod
        let task = createTask(req: req, completion: completion)
        task.resume()
    }
    
    /**
     Preforms a HTTP request with the PUT verb.
     - Parameter url: The url so send to the HTTP server (e.g. https://domain.com/url)
     - Parameter parameters: The parameters so send to the HTTP server (the things after the question mark). (e.g. https://domain.com/url?key=value)
     - Parameter useJSON: Send the parameters as a body of JSON or use the HTTP query string format.
     - Parameter httpMethod: The HTTP verb to use. This is a default value, but PUT and POST normally use the same HTTP query format, so they change the verb and are good to go.
     - Parameter completion: The closure that returns all the information of the HTTP round trip (since all the NSURLSession API calls are asynchronous). This returns the data of the request, the HTTPURLResponse of the object which contains the status code, response headers, etc and an Error if there was one.
     */
    public func post(url: URL, parameters: HTTPParameterProtocol, useJSON: Bool = false, httpMethod: String = "POST", completion: @escaping ((Data?, HTTPURLResponse?, Error?) -> (Void))) {
        var req = createRequest(url: url)
        req.httpMethod = httpMethod
        if useJSON {
            req.setValue("application/json", forHTTPHeaderField: HTTPClient.kContentType)
            do {
                req.httpBody = try JSONSerialization.data(withJSONObject: parameters as AnyObject, options: JSONSerialization.WritingOptions())
            } catch let error {
                completion(nil, nil, error)
            }
        } else {
            req.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: HTTPClient.kContentType)
            req.httpBody = createQueryString(parameters: parameters).data(using: String.Encoding.utf8)
        }
        let task = createTask(req: req, completion: completion)
        task.resume()
    }
    
    /**
     Preforms a HTTP request with the PUT verb.
     - Parameter url: The url so send to the HTTP server (e.g. https://domain.com/url)
     - Parameter parameters: The parameters so send to the HTTP server (the things after the question mark). (e.g. https://domain.com/url?key=value)
     - Parameter completion: The closure that returns all the information of the HTTP round trip (since all the NSURLSession API calls are asynchronous). This returns the data of the request, the HTTPURLResponse of the object which contains the status code, response headers, etc and an Error if there was one.
     */
    public func put(url: URL, parameters: HTTPParameterProtocol, completion: @escaping ((Data?, HTTPURLResponse?, Error?) -> (Void))) {
        post(url: url, parameters: parameters, httpMethod: "PUT", completion: completion)
    }
    
    /**
     Preforms a HTTP request with the DELETE verb.
     - Parameter url: The url so send to the HTTP server (e.g. https://domain.com/url)
     - Parameter parameters: The parameters so send to the HTTP server (the things after the question mark). (e.g. https://domain.com/url?key=value)
     - Parameter completion: The closure that returns all the information of the HTTP round trip (since all the NSURLSession API calls are asynchronous). This returns the data of the request, the HTTPURLResponse of the object which contains the status code, response headers, etc and an Error if there was one.
     */
    public func delete(url: URL, parameters: HTTPParameterProtocol?, completion: @escaping ((Data?, HTTPURLResponse?, Error?) -> (Void))) {
        get(url: url, parameters: parameters, httpMethod: "DELETE", completion: completion)
    }
    
    /**
     Preforms a HTTP request with the HEAD verb.
     - Parameter url: The url so send to the HTTP server (e.g. https://domain.com/url)
     - Parameter parameters: The parameters so send to the HTTP server (the things after the question mark). (e.g. https://domain.com/url?key=value)
     - Parameter completion: The closure that returns all the information of the HTTP round trip (since all the NSURLSession API calls are asynchronous). This returns the data of the request, the HTTPURLResponse of the object which contains the status code, response headers, etc and an Error if there was one.
     */
    public func head(url: URL, parameters: HTTPParameterProtocol?, completion: @escaping ((Data?, HTTPURLResponse?, Error?) -> (Void))) {
        get(url: url, parameters: parameters, httpMethod: "HEAD", completion: completion)
    }
    
    //MARK: - private helper methods
    
    /**
     Creates our URLRequest and do any modification to them (like adding headers) before using them.
     */
    func createRequest(url: URL, headers: [String: String]? = nil) -> URLRequest {
        var req = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        if let headers = headers {
            for (k,v) in headers {
                req.addValue(v, forHTTPHeaderField: k)
            }
        }
        for (k,v) in globalHeaders {
            req.addValue(v, forHTTPHeaderField: k)
        }
        return req
    }
    
    func createTask(req: URLRequest, completion: @escaping ((Data?, HTTPURLResponse?, Error?) -> (Void))) -> URLSessionDataTask {
        let task: URLSessionDataTask = session.dataTask(with: req) //have to include URLSessionDataTask because of promiseKit.... :/
        taskMap[task.taskIdentifier] = Response(task: task, completionHandler: completion)
        return task
    }
    
    /**
     Creates a new URL with the parameters encoded and appended.
     
     :returns: a new URL with the parameters added.
     */
    func appendParametersToQueryString(url: URL, parameters: HTTPParameterProtocol) -> URL {
        let queryString = createQueryString(parameters: parameters)
        if queryString.characters.count > 0 {
            let para = url.query != nil ? "&" : "?"
            return URL(string: "\(url.absoluteString)\(para)\(queryString)")!
        }
        return url
    }
    
    /**
     This creates the HTTP query string.
     
      :returns: a new String with the parameters key value map and ready to be append to a URL.
     */
    func createQueryString(parameters: HTTPParameterProtocol) -> String {
        return parameters.createPairs(key: nil).map({ (pair) in
            return pair.escapedValue
        }).joined(separator: "&")
    }
    
    //MARK: - URLSessionDataDelegate
    
    /**
     Handles the URLSession data coming in. This works by pulling the response object out of the taskMap and then appending the new data to the Response objects data collection since URLSession gives HTTP data in chunks.
     */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let resp = taskMap[dataTask.taskIdentifier] else {return}
        resp.data.append(data)
    }
    
    /**
    Handles the URLSession task finishing. This works by pulling the response object out of the taskMap and then calling the completion closure to finish the request.
    */
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let resp = taskMap[task.taskIdentifier] else {return}
        let httpResp = task.response as? HTTPURLResponse ?? nil
        resp.completionHandler(resp.data, httpResp, error)
        taskMap.removeValue(forKey: task.taskIdentifier)
    }
}
