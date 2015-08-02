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
    
    @IBOutlet weak var pinToBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var setDirectionsButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var startingTextField: UITextField!
    
    var onSetDirections = false
    var count = 0
    var fromCoord: CLLocationCoordinate2D!
    var toCoord: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.autoUpdate = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() {
            pinToBottomConstraint.constant = keyboardFrame.height + 12
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        pinToBottomConstraint.constant = 12
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
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
            self.fromCoord = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
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
            setDirectionsButton.setTitle("START NAVIGATION", forState: UIControlState.Normal)
            pinToBottomConstraint.constant = 12
            onSetDirections = true
        } else {
            locationManager.geocodeAddressString(address: destinationTextField.text, onGeocodingCompletionHandler: { (gecodeInfo, placemark, error) -> Void in
                if error == nil {
                    let latitude = (gecodeInfo?.valueForKey("latitude") as! NSString).doubleValue
                    let longitude = (gecodeInfo?.valueForKey("longitude") as! NSString).doubleValue
                    
                    self.toCoord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    println(self.toCoord)
                } else {
                    println(error)
                }
                
                self.mapManager.directions(from: self.fromCoord, to: self.toCoord, directionCompletionHandler: { (route, directionInformation, boundingRegion, error) -> () in
                    if error == nil {
                        println(route)
                        println()
                        println(directionInformation)
                        println()
                        println(boundingRegion)
                    } else {
                        println(error)
                    }
                    
                })
            })
        }
        
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
    }
    
}

