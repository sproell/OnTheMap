//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Steve Proell on 7/31/15.
//  Copyright (c) 2015 Steve Proell. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tfLocation: UITextField!
    @IBOutlet weak var panelURL: UIView!
    @IBOutlet weak var tfUrl: UITextField!
    @IBOutlet weak var panelLocation: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var userID : String?
    var placemark : CLPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The initial state of the view is that the first question is presented
        // and the map is hidden.
        mapView.hidden = true
        showLocationPanel()
    }
    
    // Show the view containing the location textfield
    func showLocationPanel() {
        panelURL.hidden = true
        panelLocation.hidden = false
    }
    
    // Show the view containing the URL textfield
    func showUrlPanel() {
        panelLocation.hidden = true
        panelURL.hidden = false
    }
    
    // Called when user taps the cancel button
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // Called when user chooses to find his location on the map
    @IBAction func findOnMap(sender: AnyObject) {
        
        let location = tfLocation.text

        if location.isEmpty {
            // warn the user that location is required
            showErrorAlert("Location is required.")
            
        } else {
            activityIndicator.startAnimating()
            
            var geocoder = CLGeocoder()

            geocoder.geocodeAddressString(location, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                
                if let placemark = placemarks?[0] as? CLPlacemark {
                    
                    // location geocode successful!  show it on a map.
                    
                    // save coordinate
                    self.placemark = placemark
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        // remove existing annotations
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        
                        // Center and zoom on to new point
                        var span = MKCoordinateSpanMake(0.075, 0.075)
                        var region = MKCoordinateRegion(center: placemark.location.coordinate, span: span)
                        self.mapView.setRegion(region, animated: true)
                        
                        // show map
                        self.mapView.hidden = false
                        
                        // add newly geocoded annotation
                        self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                    
                        // Show next panel
                        self.showUrlPanel()
                    })
                    
                } else {
                    // could not geocode location
                    self.showErrorAlert("Unable to geocode location.")
                }
                
                self.activityIndicator.stopAnimating()
            })
        }
    }
    
    // Called when user chooses the save his location
    @IBAction func saveLocation(sender: AnyObject) {

        let url = tfUrl.text

        if url.isEmpty {
            // warn the user that url is required
            showErrorAlert("URL is required.")
            
        } else {
            // Before saving the location, we must fetch the logged in user's key.
            // We could have done this when the user logged in, but this saves
            // an API call until we know the user is intending to save a location.
            
            activityIndicator.startAnimating()

            UdacityClient.sharedInstance().getUser({ (user, errorString) -> Void in
                
                if user == nil {
                    // could not load the user
                    self.showErrorAlert(errorString!)
                } else {
                    
                    var newLoc = StudentLocation()
                    newLoc.firstName = user!.firstName
                    newLoc.lastName = user!.lastName
                    newLoc.latitude = self.placemark!.location.coordinate.latitude
                    newLoc.longitude = self.placemark!.location.coordinate.longitude
                    newLoc.mapString = self.placemark!.name
                    newLoc.mediaURL = url
                    
                    ParseClient.sharedInstance().saveLocation(user!.key!, location: newLoc, completionHandler: {(success, error) -> Void in
                        if success {
                            // the location was saved successfully.  Dismiss view controller
                            // and return to tabbed view.
                            dispatch_async(dispatch_get_main_queue(), {
                                self.dismissViewControllerAnimated(true, completion: nil)
                            })
                        } else {
                            self.showErrorAlert(error!.description)
                        }
                    })
                }
                
                self.activityIndicator.stopAnimating()
            })
        }
    }
    
    // Display an error alert dialog with the given message
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error occurred", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
