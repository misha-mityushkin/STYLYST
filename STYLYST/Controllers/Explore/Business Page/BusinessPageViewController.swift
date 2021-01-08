//
//  BusinessPageViewController.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-07-13.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import ImageSlideshow
import StretchScrollView
import Firebase

class BusinessPageViewController: UIViewController {
	
	@IBOutlet weak var scrollView: StretchScrollView!
	@IBOutlet weak var slideshowView: ImageSlideshow!
	@IBOutlet weak var businessNameLabel: UILabel!
	@IBOutlet weak var businessTypeImage: UIImageView!
	@IBOutlet weak var businessTypeLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	
	@IBOutlet weak var todayHoursLabel: UILabel!
	@IBOutlet weak var showHideWeeklyHoursButton: UIButton!
	@IBOutlet weak var weeklyHoursStackView: UIStackView!
	@IBOutlet weak var weeklyHoursHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var mondayLabel: UILabel!
	@IBOutlet weak var tuesdayLabel: UILabel!
	@IBOutlet weak var wednesdayLabel: UILabel!
	@IBOutlet weak var thursdayLabel: UILabel!
	@IBOutlet weak var fridayLabel: UILabel!
	@IBOutlet weak var saturdayLabel: UILabel!
	@IBOutlet weak var sundayLabel: UILabel!
	
	@IBOutlet weak var mondayHoursLabel: UILabel!
	@IBOutlet weak var tuesdayHoursLabel: UILabel!
	@IBOutlet weak var wednesdayHoursLabel: UILabel!
	@IBOutlet weak var thursdayHoursLabel: UILabel!
	@IBOutlet weak var fridayHoursLabel: UILabel!
	@IBOutlet weak var saturdayHoursLabel: UILabel!
	@IBOutlet weak var sundayHoursLabel: UILabel!
	
	@IBOutlet weak var introParagraphLabel: UILabel!
	
	@IBOutlet weak var servicesTableView: UITableView!
	@IBOutlet weak var servicesTableViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var viewAllServicesButton: UIButton!
	
	var exploreVC: ExploreViewController?
	var searchTable: LocationSearchTable?
	var isFromSearch = false
	
	var businessLocation: BusinessLocation?
	var user: User?

	let spinnerView = LoadingView()
	
	let loadingView = UIActivityIndicatorView(style: .white)
	
	var shouldCollapse = false
	
	var allImagesLoaded = false
	
	var isFavorite = false {
		didSet {
			if self.isFavorite {
				if #available(iOS 13.0, *) {
					self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: K.ImageNames.heartFill)
				} else {
					self.navigationItem.rightBarButtonItem?.image = UIImage(named: K.ImageNames.heartFill)
				}
			} else {
				if #available(iOS 13.0, *) {
					self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: K.ImageNames.heart)
				} else {
					self.navigationItem.rightBarButtonItem?.image = UIImage(named: K.ImageNames.heart)
				}
			}
		}
	}
	
	var scrolledPastTitle = false {
		didSet {
			if self.scrolledPastTitle {
				self.setUpGradientNavBar(colors: K.Collections.navBarGradientColorsScrolled)
				self.navigationItem.title = self.businessLocation?.name
			} else {
				self.setUpGradientNavBar(colors: K.Collections.navBarGradientColors)
			}
		}
	}
	
	var weeklyHoursIsExpanded: Bool = true {
		didSet {
			weeklyHoursIsExpanding = true
			UIView.animate(withDuration: 0.5) {
				if self.weeklyHoursIsExpanded {
					self.showHideWeeklyHoursButton.transform = CGAffineTransform.identity
				} else {
					self.showHideWeeklyHoursButton.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
				}
			} completion: { (success) in
				self.weeklyHoursIsExpanding = false
			}
		}
	}
	var weeklyHoursIsExpanding = false
	
	var dayOfTheWeekLabels: [UILabel] = []
	var weeklyHourLabels: [UILabel] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		scrollView.delegate = self
		if let firstImage = exploreVC?.selectedAnnotation?.firstImage {
			slideshowView.setImageInputs([ImageSource(image: firstImage)])
		}
		slideshowView.contentScaleMode = .scaleAspectFill
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openImagesFullScreen))
		slideshowView.addGestureRecognizer(gestureRecognizer)
		dayOfTheWeekLabels = [mondayLabel, tuesdayLabel, wednesdayLabel, thursdayLabel, fridayLabel, saturdayLabel, sundayLabel]
		weeklyHourLabels = [mondayHoursLabel, tuesdayHoursLabel, wednesdayHoursLabel, thursdayHoursLabel, fridayHoursLabel, saturdayHoursLabel, sundayHoursLabel]
		servicesTableView.register(UINib(nibName: K.Nibs.servicesCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.servicesCellIdentifier)
		viewAllServicesButton.setTitleColor(.gray, for: .disabled)
		
		loadingView.color = K.Colors.goldenThemeColorLight
		loadingView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
		
		loadBusiness()
		
		if isFromSearch {
			user = searchTable?.exploreVC?.user
		} else {
			user = exploreVC?.user
		}
		if user?.favoritePlaces.contains(businessLocation?.docID ?? "") ?? false {
			isFavorite = true
		}
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationItem.rightBarButtonItem?.tintColor = K.Colors.goldenThemeColorLight
		navigationItem.leftBarButtonItem?.tintColor = K.Colors.goldenThemeColorLight
		// so that the nav bar gets set up properly
		scrolledPastTitle = !(!scrolledPastTitle)
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		navigationItem.rightBarButtonItem?.tintColor = K.Colors.goldenThemeColorLight
		navigationItem.leftBarButtonItem?.tintColor = K.Colors.goldenThemeColorLight
	}
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	@objc func openImagesFullScreen() {
		slideshowView.presentFullScreenController(from: self)
	}
	
	func setSlideShowImageInputs(images: [UIImage?]) {
		var imageInputs: [InputSource] = []
		for image in images {
			if let image = image {
				imageInputs.append(ImageSource(image: image))
			}
		}
		self.slideshowView.setImageInputs(imageInputs)
	}
	
	func fetchAnnotation() -> BusinessAnnotation? {
		if isFromSearch {
			return searchTable?.selectedItem
		} else {
			return exploreVC?.selectedAnnotation
		}
	}
	
	func loadBusiness() {

		if let annotation = fetchAnnotation() {
			let data = annotation.data
			let images = annotation.images
			let type = annotation.type
			
			businessLocation = BusinessLocation(docID: annotation.docID, data: data, images: images, placeholderImage: K.Images.getPlaceholderImage())
			
			businessNameLabel.text = businessLocation?.name
			addressLabel.text = businessLocation?.addressFormatted
			
			let dayOfTheWeekCapitalized = Date().dayOfWeekCapitalized()
			let dayOfTheWeekIdentifier = Date().dayOfWeek()
			
			let todayDateString = Date().dateStringWith(strFormat: K.Strings.dateFormatString)
			if let specificHoursToday = businessLocation?.specificHours?[todayDateString] {
				todayHoursLabel.text = "Today: \(specificHoursToday.formattedStartEndTime())"
			} else {
				let weeklyHoursToday = businessLocation?.weeklyHours?[dayOfTheWeekIdentifier ?? ""]
				if weeklyHoursToday == "closed" {
					todayHoursLabel.text = "Today: Closed"
				} else {
					todayHoursLabel.text = "Today: \(businessLocation?.weeklyHours?[dayOfTheWeekIdentifier ?? ""]?.formattedStartEndTime() ?? "Unavailable")"
				}
			}
			
			for i in 0..<weeklyHourLabels.count {
				
				if dayOfTheWeekCapitalized == dayOfTheWeekLabels[i].text {
					dayOfTheWeekLabels[i].font = UIFont(name: K.FontNames.glacialIndifferenceBold, size: 20)
					weeklyHourLabels[i].font = UIFont(name: K.FontNames.glacialIndifferenceBold, size: 20)
				}
				
				let hoursText = businessLocation?.weeklyHours?[K.Collections.daysOfTheWeekIdentifiers[i]]
				if hoursText == nil {
					weeklyHourLabels[i].text = "Unavailable"
				} else if hoursText == "closed" {
					weeklyHourLabels[i].text = "Closed"
				} else {
					weeklyHourLabels[i].text = hoursText?.formattedStartEndTime()
				}
				
			}
			
			introParagraphLabel.text = businessLocation?.introParagraph
			for i in 0..<K.Collections.businessTypeEnums.count {
				if K.Collections.businessTypeEnums[i] == type {
					businessTypeImage.image = UIImage(named: K.Collections.businessTypeMapPinImageNames[i])
					businessTypeLabel.text = K.Collections.businessTypeDisplayNames[i]
				}
			}
			if annotation.distanceToUsersCurrentLocation < 0 {
				distanceLabel.text = "?km"
			} else {
				distanceLabel.text = "\((annotation.distanceToUsersCurrentLocation / 1000).rounded(toPlaces: 1))km"
			}
			
			setSlideShowImageInputs(images: images)
			
			allImagesLoaded = annotation.allImagesLoaded
			
			if !annotation.allImagesLoaded {
				
//				Alerts.showNoOptionAlert(title: "Loading Images", message: "Please give us a second to finish loading all the images. The loading indicator in the top right will disappear once they are finished loading.", sender: self)
				
				loadingView.startAnimating()
				navigationItem.rightBarButtonItems?.append(UIBarButtonItem(customView: loadingView))
				
				let loadingImage = K.Images.loadingImage
				let errorImage = K.Images.getErrorImage()
				var images: [UIImage?] = [annotation.firstImage ?? loadingImage, loadingImage, loadingImage, loadingImage, loadingImage]
				setSlideShowImageInputs(images: images)
				
				
				let checkAllImagesLoadedTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { (timer) in
					if !self.allImagesLoaded {
						if let annotation = self.fetchAnnotation() {
							if annotation.allImagesLoaded {
								self.setSlideShowImageInputs(images: annotation.images)
								self.loadingView.stopAnimating()
								if self.navigationItem.rightBarButtonItems?.count ?? 0 > 1 {
									self.navigationItem.rightBarButtonItems?.remove(at: 1)
								}
								timer.invalidate()
							}
						}
					}
				}
				
				
				if annotation.firstImage == nil {
					spinnerView.create(parentVC: self)
					Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { (timer) in
						if let firstImage = self.fetchAnnotation()?.firstImage {
							images[0] = firstImage
							self.setSlideShowImageInputs(images: images)
							self.spinnerView.remove()
							timer.invalidate()
						}
					}
				}
				
								
				let imagesFolderRef = Storage.storage().reference().child("\(K.Firebase.Storage.placesImagesFolder)/\(annotation.docID)")
				
				imagesFolderRef.listAll { (result, error) in
					if let error = error {
						images = [errorImage, errorImage, errorImage, errorImage, errorImage]
					} else {
						images = []
						for i in 0..<result.items.count {
							if i == 0 {
								images.append(annotation.firstImage ?? loadingImage)
							} else {
								images.append(loadingImage)
							}
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
										self.setSlideShowImageInputs(images: images)
									} else {
										// idk what else to do
										images[i] = errorImage
									}
									
								}
								
								
								
								var numImages = 0
								for image in images {
									if image != loadingImage {
										numImages += 1
									}
								}
								if numImages >= result.items.count {
									annotation.images = images
									annotation.allImagesLoaded = true
									self.allImagesLoaded = true
									checkAllImagesLoadedTimer.invalidate()
									
									self.setSlideShowImageInputs(images: annotation.images)
									self.loadingView.stopAnimating()
									if self.navigationItem.rightBarButtonItems?.count ?? 0 > 1 {
										self.navigationItem.rightBarButtonItems?.remove(at: 1)
									}
									//self.spinnerView.remove()
								}
								
							}
							
						}
					}
				}
				
			}
			
		} else {
			Alerts.showNoOptionAlert(title: "An error occurred", message: "We were unable to load this page. Please restart the app and try again", sender: self) { (_) in
				self.dismiss(animated: true, completion: nil)
			}
		}
	}
	
	@IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
		
		if let user = user {
			
			guard let businessID = businessLocation?.docID else {
				Alerts.showNoOptionAlert(title: "An Error Occurred", message: "Please check your internet connection, restart the app, and try again.", sender: self)
				return
			}
			let db = Firestore.firestore()
			spinnerView.create(parentVC: self)
			
			let isFavoriteNew = !self.isFavorite
			
			var favoritePlaces = user.favoritePlaces
			
			if isFavoriteNew { // if the user wants to add to favorites
				spinnerView.label.text = "Adding to favorites..."
				favoritePlaces.append(businessID)
			} else { // if the user wants to remove from favorites
				spinnerView.label.text = "Removing from favorites..."
				for i in 0..<favoritePlaces.count {
					if favoritePlaces[i] == businessID {
						favoritePlaces.remove(at: i)
						break
					}
				}
			}
			
			db.collection(K.Firebase.CollectionNames.users).document(user.userID).updateData([
				K.Firebase.UserFieldNames.favoritePlaces: favoritePlaces
			]) { (error) in
				
				self.spinnerView.remove()
				if let error = error {
					Alerts.showNoOptionAlert(title: "An Error Occurred", message: "Please check your internet connection, restart the app, and try again. Error description: \(error.localizedDescription)", sender: self)
				} else {
					self.isFavorite = isFavoriteNew
					if isFavoriteNew { //added
						Alerts.showNoOptionAlert(title: "Added to Favorites", message: "You can view all your favorites in the For You section.", sender: self)
					} else { //removed
						Alerts.showNoOptionAlert(title: "Removed from Favorites", message: "You can view all your favorites in the For You section.", sender: self)
					}
					
					self.user?.favoritePlaces = favoritePlaces
					if self.isFromSearch {
						self.searchTable?.exploreVC?.user?.favoritePlaces = favoritePlaces
					} else {
						self.exploreVC?.user?.favoritePlaces = favoritePlaces
					}
				}
				
			}
			
		} else {
			Alerts.showNoOptionAlert(title: "Not Signed In", message: "You must be signed in to your Stylyst account to add to your favorites", sender: self)
		}
		
	}
	
	@IBAction func viewMapPressed(_ sender: UIButton) {
		performSegue(withIdentifier: K.Segues.businessPageToShowLocation, sender: self)
	}
	
	@IBAction func showHideWeeklyHoursPressed(_ sender: UIButton) {
		if weeklyHoursIsExpanding {
			return
		}
		
		weeklyHoursIsExpanded = !weeklyHoursIsExpanded
		if shouldCollapse {
			animateView(isCollapse: false, heighConstraint: 0)
		} else {
			animateView(isCollapse: true, heighConstraint: 200)
		}
	}
	
	func animateView(isCollapse: Bool, heighConstraint: Double) {
		shouldCollapse = isCollapse
		weeklyHoursHeightConstraint.constant = CGFloat(heighConstraint)
		UIView.animate(withDuration: 0.5) {
			self.view.layoutIfNeeded()
		}
	}
	
	@IBAction func viewAllServicesButtonPressed(_ sender: UIButton) {
		performSegue(withIdentifier: K.Segues.businessPageToViewAllServices, sender: self)
	}
	
	@IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is ViewMapViewController {
			let showMapVC = segue.destination as! ViewMapViewController
			showMapVC.businessPageVC = self
		} else if segue.destination is ServicesTableViewController {
			let servicesVC = segue.destination as! ServicesTableViewController
			servicesVC.businessPageVC = self
		}
	}
	
}


extension BusinessPageViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var numRows = 0;
		if businessLocation?.services.count ?? 0 > 3 {
			numRows = 3
		} else if businessLocation?.services.count ?? 0 == 0 {
			numRows = 1
		} else {
			numRows = businessLocation?.services.count ?? 0
		}
		servicesTableViewHeightConstraint.constant = CGFloat(numRows) * 65
		print("number of service rows: \(numRows)")
		return numRows
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		print("cellforrowat")
		let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.servicesCellIdentifier, for: indexPath) as! ServicesTableViewCell
		
		let services = businessLocation?.services
		if let services = services, services.count > 0 {
			if let name = services[indexPath.row][K.Firebase.PlacesFieldNames.Services.name] as? String, let price = services[indexPath.row][K.Firebase.PlacesFieldNames.Services.defaultPrice] as? Double, let time = services[indexPath.row][K.Firebase.PlacesFieldNames.Services.defaultTime] as? String {
				cell.serviceNameLabel.text = name
				cell.servicePriceLabel.text = String(format: "$%.02f", price)
				cell.serviceTimeLabel.text = time
			} else {
				cell.serviceNameLabel.text = "Error loading service"
				cell.servicePriceLabel.text = ""
				cell.serviceTimeLabel.text = ""
			}
		} else {
			cell.serviceNameLabel.text = "No Services Found"
			cell.servicePriceLabel.text = ""
			cell.serviceTimeLabel.text = ""
			viewAllServicesButton.isEnabled = false
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
}



extension BusinessPageViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		print("didscroll")
		(scrollView as? StretchScrollView)?.scrollViewDidScroll(scrollView)
		if scrollView.contentOffset.y >= businessNameLabel.frame.minY {
			if !scrolledPastTitle {
				scrolledPastTitle = true
			}
		} else {
			if scrolledPastTitle {
				scrolledPastTitle = false
			}
		}
	}
}
