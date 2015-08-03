//
//  StudentLocations.swift
//  OnTheMap
//
//  Created by Steve Proell on 7/29/15.
//  Copyright (c) 2015 Steve Proell. All rights reserved.
//

import Foundation

class StudentLocations : NSObject {
    
    private var locations : [StudentLocation]?
    
    func load(refresh: Bool, completionHandler: (locations: [StudentLocation]?, errorString: String?) -> Void) {

        if refresh || locations == nil {
            ParseClient.sharedInstance().getLocations { (result, error) -> Void in
                if let locations = result {
                    self.locations = locations
                    completionHandler(locations: self.locations!, errorString: nil)
                } else {
                    self.locations = nil
                    completionHandler(locations: nil, errorString: error?.localizedDescription)
                }
            }
        } else {
            completionHandler(locations: locations!, errorString: nil)
        }
    }
    
    class func sharedInstance() -> StudentLocations {
        
        struct Singleton {
            static var sharedInstance = StudentLocations()
        }
        
        return Singleton.sharedInstance
    }
}
