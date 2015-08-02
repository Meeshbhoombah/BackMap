//
//  ViewController.swift
//  BackMap
//
//  Created by Rohan Mishra on 8/1/15.
//  Copyright (c) 2015 Holla. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, LocationManagerDelegate, CLLocationManagerDelegate {
    
    let mapManager = MapManager.sharedInstance
    let locationManager = LocationManager.sharedInstance
    
    @IBOutlet weak var setDirectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var setDirectionsButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var startingTextField: UITextField!
    
    var onSetDirections = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.autoUpdate = true
    }
    
    @IBAction func reverseGeocode(sender:UIButton) {
            locationManager.startUpdatingLocationWithCompletionHandler { (latitude, longitude, status, verboseMessage, error) -> () in
                if error != nil {
                    println(error)
                } else {
                    self.plotOnMapWithCoordinates(latitude: latitude, longitude: longitude)
                }
        }
    }
    
    func locationManagerStatus(status:NSString) {
        
        println(status)
    }
    
    func locationManagerReceivedError(error:NSString) {
        
        println(error)
    }
    
    func locationFound(latitude:Double, longitude:Double) {
        
        self.plotOnMapWithCoordinates(latitude: latitude, longitude: longitude)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func plotOnMapUsingGoogleWithAddress(address:NSString) {
        
        locationManager.geocodeUsingGoogleAddressString(address: address) { (geocodeInfo,placemark, error) -> Void in
            
            self.performActionWithPlacemark(placemark, error: error)
        }
    }
    
    func plotOnMapWithAddress(address:NSString) {
        
        locationManager.geocodeAddressString(address: address) { (geocodeInfo,placemark, error) -> Void in
            
            self.performActionWithPlacemark(placemark, error: error)        }
    }
    
    func plotOnMapWithCoordinates(#latitude: Double, longitude: Double) {
        
        locationManager.reverseGeocodeLocationWithLatLon(latitude: latitude, longitude: longitude, onReverseGeocodingCompletionHandler: { (reverseGecodeInfo, placemark, error) -> Void in
            self.startingTextField.text = reverseGecodeInfo!.valueForKey("formattedAddress") as! String
            self.performActionWithPlacemark(placemark, error: error)
        })
    }
    
    
    func performActionWithPlacemark(placemark:CLPlacemark?,error:String?) {
        
        if error != nil {
            
            println(error)
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.plotPlacemarkOnMap(placemark)
            })
        }
    }
    
    func removeAllPlacemarkFromMap(#shouldRemoveUserLocation:Bool) {
        
        if let mapView = self.mapView {
            for annotation in mapView.annotations{
                if shouldRemoveUserLocation {
                    if annotation as? MKUserLocation !=  mapView.userLocation {
                        mapView.removeAnnotation(annotation as! MKAnnotation)
                    }
                }
            }
        }
    }
    
    func plotPlacemarkOnMap(placemark:CLPlacemark?) {
        
        removeAllPlacemarkFromMap(shouldRemoveUserLocation:true)
        
        if self.locationManager.isRunning {
            self.locationManager.stopUpdatingLocation()
        }
        
        var latDelta:CLLocationDegrees = 0.1
        var longDelta:CLLocationDegrees = 0.1
        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        var latitudinalMeters = 100.0
        var longitudinalMeters = 100.0
        var theRegion:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(placemark!.location.coordinate, latitudinalMeters, longitudinalMeters)
        
        self.mapView?.setRegion(theRegion, animated: true)
        
        self.mapView?.addAnnotation(MKPlacemark(placemark: placemark))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func setDirections(sender: AnyObject) {
        if !onSetDirections {
            setDirectionsButton.setTitle("START TRIP", forState: UIControlState.Normal)
            setDirectionBottomConstraint.constant = self.view.frame.height/2
            onSetDirections = true
        } else {
            
        }
        
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
    }
    
}

