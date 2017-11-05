//
//  TaskTableViewCell.swift
//  Task
//
//  Created by Pawan on 04/11/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

	@IBOutlet weak var lblTitle: UILabel!
	@IBOutlet weak var innerView: UIView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		innerView.addDropShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
