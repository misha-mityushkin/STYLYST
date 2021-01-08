//
//  ExploreListViewController.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-20.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var mapVC: MapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.changeSearchBarColor(color: UIColor(named: K.ColorNames.goldenThemeColorDefault) ?? .black, size: CGSize(width: searchBar.frame.size.width, height: 40))
        searchBar.layer.cornerRadius = 15
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        if #available(iOS 13.0, *) {
            searchBar.changeSearchBarColor(color: UIColor(named: K.ColorNames.goldenThemeColorDefault) ?? .black, size: CGSize(width: searchBar.frame.size.width, height: 40))
            
            if UITraitCollection.current.userInterfaceStyle == .dark {
                searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            } else {
                searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            }
            
            //searchBar.searchTextField.rightView = nil
        } else {
            // Fallback on earlier versions
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
    
    
    @IBAction func mapViewButtonPressed(_ sender: UIButton) {
        tabBarController?.selectedIndex = 0
        dismiss(animated: true, completion: nil)
        //performSegue(withIdentifier: K.Segues.listToMapSegue, sender: self)
        //navigationController?.popToViewController(mapVC!, animated: true)
    }
    

}
