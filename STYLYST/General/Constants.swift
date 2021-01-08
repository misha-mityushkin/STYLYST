//
//  Constants.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-15.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

struct K {
	
	struct Collections {
		static let businessTypeIdentifiers = ["barbershop", "hairSalon", "nailSalon", "beautySalon", "spa", "other"]
		static let businessTypeDisplayNames = ["Barbershop", "Hair Salon", "Nail Salon", "Beauty Salon", "Spa", "Other"]
		static let businessTypeEnums = [BusinessType.BarberShop, BusinessType.HairSalon, BusinessType.NailSalon, BusinessType.BeautySalon, BusinessType.Spa, BusinessType.Other]
		static let businessTypeMapPinImageNames = [K.ImageNames.barberMapPin, K.ImageNames.hairSalonMapPin, K.ImageNames.nailSalonMapPin, K.ImageNames.beautySalonMapPin, K.ImageNames.spaMapPin, K.ImageNames.otherMapPin]
		static let daysOfTheWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
		static let daysOfTheWeekIdentifiers = [K.Firebase.PlacesFieldNames.WeeklyHours.monday, K.Firebase.PlacesFieldNames.WeeklyHours.tuesday, K.Firebase.PlacesFieldNames.WeeklyHours.wednesday, K.Firebase.PlacesFieldNames.WeeklyHours.thursday, K.Firebase.PlacesFieldNames.WeeklyHours.friday, K.Firebase.PlacesFieldNames.WeeklyHours.saturday, K.Firebase.PlacesFieldNames.WeeklyHours.sunday]
		static let sortingMethodsDisplayNames = ["Distance from you", "Alphabetically"]
		static let sortingMethodsEnums = [SortingMethod.DistanceFromCurrentLocation, SortingMethod.Alphabetically]
		static let navBarGradientColors = [K.Colors.transparentBlackHeavy?.cgColor ?? UIColor.black.cgColor, K.Colors.transparentBlackMedium?.cgColor ?? UIColor.clear.cgColor, UIColor.clear.cgColor]
		static let navBarGradientColorsScrolled = [UIColor.black.cgColor, K.Colors.transparentBlackHeavy?.cgColor ?? UIColor.black.cgColor, K.Colors.transparentBlackMediumHeavy?.cgColor ?? UIColor.clear.cgColor, K.Colors.transparentBlackMediumLight?.cgColor ?? UIColor.clear.cgColor]
	}
	
	struct FontNames {
		static let glacialIndifferenceRegular = "GlacialIndifference-Regular"
		static let glacialIndifferenceBold = "GlacialIndifference-Bold"
	}
    
    struct Identifiers {
		static let profileHeaderCellIdentifier = "profileHeaderCell"
        static let profileSectionCell = "profileSectionCell"
		static let listViewCell = "listViewCell"
        static let searchResultsCell = "searchResultsCell"
		static let searchResultsHeaderCell = "searchResultsHeaderCell"
		static let businessTypeFilterTableViewCellIdentifier = "businessTypeFilterTableViewCell"
		static let businessAnnotationViewIdentifier = "businessAnnotationViewIdentifier"
		static let sideMenuNavController = "sideMenuNavController"
		static let filterMenuViewController = "filterMenuVC"
		static let businessPageViewController = "businessPageVC"
		static let servicesCellIdentifier = "servicesCell"
		static let servicesHeaderCellIdentifier = "servicesHeaderCell"
    }
	
	struct Nibs {
		static let mapViewNibName = "MapView"
		static let listViewNibName = "ListView"
		static let profileHeaderCellNibName = "ProfileHeaderTableViewCell"
		static let profileSectionCellNibName = "ProfileSectionTableViewCell"
		static let filtersMenuBusinessTypeCellNibName = "BusinessTypeFilterTableViewCell"
		static let listViewCellNibName = "ListViewTableViewCell"
		static let searchResultsCellNibName = "SearchResultTableViewCell"
		static let searchResultsHeaderCellNibName = "SearchResultsHeaderTableViewCell"
		static let loadingViewNibName = "LoadingView"
		static let servicesHeaderCellNibName = "ServicesHeaderCell"
		static let servicesCellNibName = "ServicesTableViewCell"
		
	}
    
    struct ImageNames {
        static let firstLaunchSlideImageName = "randomScreenshot"
        static let backgroundNoLogo = "background"
        static let backgroundWithLogo = "background.logo"
        static let listView = "list.bullet.below.rectangle"
        static let mapView = "map"
        static let ellipsis = "ellipsis.circle"
        static let slider = "slider.horizontal.3"
		static let photoPlaceholder = "photo"
		static let loadingError = "exclamationmark.icloud"
		static let loadingImage = "loadingImage"
		static let eyeSlash = "eye.slash"
		static let greaterThan = "greaterthan"
		static let arrowRight = "arrow.right"
		static let arrowRightCircle = "arrow.right.circle"
		static let xMarkCircle = "xmark.circle.fill"
		static let chevronDown = "chevron.down"
		static let chevronUp = "chevron.up"
		static let locationArrow = "location"
		static let locationArrowFill = "location.fill"
		static let heart = "heart"
		static let heartFill = "heart.fill"
		
		static let barberMapPin = "barberMapPin"
		static let hairSalonMapPin = "hairSalonMapPin"
		static let nailSalonMapPin = "nailSalonMapPin"
		static let beautySalonMapPin = "beautySalonMapPin"
		static let spaMapPin = "spaMapPin"
		static let otherMapPin = "otherMapPin"
    }
    struct Images {
		@available(iOS 13.0, *)
		static let photoPlaceholderSystem = UIImage(systemName: K.ImageNames.photoPlaceholder)!
		static let photoPlaceHolder = UIImage(named: K.ImageNames.photoPlaceholder)!
		@available(iOS 13.0, *)
		static let errorImageSystem = UIImage(systemName: K.ImageNames.loadingError)!
		static let errorImage = UIImage(named: K.ImageNames.loadingError)!
		
		
		static func getPlaceholderImage() -> UIImage {
			if #available(iOS 13.0, *) {
				return photoPlaceholderSystem
			} else {
				return photoPlaceHolder
			}
		}
		
		static func getErrorImage() -> UIImage {
			if #available(iOS 13.0, *) {
				return errorImageSystem
			} else {
				return errorImage
			}
		}
		
		static let loadingImage = UIImage(named: K.ImageNames.loadingImage)
		
//        static let firstLaunchSlideImageName = UIImage(named: K.ImageNames.firstLaunchSlideImageName)
//        static let backgroundNoLogo = UIImage(named: K.ImageNames.backgroundNoLogo)
//        static let backgroundWithLogo = UIImage(named: K.ImageNames.backgroundWithLogo)
//
//        // icons
//        @available(iOS 13.0, *)
//        static let listViewSystem = UIImage(systemName: K.ImageNames.listView)
//        static let listView = UIImage(named: K.ImageNames.listView)
//
//        @available(iOS 13.0, *)
//        static let mapViewSystem = UIImage(systemName: K.ImageNames.mapView)
//        static let mapView = UIImage(named: K.ImageNames.mapView)
//
//        @available(iOS 13.0, *)
//        static let ellipsisSystem = UIImage(systemName: K.ImageNames.ellipsis)
//        static let ellipsis = UIImage(named: K.ImageNames.ellipsis)
//
//        @available(iOS 13.0, *)
//        static let sliderSystem = UIImage(systemName: K.ImageNames.slider)
//        static let slider = UIImage(named: K.ImageNames.slider)
    }
    
    struct Strings {
        static let appName = "STYLYST"
		static let dateAndTimeFormatString = "yyyy-MM-dd HH:mm"
		static let dateFormatString = "yyyy-MM-dd"
    }
    
    struct ColorNames {
        static let goldenThemeColorLight = "GoldenThemeColorLight"
        static let goldenThemeColorDark = "GoldenThemeColorDark"
        static let goldenThemeColorDefault = "GoldenThemeColorDefault"
        static let goldenThemeColorInverse = "GoldenThemeColorInverse"
		static let goldenThemeColorInverseMoreContrast = "GoldenThemeColorInverseMoreContrast"
        static let placeholderTextColor = "placeholderTextColor"
		static let transparentBlackHeavy = "TransparentBlackHeavy"
		static let transparentBlackMediumHeavy = "TransparentBlackMediumHeavy"
		static let transparentBlackMedium = "TransparentBlackMedium"
		static let transparentBlackMediumLight = "TransparentBlackMediumLight"
		static let transparentBlackLight = "TransparentBlackLight"
		static let transparentBlackLighter = "TransparentBlackLighter"
    }
    struct Colors {
        static let goldenThemeColorLight = UIColor(named: K.ColorNames.goldenThemeColorLight)
        static let goldenThemeColorDark = UIColor(named: K.ColorNames.goldenThemeColorDark)
        static let goldenThemeColorDefault = UIColor(named: K.ColorNames.goldenThemeColorDefault)
        static let goldenThemeColorInverse = UIColor(named: K.ColorNames.goldenThemeColorInverse)
		static let goldenThemeColorInverseMoreContrast = UIColor(named: K.ColorNames.goldenThemeColorInverseMoreContrast)
        static let placeholderTextColor = UIColor(named: K.ColorNames.placeholderTextColor)
		static let transparentBlackHeavy = UIColor(named: K.ColorNames.transparentBlackHeavy)
		static let transparentBlackMediumHeavy = UIColor(named: K.ColorNames.transparentBlackMediumHeavy)
		static let transparentBlackMedium = UIColor(named: K.ColorNames.transparentBlackMedium)
		static let transparentBlackMediumLight = UIColor(named: K.ColorNames.transparentBlackMediumLight)
		static let transparentBlackLight = UIColor(named: K.ColorNames.transparentBlackLight)
		static let transparentBlackLighter = UIColor(named: K.ColorNames.transparentBlackLighter)
    }
    
    
    struct Segues {
        static let firstLaunchSegue = "firstLaunchSegue"
        
        static let mapToListSegue = "mapToListSegue"
        static let listToMapSegue = "listToMapSegue"
		
		static let exploreToBusinessPage = "exploreToBusinessPage"
		static let searchToBusinessPage = "searchToBusinessPage"
		
		static let businessPageToShowLocation = "businessPageToShowLocation"
		static let businessPageToViewAllServices = "businessPageToViewAllServices"
        
        static let signInToRegister = "signInToRegister"
        static let signInToFinishRegister = "signInToFinishRegister"
        static let registerToConfirm = "registerToConfirm"
        static let signInToProfile = "signInToProfile"
    }
    
    struct UserDefaultKeys {
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let email = "email"
        static let phoneNumber = "phoneNumber"
        static let phoneNumberFormatted = "phoneNumberFormatted"
        static let password = "password"
        static let verificationID = "verificationID"
        static let otp = "otp"
		static let personalCode = "personalCode"
        static let uid = "uid"
        
        static let sentVerificationCode = "sentVerificationCode"
        static let finishedRegistration = "finishedRegistration"
        static let isSignedIn = "isSignedIn"
    }
    
    struct Firebase {
        struct CollectionNames {
            static let users = "users"
            static let places = "places"
        }
        
        struct UserFieldNames {
            static let firstName = "firstName"
            static let lastName = "lastName"
            static let email = "email"
            static let phoneNumber = "phoneNumber"
            static let password = "password"
            static let verificationID = "verificationID"
            static let otp = "otp"
			static let personalCode = "personalCode"
            static let hasBusinessAccount = "hasBusinessAccount"
            static let businesses = "businesses"
			static let employmentLocations = "employmentLocations"
			static let favoritePlaces = "favoritePlaces"
        }
        
        struct PlacesFieldNames {
			static let dateEstablished = "dateEstablished"
			static let name = "name"
			static let addressFormatted = "addressFormatted"
			static let lat = "lat"
			static let lon = "lon"
			static let address = "address"
			struct Address {
				static let streetNumber = "streetNumber"
				static let streetName = "streetName"
				static let city = "city"
				static let province = "province"
				static let postalCode = "postalCode"
			}
			static let ownerUserID = "ownerUserID"
			static let staffUserIDs = "staffUserIDs"
			static let email = "email"
			static let phoneNumber = "phoneNumber"
			static let coordinates = "coordinates"
			static let introParagraph = "introParagraph"
			static let businessType = "businessType"
			
			static let services = "services"
			struct Services {
				static let enabled = "enabled"
				static let name = "name"
				static let description = "description"
				static let defaultPrice = "price"
				static let specificPrices = "prices"
				static let defaultTime = "time"
				static let specificTimes = "times"
				static let staff = "staff"
			}
			
			static let weeklyHours = "weeklyHours"
			static let staffWeeklyHours = "staffWeeklyHours"
			struct WeeklyHours {
				static let monday = "monday"
				static let tuesday = "tuesday"
				static let wednesday = "wednesday"
				static let thursday = "thursday"
				static let friday = "friday"
				static let saturday = "saturday"
				static let sunday = "sunday"
			}
			static let specificHours = "specificHours"
			static let staffSpecificHours = "staffSpecificHours"
			
			static let keywords = "keywords"
        }
		
		struct Storage {
			static let placesImagesFolder = "placesImages"
		}
        
    }
    
    struct Storyboard {
        static let profileVC = "profileVC"
        static let signInVC = "signInVC"
		static let confirmRegisterVC = "confirmRegisterVC"
        static let locationSearchTable = "locationSearchTable"
    }
}
