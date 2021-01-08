//
//  BusinessAnnotation.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-07-08.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import MapKit

class BusinessAnnotation: NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D
	var type: BusinessType
	var docID: String
	
	var title: String?
	var subtitle: String?
	var firstImage: UIImage?
	var images: [UIImage?] = []
	var data: [String : Any]?
	
	var allImagesLoaded = false
	
	
	init(coordinate: CLLocationCoordinate2D, data: [String : Any]?, docID: String) {
		self.data = data
		self.docID = docID
		self.coordinate = coordinate
		let businessTypeIdentifier = data?[K.Firebase.PlacesFieldNames.businessType] as? String ?? "barbershop"
		self.type = Helpers.getBusinessTypeEnum(fromIdentifier: businessTypeIdentifier)
	}
	
	init(data: [String : Any]?, docID: String) {
		self.docID = docID
		self.data = data
		let lat = data?[K.Firebase.PlacesFieldNames.lat] as? Double ?? 0
		let lon = data?[K.Firebase.PlacesFieldNames.lon] as? Double ?? 0
		self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
		let businessTypeIdentifier = data?[K.Firebase.PlacesFieldNames.businessType] as? String ?? "barbershop"
		self.type = Helpers.getBusinessTypeEnum(fromIdentifier: businessTypeIdentifier)
		let name = data?[K.Firebase.PlacesFieldNames.name] as? String
		let address = data?[K.Firebase.PlacesFieldNames.addressFormatted] as? String
		self.title = name
		self.subtitle = address
	}
	
	func setFirstImage(image: UIImage?) {
		self.firstImage = image
		if images.isEmpty {
			images = [image]
		}
	}
}



extension BusinessAnnotation {
	var distanceToUsersCurrentLocation: Double {
		if let userLoc = CLLocationManager().location {
			
			let destinationCoordinates = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude) //coordinates for destination
			let selfCoordinates = CLLocation(latitude: userLoc.coordinate.latitude, longitude: userLoc.coordinate.longitude) //user's location
			
			return selfCoordinates.distance(from: destinationCoordinates) //return distance in **meters**
			
		} else {
			return -1
		}
	}
}
