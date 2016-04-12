//
//  APIClient.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 4/8/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

import Foundation

final class APIClient {

    // MARK: - URLs
    
    private struct Google {
        static let Base_URL = "https://maps.googleapis.com"
        static let API_Key = "AIzaSyAhW8_ChiSz8rpSZJ8uDEl3xjytmWaRCQI"
        struct Path {
            static let Autocompletion = "/maps/api/place/autocomplete/json"
            static let PlaceDetail = "/maps/api/place/details/json"
        }
    }
    
    // MARK: - Shared Instance
    
    static let sharedInstance = APIClient()
    
    // MARK: - Initialization
    
    private init() {
        session = NSURLSession.sharedSession()
    }
    
    var session: NSURLSession
    
    typealias CompletionHandler = (result: AnyObject?, error: NSError?) -> Void
    
    private lazy var URLWithPath: (String, query: [String: String]) -> NSURL = {
        let URLComponents = NSURLComponents(string: Google.Base_URL)!
        URLComponents.path = $0
        URLComponents.queryItems = $1.map() {
            return NSURLQueryItem(name: $0.0, value: $0.1)
        }
        return URLComponents.URL!
    }
    
    // MARK: - Request
    
    private func requestWithURL(url: NSURL, completionHandler: CompletionHandler) -> NSURLSessionDataTask {
        let task = session.dataTaskWithURL(url) { data, response, error in
            dispatch_async(dispatch_get_main_queue()) {
                guard error == nil, let data = data else {
                    completionHandler(result: nil, error: error)
                    return
                }
                APIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        task.resume()
        return task
    }
    
    func autocompletePlace(searchText: String, completionHandler: CompletionHandler) -> NSURLSessionDataTask {
        let url = URLWithPath(Google.Path.Autocompletion, query: ["input": searchText, "key": Google.API_Key])
        return requestWithURL(url, completionHandler: completionHandler)
    }
    
    func lookUpPlaceWithID(placeID: String, completionHandler: CompletionHandler) -> NSURLSessionDataTask {
        let url = URLWithPath(Google.Path.PlaceDetail, query: ["placeid": placeID, "key": Google.API_Key])
        return requestWithURL(url, completionHandler: completionHandler)
    }
    
    // Parsing the JSON
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHandler) {
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            guard let status = parsedResult!["status"] as? String where status == "OK" else {
                completionHandler(result: nil, error: nil)
                return
            }
            completionHandler(result: parsedResult, error: nil)
        } catch let error as NSError {
            completionHandler(result: nil, error: error)
        }
    }
    
}