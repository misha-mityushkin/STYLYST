//
//  SearchResultsHeaderTableViewCell.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-08-31.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class SearchResultsHeaderTableViewCell: UITableViewCell {
	
	@IBOutlet weak var numberOfResultsFoundLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
