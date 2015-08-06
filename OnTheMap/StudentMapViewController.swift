//
//  StudentMapViewController.swift
//  OnTheMap
//
//  Created by Steve Proell on 7/13/15.
//  Copyright (c) 2015 Steve Proell. All rights reserved.
//

import UIKit
import MapKit

class StudentMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add listener for refresh notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshLocations", name: "RefreshLocations", object: nil)
    }
    
    func refreshLocations() {
        addPins(StudentLocations.sharedInstance.locations)
    }
        
    // add the array of StudentLocations to the map
    func addPins(locations: [StudentLocation]) {
        
        // We will create an MKPointAnnotation for each student location. The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        for location in locations {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(location.latitude!)
            let long = CLLocationDegrees(location.longitude!)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = location.firstName!
            let last = location.lastName!
            let mediaURL = location.mediaURL!
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        dispatch_async(dispatch_get_main_queue(), {
            
            // clear existing annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            // add new ones
            self.mapView.addAnnotations(annotations)
        })
    }
    
    // Add an info button to every annotation callout
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "loc")
        view.canShowCallout = true
     
        let button = UIButton.buttonWithType(UIButtonType.InfoLight) as! UIButton
        view.rightCalloutAccessoryView = button
        
        return view
    }
    
    // When the annotation callout button is tapped, open the mediaURL in a browser
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        // some saved locations have no URL or an invalid URL.
        if let mediaURL = view.annotation.subtitle {
            let url = NSURL(string:mediaURL)
            if let validURL = url {
                UIApplication.sharedApplication().openURL(validURL)
            }
        }
    }
}
