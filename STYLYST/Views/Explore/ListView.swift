//
//  ListView.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-23.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import ImageSlideshow

class ListView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var searchInstructionView: UIView!
	
    var exploreVC: ExploreViewController?
	
	let spinnerView = LoadingView()
	
	var noDataLabel: UILabel?
	
	var slideshowHeight: CGFloat = 0
	var cellHeight: CGFloat = 0
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		slideshowHeight = (UIScreen.main.bounds.width - 50) * 0.66
		cellHeight = 250 + slideshowHeight
		//tableView.rowHeight = cellHeight
		
		noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
		noDataLabel?.numberOfLines = 0
		noDataLabel!.text = "No results found.\nAdjust your filter settings and visible map region and try again."
		noDataLabel!.textColor = K.Colors.goldenThemeColorDefault
		noDataLabel!.textAlignment = .center
		noDataLabel!.isHidden = true
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(UINib(nibName: K.Nibs.listViewCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.listViewCell)
	}
    
    
    
}


extension ListView: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if exploreVC?.visibleAnnotations.count == 0 {
			noDataLabel?.isHidden = false
			tableView.backgroundView = noDataLabel
			tableView.separatorStyle = .none
		} else {
			tableView.backgroundView = nil
		}
		
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		print("number of rows")
		return exploreVC?.visibleAnnotations.count ?? 0
	}
	
//	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		print("height for row at: \(cellHeight)")
//		return cellHeight
//	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		print("cell for row at")
		let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.listViewCell, for: indexPath) as! ListViewTableViewCell
		let annotation = exploreVC?.visibleAnnotations[indexPath.row]
		if let annotation = annotation {
			cell.businessNameLabel.text = annotation.title
			cell.addressLabel.text = annotation.subtitle
			cell.businessTypeImage.image = Helpers.getBusinessTypeMapPinImage(fromEnum: annotation.type)
			cell.businessTypeLabel.text = Helpers.getBusinessTypeDisplayName(fromEnum: annotation.type)
			
			var imageInputs: [InputSource] = []
			if annotation.firstImage != nil {
				for image in annotation.images {
					if let image = image {
						imageInputs.append(ImageSource(image: image))
					}
				}
			} else {
				imageInputs.append(ImageSource(image: K.Images.loadingImage!))
			}
			
			if annotation.distanceToUsersCurrentLocation < 0 {
				cell.distanceLabel.text = "?km"
			} else {
				cell.distanceLabel.text = "\((annotation.distanceToUsersCurrentLocation / 1000).rounded(toPlaces: 1))km"
			}
			cell.slideshowView.setImageInputs(imageInputs)
			cell.exploreVC = exploreVC
			cell.cellIndex = indexPath.row
			
			cell.slideshowHeightConstraint.constant = slideshowHeight
			cellHeight = 60 + cell.slideshowHeightConstraint.constant + cell.businessNameLabel.frame.height + cell.addressLabel.frame.height + cell.businessTypeImage.frame.height + cell.nextAvailableApptLabel.frame.height
			print("\(cell.businessNameLabel.text) cellHeight: \(cellHeight)")
		}
		
		return cell
	}
	
	@objc func tapped() {
		print("tapped")
	}
	
	
}


extension ListView: UITableViewDelegate {
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		if searchInstructionView.alpha > 0 {
			exploreVC?.fadeOutSearchInstructions()
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("did selct row")
		exploreVC?.selectedAnnotation = exploreVC?.visibleAnnotations[indexPath.row]
		exploreVC?.performSegue(withIdentifier: K.Segues.exploreToBusinessPage, sender: exploreVC)
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
