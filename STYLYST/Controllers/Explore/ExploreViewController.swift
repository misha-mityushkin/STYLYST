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
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Geofirestore
import SideMenu
import ImageSlideshow

class ExploreViewController: UIViewController, CLLocationManagerDelegate {
    
	var db: Firestore!
    
    var mapView = UINib(nibName: K.Nibs.mapViewNibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MapView
    var listView = UINib(nibName: K.Nibs.listViewNibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ListView
	
	var filterButton: UIButton?
    var switchViewButton: UIButton?
    var isSwitchingViews = false
	let loadingView = UIActivityIndicatorView(style: .gray)
    
    var errorOccurredOnce = false
    
    var resultSearchController: UISearchController?
	
	var allAnnotations: [BusinessAnnotation] = [] // all custom annotations including those not displayed on the map due to filters
	var visibleAnnotations: [BusinessAnnotation] = [] // only the annotations currently visible in the map rectangle
	
	var spinnerView = LoadingView()
	
	var filterMenu: SideMenuNavigationController?
	
	var viewAppearedOnce = false
	
	var businessTypeIsEnabled: [Bool] = []
	
	var selectedAnnotation: BusinessAnnotation? // the last annotation that was selected
	
	var displayedNoResultsAlert = false
	
	var sortingMethod: SortingMethod = .DistanceFromCurrentLocation
	
	var user: User?
	    
    override func viewDidLoad() {
        super.viewDidLoad()
		db = Firestore.firestore()
		
		getUserData()
		
        view = mapView
		mapView.searchInstructionView.alpha = 0
		listView.searchInstructionView.alpha = 0
        mapView.exploreVC = self
        listView.exploreVC = self
        
		filterMenu = storyboard?.instantiateViewController(withIdentifier: K.Identifiers.sideMenuNavController) as? SideMenuNavigationController
		SideMenuManager.default.rightMenuNavigationController = filterMenu
		filterMenu?.statusBarEndAlpha = 0
		filterMenu?.presentationStyle = .viewSlideOutMenuPartialIn
		filterMenu?.menuWidth = UIScreen.main.bounds.width * 2.0 / 3.0
		filterMenu?.presentDuration = 0.5
		filterMenu?.dismissDuration = 0.5
		filterMenu?.initialSpringVelocity = 0.7
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: K.Storyboard.locationSearchTable) as! LocationSearchTable
		locationSearchTable.tableView.backgroundView = UIImageView(image: UIImage(named: K.ImageNames.backgroundNoLogo))
		locationSearchTable.exploreVC = self
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        
		for _ in 0..<K.Collections.businessTypeDisplayNames.count {
			businessTypeIsEnabled.append(true)
		}
        
        hideKeyboardWhenTappedAround(for: mapView)
        hideKeyboardWhenTappedAround(for: listView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		
		if !viewAppearedOnce {
			viewAppearedOnce = true
			
			print("mapView w: \(mapView.frame.width) h: \(mapView.frame.height)")
			
			let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
			if launchedBefore {
				mapView.locationManager = CLLocationManager()
				mapView.checkLocationServices()
			} else {
				performSegue(withIdentifier: K.Segues.firstLaunchSegue, sender: self)
				UserDefaults.standard.set(true, forKey: "launchedBefore")
			}
			setUpNavBar()
			
		} else {
			//nothing for now
		}
    }
    
    func setUpNavBar() {
        let searchBar = resultSearchController!.searchBar
		var placeholderText = "What'll it be today"
		if let firstName = UserDefaults.standard.string(forKey: K.UserDefaultKeys.firstName) {
			placeholderText.append(", \(firstName)?")
		} else {
			placeholderText.append("?")
		}
		searchBar.placeholder = placeholderText
        searchBar.searchBarStyle = .minimal
		searchBar.delegate = self
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = .black
        navigationItem.titleView = resultSearchController?.searchBar
        
        switchViewButton = UIButton(type: .system)
		switchViewButton!.setBackgroundImage(UIImage(named: K.ImageNames.listView), for: .normal)
        switchViewButton!.tintColor = .black
        switchViewButton!.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        switchViewButton!.addTarget(self, action: #selector(changeView), for: .touchUpInside)
		
		loadingView.color = .black
		loadingView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
		loadingView.startAnimating()
		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: loadingView)
        
        filterButton = UIButton(type: .system)
		filterButton!.setImage(UIImage(named: K.ImageNames.slider), for: .normal)
        filterButton!.tintColor = .black
        filterButton!.frame = CGRect(x: 0, y: 0, width: 33, height: 36)
		filterButton!.imageView?.contentMode = .scaleAspectFill
		filterButton!.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 4.6, right: 0)
        filterButton!.addTarget(self, action: #selector(openFilters), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterButton!)
        
        
        if #available(iOS 13.0, *) {
            resultSearchController!.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: K.ColorNames.placeholderTextColor) ?? UIColor.gray])
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
//        if #available(iOS 13.0, *) {
//            resultSearchController!.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: K.Colors.placeholderTextColor) ?? UIColor.gray])
//        }
    }
	
	func getUserData() {
		if let user = Auth.auth().currentUser {
			db.collection(K.Firebase.CollectionNames.users).document(user.uid).getDocument { (userDocument, error) in
				if let userDocument = userDocument, userDocument.exists, error == nil {
					self.user = User(userID: user.uid, data: userDocument.data())
				}
			}
		}
	}
    
    
    @objc func openFilters() {
		if let filterMenu = filterMenu {
			filterMenu.isNavigationBarHidden = true
			(filterMenu.viewControllers[0] as? FilterMenuViewController)?.exploreVC = self
			present(filterMenu, animated: true, completion: nil)
		}
    }
    
	
	func addOrRemoveBusinessType(typeIndex: Int, isEnabled: Bool) {
		(resultSearchController?.searchResultsController as? LocationSearchTable)?.updateSearchResults(for: resultSearchController!)
		let type = K.Collections.businessTypeEnums[typeIndex]
		for annotation in allAnnotations {
			if annotation.type == type {
				if isEnabled {
					mapView.map.addAnnotation(annotation)
				} else {
					mapView.map.removeAnnotation(annotation)
				}
			}
		}
	}
    
    
    @objc func changeView() {
        resultSearchController?.isActive = false
		fadeOutSearchInstructions()
        if !isSwitchingViews {
            isSwitchingViews = true
            switch view {
                case mapView:
                    //switch views
                    UIView.transition(from: mapView, to: listView, duration: 0.6, options: .transitionFlipFromLeft) { (finished) in
                        if finished {
                            self.isSwitchingViews = false
                        }
                    }
                    UIView.animate(withDuration: 0.3, animations: {
                        //fade out current icon
                        self.switchViewButton?.alpha = 0
                    }) { (_) in
                        //change icon
						self.switchViewButton!.setBackgroundImage(UIImage(named: K.ImageNames.mapView), for: .normal)
                        
                        //fade in new icon
                        UIView.animate(withDuration: 0.3) {
                            self.switchViewButton?.alpha = 1
                        }
                    }
                    view = listView
                default:
                    UIView.transition(from: listView, to: mapView, duration: 0.6, options: .transitionFlipFromLeft) { (finished) in
                        if finished {
                            self.isSwitchingViews = false
                        }
                    }
                    UIView.animate(withDuration: 0.3, animations: {
                        //fade out current icon
                        self.switchViewButton?.alpha = 0
                    }) { (_) in
                        //change icon
						self.switchViewButton!.setBackgroundImage(UIImage(named: K.ImageNames.listView), for: .normal)
                        
                        //fade in new icon
                        UIView.animate(withDuration: 0.3) {
                            self.switchViewButton?.alpha = 1
                        }
                    }
                    view = mapView
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FirstLaunchSlideViewController {
            (segue.destination as! FirstLaunchSlideViewController).exploreVC = self
		} else if segue.destination is UINavigationController {
			print("setting exploreVC of business page vc")
			let businessPageVC = storyboard!.instantiateViewController(withIdentifier: K.Identifiers.businessPageViewController) as! BusinessPageViewController
			(segue.destination as! UINavigationController).viewControllers = [businessPageVC]
			
			businessPageVC.exploreVC = self
			businessPageVC.isFromSearch = false
		}
    }
    
    
    
    func sendQuery(region: MKCoordinateRegion) {
		print("sendQuery")
        let placesFirestoreRef = db.collection(K.Firebase.CollectionNames.places)
        let geoFirestore = GeoFirestore(collectionRef: placesFirestoreRef)
        
        if region.isValid {
			print("region is valid, making regionquery")
			
			let regionQuery = geoFirestore.query(inRegion: region)
			//let regionQuery = geoFirestore.query(withCenter: CLLocation(latitude: region.center.latitude, longitude: region.center.longitude), radius: mapView.map.currentRadius())
			
			regionQuery.removeAllObservers()
			let queryHandleEntered = regionQuery.observe(.documentEntered, with: { (docID, location) in
				if let location = location, let docID = docID {
					
					for annotation in self.allAnnotations {
						if annotation.docID == docID { //if this document is already in the annotations array
							return
						}
					}
					
					print("The document with documentID '\(docID)' entered the search area and is at location '\(location)'")
					placesFirestoreRef.document(docID).getDocument { (document, error) in
						print("getting document")
						if let document = document, document.exists, error == nil {
							let name = document.get(K.Firebase.PlacesFieldNames.name) as? String
							let address = document.get(K.Firebase.PlacesFieldNames.addressFormatted) as? String
							let typeIdentifier = document.get(K.Firebase.PlacesFieldNames.businessType) as? String
							
							var type: BusinessType = .Other
							for i in 0..<K.Collections.businessTypeIdentifiers.count {
								if K.Collections.businessTypeIdentifiers[i] == typeIdentifier {
									type = K.Collections.businessTypeEnums[i]
								}
							}
							
							let annotation = BusinessAnnotation(coordinate: location.coordinate, data: document.data(), docID: docID)
							annotation.title = name
							annotation.subtitle = address
							
							for annotation in self.allAnnotations {
								if annotation.docID == docID { //if this document is already in the annotations array
									return
								}
							}
							self.allAnnotations.append(annotation)
							
							for i in 0..<K.Collections.businessTypeEnums.count {
								if K.Collections.businessTypeEnums[i] == type && !self.businessTypeIsEnabled[i] {
									return
								}
							}
							self.mapView.map.addAnnotation(annotation)
							
							let imagesFolderRef = Storage.storage().reference().child("\(K.Firebase.Storage.placesImagesFolder)/\(docID)")
							imagesFolderRef.child("image1").getData(maxSize: 5 * 1024 * 1024) { (data, error) in
								if let error = error {
									print("error: \(error.localizedDescription)")
								} else {
									if let data = data {
										annotation.setFirstImage(image: UIImage(data: data))
										self.mapView.map.view(for: annotation)?.leftCalloutAccessoryView = self.getImageViewForAnnotation(image: annotation.firstImage)
									}
								}
							}
							
							print("closure annotions count: \(self.allAnnotations.count)")
							print("closure annotations on map count: \(self.mapView.map.annotations.count)")
						} else {
							if !self.errorOccurredOnce {
								Alerts.showNoOptionAlert(title: "Minor Error Occurred", message: "We were unable to load some results. Please check your internet connection, restart the app, and try again", sender: self)
								self.errorOccurredOnce = true
							}
						}
					}
				} else {
					if !self.errorOccurredOnce {
						Alerts.showNoOptionAlert(title: "Minor Error Occurred", message: "We were unable to load some results. Please check your internet connection, restart the app, and try again", sender: self)
						self.errorOccurredOnce = true
					}
					
				}
			})
			
			let queryHandleExited = regionQuery.observe(.documentExited, with: { (docID, location) in
				print("document exited")
			})
			
			let queryHandleAllReady = regionQuery.observeReady {
				print("all results loaded")
				print("closure annotions count: \(self.allAnnotations.count)")
				print("closure annotations on map count: \(self.mapView.map.annotations.count)")
				self.updateVisibleAnnotations()
				regionQuery.removeAllObservers()
			}
			
		} else {
			print("invalid region")
		}
    }
	
	func getImageViewForAnnotation(image: UIImage?) -> UIImageView {
		let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 55, height: 43))
		if let image = image {
			imageView.image = image
		} else {
			if #available(iOS 13.0, *) {
				imageView.image = K.Images.getPlaceholderImage()
			} else {
				imageView.image = UIImage(named: K.ImageNames.photoPlaceholder)
			}
		}
		imageView.contentMode = .scaleAspectFill
		imageView.tintColor = K.Colors.goldenThemeColorInverse
		imageView.layer.masksToBounds = true
		imageView.layer.cornerRadius = 5
		return imageView
	}
	
	
	func updateVisibleAnnotations() {
		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: loadingView)
		print("update visible annotations")
		let newVisibleAnnotations = Array(self.mapView.map.annotations(in: self.mapView.map.visibleMapRect)) as? [MKAnnotation]
		if let newVisibleAnnotations = newVisibleAnnotations {
			
			var newVisibleBusinessAnnotations: [BusinessAnnotation] = []
			for i in 0..<newVisibleAnnotations.count {
				if newVisibleAnnotations[i] is BusinessAnnotation {
					newVisibleBusinessAnnotations.append(newVisibleAnnotations[i] as! BusinessAnnotation)
				}
			}
			if newVisibleBusinessAnnotations.isEmpty {
				print("visible annotations is empty")
				if !displayedNoResultsAlert {
					Alerts.showNoOptionAlert(title: "No results found", message: "No results were found in your area. Try zooming out on the map and/or changing your filter settings.", sender: self)
					displayedNoResultsAlert = true
				}
			} else {
				displayedNoResultsAlert = false
				
				for annotation in newVisibleBusinessAnnotations {
					if annotation.images.count <= 1 {
						
						let placeholderImage = K.Images.getPlaceholderImage()
						let errorImage = K.Images.getErrorImage()
						var images: [UIImage?] = [placeholderImage, placeholderImage, placeholderImage, placeholderImage, placeholderImage]
						let imagesFolderRef = Storage.storage().reference().child("\(K.Firebase.Storage.placesImagesFolder)/\(annotation.docID)")
						
						imagesFolderRef.listAll { (result, error) in
							if let error = error {
								images = [errorImage, errorImage, errorImage, errorImage, errorImage]
								Alerts.showNoOptionAlert(title: "Error", message: "We were unable to load some images", sender: self)
							} else {
								images = []
								for _ in 0..<result.items.count {
									images.append(placeholderImage)
								}
								
								for i in 0..<result.items.count {
									
									let item = result.items[i]
									item.getData(maxSize: 5 * 1024 * 1024) { (data, error) in
										if let error = error {
											// idk what else to do
											images[i] = errorImage
										} else {
											
											if let data = data {
												images[i] = UIImage(data: data)
											} else {
												// idk what else to do
												images[i] = errorImage
											}
											
										}
										var numImages = 0
										for image in images {
											if image != placeholderImage {
												numImages += 1
											}
										}
										if numImages >= result.items.count {
											annotation.images = images
											annotation.allImagesLoaded = true
											self.listView.tableView.reloadData()
										}
										
									}
									
								}
							}
						}
						
					}
				}
				
			}
			
			visibleAnnotations = Helpers.sortAnnotations(annotations: newVisibleBusinessAnnotations, sortingMethod: sortingMethod)
			listView.tableView.reloadData()
			navigationItem.leftBarButtonItem = UIBarButtonItem(customView: switchViewButton!)
			for annotation in allAnnotations {
				if !visibleAnnotations.contains(annotation) {
					annotation.images = [annotation.firstImage]
					annotation.allImagesLoaded = false
				}
			}
		}
	}
	
	
	func fadeInSearchInstructions() {
		print("fade in")
		UIView.animate(withDuration: 0.3) {
			self.mapView.searchInstructionView.alpha = 1
			self.listView.searchInstructionView.alpha = 1
		}
	}
	func fadeOutSearchInstructions() {
		print("fade out")
		UIView.animate(withDuration: 0.3) {
			self.mapView.searchInstructionView.alpha = 0
			self.listView.searchInstructionView.alpha = 0
		}
	}
	
	
	@objc func openBusinessPage() {
		print("docID: \(selectedAnnotation!.docID)")
		performSegue(withIdentifier: K.Segues.exploreToBusinessPage, sender: self)
	}
	
	
	
	override func didReceiveMemoryWarning() {
		for annotation in visibleAnnotations {
			annotation.images = [annotation.firstImage]
			annotation.allImagesLoaded = false
		}
	}
	
}




extension ExploreViewController: SideMenuNavigationControllerDelegate {
	
	func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
		print("SideMenu Appearing! (animated: \(animated))")
		if resultSearchController?.isActive ?? false {
			fadeOutSearchInstructions()
		}
	}
	
	func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
		print("SideMenu Appeared! (animated: \(animated))")
	}
	
	func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
		print("SideMenu Disappearing! (animated: \(animated))")
		if resultSearchController?.isActive ?? false {
			fadeInSearchInstructions()
		}
	}
	
	func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
		print("SideMenu Disappeared! (animated: \(animated))")
		updateVisibleAnnotations()
		(resultSearchController?.searchResultsController as? LocationSearchTable)?.updateSearchResults(for: resultSearchController!)
	}
}


extension ExploreViewController: UISearchBarDelegate {
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		fadeInSearchInstructions()
		return true
	}
	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		fadeOutSearchInstructions()
		return true
	}
}
