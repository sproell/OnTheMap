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
    var locations : [StudentLocation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("vdl: llvc")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTable", name: "RefreshLocations", object: nil)
        
        updateTable()
    }
    
    func updateTable() {

        StudentLocations.sharedInstance().load(false, completionHandler: { (result, error) -> Void in
            if let locations = result {
                self.locations = locations
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            } else {
                // what if we cannot load locations?
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println("vwa: llvc")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locations!.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentLocationCell", forIndexPath: indexPath) as! StudentLocationTableViewCell
        let loc = locations![indexPath.row]
        cell.label.text = "\(loc.firstName!) \(loc.lastName!)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get currently selected location and show the associated media URL in a browser
        let loc = locations![indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string:loc.mediaURL!)!)
    }
}
