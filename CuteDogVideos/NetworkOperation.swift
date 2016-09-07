//
//  NetworkOperation.swift
//  Cute Dog Videos
//
//  Created by AL on 11/6/15.
//  Copyright © 2015 AL. All rights reserved.
//

import Foundation

class NetworkOperation {
    
    lazy var config: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var session: NSURLSession = NSURLSession(configuration: self.config)
    let queryURL: NSURL
    
    typealias JSONArrayCompletion = ([[String: AnyObject]]? -> Void)
    
    init(url: NSURL) {
        self.queryURL = url
    }
    
    // func has a single parameter that is a closure for a call back
    func downloadJSONFromURL(completion: JSONArrayCompletion) {
        
        let request = NSURLRequest(URL: queryURL)
        let dataTask = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            // 1. Check HTTP response for successful GET request
            if let httpResponse = response as? NSHTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    // 2. Create JSON object with data
                    do {
                        let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [[String: AnyObject]]
                        completion(jsonArray)
                        
                    } catch {
                        completion(nil)
                    }
                default:
                    print("GET request not successful. HTTP status code: \(httpResponse.statusCode)")
                }
            } else {
                print("Error: Not a valid HTTP response")
            }
        }
        
        dataTask.resume()
    }
}