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
    
    
    // Handling did update locations function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Getting the latest location
        let userLocation = locations[0]
        
        // Extracting latitude and longitude from the location coordinate
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        // calling displayLocation function to display the location of the user
        displayLocation(latitude: latitude, longitude: longitude, title: "My Location", subtitle: "I am here")
    }
    
    // Function to display user location in mapview
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        
        // Defining span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        
        // Defining Location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Defining Region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // Setting up the region in the map
        mapView.setRegion(region, animated: true)
        
        // Adding annotation to the map view
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }


}

