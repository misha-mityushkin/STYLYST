//
//  Helpers.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-06-01.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import MapKit
import Firebase

struct Helpers {
	
	static func addUserToUserDefaults(firstName: String, lastName: String, email: String, phoneNumber: String, password: String, uid: String) {
		UserDefaults.standard.set(firstName, forKey: K.UserDefaultKeys.firstName)
		UserDefaults.standard.set(lastName, forKey: K.UserDefaultKeys.lastName)
		UserDefaults.standard.set(email, forKey: K.UserDefaultKeys.email)
		UserDefaults.standard.set(phoneNumber, forKey: K.UserDefaultKeys.phoneNumber)
		UserDefaults.standard.set(password, forKey: K.UserDefaultKeys.password)
		UserDefaults.standard.set(uid, forKey: K.UserDefaultKeys.uid)
	}
	
	static func removeUserFromDefaults() {
		UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.firstName)
		UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.lastName)
		UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.email)
		UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.phoneNumber)
		UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.password)
		UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.uid)
		UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.verificationID)
		UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.otp)
		print("removed user")
	}
	
	
	static func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
		guard !phoneNumber.isEmpty else { return "" }
		guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
		let r = NSString(string: phoneNumber).range(of: phoneNumber)
		var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")
		
		if number.count > 10 {
			let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
			number = String(number[number.startIndex..<tenthDigitIndex])
		}
		
		if shouldRemoveLastDigit {
			let end = number.index(number.startIndex, offsetBy: number.count-1)
			number = String(number[number.startIndex..<end])
		}
		
		if number.count < 7 {
			let end = number.index(number.startIndex, offsetBy: number.count)
			let range = number.startIndex..<end
			number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)
			
		} else {
			let end = number.index(number.startIndex, offsetBy: number.count)
			let range = number.startIndex..<end
			number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
		}
		
		return number
	}
	
	
	static func parseAddress(for placemark: MKPlacemark) -> String {
		// put a space between number and street name
		let firstSpace = (placemark.subThoroughfare != nil && placemark.thoroughfare != nil) ? " " : ""
		// put a comma between street and city/state
		let comma = (placemark.subThoroughfare != nil || placemark.thoroughfare != nil) && (placemark.subAdministrativeArea != nil || placemark.administrativeArea != nil) ? ", " : ""
		// put a space between city and state
		let secondSpace = (placemark.subAdministrativeArea != nil && placemark.administrativeArea != nil) ? " " : ""
		// put a space between state and postal code
		let thirdSpace = (placemark.administrativeArea != nil && placemark.postalCode != nil) ? " " : ""
		let addressLine = String(
			format:"%@%@%@%@%@%@%@%@%@",
			// street number
			placemark.subThoroughfare ?? "",
			firstSpace,
			// street name
			placemark.thoroughfare ?? "",
			comma,
			// city
			placemark.locality ?? "",
			secondSpace,
			// state
			placemark.administrativeArea ?? "",
			thirdSpace,
			// postal code
			placemark.postalCode ?? ""
		)
		return addressLine
	}
	
	static func formatAddress(streetNumber: String, streetName: String, city: String, province: String, postalCode: String) -> String {
		return "\(streetNumber) \(streetName), \(city) \(province) \(postalCode)"
	}
	static func formatAddress(dictionary: [String : String]?) -> String {
		let streetNumber = dictionary?[K.Firebase.PlacesFieldNames.Address.streetNumber] ?? "Unknown Address"
		let streetName = dictionary?[K.Firebase.PlacesFieldNames.Address.streetName] ?? ""
		let city = dictionary?[K.Firebase.PlacesFieldNames.Address.city] ?? ""
		let province = dictionary?[K.Firebase.PlacesFieldNames.Address.province] ?? ""
		let postalCode = dictionary?[K.Firebase.PlacesFieldNames.Address.postalCode] ?? ""
		return formatAddress(streetNumber: streetNumber, streetName: streetName, city: city, province: province, postalCode: postalCode)
	}
	
	
	
	static func getBusinessTypeEnum(fromIdentifier identifier: String) -> BusinessType {
		var businessType = BusinessType.BarberShop
		for i in 0..<K.Collections.businessTypeIdentifiers.count {
			if K.Collections.businessTypeIdentifiers[i] == identifier {
				businessType = K.Collections.businessTypeEnums[i]
			}
		}
		return businessType
	}
	
	static func getBusinessTypeDisplayName(fromEnum type: BusinessType) -> String {
		var displayName = "Barber Shop"
		for i in 0..<K.Collections.businessTypeEnums.count {
			if K.Collections.businessTypeEnums[i] == type {
				displayName = K.Collections.businessTypeDisplayNames[i]
			}
		}
		return displayName
	}
	
	static func getBusinessTypeMapPinImage(fromEnum type: BusinessType) -> UIImage? {
		var mapPinImage = UIImage(named: K.ImageNames.barberMapPin)
		for i in 0..<K.Collections.businessTypeEnums.count {
			if K.Collections.businessTypeEnums[i] == type {
				mapPinImage = UIImage(named: K.Collections.businessTypeMapPinImageNames[i])
			}
		}
		return mapPinImage
	}
	
	
	static func sortAnnotations(annotations: [BusinessAnnotation], sortingMethod: SortingMethod) -> [BusinessAnnotation] {
		var sortedAnnotations = annotations
		switch sortingMethod {
			case .DistanceFromCurrentLocation:
				sortedAnnotations.sort { (annotation1, annotation2) -> Bool in
					return annotation1.distanceToUsersCurrentLocation < annotation2.distanceToUsersCurrentLocation
				}
			case .Alphabetically:
				sortedAnnotations.sort { (annotation1, annotation2) -> Bool in
					return annotation1.title ?? "Unknown Name" < annotation2.title ?? "Unknown Name"
				}
		}
		return sortedAnnotations
	}
	
}
