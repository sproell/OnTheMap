//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Steve Proell on 7/13/15.
//  Copyright (c) 2015 Steve Proell. All rights reserved.
//

import UIKit

class ParseClient: NSObject {
    
    // shared session
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // convenience method for adding headers to http requests
    func addAuthHeadersToRequest(request: NSMutableURLRequest) {
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
    }

    func getLocations(completionHandler: (result: [StudentLocation]?, error: NSError?) -> Void) {
        
        // Specify method and parameters
        // results are returned in order of most recent update
        let parameters = ["limit": 100, "order": "-updatedAt"]
        let urlString = "https://api.parse.com/1/classes/StudentLocation" + escapedParameters(parameters)
        let url = NSURL(string: urlString)!

        // Create a request and add the authentication keys as headers
        let request = NSMutableURLRequest(URL: url)
        addAuthHeadersToRequest(request)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(result: nil, error: NSError(domain: "getLocations", code: 0, userInfo: [NSLocalizedDescriptionKey: "request failed"]))
            } else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let locationResults = parsedResult.valueForKey("results") as? [[String:AnyObject]] {
                    // create Location objects from JSON
                    let locationsArray = StudentLocation.locationsFromResults(locationResults)
                    completionHandler(result: locationsArray, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getLocations", code: 0, userInfo: [NSLocalizedDescriptionKey: "could not find key \"results\" in response"]))
                }
            }
        }
        
        task.resume()
    }
    
    // POST a new student location
    func saveLocation(userKey: String, location: StudentLocation, completionHandler: (success: Bool, error: NSError?) -> Void) {

        // create request using API endpoint URL
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        
        // add headers to the request
        addAuthHeadersToRequest(request)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // set the request body with the provided location data
        request.HTTPBody = "{\"uniqueKey\": \"\(userKey)\", \"firstName\": \"\(location.firstName!)\", \"lastName\": \"\(location.lastName!)\", \"mapString\": \"\(location.mapString!)\",\"mediaURL\": \"\(location.mediaURL!)\", \"latitude\": \(location.latitude!), \"longitude\": \(location.longitude!)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        // make the request.  we assume the request succeeded if a valid objectId is returned
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                completionHandler(success: false, error: NSError(domain: "ParseClient.saveLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "request failed"]))
            } else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let objectId = parsedResult.valueForKey("objectId") as? String {
                    completionHandler(success: true, error: nil)
                } else {
                    completionHandler(success: false, error: NSError(domain: "ParseClient.saveLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "could not find key \"objectId\" in response"]))
                }
            }
        }

        task.resume()
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}