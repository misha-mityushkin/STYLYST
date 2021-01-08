//
//  BusinessTypeFilterTableViewCell.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-07-10.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class BusinessTypeFilterTableViewCell: UITableViewCell {
	
	@IBOutlet weak var mapPinIcon: UIImageView!
	@IBOutlet weak var businessTypeLabel: UILabel!
	@IBOutlet weak var checkmark: UIImageView!
	

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		
    }
    
}
