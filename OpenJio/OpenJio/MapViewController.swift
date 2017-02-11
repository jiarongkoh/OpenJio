//
//  MapViewController.swift
//  OpenJio
//
//  Created by Koh Jia Rong on 5/2/17.
//  Copyright © 2017 Koh Jia Rong. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var ref: FIRDatabaseReference!
    let locationManager = CLLocationManager()
    var userLocationCoordinate = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        ref = FIRDatabase.database().reference()
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            mapView.showsUserLocation = true
            setUpMapView()
            
        }
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        longPress.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPress)
        
        FIRHelperClient.sharedInstance.getLocationsForActivities(ref) { (results, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
//                print(results)
                
                for result in results! {
                    guard let lat = result.lat, let lon = result.lon, let activity = result.searchActivities else {
                        print("locationForActivities did not return lat or lon")
                        return
                    }
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    annotation.title = activity
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    
    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            print(touchCoordinate)
        }
    }

    
    func setUpMapView() {
        if let userCoordinate = locationManager.location?.coordinate {
            userLocationCoordinate = userCoordinate
            let annotation = MKPointAnnotation()
            annotation.coordinate = userCoordinate
            mapView.addAnnotation(annotation)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: userCoordinate, span: span)
            mapView.setRegion(region, animated: true)

        }
    }

    @IBAction func newSearchButtonDidTap(_ sender: Any) {
        let newSearchVC = storyboard?.instantiateViewController(withIdentifier: "newSearchVC") as! NewSearchViewController
        let navController = UINavigationController(rootViewController: newSearchVC)
        newSearchVC.locationCoordinate = userLocationCoordinate
        present(navController, animated: true, completion: nil)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.image = UIImage(named: "PersonIcon")

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            viewActivity()
            print(view.annotation?.title)
        }
    }
    
    func viewActivity() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "ActivityView") as! ActivityViewController
        navigationController?.pushViewController(controller, animated: true)
    }
}
