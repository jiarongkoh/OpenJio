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
import FBSDKLoginKit

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var ref: FIRDatabaseReference!
    let locationManager = CLLocationManager()
    var userLocationCoordinate = CLLocationCoordinate2D()
    let SGCoordinate = CLLocationCoordinate2DMake(1.3521, 103.8198)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var annotationArray: [MKPointAnnotation] = []
        
        let searchGender = UserDefaults.standard.value(forKey: UserDefaultsConstants.SearchPref.Gender) as? String
        let searchDistance = UserDefaults.standard.value(forKey: UserDefaultsConstants.SearchPref.Distance) as? Int
        
        self.navigationItem.title = "Updating..."

        if Reachability.connectedToNetwork() {
            FIRHelperClient.sharedInstance.getLocationsForActivities(userLocationCoordinate, searchGender!, searchDistance!, ref) { (results, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    //                print(results)
                    
                    for result in results! {
                        guard let lat = result.lat, let lon = result.lon, let activity = result.searchActivities, let name = result.name else {
                            print("locationForActivities did not return lat or lon")
                            return
                        }
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        annotation.title = "\(name) \(activity)"
                        annotationArray.append(annotation)
                    }
                    
                    DispatchQueue.main.async {
                        let allAnnotations = self.mapView.annotations
                        self.mapView.removeAnnotations(allAnnotations)
                        self.mapView.addAnnotations(annotationArray)
                        self.navigationItem.title = "Map"
                    }
                }
                
            }
        } else {
            DisplayUI.displayErrorMessage(Messages.NoInternetConnection, hostViewController: self, activityIndicator: nil)
            DispatchQueue.main.async {
                self.navigationItem.title = ""
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        ref = FIRDatabase.database().reference()
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            mapView.showsUserLocation = false
            setUpMapView()
            
        }
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        longPress.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPress)
        
        
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
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = userCoordinate
//            mapView.addAnnotation(annotation)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: SGCoordinate, span: span)
            mapView.setRegion(region, animated: true)

        }
        
        DisplayUI.setUpTabAndNavBar(hostViewController: self)
        
        self.navigationItem.title = "Map"
    }

    @IBAction func newSearchButtonDidTap(_ sender: Any) {
        let newSearchVC = storyboard?.instantiateViewController(withIdentifier: "newSearchVC") as! NewSearchViewController
        let navController = UINavigationController(rootViewController: newSearchVC)
        newSearchVC.locationCoordinate = SGCoordinate
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
        let pinImage = UIImage(named: "PersonIcon")
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContext(size)
        pinImage?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        annotationView?.image = resizedImage
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            if Reachability.connectedToNetwork() {
                viewActivity((view.annotation?.coordinate)!)
//                print(view.annotation?.coordinate)
            } else {
                DisplayUI.displayErrorMessage(Messages.NoInternetConnection, hostViewController: self, activityIndicator: nil)
            }
        }
    }
    
    func viewActivity(_ coordinate: CLLocationCoordinate2D) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "ActivityView") as! ActivityViewController
        let navController = UINavigationController(rootViewController: controller)
        controller.coordinate = coordinate
        present(navController, animated: true, completion: nil)
    }
}
