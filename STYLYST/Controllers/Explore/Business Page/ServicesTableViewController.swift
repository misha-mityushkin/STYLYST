//
//  AddServicesTableViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-07-22.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class ServicesTableViewController: UITableViewController {
	
	var businessPageVC: BusinessPageViewController?
	
	var titleStr = "Menu"
	
	var services: [[String : Any]]?
	
	var selectedCellIndex: Int?
	
	var noDataLabel: UILabel?
	
	let navBarColors = [K.Colors.transparentBlackHeavy?.cgColor ?? UIColor.black.cgColor, K.Colors.transparentBlackMedium?.cgColor ?? UIColor.clear.cgColor, UIColor.clear.cgColor]

    override func viewDidLoad() {
        super.viewDidLoad()
		services = businessPageVC?.businessLocation?.services
		noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
		noDataLabel?.numberOfLines = 0
		noDataLabel!.text = "No services found."
		noDataLabel!.textColor = K.Colors.goldenThemeColorDefault
		noDataLabel!.textAlignment = .center
		noDataLabel!.isHidden = true
		tableView.backgroundView = UIImageView(image: UIImage(named: K.ImageNames.backgroundNoLogo))
		tableView.register(UINib(nibName: K.Nibs.servicesHeaderCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.servicesHeaderCellIdentifier)
		tableView.register(UINib(nibName: K.Nibs.servicesCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.servicesCellIdentifier)
    }
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//		navigationController?.navigationBar.tintColor = K.Colors.goldenThemeColorLight
//		UIView.animate(withDuration: 0.5) {
//			self.navigationItem.leftBarButtonItem?.tintColor = K.Colors.goldenThemeColorLight?.withAlphaComponent(1)
//			self.navigationController?.makeTransparent()
//			self.navigationController?.navigationBar.layoutIfNeeded()
//		}
//	}
//	override func viewDidAppear(_ animated: Bool) {
//		super.viewDidAppear(animated)
//		navigationController?.navigationBar.tintColor = K.Colors.goldenThemeColorLight
//		navigationController?.makeTransparent()
//	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.makeTransparent()
		navigationController?.navigationBar.tintColor = K.Colors.goldenThemeColorLight
		//setUpNavBar(colors: businessPageVC!.navBarColorsScrolled)
	}
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//		navigationController?.navigationBar.tintColor = .black
//		UIView.animate(withDuration: 0.5) {
//			self.navigationItem.leftBarButtonItem?.tintColor = .black
//			self.navigationItem.rightBarButtonItem?.tintColor = .black
//			self.navigationController?.returnToOriginalState()
//			let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
//			self.navigationController?.navigationBar.titleTextAttributes = textAttributes
//			self.navigationController?.navigationBar.layoutIfNeeded()
//		}
//	}
	

    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		if services?.count == 0 {
			if let noDataLabel = noDataLabel {
				noDataLabel.isHidden = false
				tableView.backgroundView?.addSubview(noDataLabel)
			}
			tableView.separatorStyle = .none
		} else {
			tableView.separatorStyle = .singleLine
			tableView.backgroundView = UIImageView(image: UIImage(named: K.ImageNames.backgroundNoLogo))
		}
		return 1
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (services?.count ?? 0) + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			
			return tableView.dequeueReusableCell(withIdentifier: K.Identifiers.servicesHeaderCellIdentifier, for: indexPath) as! ServicesHeaderCell
			
		} else {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.servicesCellIdentifier, for: indexPath) as! ServicesTableViewCell
			if let service = services?[indexPath.row - 1] {
				if let name = service[K.Firebase.PlacesFieldNames.Services.name] as? String, let price = service[K.Firebase.PlacesFieldNames.Services.defaultPrice] as? Double, let time = service[K.Firebase.PlacesFieldNames.Services.defaultTime] as? String {
					cell.serviceNameLabel.text = name
					if service[K.Firebase.PlacesFieldNames.Services.enabled] as? Bool ?? true {
						cell.enabledIndicator.tintColor = .systemGreen
					} else {
						cell.enabledIndicator.tintColor = .systemRed
					}
					cell.servicePriceLabel.text = String(format: "$%.02f", price)
					cell.serviceTimeLabel.text = time
				} else {
					cell.serviceNameLabel.text = "Error loading service"
				}
			} else {
				cell.serviceNameLabel.text = "Error loading service"
			}
			return cell
			
		}
    }
	
	//MARK: - Table view delegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		selectedCellIndex = indexPath.row
		//performSegue(withIdentifier: K.Segues.servicesToAddService, sender: self)
	}

    // MARK: - Navigation
	
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		if segue.destination is AddServiceViewController {
//			let addServiceVC = segue.destination as! AddServiceViewController
//			addServiceVC.servicesVC = self
//			if let selectedCellIndex = selectedCellIndex {
//				addServiceVC.isEditService = true
//				addServiceVC.selectedIndex = selectedCellIndex
//			}
//		}
//    }
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.contentOffset.y >= 40 {
			if navigationItem.title != titleStr {
				setUpGradientNavBar(colors: K.Collections.navBarGradientColorsScrolled)
				navigationItem.title = titleStr
			}
		} else {
			if navigationItem.title == titleStr {
				removeGradientNavBar()
				navigationController?.makeTransparent()
				navigationItem.title = nil
			}
		}
	}

	
}

