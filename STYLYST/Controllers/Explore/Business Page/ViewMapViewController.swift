//
//  ShowMapViewController.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-12-27.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import MapKit

class ViewMapViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: UINavigationItem!
	@IBOutlet weak var map: MKMapView!
	@IBOutlet weak var centerLocationButton: UIBarButtonItem!
	
	var businessPageVC: BusinessPageViewController?
	
	var locationPin = MKPointAnnotation()
	
	let regionMeters = 10000.0
	
	var isCentered = true {
		didSet {
			if self.isCentered  {
				if #available(iOS 13.0, *) {
					centerLocationButton.image = UIImage(systemName: K.ImageNames.locationArrowFill)
				} else {
					centerLocationButton.image = UIImage(named: K.ImageNames.locationArrowFill)
				}
			} else {
				if #available(iOS 13.0, *) {
					centerLocationButton.image = UIImage(systemName: K.ImageNames.locationArrow)
				} else {
					centerLocationButton.image = UIImage(named: K.ImageNames.locationArrow)
				}
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		navigationBar.title = businessPageVC?.businessNameLabel.text
		centerMapOnLocation()
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		centerLocationPressed(centerLocationButton)
	}
    
	func centerMapOnLocation() {
		locationPin.coordinate = CLLocationCoordinate2D(latitude: businessPageVC?.businessLocation?.lat ?? 0, longitude: businessPageVC?.businessLocation?.lon ?? 0)
		locationPin.title = businessPageVC?.addressLabel.text
		
		map.addAnnotation(locationPin)
		map.setRegion(MKCoordinateRegion(center: locationPin.coordinate, latitudinalMeters: regionMeters / 10, longitudinalMeters: regionMeters / 10), animated: true)
		isCentered = true
	}
	
	@IBAction func centerLocationPressed(_ sender: UIBarButtonItem) {
		map.setRegion(MKCoordinateRegion(center: locationPin.coordinate, latitudinalMeters: regionMeters / 10, longitudinalMeters: regionMeters / 10), animated: true)
		isCentered = true
	}
	
	@IBAction func closePressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	
}


extension ViewMapViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
		isCentered = false
	}
	
}
