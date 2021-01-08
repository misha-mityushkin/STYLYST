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
import Firebase

class MapView: UIView {

    @IBOutlet weak var map: MKMapView!
	@IBOutlet weak var searchInstructionView: UIView!
	
    var exploreVC: ExploreViewController?
    var locationManager: CLLocationManager?
    let regionMeters = 10000.0
    var centeredLocationOnce = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
		map.delegate = self
//		if #available(iOS 13.0, *) {
//			self.overrideUserInterfaceStyle = .light
//		}
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
extension MapView: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //guard let location = locations.last else { return }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}


//MARK: - MKMapViewDelegate Extension
extension MapView: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
		if searchInstructionView.alpha > 0 {
			exploreVC?.fadeOutSearchInstructions()
		}
	}
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("region changed")
        print("radius: \(map.currentRadius())")
        exploreVC?.sendQuery(region: map.region)
    }
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		if annotation is MKUserLocation {
			return nil
		} else if annotation is BusinessAnnotation {
			let businessAnnotation = annotation as! BusinessAnnotation
			
			let annotationView = MKAnnotationView(annotation: businessAnnotation, reuseIdentifier: K.Identifiers.businessAnnotationViewIdentifier)
			annotationView.canShowCallout = true
			
			annotationView.leftCalloutAccessoryView = exploreVC?.getImageViewForAnnotation(image: businessAnnotation.firstImage)
			let button = UIButton(frame: CGRect(x: 0, y: 0, width: 26, height: 25))
			//button.imageView?.contentMode = .scaleAspectFit
			if #available(iOS 13.0, *) {
				button.setBackgroundImage(UIImage(systemName: K.ImageNames.arrowRightCircle), for: .normal)
			} else {
				button.setBackgroundImage(UIImage(named: K.ImageNames.arrowRightCircle), for: .normal)
			}
			button.tintColor = K.Colors.goldenThemeColorInverseMoreContrast
			button.addTarget(exploreVC, action: #selector(exploreVC?.openBusinessPage), for: .touchUpInside)
			annotationView.rightCalloutAccessoryView = button
			annotationView.image = Helpers.getBusinessTypeMapPinImage(fromEnum: businessAnnotation.type)
//			for i in 0..<K.Collections.businessTypeEnums.count {
//				if K.Collections.businessTypeEnums[i] == businessAnnotation.type {
//					annotationView.image = UIImage(named: K.Collections.businessTypeMapPinImageNames[i])
//				}
//			}
			
			return annotationView
			
		} else {
			return nil
		}
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		if view.annotation is BusinessAnnotation {
			exploreVC?.selectedAnnotation = view.annotation as? BusinessAnnotation
		}
	}
    
}

