//
//  EmployeeTableViewCell.swift
//  EmployeeSystem
//
//  Created by Arthur Tristan M. Ramos on 11/6/22.
//

import UIKit

class EmployeeTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var positionLabel: UILabel!
    @IBOutlet var resignedLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
