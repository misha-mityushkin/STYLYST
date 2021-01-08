//
//  LocationSearchResultsTable.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-06-13.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseFirestore

class LocationSearchTable: UITableViewController {
	
	let placesCollectionRef = Firestore.firestore().collection(K.Firebase.CollectionNames.places)
	let imagesRef = Storage.storage().reference().child(K.Firebase.Storage.placesImagesFolder)
	
	var exploreVC: ExploreViewController?
	
	var matchingItems: [BusinessAnnotation] = []
	var visibleItems: [BusinessAnnotation] = []
	var selectedItem: BusinessAnnotation?
	
	let spinnerView = LoadingView()
	
//	var noDataLabel: UILabel?
		
    override func viewDidLoad() {
        super.viewDidLoad()
		
//		noDataLabel = UILabel(frame: CGRect(x: 0, y: -250, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
//		noDataLabel?.numberOfLines = 0
//		noDataLabel!.text = "No results found"
//		noDataLabel!.textColor = K.Colors.goldenThemeColorDefault
//		noDataLabel!.textAlignment = .center
//		noDataLabel!.isHidden = true
		
		tableView.register(UINib(nibName: K.Nibs.searchResultsHeaderCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.searchResultsHeaderCell)
		tableView.register(UINib(nibName: K.Nibs.searchResultsCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.searchResultsCell)
		tableView.keyboardDismissMode = .onDrag
		
    }
    

    // MARK: - Table view data source

//	override func numberOfSections(in tableView: UITableView) -> Int {
//		print("number of sections")
//		if visibleItems.count == 0 {
//			if let noDataLabel = noDataLabel {
//				noDataLabel.isHidden = false
//				tableView.backgroundView?.addSubview(noDataLabel)
//			}
//		} else {
//			tableView.backgroundView = UIImageView(image: UIImage(named: K.ImageNames.backgroundNoLogo))
//		}
//		return 1
//	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		print("number of rows: \(visibleItems.count)")
        return visibleItems.count + 1
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return 60
		} else {
			return 210
		}
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		print("cell for row at: \(indexPath.row)")
		
		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.searchResultsHeaderCell, for: indexPath) as! SearchResultsHeaderTableViewCell
			if visibleItems.count == 1 {
				cell.numberOfResultsFoundLabel.text = "\(visibleItems.count) result found"
			} else {
				cell.numberOfResultsFoundLabel.text = "\(visibleItems.count) results found"
			}
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.searchResultsCell, for: indexPath) as! SearchResultTableViewCell
			let annotation = visibleItems[indexPath.row - 1]
			cell.nameLabel.text = annotation.title
			cell.addressLabel.text = annotation.subtitle
			cell.businessTypeImageView.image = Helpers.getBusinessTypeMapPinImage(fromEnum: annotation.type)
			cell.businessTypeLabel.text = Helpers.getBusinessTypeDisplayName(fromEnum: annotation.type)
			cell.firstImageView.image = annotation.firstImage ?? K.Images.loadingImage
			if annotation.distanceToUsersCurrentLocation < 0 {
				cell.distanceLabel.text = "?km"
			} else {
				cell.distanceLabel.text = "\((annotation.distanceToUsersCurrentLocation / 1000).rounded(toPlaces: 1))km"
			}
			if indexPath.row < visibleItems.count {
				cell.bottomLine.alpha = 0
			} else {
				cell.bottomLine.alpha = 1
			}
			return cell
		}
    }

	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		selectedItem = visibleItems[indexPath.row - 1]
		performSegue(withIdentifier: K.Segues.searchToBusinessPage, sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is UINavigationController {
			let businessPageVC = storyboard!.instantiateViewController(withIdentifier: K.Identifiers.businessPageViewController) as! BusinessPageViewController
			(segue.destination as! UINavigationController).viewControllers = [businessPageVC]
			
			businessPageVC.searchTable = self
			businessPageVC.isFromSearch = true
			
			//businessPageVC.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: exploreVC!.getXButton(target: businessPageVC, action: #selector(businessPageVC.cancelButtonPressed)))
		}
	}
	
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
    

}


extension LocationSearchTable : UISearchResultsUpdating {
	
	
	func updateSearchResults(for searchController: UISearchController) {
		print("update search")
		if let searchText = searchController.searchBar.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
			print("search text: \(searchText)")
			spinnerView.create(parentVC: self)
			spinnerView.centerYConstraint.constant = -100
			placesCollectionRef.whereField(K.Firebase.PlacesFieldNames.keywords, arrayContains: searchText).getDocuments { (snapshot, error) in
				if let error = error {
					self.spinnerView.remove()
					Alerts.showNoOptionAlert(title: "Error", message: "An error occurred when searching for \"\(searchText)\". Error description: \(error.localizedDescription)", sender: self)
				} else {
					print("got docs")
					var newMatchingItems: [BusinessAnnotation] = []
					var newVisibleItems: [BusinessAnnotation] = []
					if let documents = snapshot?.documents {
						for doc in documents {
							print("looping through docs")
							
							var annotationExistsOnMap = false
							var existingAnnotation: BusinessAnnotation?
							for annotation in self.exploreVC?.allAnnotations ?? [] {
								if annotation.docID == doc.documentID {
									annotationExistsOnMap = true
									existingAnnotation = annotation
								}
							}
							
							var businessAnnotation: BusinessAnnotation?
							if annotationExistsOnMap {
								businessAnnotation = existingAnnotation
							} else {
								businessAnnotation = BusinessAnnotation(data: doc.data(), docID: doc.documentID)
								businessAnnotation!.firstImage = K.Images.loadingImage
							}
														
							newMatchingItems.append(businessAnnotation!)
							
							if self.shouldBeVisible(annotation: businessAnnotation!) {
								newVisibleItems.append(businessAnnotation!)
								var keepImage = false
								for item in self.matchingItems {
									print("looping through matching items")
									if item.docID == doc.documentID {
										print("docIDs match")
									}
									if item.docID == doc.documentID && item.firstImage != K.Images.loadingImage {
										print("keep image")
										keepImage = true
										businessAnnotation!.setFirstImage(image: item.firstImage)
										if self.visibleItems.contains(businessAnnotation!) {
											self.tableView.reloadData()
										}
									}
								}
								
								if !keepImage {
									self.imagesRef.child("\(doc.documentID)/image1").getData(maxSize: 5 * 1024 * 1024) { (data, error) in
										if let error = error {
											Alerts.showNoOptionAlert(title: "Error", message: "We were unable to load some images. Error description: \(error.localizedDescription)", sender: self)
										} else if let data = data {
											print("set actual image")
											businessAnnotation!.setFirstImage(image: UIImage(data: data))
											if self.visibleItems.contains(businessAnnotation!) {
												self.tableView.reloadData()
											}
										} else {
											Alerts.showNoOptionAlert(title: "Error", message: "We were unable to load some images", sender: self)
										}
									}
								}
								
							}
							
						}
					}
					self.matchingItems = Helpers.sortAnnotations(annotations: newMatchingItems, sortingMethod: self.exploreVC?.sortingMethod ?? .DistanceFromCurrentLocation)
					self.visibleItems = Helpers.sortAnnotations(annotations: newVisibleItems, sortingMethod: self.exploreVC?.sortingMethod ?? .DistanceFromCurrentLocation)
					self.tableView.reloadData()
					self.spinnerView.remove()
				}
			}
		}
		
	}
	
	
	func shouldBeVisible(annotation: BusinessAnnotation) -> Bool {
		for i in 0..<K.Collections.businessTypeEnums.count {
			if annotation.type == K.Collections.businessTypeEnums[i] && exploreVC?.businessTypeIsEnabled[i] ?? true {
				return true
			}
		}
		return false
	}
	
	func updateVisibleItems() {
		var newVisibleItems: [BusinessAnnotation] = []
		for item in matchingItems {
			for i in 0..<K.Collections.businessTypeEnums.count {
				if item.type == K.Collections.businessTypeEnums[i] && exploreVC?.businessTypeIsEnabled[i] ?? true {
					newVisibleItems.append(item)
					
				}
			}
		}
		
	}
	
}
