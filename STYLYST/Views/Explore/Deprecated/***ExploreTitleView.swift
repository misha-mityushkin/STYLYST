//
//  ExploreTitleView.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-06-13.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class ExploreTitleView: UIView {

    @IBOutlet weak var switchViewButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var listViewImage, mapViewImage: UIImage?
    var inMapView = true
    
    var exploreVC: ExploreViewController?
    
    
    
    override func awakeFromNib() {
        if #available(iOS 13.0, *) {
            listViewImage = UIImage(systemName: K.ImageNames.listView)
            mapViewImage = UIImage(systemName: K.ImageNames.mapView)
        } else {
            listViewImage = UIImage(named: K.ImageNames.listView)
            mapViewImage = UIImage(named: K.ImageNames.mapView)
        }
        
        searchBar.format(height: 40)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        searchBar.format(height: 40)
    }
    
    
    @IBAction func switchViewButtonPressed(_ sender: UIButton) {
        exploreVC?.changeView()
        if inMapView { // the current icon is listView
            switchViewButton.setBackgroundImage(mapViewImage, for: .normal)
        } else { // the current icon is mapView
            switchViewButton.setBackgroundImage(listViewImage, for: .normal)
        }
        inMapView = !inMapView
    }
    
}
