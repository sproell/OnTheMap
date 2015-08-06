//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by Steve Proell on 7/17/15.
//  Copyright (c) 2015 Steve Proell. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add refresh and add-location buttons to navigation bar
        var rightPinBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "pinTapped:")
        var rightRefreshBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshLocations:")
        self.navigationItem.setRightBarButtonItems([rightRefreshBarButtonItem, rightPinBarButtonItem], animated: true)
        
        loadLocationData()
    }
    
    // Called wher user taps the logout button.
    // End the Udacity session and dismiss the tab view, returning to the login view
    @IBAction func logout(sender: AnyObject) {
        
        UdacityClient.sharedInstance().endSession() { success, errorString in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                // If logout doesn't work, alert the user, but just return to the login view anyway
                let alertController = UIAlertController(title: "Error Logging Out", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                })
            }
        }
    }
    
    // Location data is loaded from within the tabbarcontroller.  If the load is successful,
    // a notification is sent to the tabbed view controllers to update their views with the 
    // new data.
    func loadLocationData() {
        StudentLocations.sharedInstance.load({ (success, error) -> Void in
            if success {
                NSNotificationCenter.defaultCenter().postNotificationName("RefreshLocations", object: self)
            } else {
                let alertController = UIAlertController(title: "Error Loading Locations", message: error!, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }

    // Called when user taps refresh button on nav bar.  
    // Reload the data and send a notification to my view controllers 
    // to refresh their views of the location data
    func refreshLocations(sender: AnyObject) {
        loadLocationData()
    }
    
    // Called when user taps pin button on nav bar.
    // Seque to the Add Location view controller
    func pinTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("AddLocation", sender: sender)
    }
}