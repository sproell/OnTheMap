//
//  UdacityUser.swift
//  OnTheMap
//
//  Created by Steve Proell on 8/1/15.
//  Copyright (c) 2015 Steve Proell. All rights reserved.
//

struct UdacityUser {
    
    var key: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    /* Construct a UdacityUser from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        key = dictionary["key"] as? String
        firstName = dictionary["first_name"] as? String
        lastName = dictionary["last_name"] as? String
    }
}
