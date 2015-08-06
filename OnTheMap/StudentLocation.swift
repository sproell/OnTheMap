//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Steve Proell on 7/13/15.
//  Copyright (c) 2015 Steve Proell. All rights reserved.
//

struct StudentLocation {
  
    var firstName: String? = nil
    var lastName: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    var mapString: String? = nil
    var mediaURL: String? = nil
    
    // Empty init method allows caller to initialize members in a custom way
    init() {}
    
    // Construct a StudentLocation from a dictionary
    init(dictionary: [String : AnyObject]) {

        firstName = dictionary["firstName"] as? String
        lastName = dictionary["lastName"] as? String
        latitude = dictionary["latitude"] as? Double
        longitude = dictionary["longitude"] as? Double
        mapString = dictionary["mapString"] as? String
        mediaURL = dictionary["mediaURL"] as? String
    }
    
    // Helper: Given an array of dictionaries, convert them to an array of StudentLocation objects
    static func locationsFromResults(results: [[String : AnyObject]]) -> [StudentLocation] {
        var locations = [StudentLocation]()
        
        for result in results {
            locations.append(StudentLocation(dictionary: result))
        }
        
        return locations
    }
}




