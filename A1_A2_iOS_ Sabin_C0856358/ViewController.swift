//
//  ViewController.swift
//  A1_A2_iOS_ Sabin_C0856358
//
//  Created by Sabin Regmi on 24/05/2022.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    // create location manager
    var locationMnager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        // assigning the delegate property of the location manager to be this class
        locationMnager.delegate = self
        
        // defining the accuracy of the location
        locationMnager.desiredAccuracy = kCLLocationAccuracyBest
        
        // requesting the permission for location
        locationMnager.requestWhenInUseAuthorization()
        
        // start updating the location
        locationMnager.startUpdatingLocation()
    }
    
   
}

