//
//  ViewController.swift
//  BackMap
//
//  Created by Rohan Mishra on 8/1/15.
//  Copyright (c) 2015 Holla. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var setDirectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var setDirectionsButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var startingTextField: UITextField!
    
    var onSetDirections = false
    var textFields: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textFields = [destinationTextField, startingTextField]
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

    @IBAction func setCurrentLocation(sender: AnyObject) {
        
    }
    

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for field in textFields {
            field.resignFirstResponder()
        }
    }
}

