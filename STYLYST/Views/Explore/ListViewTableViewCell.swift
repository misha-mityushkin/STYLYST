//
//  ListViewTableViewCell.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-07-15.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import ImageSlideshow

class ListViewTableViewCell: UITableViewCell {
		
	@IBOutlet weak var slideshowView: ImageSlideshow!
	@IBOutlet weak var businessNameLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var businessTypeImage: UIImageView!
	@IBOutlet weak var businessTypeLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var nextAvailableApptLabel: UILabel!
	
	@IBOutlet weak var slideshowHeightConstraint: NSLayoutConstraint!
	
	var exploreVC: ExploreViewController?
	var cellIndex = 0

    override func awakeFromNib() {
        super.awakeFromNib()
		slideshowView.contentScaleMode = .scaleAspectFill
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
		addGestureRecognizer(tapGesture)
		
		
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	
	@objc func tapped() {
		print("tapped")
		exploreVC?.selectedAnnotation = exploreVC?.visibleAnnotations[cellIndex]
		exploreVC?.performSegue(withIdentifier: K.Segues.exploreToBusinessPage, sender: exploreVC)
	}
    
}
