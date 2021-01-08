//
//  HomeScreenViewController.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-15.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext = true
        navigationController?.isNavigationBarHidden = true
        
        
        mapView.showsUserLocation = true
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            //locationManager.requestLocation()
        } else {
            
        }
        

        searchBar.layer.cornerRadius = 15
        searchBar.changeSearchBarColor(color: UIColor(named: K.Colors.goldenThemeColorDefault) ?? .black, size: CGSize(width: searchBar.frame.size.width, height: 40))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            performSegue(withIdentifier: K.Segues.firstLaunchSegue, sender: self)
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        
        
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            }
            
            //searchBar.searchTextField.rightView = nil
        } else {
            // Fallback on earlier versions
        }
        
        
        
    }
    
    
    @IBAction func listViewButtonPressed(_ sender: UIButton) {
        //tabBarController?.tabBar.isHidden = true
        performSegue(withIdentifier: K.Segues.mapToListSegue, sender: self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        if #available(iOS 13.0, *) {
            searchBar.changeSearchBarColor(color: UIColor(named: K.Colors.goldenThemeColorDefault) ?? .black, size: CGSize(width: searchBar.frame.size.width, height: 40))
            
            if UITraitCollection.current.userInterfaceStyle == .dark {
                searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            } else {
                searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            }
            
            //searchBar.searchTextField.rightView = nil
        } else {
            // Fallback on earlier versions
        }

    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lat = locations[0].coordinate.latitude
        let lon = locations[0].coordinate.longitude
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07))
        mapView.setRegion(region, animated: false)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
//        stopLoadingAnimation()
        Alerts.showNoOptionAlert(title: "Network Error", message: "We have encountered a network error. Check your internet connection and try again.", sender: self)
    }
    
}



