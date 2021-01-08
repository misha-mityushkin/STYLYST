//
//  MapView.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-23.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewOLD: UIView {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var centerViewOnLocButton: UIButton!
    
    var exploreVC: ExploreViewController?
    var locationManager: CLLocationManager?
    let regionMeters = 10000.0
    var centeredLocationOnce = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //locationManager = CLLocationManager()
        //checkLocationServices()
        
        
    }
    
    
    
    @IBAction func listViewButtonPressed(_ sender: UIButton) {
        exploreVC?.changeView()
    }
    
    @IBAction func centerViewOnLocPressed(_ sender: UIButton) {
        centerViewOnUserLocation()
    }
    
    

    //MARK: - Location Services Methods
    func setupLocationManager() {
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            Alerts.showNoOptionAlert(title: "Location Services are disabled", message: "Go to Settings>Privacy>Location Services and enable Location Services", sender: exploreVC!)
        }
    }
    
    func checkLocationAuthorization() {
        print("in checkLocationAuthorization")
        switch CLLocationManager.authorizationStatus() {
            case .denied:
                print("denied")
                Alerts.showNoOptionAlert(title: "Please enable Location Services", message: "Go to Settings>Privacy>Location Services>STYLYST and tap \"While Using the App\"", sender: exploreVC!)
                break
            case .restricted:
                print("restricted")
                Alerts.showNoOptionAlert(title: "Location Services are Restricted", message: "Your device has active restrictions such as parental controls. Please contact your administrator to enable Location Services for this app", sender: exploreVC!)
                break
            case .notDetermined:
                print("notDetermined")
                locationManager?.requestWhenInUseAuthorization()
                break
            case .authorizedAlways:
                print("always")
                fallthrough
            case .authorizedWhenInUse:
                print("case whenInUse")
                centerViewOnUserLocation()
                locationManager?.startUpdatingLocation()
                break
            @unknown default:
                print("unknown case")
                break
        }
    }
    
    func centerViewOnUserLocation() {
        print("in centerview")
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            if let location = locationManager?.location?.coordinate {
                print("location not nil")
                let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
                map.setRegion(region, animated: true)
            }
        } else {
            checkLocationAuthorization()
        }
        
    }
    
    
}





//MARK: - CLLocationManagerDelegate Extension
extension MapViewOLD: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //guard let location = locations.last else { return }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}


//MARK: - MKMapViewDelegate Extension
extension MapViewOLD: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //centerViewOnLocButton.setBackgroundImage(UIImage(named: K.Images.locationArrow), for: .normal)
    }
    
}

