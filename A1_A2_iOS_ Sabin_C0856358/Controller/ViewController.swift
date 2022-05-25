//
//  ViewController.swift
//  A1_A2_iOS_ Sabin_C0856358
//
//  Created by Sabin Regmi on 24/05/2022.
//

import UIKit
import MapKit
import GLKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!

    
    // create location manager
    var locationMnager = CLLocationManager()
    
    // defining user location
    var userLat:CLLocationDegrees = 0;
    var userLong:CLLocationDegrees = 0;
    
    // create the places array
    var places = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.isZoomEnabled = false
        mapView.showsUserLocation = true
        
        // giving the delegate of MKMapViewDelegate to this class
        mapView.delegate = self
        
        // assigning the delegate property of the location manager to be this class
        locationMnager.delegate = self
        
        // defining the accuracy of the location
        locationMnager.desiredAccuracy = kCLLocationAccuracyBest
        
        // requesting the permission for location
        locationMnager.requestWhenInUseAuthorization()
        
        // start updating the location
        locationMnager.startUpdatingLocation()
        
        // Creating a double tap gesture recognizer and placing addDoubleTapAnnotattion function as an action
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(addDoubleTapAnnotattion))
        
        // setting no of taps required as 2
        doubleTap.numberOfTapsRequired = 2
        
        // adding double tap gesture in mapview
        mapView.addGestureRecognizer(doubleTap)
        
    }
    
    
    // Handling did update locations function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Getting the latest location
        let userLocation = locations[0]
        
        // Extracting latitude and longitude from the location coordinate
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        // setting user latitude and longitude
        userLat = latitude;
        userLong = longitude;
        
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
    
    // function to add annotations to the places
    func addAnnotationForPlaces(){
        
        // removing all the annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // looping through places list and creating annotations and adding it to mapview
        for place in places {
            // add annotation for the coordinatet
            let annotation = MKPointAnnotation()
            annotation.title = place.title
            annotation.subtitle = place.subtitle
            annotation.coordinate = place.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    // function to handle double tap in mapview
    @objc func addDoubleTapAnnotattion(gestureRecognizer: UIGestureRecognizer) {
        // getting the touch point
        let touchPoint = gestureRecognizer.location(in: mapView)
        
        // converting touch point to coordinate in mapview
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        
        let nearbyMarker = isNearByMarkerAvailable(coordinate: coordinate)
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude:  coordinate.longitude) // <- Canada
        

        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in

            placemarks?.forEach { (placemark) in

                if let pro = placemark.administrativeArea {
                    
                    if pro == "ON"{
                        
                        if nearbyMarker == "false"{
                            // appending it to places depending upon if its a first location or second or third
                            if self.places.count == 0{
                                self.places.append(Place(title: "A", subtitle: "A", coordinate: coordinate))
                            } else if self.places.count == 1{
                                self.places.append(Place(title: "B", subtitle: "B", coordinate: coordinate))
                            } else if self.places.count == 2{
                                self.places.append(Place(title: "C", subtitle: "C", coordinate: coordinate))
                                
                                // forcing to draw polygon when we have 3 coordinates only will create a triangle
                                self.addPolygon()
                                self.showDistanceAnnotation()
                            } else {
                                // removing annotation from mapview
                                self.mapView.removeAnnotations(self.mapView.annotations)
                                self.mapView.removeOverlays(self.mapView.overlays)
                                
                                // removing places from the list
                                self.places = [Place]()
                            }
                            
                            // calling addAnnotationForPlaces function to add annotation for locations
                            self.addAnnotationForPlaces()
                        }else{
                            self.removePlaces(title: nearbyMarker)
                            self.addAnnotationForPlaces()
                        }
                    }
                    
                }
            }
        })
        
    }
    
    // function to find the nearby marker
    func isNearByMarkerAvailable(coordinate:CLLocationCoordinate2D) -> String{
        for place in places {
            let location1 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let location2 = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            if (calculateDistance(location1: location1, location2: location2) < 100){
                return place.title!
            }
        }
        return "false";
    }
    
    // function to create a triangle (polygon with 3 coordinate will create a triangle)
    func addPolygon() {
        let coordinates = places.map {$0.coordinate}
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polygon)
    }
    
    // function to calculate the distance from user location
    func calculateDistanceFromUserLocation(markerLat: CLLocationDegrees, markerLong: CLLocationDegrees) -> CLLocationDistance{
        
        // defining the user location
        let userLocation = CLLocation(latitude: userLat, longitude: userLong)
        
        // defining the marker location
        let markerLocation = CLLocation(latitude: markerLat, longitude: markerLong)
        
        // calculating the distance between marker location and user location in meters
        let distance: CLLocationDistance = markerLocation.distance(from: userLocation)
        
        // returning the distance
        return distance;
    }
    
    // function to calculate the distance between two locations
    func calculateDistance(location1: CLLocation, location2:CLLocation) -> CLLocationDistance{
        
        // calculating the distance between marker location and user location in meters
        let distance: CLLocationDistance = location1.distance(from: location2)
        
        // returning the distance
        return distance;
    }
    
    // function to remove place from places list
    func removePlaces(title:String){
        for place in places {
            if place.title == title{
                places.remove(at: places.firstIndex(of: place)!)
            }
        }
    }
    
    // function to calculate midpoint of a polygon between two co ordinates  (Reference from stackoverflow)
    func getCenterCoord(_ LocationPoints: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D{
            var x:Float = 0.0;
            var y:Float = 0.0;
            var z:Float = 0.0;
            for points in LocationPoints {
                let lat = GLKMathDegreesToRadians(Float(points.latitude));
                let long = GLKMathDegreesToRadians(Float(points.longitude));

                x += cos(lat) * cos(long);

                y += cos(lat) * sin(long);

                z += sin(lat);
            }
            x = x / Float(LocationPoints.count);
            y = y / Float(LocationPoints.count);
            z = z / Float(LocationPoints.count);
            let resultLong = atan2(y, x);
            let resultHyp = sqrt(x * x + y * y);
            let resultLat = atan2(z, resultHyp);
            let result = CLLocationCoordinate2D(latitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLat))), longitude: CLLocationDegrees(GLKMathRadiansToDegrees(Float(resultLong))));
            return result;
        }
    
    func showDistanceAnnotation() {
            // getting midpoint of polyline from two locations
            let coordinate1 = getCenterCoord([places[0].coordinate, places[1].coordinate])
            let coordinate2 = getCenterCoord([places[1].coordinate, places[2].coordinate])
            let coordinate3 = getCenterCoord([places[2].coordinate, places[0].coordinate])
        
            // getting location of each markers
            let location1 = CLLocation(latitude: places[0].coordinate.latitude, longitude: places[0].coordinate.longitude)
            let location2 = CLLocation(latitude: places[1].coordinate.latitude, longitude: places[1].coordinate.longitude)
            let location3 = CLLocation(latitude: places[2].coordinate.latitude, longitude: places[2].coordinate.longitude)
        
            // plotting annotations showing distance between two markers in the midpoints
            let annotation1 = MKPointAnnotation()
            annotation1.coordinate = coordinate1
            annotation1.title = String(format: "%.2f", calculateDistance(location1: location1, location2: location2))

            let annotation2 = MKPointAnnotation()
            annotation2.coordinate = coordinate2
            annotation2.title = String(format: "%.2f", calculateDistance(location1: location2, location2: location3))

            let annotation3 = MKPointAnnotation()
            annotation3.coordinate = coordinate3
            annotation3.title = String(format: "%.2f", calculateDistance(location1: location1, location2: location3))

            // adding annotations to mapview
            mapView.addAnnotation(annotation1)
            mapView.addAnnotation(annotation2)
            mapView.addAnnotation(annotation3)
        
        }
    
    // function to draw route between two markers
    func drawRouteBetweenTwoMarkers(sourceCoordinate:CLLocationCoordinate2D, destinationCoordinate:CLLocationCoordinate2D){
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationCoordinate)
        
        // request a direction
        let directionRequest = MKDirections.Request()
        
        // assign the source and destination properties of the request
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        // transportation type
        directionRequest.transportType = .automobile
        
        // calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            // create the route
            let route = directionResponse.routes[0]
            // drawing a polyline
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
        
            let rect = route.polyline.boundingMapRect
            self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
                
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            
        }
    }
    
    
    // function to draw route between two markers
    @IBAction func drawRouteBetweenMarkers(_ sender: UIButton) {
        
        mapView.removeOverlays(mapView.overlays)
        
        if places.count == 3 {
            drawRouteBetweenTwoMarkers(sourceCoordinate: places[0].coordinate, destinationCoordinate: places[1].coordinate)
            
            drawRouteBetweenTwoMarkers(sourceCoordinate: places[1].coordinate, destinationCoordinate: places[2].coordinate)

            drawRouteBetweenTwoMarkers(sourceCoordinate: places[2].coordinate, destinationCoordinate: places[0].coordinate)
        } else if places.count == 2 {
            drawRouteBetweenTwoMarkers(sourceCoordinate: places[0].coordinate, destinationCoordinate: places[1].coordinate)
        }
        
        
    }
    
}


extension ViewController: MKMapViewDelegate {
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation.title {
        case "A", "B", "C":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        default:
            return nil
        }
    }
    
    // function to callout accessory control
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // getting latitude and longitude from annotationview
        let lat = (view.annotation?.coordinate.latitude)!;
        let long = view.annotation?.coordinate.longitude;
        
        // calling function to calculate the distance
        let distance = calculateDistanceFromUserLocation(markerLat: lat, markerLong: long!)
        
        // showing informational alert to show the distance
        let alertController = UIAlertController(title: "Distance", message: "Distance between the marker and user location is \(String(format: "%.3f", distance))} meters", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    // function to render overlay for polygon
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        } else if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.blue
            rendrer.lineWidth = 3
            return rendrer
        }
        return MKOverlayRenderer()
    }
}


