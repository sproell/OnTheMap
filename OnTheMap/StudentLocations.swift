//
//  StudentLocations.swift
//  OnTheMap
//
//  Created by Steve Proell on 7/29/15.
//  Copyright (c) 2015 Steve Proell. All rights reserved.
//

import Foundation

// This model class contains the array of locations displayed within the app.

class StudentLocations : NSObject {
    
    static let sharedInstance = StudentLocations()

    var locations = [StudentLocation]()
    
    func load(completionHandler: (success: Bool, errorString: String?) -> Void) {

        ParseClient.sharedInstance().getLocations { (result, error) -> Void in
            if let locations = result {
                // remove all locations from array and add the new ones
                self.locations.removeAll(keepCapacity: true)
                self.locations.extend(locations)
                completionHandler(success: true, errorString: nil)
            } else {
                self.locations.removeAll(keepCapacity: true)
                completionHandler(success: false, errorString: error?.localizedDescription)
            }
        }
    }
}
