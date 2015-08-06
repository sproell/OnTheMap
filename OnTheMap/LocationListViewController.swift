//
//  LocationListViewController.swift
//  OnTheMap
//
//  Created by Steve Proell on 7/19/15.
//  Copyright (c) 2015 Steve Proell. All rights reserved.
//

import UIKit

class LocationListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Add listener for refresh notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTable", name: "RefreshLocations", object: nil)
    }
    
    // called upon notification when locations are loaded
    func updateTable() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }

    // functions for rendering location data in the tableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocations.sharedInstance.locations.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentLocationCell", forIndexPath: indexPath) as! StudentLocationTableViewCell
        let loc = StudentLocations.sharedInstance.locations[indexPath.row]
        cell.label.text = "\(loc.firstName!) \(loc.lastName!)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get currently selected location and show the associated media URL in a browser
        let loc = StudentLocations.sharedInstance.locations[indexPath.row]
        
        // some saved locations have no URL or an invalid URL.
        if let mediaURL = loc.mediaURL {
            let url = NSURL(string:mediaURL)
            if let validURL = url {
                UIApplication.sharedApplication().openURL(validURL)
            }
        }
    }
}
