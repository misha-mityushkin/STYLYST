//
//  ListView.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-23.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class ListViewOLD: UIView {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var exploreVC: ExploreViewController?
    
    @IBAction func mapViewButtonPressed(_ sender: UIButton) {
        exploreVC?.changeView()
    }
    
}
