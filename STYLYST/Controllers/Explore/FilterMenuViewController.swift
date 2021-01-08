//
//  FilterMenuViewController.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-07-10.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class FilterMenuViewController: UIViewController {
	
	@IBOutlet weak var businessTypesTableView: UITableView!
	@IBOutlet weak var sortingMethodPickerView: UIPickerView!
	@IBOutlet weak var sortingMethodSelectionLabel: UILabel!
	
	
	var exploreVC: ExploreViewController?
	
	var businessTypeIsEnabled: [Bool] = []

    override func viewDidLoad() {
        super.viewDidLoad()

		businessTypesTableView.dataSource = self
		businessTypesTableView.delegate = self
		businessTypesTableView.register(UINib(nibName: K.Nibs.filtersMenuBusinessTypeCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.businessTypeFilterTableViewCellIdentifier)
		
		for _ in 0..<K.Collections.businessTypeDisplayNames.count {
			businessTypeIsEnabled.append(true)
		}
		
		sortingMethodPickerView.dataSource = self
		sortingMethodPickerView.delegate = self
    }
	
	
	
	
	@IBAction func locationInfoButtonPressed(_ sender: UIButton) {
		Alerts.showNoOptionAlert(title: "Location Query Info", message: "All displayed results are based on the visible region of the map. If you would like to search in a particular area, navigate to that area on the map and adjust the zoom to either tighten or expand the search radius.", sender: self)
	}
	
	@IBAction func businessTypeInfoButtonPressed(_ sender: UIButton) {
		Alerts.showNoOptionAlert(title: "Business Type Info", message: "Different business types may offer similar services", sender: self)
	}
	
	@IBAction func sortingMethodInfoButtonPressed(_ sender: UIButton) {
		Alerts.showNoOptionAlert(title: "Sorting Methods Info", message: "The default sorting method is by distance from your current location. Changes here will be reflected in the list view (tap the button to the left of the search bar)", sender: self)
	}
	

}


extension FilterMenuViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return K.Collections.businessTypeDisplayNames.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.businessTypeFilterTableViewCellIdentifier, for: indexPath) as! BusinessTypeFilterTableViewCell
		
		cell.businessTypeLabel.text = K.Collections.businessTypeDisplayNames[indexPath.row]
		cell.mapPinIcon.image = UIImage(named: K.Collections.businessTypeMapPinImageNames[indexPath.row])
		cell.checkmark.isHidden = false
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		businessTypesTableView.deselectRow(at: indexPath, animated: true)
		let cell = businessTypesTableView.cellForRow(at: indexPath) as! BusinessTypeFilterTableViewCell
		cell.checkmark.isHidden = !cell.checkmark.isHidden
		businessTypeIsEnabled[indexPath.row] = !businessTypeIsEnabled[indexPath.row]
		exploreVC?.businessTypeIsEnabled = businessTypeIsEnabled
		exploreVC?.addOrRemoveBusinessType(typeIndex: indexPath.row, isEnabled: businessTypeIsEnabled[indexPath.row])
	}
	
}




extension FilterMenuViewController: UIPickerViewDataSource {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return K.Collections.sortingMethodsDisplayNames.count
	}
	
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		return NSAttributedString(string: K.Collections.sortingMethodsDisplayNames[row], attributes: [NSAttributedString.Key.foregroundColor: K.Colors.goldenThemeColorDefault ?? UIColor.black])
	}
	
}


extension FilterMenuViewController: UIPickerViewDelegate {
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		exploreVC?.sortingMethod = K.Collections.sortingMethodsEnums[row]
		sortingMethodSelectionLabel.text = "Selected: \(K.Collections.sortingMethodsDisplayNames[row])"
	}
}
