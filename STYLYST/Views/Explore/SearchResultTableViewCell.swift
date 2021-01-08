//
//  SearchResultTableViewCell.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-07-27.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var firstImageView: UIImageView!
	@IBOutlet weak var businessTypeImageView: UIImageView!
	@IBOutlet weak var businessTypeLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	
	@IBOutlet weak var bottomLine: UIView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }
	

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
}
