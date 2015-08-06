//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Steve Proell on 7/10/15.
//  Copyright (c) 2015 Steve Proell. All rights reserved.
//

import UIKit

class UdacityClient: NSObject {
    
    // shared session
    var session: NSURLSession
    
    // The user's Udacity id.  Populated after the user logs in.
    var userID: String?
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // Begin a Udacity session by logging in the user.
    func beginSession(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        self.userID = nil

        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in

            // An error occurred with the request.
            if error != nil {
                completionHandler(success: false, errorString: error.localizedDescription)
                return
            }
            
            // We received a response, now parse the data
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as? NSDictionary
            
            if let error = parsingError {
                completionHandler(success: false, errorString: "beginSession(parse error)")
            } else {
                if let account = parsedResult?.valueForKey("account") as? [String : AnyObject] {
                    if let key = account["key"] as? String {
                        // successful login
                        self.userID = key
                        completionHandler(success: true, errorString: nil)
                    } else {
                        completionHandler(success: false, errorString: "beginSession (key)")
                    }
                } else {
                    // If we cannot find the account key in the response, it's likely
                    // that the user entered invalid account credentials.  So look for the 
                    // error message and return it to the user.

                    if let errorMsg = parsedResult?.valueForKey("error") as? String {
                        completionHandler(success: false, errorString: errorMsg)
                    } else {
                        completionHandler(success: false, errorString: "beginSession (account)")
                    }
                }
            }
        }
        
        task.resume()
    }
 
    // End a Udacity user's session
    func endSession(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        
        // add xsrf cookie for authentication
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            // error with request
            if error != nil {
                completionHandler(success: false, errorString: error.localizedDescription)
                return
            }
        
            // request successful
            var parsingError: NSError? = nil
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as? NSDictionary
        
            if let error = parsingError {
                completionHandler(success: false, errorString: "endSession(parse error)")
            } else {
                // if the response contains a session node which contains an id node, we consider this success.
                if let sessionNode = parsedResult?.valueForKey("session") as? [String : AnyObject] {
                    if let id = sessionNode["id"] as? String {
                        completionHandler(success: true, errorString: nil)
                    } else {
                        completionHandler(success: false, errorString: "endSession (cannot find id)")
                    }
                } else {
                    completionHandler(success: false, errorString: "endSession (cannot find session node)")
                }
            }
        }
    
        task.resume()
    }
    
    
    // Get public user info for Udacity user
    func getUser(completionHandler: (user: UdacityUser?, errorString : String?) -> Void) {
        
        // Setup the request.  Assume that the user has logged in and that we have saved the 
        // user id needed for this request.
        
        let urlString = "https://www.udacity.com/api/users/\(userID!)"
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, error in
            
            if let error = error {
                completionHandler(user: nil, errorString: error.localizedDescription)
                
            } else {
                var parsingError: NSError? = nil
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let user = parsedResult.valueForKey("user") as? [String : AnyObject] {
                    // sucesss.  return a loaded udacity user
                    let udacityUser = UdacityUser(dictionary: user)
                    completionHandler(user: udacityUser, errorString: nil)
                } else {
                    completionHandler(user: nil, errorString: error.localizedDescription)
                }
            }
        }
        
        task.resume()
    }
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}
